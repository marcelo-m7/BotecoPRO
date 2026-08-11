from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Mapping


SENSITIVE_KEY = re.compile(
    r"(?i)(authorization|cookie|set-cookie|api[_-]?key|password|passwd|secret|token)"
)
TEXT_SECRET_PATTERNS = (
    re.compile(r"(?i)\b(?:authorization)\s*:\s*(?:bearer\s+)?\S+"),
    re.compile(r"(?i)\b(?:bearer)\s+[A-Za-z0-9._~+/=-]{8,}"),
    re.compile(r"(?i)\b(?:ODOO_ONLINE_API_KEY|API_KEY|ACCESS_TOKEN|REFRESH_TOKEN)\s*[=:]\s*\S+"),
    re.compile(r"(?i)\b(?:cookie|set-cookie)\s*:\s*\S+"),
)
TEXT_SUFFIXES = {".json", ".md", ".txt", ".log", ".xml", ".yaml", ".yml"}


def redact(value: object) -> object:
    if isinstance(value, Mapping):
        return {
            str(key): "[REDACTED]" if SENSITIVE_KEY.search(str(key)) else redact(item)
            for key, item in value.items()
        }
    if isinstance(value, list):
        return [redact(item) for item in value]
    if isinstance(value, tuple):
        return tuple(redact(item) for item in value)
    if isinstance(value, str):
        result = value
        for pattern in TEXT_SECRET_PATTERNS:
            result = pattern.sub("[REDACTED]", result)
        return result
    return value


def redact_command(command: Iterable[str]) -> list[str]:
    values = list(command)
    redacted: list[str] = []
    hide_next = False
    for value in values:
        if hide_next:
            redacted.append("[REDACTED]")
            hide_next = False
            continue
        if SENSITIVE_KEY.search(value):
            if "=" in value:
                redacted.append(f"{value.split('=', 1)[0]}=[REDACTED]")
            else:
                redacted.append(value)
                hide_next = True
            continue
        redacted.append(value)
    return redacted


@dataclass(frozen=True)
class PrivacyFinding:
    path: str
    line: int
    pattern: str


def audit_text(text: str, path: str = "<memory>") -> list[PrivacyFinding]:
    findings: list[PrivacyFinding] = []
    for number, line in enumerate(text.splitlines(), start=1):
        for pattern in TEXT_SECRET_PATTERNS:
            if pattern.search(line):
                findings.append(PrivacyFinding(path, number, pattern.pattern))
                break
    return findings


def audit_paths(paths: Iterable[Path]) -> list[PrivacyFinding]:
    findings: list[PrivacyFinding] = []
    for path in paths:
        if not path.is_file() or path.suffix.lower() not in TEXT_SUFFIXES:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        findings.extend(audit_text(text, str(path)))
    return findings
