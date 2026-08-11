from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from . import flutter
from .android import acquire_android_target, apk_path
from .config import Settings
from .evidence import (
    audit_run,
    default_run_id,
    environment_data,
    safe_run_directory,
    sha256_file,
    utc_now,
)
from .privacy import redact
from .process import CommandResult, Runner
from .report import generate


SCENARIO = "synthetic-connected-offline-cart"
EXPECTED_SCREENSHOTS = (
    "01-connected-home.png",
    "02-catalog.png",
    "03-category-filter.png",
    "04-search-result.png",
    "05-product-detail.png",
    "06-cart.png",
    "07-table-selected.png",
    "08-offline-catalog.png",
    "09-restored-cart.png",
)


@dataclass(frozen=True)
class IntegrationRunResult:
    directory: Path
    manifest: dict[str, Any]

    @property
    def ok(self) -> bool:
        return self.manifest.get("status") == "passed"


def parse_integration_response(path: Path) -> dict[str, Any]:
    if not path.is_file():
        return {
            "scenario": SCENARIO,
            "status": "failed",
            "failed_step": "driver-response",
            "error_category": "missing_integration_response",
            "steps": [],
        }
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
        result = payload["scenario_result"]
        if not isinstance(result, dict):
            raise TypeError("scenario_result is not an object")
        steps = result.get("steps")
        if not isinstance(steps, list):
            raise TypeError("steps is not an array")
        return dict(result)
    except (OSError, ValueError, KeyError, TypeError) as error:
        return {
            "scenario": SCENARIO,
            "status": "failed",
            "failed_step": "driver-response",
            "error_category": f"invalid_integration_response:{type(error).__name__}",
            "steps": [],
        }


def validate_app_logcat(
    text: str,
    *,
    package: str = "com.example.botecopro",
) -> list[str]:
    lines = text.splitlines()
    findings: list[str] = []
    for index, line in enumerate(lines):
        lowered = line.lower()
        if "a renderflex overflowed" in lowered:
            findings.append("flutter_render_overflow")
        if "unhandled exception" in lowered and (
            "flutter" in lowered or "e/flutter" in lowered
        ):
            findings.append("flutter_unhandled_exception")
        if "fatal exception" in lowered:
            context = "\n".join(lines[index : index + 20]).lower()
            if package.lower() in context:
                findings.append("android_fatal_exception")
        if package.lower() in lowered and "has died" in lowered:
            findings.append("android_process_death")
    return sorted(set(findings))


def register_screenshots(
    attempt_directory: Path,
    scenario_steps: list[dict[str, Any]],
    *,
    run_directory: Path,
    attempt: int,
) -> list[dict[str, Any]]:
    screenshot_directory = attempt_directory / "screenshots"
    by_filename = {
        str(step.get("screenshot")): str(step.get("name"))
        for step in scenario_steps
        if step.get("status") == "passed" and step.get("screenshot")
    }
    registered: list[dict[str, Any]] = []
    for path in sorted(screenshot_directory.glob("*.png")):
        stat = path.stat()
        registered.append(
            {
                "attempt": attempt,
                "step": by_filename.get(path.name, "failure-diagnostic"),
                "filename": str(path.relative_to(run_directory)),
                "sha256": sha256_file(path),
                "captured_at": datetime.fromtimestamp(
                    stat.st_mtime,
                    tz=timezone.utc,
                ).isoformat().replace("+00:00", "Z"),
                "classification": "SYNTHETIC",
                "assertion_status": (
                    "passed" if path.name in by_filename else "diagnostic"
                ),
            }
        )
    return registered


def _write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(value, indent=2, sort_keys=True, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def run(
    settings: Settings,
    runner: Runner,
    *,
    requested_device: str | None,
    avd_name: str | None,
    repeat: int,
    run_id: str | None,
) -> IntegrationRunResult:
    if repeat < 1:
        raise ValueError("--repeat deve ser pelo menos 1.")
    identifier = run_id or default_run_id()
    destination = safe_run_directory(settings, identifier)
    if destination.exists():
        raise RuntimeError(f"Execução já existe: {destination}")
    destination.mkdir(parents=True)

    started_at = utc_now()
    attempts: list[dict[str, Any]] = []
    all_screenshots: list[dict[str, Any]] = []
    command_results: list[CommandResult] = []
    combined_logcat: list[str] = []
    target = None
    metadata: dict[str, str] = {}
    package = str(settings.toolchain["android"]["application_id"])
    overall_status = "failed"
    failed_step: str | None = None
    error_category: str | None = None

    try:
        target = acquire_android_target(
            settings,
            runner,
            requested_device=requested_device,
            avd_name=avd_name,
        )
        adb = target.adb
        device = target.device
        metadata = adb.properties(device.serial)
        flutter.pub_get(runner, settings)

        for attempt_number in range(1, repeat + 1):
            attempt_directory = (
                destination
                if attempt_number == 1
                else destination / "repeats" / f"attempt-{attempt_number:02d}"
            )
            attempt_directory.mkdir(parents=True, exist_ok=True)
            failure_screenshots = attempt_directory / "failure-screenshots"
            adb.logcat(device.serial, clear=True)

            binary = None if attempt_number == 1 else apk_path(settings)
            if binary is not None and not binary.is_file():
                raise RuntimeError(
                    "APK de integração não encontrado para a repetição."
                )
            result = flutter.integration_drive(
                runner,
                settings,
                device=device.serial,
                evidence_directory=attempt_directory,
                failure_screenshot_directory=failure_screenshots,
                application_binary=binary,
            )
            command_results.append(result)
            driver_output = f"{result.stdout}\n{result.stderr}".strip()
            (attempt_directory / "driver-output.txt").write_text(
                str(redact(driver_output)) + "\n",
                encoding="utf-8",
            )
            logcat = adb.logcat(device.serial).stdout
            (attempt_directory / "logcat.txt").write_text(
                logcat,
                encoding="utf-8",
            )
            combined_logcat.append(
                f"===== attempt {attempt_number} =====\n{logcat}"
            )
            logcat_findings = validate_app_logcat(logcat, package=package)
            response = parse_integration_response(
                attempt_directory / "integration-response.json"
            )
            steps = [
                dict(step)
                for step in response.get("steps", [])
                if isinstance(step, dict)
            ]

            if not result.ok:
                failure_path = (
                    attempt_directory / "screenshots" / "failure-adb.png"
                )
                try:
                    adb.screenshot(device.serial, failure_path)
                except RuntimeError:
                    pass

            screenshots = register_screenshots(
                attempt_directory,
                steps,
                run_directory=destination,
                attempt=attempt_number,
            )
            all_screenshots.extend(screenshots)
            expected_present = {
                Path(item["filename"]).name
                for item in screenshots
                if item["assertion_status"] == "passed"
            }
            missing_screenshots = sorted(
                set(EXPECTED_SCREENSHOTS) - expected_present
            )
            attempt_ok = (
                result.ok
                and response.get("status") == "passed"
                and not logcat_findings
                and not missing_screenshots
            )
            attempt_result = {
                "attempt": attempt_number,
                "status": "passed" if attempt_ok else "failed",
                "started_at": response.get("started_at", result.started_at),
                "duration_seconds": result.duration_seconds,
                "exit_code": result.return_code,
                "failed_step": response.get("failed_step"),
                "error_category": response.get("error_category"),
                "logcat_findings": logcat_findings,
                "missing_screenshots": missing_screenshots,
                "steps": steps,
                "odoo_write_count": response.get("odoo_write_count"),
            }
            attempts.append(attempt_result)
            if not attempt_ok:
                failed_step = str(
                    response.get("failed_step") or "android-integration"
                )
                error_category = str(
                    response.get("error_category")
                    or (logcat_findings[0] if logcat_findings else "command_failed")
                )
                break

        overall_status = (
            "passed"
            if len(attempts) == repeat
            and all(attempt["status"] == "passed" for attempt in attempts)
            else "failed"
        )
    except Exception as error:
        failed_step = failed_step or "android-orchestration"
        error_category = error_category or type(error).__name__
        (destination / "orchestration-error.txt").write_text(
            f"{type(error).__name__}: {redact(str(error))}\n",
            encoding="utf-8",
        )
    finally:
        if target:
            try:
                final_logs = target.adb.logcat(target.device.serial).stdout
                combined_logcat.append(f"===== final =====\n{final_logs}")
            except RuntimeError:
                pass
            target.close()

    (destination / "logcat.txt").write_text(
        "\n".join(combined_logcat),
        encoding="utf-8",
    )
    environment = environment_data(settings, runner, metadata)
    _write_json(destination / "environment.json", environment)
    test_results = {
        "scenario": SCENARIO,
        "started_at": started_at,
        "finished_at": utc_now(),
        "status": overall_status,
        "repeat_requested": repeat,
        "repeat_completed": len(attempts),
        "failed_step": failed_step,
        "error_category": error_category,
        "device": metadata,
        "android_api": metadata.get("api"),
        "flutter_commit": environment.get("flutter_framework_revision"),
        "monorepo_commit": environment.get("git_sha"),
        "attempts": attempts,
        "commands": [
            command.to_dict(include_output=False) for command in command_results
        ],
    }
    _write_json(destination / "test-results.json", test_results)
    canonical_steps = attempts[0]["steps"] if attempts else []
    manifest: dict[str, Any] = {
        "run_id": identifier,
        "timestamp": utc_now(),
        "git_sha": environment.get("git_sha"),
        "mobile_gitlink_sha": environment.get("mobile_gitlink_sha"),
        "mobile_worktree_sha": environment.get("mobile_worktree_sha"),
        "flutter_version": environment.get("flutter_version"),
        "dart_version": environment.get("dart_version"),
        "device": metadata,
        "android_api": metadata.get("api"),
        "evidence_classification": "SYNTHETIC",
        "scenario": SCENARIO,
        "test_scenario": SCENARIO,
        "status": overall_status,
        "command_result": "PASSED" if overall_status == "passed" else "FAILED",
        "failed_step": failed_step,
        "error_category": error_category,
        "steps": canonical_steps,
        "attempts": attempts,
        "screenshots": all_screenshots,
        "privacy": {
            "text_audit": "pending",
            "image_review": "not_required",
            "capture_is_not_publication": True,
        },
    }
    _write_json(destination / "manifest.json", manifest)
    findings = audit_run(destination)
    manifest["privacy"]["text_audit"] = "passed" if not findings else "failed"
    manifest["privacy"]["findings"] = [
        {
            "path": finding.path,
            "line": finding.line,
            "pattern": finding.pattern,
        }
        for finding in findings
    ]
    if findings:
        manifest["status"] = "failed"
        manifest["command_result"] = "FAILED_PRIVACY_AUDIT"
        manifest["error_category"] = "privacy_audit"
    _write_json(destination / "manifest.json", manifest)
    generate(destination)
    return IntegrationRunResult(destination, manifest)
