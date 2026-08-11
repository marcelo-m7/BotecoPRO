from __future__ import annotations

import hashlib
import json
import re
import subprocess
import time
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

from . import flutter
from .android import SmokeResult, smoke
from .config import Settings
from .privacy import PrivacyFinding, audit_paths
from .process import Runner


RUN_ID_PATTERN = re.compile(r"^[0-9]{8}T[0-9]{6}Z(?:-[a-z0-9_-]+)?$")


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def default_run_id() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def safe_run_directory(settings: Settings, run_id: str) -> Path:
    if not RUN_ID_PATTERN.fullmatch(run_id):
        raise ValueError("RUN_ID inválido; use YYYYMMDDTHHMMSSZ e sufixo opcional seguro.")
    base = (settings.artifacts / "evidence").resolve()
    destination = (base / run_id).resolve()
    if destination.parent != base:
        raise ValueError("RUN_ID escaparia do diretório de evidências.")
    return destination


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def _git(settings: Settings, *args: str) -> str:
    completed = subprocess.run(
        ["git", *args],
        cwd=settings.root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    return completed.stdout.strip() if completed.returncode == 0 else "unknown"


def _write_json(path: Path, data: Any) -> None:
    path.write_text(json.dumps(data, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")


def environment_data(settings: Settings, runner: Runner, device: dict[str, str]) -> dict[str, Any]:
    version_result = flutter.version(runner, settings)
    output = f"{version_result.stdout}\n{version_result.stderr}" if version_result else ""
    flutter_version, dart_version = flutter.parse_versions(output)
    return {
        "captured_at": utc_now(),
        "git_sha": _git(settings, "rev-parse", "HEAD"),
        "git_branch": _git(settings, "rev-parse", "--abbrev-ref", "HEAD"),
        "mobile_gitlink_sha": (_git(settings, "ls-tree", "HEAD", "apps/mobile").split() + ["unknown"] * 3)[2],
        "mobile_worktree_sha": _git(settings, "-C", str(settings.mobile), "rev-parse", "HEAD"),
        "flutter_version": flutter_version,
        "dart_version": dart_version,
        "expected_java": settings.toolchain["java"],
        "device": device,
        "android_profile": dict(settings.android_profile),
    }


def audit_run(run_directory: Path) -> list[PrivacyFinding]:
    return audit_paths(path for path in run_directory.rglob("*") if path.is_file())


def capture(
    settings: Settings,
    runner: Runner,
    *,
    source: str,
    requested_device: str | None,
    avd_name: str | None,
    run_id: str | None,
    reset_app_data: bool,
) -> tuple[Path, dict[str, Any]]:
    if source not in {"synthetic", "real"}:
        raise ValueError("Fonte deve ser synthetic ou real.")
    if source == "synthetic" and not reset_app_data:
        raise RuntimeError(
            "Evidência sintética determinística exige --reset-app-data. "
            "A opção apaga somente os dados locais do APK de desenvolvimento no dispositivo selecionado."
        )
    identifier = run_id or default_run_id()
    destination = safe_run_directory(settings, identifier)
    if destination.exists():
        raise RuntimeError(f"Execução já existe: {destination}")
    destination.mkdir(parents=True)
    screenshot = destination / "01-launch.png"
    try:
        result = smoke(
            settings,
            runner,
            requested_device=requested_device,
            avd_name=avd_name,
            build=True,
            screenshot=screenshot,
            reset_app_data=reset_app_data,
            artifact_directory=destination,
        )
        environment = environment_data(settings, runner, result.metadata)
        _write_json(destination / "environment.json", environment)
        tests = {
            "scenario": "android-apk-launch-render-and-stability",
            "commands": [command.to_dict(include_output=False) for command in result.commands],
            "status": "passed",
        }
        _write_json(destination / "test-results.json", tests)
        screenshots = [
            {
                "filename": screenshot.name,
                "sha256": result.screenshot_sha256 or sha256_file(screenshot),
                "captured_at": utc_now(),
                "scenario_step": "APK instalado e tela inicial renderizada",
            }
        ]
        manifest: dict[str, Any] = {
            "run_id": identifier,
            "timestamp": utc_now(),
            "git_sha": environment["git_sha"],
            "mobile_gitlink_sha": environment["mobile_gitlink_sha"],
            "mobile_worktree_sha": environment["mobile_worktree_sha"],
            "flutter_version": environment["flutter_version"],
            "dart_version": environment["dart_version"],
            "device": result.metadata,
            "android_api": result.metadata.get("api"),
            "test_scenario": tests["scenario"],
            "evidence_classification": "SYNTHETIC" if source == "synthetic" else "REAL_INSTANCE",
            "screenshots": screenshots,
            "command_result": "CAPTURED",
            "privacy": {
                "text_audit": "pending",
                "image_review": "not_required" if source == "synthetic" else "required_manual_review",
                "capture_is_not_publication": True,
            },
        }
        _write_json(destination / "manifest.json", manifest)
        findings = audit_run(destination)
        manifest["privacy"]["text_audit"] = "passed" if not findings else "failed"
        manifest["privacy"]["findings"] = [asdict(finding) for finding in findings]
        if findings:
            manifest["command_result"] = "FAILED_PRIVACY_AUDIT"
        elif source == "real":
            manifest["command_result"] = "CAPTURED_REVIEW_REQUIRED"
        else:
            manifest["command_result"] = "PASSED"
        _write_json(destination / "manifest.json", manifest)
        from .report import generate

        generate(destination)
        if findings:
            raise RuntimeError(f"Auditoria encontrou {len(findings)} possível(is) segredo(s) em {destination}")
        return destination, manifest
    except Exception:
        failure = {
            "run_id": identifier,
            "timestamp": utc_now(),
            "evidence_classification": "SYNTHETIC" if source == "synthetic" else "REAL_INSTANCE",
            "command_result": "FAILED",
        }
        if not (destination / "manifest.json").exists():
            _write_json(destination / "manifest.json", failure)
        raise
