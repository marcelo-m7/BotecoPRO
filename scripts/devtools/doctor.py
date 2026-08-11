from __future__ import annotations

import os
import platform
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

from . import flutter
from .adb import AdbClient, list_avds
from .config import Settings, android_sdk_root, find_executable
from .process import Runner


@dataclass(frozen=True)
class Check:
    status: str
    name: str
    detail: str
    required_for_build: bool = False
    required_for_emulator: bool = False

    def print(self) -> None:
        print(f"[{self.status:<4}] {self.name:<18} {self.detail}")


def _command_output(command: list[str], cwd: Path) -> str | None:
    try:
        result = subprocess.run(
            command,
            cwd=cwd,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            timeout=15,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    return result.stdout.strip() if result.returncode == 0 else None


def _java_major(output: str) -> str | None:
    match = re.search(r'version\s+"(?:1\.)?(\d+)', output)
    return match.group(1) if match else None


def collect(settings: Settings, runner: Runner) -> list[Check]:
    checks: list[Check] = []
    expected = settings.toolchain

    python_version = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    python_ok = sys.version_info[:2] >= tuple(map(int, str(expected["python_min"]).split(".")))
    checks.append(Check("PASS" if python_ok else "FAIL", "Python", python_version, True))

    git = find_executable("git")
    git_version = _command_output([git, "--version"], settings.root) if git else None
    checks.append(Check("PASS" if git_version else "FAIL", "Git", git_version or "não encontrado", True))

    flutter_path = flutter.flutter_executable()
    flutter_result = flutter.version(runner, settings) if flutter_path else None
    flutter_output = ""
    if flutter_result:
        flutter_output = f"{flutter_result.stdout}\n{flutter_result.stderr}"
    flutter_version, dart_version = flutter.parse_versions(flutter_output)
    expected_flutter = str(expected["flutter"])
    expected_dart = str(expected["dart"])
    if flutter_version:
        suffix = f" ({flutter_path})" if Path(flutter_path).parent not in _path_dirs() else ""
        checks.append(Check("PASS" if flutter_version == expected_flutter else "FAIL", "Flutter", f"{flutter_version}; esperado {expected_flutter}{suffix}", True))
    else:
        checks.append(Check("FAIL", "Flutter", f"não encontrado; esperado {expected_flutter}", True))
    checks.append(Check("PASS" if dart_version == expected_dart else "FAIL", "Dart", f"{dart_version or 'não encontrado'}; esperado {expected_dart}", True))

    java = find_executable("java")
    java_output = _command_output([java, "-version"], settings.root) if java else None
    java_major = _java_major(java_output or "")
    expected_java = str(expected["java"])
    checks.append(Check("PASS" if java_major == expected_java else "FAIL", "Java", f"{java_major or 'não encontrado'}; esperado {expected_java}", True))

    sdk = android_sdk_root()
    checks.append(Check("PASS" if sdk else "FAIL", "Android SDK", str(sdk) if sdk else "ANDROID_SDK_ROOT/ANDROID_HOME ausente", True, True))
    for name in ("adb", "emulator", "sdkmanager"):
        executable = find_executable(name)
        checks.append(Check("PASS" if executable else "FAIL", name, executable or "não encontrado", False, name in {"adb", "emulator"}))

    gradle_properties = settings.mobile / "android" / "gradle" / "wrapper" / "gradle-wrapper.properties"
    gradle_version = str(settings.toolchain["android"]["gradle"])
    gradle_ok = gradle_properties.is_file() and f"gradle-{gradle_version}-" in gradle_properties.read_text(encoding="utf-8")
    checks.append(Check("PASS" if gradle_ok else "FAIL", "Gradle config", f"{gradle_version}; {'metadata válida (launcher gerado pelo Flutter)' if gradle_ok else 'wrapper metadata inválida'}", True))

    adb_path = find_executable("adb")
    devices = AdbClient(adb_path, runner, settings.root).devices() if adb_path else []
    if devices:
        detail = ", ".join(f"{device.serial} ({device.state})" for device in devices)
        checks.append(Check("PASS", "Android devices", detail))
    else:
        checks.append(Check("INFO", "Physical device", "nenhum dispositivo detectado"))

    emulator = find_executable("emulator")
    avds = list_avds(emulator, settings.root) if emulator else []
    checks.append(Check("PASS" if avds else "INFO", "AVDs", ", ".join(avds) if avds else "nenhum AVD disponível", False, True))

    if platform.system() == "Linux":
        kvm = Path("/dev/kvm")
        if not kvm.exists():
            checks.append(Check("FAIL", "KVM", "/dev/kvm indisponível", False, True))
        elif not os.access(kvm, os.R_OK | os.W_OK):
            checks.append(Check("FAIL", "KVM", "/dev/kvm existe, mas o utilizador não tem acesso", False, True))
        else:
            checks.append(Check("PASS", "KVM", "/dev/kvm acessível", False, True))

    root_head = _command_output([git, "rev-parse", "--short=12", "HEAD"], settings.root) if git else None
    mobile_head = _command_output([git, "-C", str(settings.mobile), "rev-parse", "--short=12", "HEAD"], settings.root) if git else None
    status = _command_output([git, "status", "--porcelain=v1"], settings.root) if git else None
    repo_detail = f"root={root_head or '?'} mobile={mobile_head or '?'}; {'limpo' if status == '' else 'alterações locais'}"
    checks.append(Check("PASS", "Repository", repo_detail, True))

    gitlink = _command_output([git, "ls-tree", "HEAD", "apps/mobile"], settings.root) if git else None
    gitlink_sha = gitlink.split()[2] if gitlink and len(gitlink.split()) >= 3 else None
    checks.append(Check("PASS" if gitlink_sha and mobile_head and gitlink_sha.startswith(mobile_head) else "FAIL", "Mobile gitlink", gitlink_sha or "não resolvido", True))

    root_env = settings.root / ".env.local"
    tracked = _command_output([git, "ls-files", ".env.local"], settings.root) if git else None
    checks.append(Check("FAIL" if tracked else "INFO", "Local Odoo env", "presente e não rastreado" if root_env.exists() and not tracked else ("ausente (necessário apenas para smoke real read-only)" if not root_env.exists() else "ERRO: arquivo rastreado")))
    return checks


def _path_dirs() -> set[Path]:
    return {Path(item).resolve() for item in os.environ.get("PATH", "").split(os.pathsep) if item}


def run(settings: Settings, runner: Runner) -> int:
    checks = collect(settings, runner)
    for check in checks:
        check.print()
    build_available = not any(check.status == "FAIL" and check.required_for_build for check in checks)
    emulator_available = build_available and not any(check.status == "FAIL" and check.required_for_emulator for check in checks) and any(check.name == "AVDs" and check.status == "PASS" for check in checks)
    print()
    print(f"Android build: {'AVAILABLE' if build_available else 'UNAVAILABLE'}")
    print(f"Local emulator: {'AVAILABLE' if emulator_available else 'UNAVAILABLE'}")
    if not emulator_available:
        print("Recommended Android runner: dispositivo físico ou GitHub Actions")
    return 0 if build_available else 1
