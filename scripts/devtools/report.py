from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def _read_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"Objeto JSON esperado em {path}")
    return value


def generate(run_directory: Path) -> tuple[Path, Path]:
    manifest = _read_json(run_directory / "manifest.json")
    environment_path = run_directory / "environment.json"
    environment = _read_json(environment_path) if environment_path.exists() else {}
    screenshots = manifest.get("screenshots", [])
    failures = [] if manifest.get("command_result") in {"PASSED", "CAPTURED_REVIEW_REQUIRED"} else [manifest.get("command_result", "unknown")]
    report = {
        "environment": environment,
        "git_state": {
            "git_sha": manifest.get("git_sha"),
            "mobile_gitlink_sha": manifest.get("mobile_gitlink_sha"),
            "mobile_worktree_sha": manifest.get("mobile_worktree_sha"),
        },
        "flutter_validation": {
            "flutter_version": manifest.get("flutter_version"),
            "dart_version": manifest.get("dart_version"),
        },
        "android_validation": manifest.get("device", {}),
        "scenario": manifest.get("test_scenario"),
        "screenshots": screenshots,
        "failures": failures,
        "privacy_classification": manifest.get("evidence_classification"),
        "privacy": manifest.get("privacy", {}),
    }
    json_path = run_directory / "report.json"
    json_path.write_text(json.dumps(report, indent=2, sort_keys=True, ensure_ascii=False) + "\n", encoding="utf-8")
    screenshot_lines = "\n".join(
        f"- `{item.get('filename')}` — `{item.get('sha256')}` — {item.get('scenario_step')}"
        for item in screenshots
    ) or "- Nenhuma captura."
    failure_lines = "\n".join(f"- {failure}" for failure in failures) or "- Nenhuma."
    markdown = f"""# BotecoPRO Android evidence report

Run: `{manifest.get('run_id', run_directory.name)}`<br>
Result: `{manifest.get('command_result', 'unknown')}`<br>
Classification: `{manifest.get('evidence_classification', 'unknown')}`

## Environment

- Git: `{manifest.get('git_sha', 'unknown')}`
- Mobile gitlink: `{manifest.get('mobile_gitlink_sha', 'unknown')}`
- Flutter: `{manifest.get('flutter_version', 'unknown')}`
- Dart: `{manifest.get('dart_version', 'unknown')}`
- Device: `{manifest.get('device', {}).get('model', 'unknown')}` (`{manifest.get('device', {}).get('serial', 'unknown')}`)
- Android API: `{manifest.get('android_api', 'unknown')}`

## Scenario

{manifest.get('test_scenario', 'not recorded')}

## Screenshots

{screenshot_lines}

## Failures

{failure_lines}

## Privacy

- Text audit: `{manifest.get('privacy', {}).get('text_audit', 'not run')}`
- Image review: `{manifest.get('privacy', {}).get('image_review', 'not recorded')}`
- Capture and publication are separate operations: `{manifest.get('privacy', {}).get('capture_is_not_publication', True)}`
"""
    markdown_path = run_directory / "report.md"
    markdown_path.write_text(markdown, encoding="utf-8")
    return markdown_path, json_path
