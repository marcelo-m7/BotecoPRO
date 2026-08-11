from __future__ import annotations

import hashlib
import os
import re
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from .process import CommandResult, Runner


@dataclass(frozen=True)
class AndroidDevice:
    serial: str
    state: str
    details: dict[str, str]

    @property
    def is_emulator(self) -> bool:
        return self.serial.startswith("emulator-")


def parse_devices(output: str) -> list[AndroidDevice]:
    devices: list[AndroidDevice] = []
    for raw_line in output.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("List of devices") or line.startswith("*"):
            continue
        fields = line.split()
        if len(fields) < 2:
            continue
        details = {}
        for field in fields[2:]:
            if ":" in field:
                key, value = field.split(":", 1)
                details[key] = value
        devices.append(AndroidDevice(fields[0], fields[1], details))
    return devices


def list_avds(emulator: str | None, cwd: Path) -> list[str]:
    if not emulator:
        return []
    try:
        completed = subprocess.run(
            [emulator, "-list-avds"],
            cwd=cwd,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            timeout=10,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return []
    if completed.returncode != 0:
        return []
    return [line.strip() for line in completed.stdout.splitlines() if line.strip()]


class AdbClient:
    def __init__(self, executable: str | None, runner: Runner, cwd: Path):
        self.executable = executable
        self.runner = runner
        self.cwd = cwd

    def _base(self, serial: str | None = None) -> list[str]:
        if not self.executable:
            raise RuntimeError("adb não encontrado. Execute make android-doctor.")
        return [self.executable, *( ["-s", serial] if serial else [] )]

    def run(
        self,
        args: Iterable[str],
        *,
        serial: str | None = None,
        check: bool = False,
        stream: bool = True,
        timeout: float | None = 60,
    ) -> CommandResult:
        return self.runner.run(
            [*self._base(serial), *args],
            cwd=self.cwd,
            check=check,
            stream=stream,
            timeout=timeout,
        )

    def devices(self) -> list[AndroidDevice]:
        if not self.executable:
            return []
        result = self.run(["devices", "-l"], stream=False)
        return parse_devices(result.stdout) if result.ok else []

    def select(self, requested: str | None = None) -> AndroidDevice:
        devices = [device for device in self.devices() if device.state == "device"]
        if requested:
            matching = [device for device in devices if device.serial == requested]
            if not matching:
                available = ", ".join(device.serial for device in devices) or "nenhum"
                raise RuntimeError(f"Dispositivo {requested!r} indisponível. Disponíveis: {available}")
            return matching[0]
        if not devices:
            raise RuntimeError("Nenhum dispositivo Android pronto. Conecte um dispositivo ou informe --avd.")
        if len(devices) > 1:
            available = ", ".join(device.serial for device in devices)
            raise RuntimeError(f"Mais de um dispositivo disponível ({available}). Informe --device SERIAL.")
        return devices[0]

    def wait_for_boot(self, serial: str, timeout: int) -> None:
        self.run(["wait-for-device"], serial=serial, check=True, timeout=timeout)
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            boot = self.run(
                ["shell", "getprop", "sys.boot_completed"],
                serial=serial,
                stream=False,
                timeout=10,
            )
            if boot.ok and boot.stdout.strip() == "1":
                return
            time.sleep(2)
        raise RuntimeError(f"Boot Android excedeu {timeout}s para {serial}")

    def properties(self, serial: str) -> dict[str, str]:
        keys = {
            "api": "ro.build.version.sdk",
            "model": "ro.product.model",
            "manufacturer": "ro.product.manufacturer",
            "android_version": "ro.build.version.release",
            "locale": "persist.sys.locale",
        }
        values: dict[str, str] = {"serial": serial}
        for name, prop in keys.items():
            result = self.run(["shell", "getprop", prop], serial=serial, stream=False)
            values[name] = result.stdout.strip() if result.ok else ""
        return values

    def package_installed(self, serial: str, package: str) -> bool:
        result = self.run(["shell", "pm", "path", package], serial=serial, stream=False)
        return result.ok and result.stdout.strip().startswith("package:")

    def clear_package(self, serial: str, package: str) -> CommandResult:
        return self.run(["shell", "pm", "clear", package], serial=serial, check=True)

    def install(self, serial: str, apk: Path) -> CommandResult:
        return self.run(["install", "-r", "-t", str(apk)], serial=serial, check=True, timeout=300)

    def uninstall(self, serial: str, package: str) -> CommandResult:
        return self.run(["uninstall", package], serial=serial, check=True)

    def launch(self, serial: str, activity: str) -> CommandResult:
        return self.run(["shell", "am", "start", "-W", "-n", activity], serial=serial, check=True)

    def force_stop(self, serial: str, package: str) -> CommandResult:
        return self.run(["shell", "am", "force-stop", package], serial=serial, check=True)

    def pid(self, serial: str, package: str) -> str | None:
        result = self.run(["shell", "pidof", package], serial=serial, stream=False)
        return result.stdout.strip() if result.ok and result.stdout.strip() else None

    def logcat(self, serial: str, *, clear: bool = False) -> CommandResult:
        return self.run(["logcat", "-c" if clear else "-d", "-v", "threadtime"], serial=serial, stream=False, timeout=60)

    def screenshot(self, serial: str, destination: Path) -> str:
        destination.parent.mkdir(parents=True, exist_ok=True)
        command = [*self._base(serial), "exec-out", "screencap", "-p"]
        print(f"[RUN ] {' '.join(command)} > {destination}")
        try:
            completed = subprocess.run(
                command,
                cwd=self.cwd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=60,
                check=False,
            )
        except subprocess.TimeoutExpired as error:
            raise RuntimeError("Captura de tela excedeu 60s") from error
        if completed.returncode != 0 or not completed.stdout.startswith(b"\x89PNG\r\n\x1a\n"):
            message = completed.stderr.decode("utf-8", errors="replace").strip()
            raise RuntimeError(f"adb screencap não produziu PNG válido: {message}")
        destination.write_bytes(completed.stdout)
        digest = hashlib.sha256(completed.stdout).hexdigest()
        print(f"[PASS] Screenshot {destination.name} sha256={digest}")
        return digest
