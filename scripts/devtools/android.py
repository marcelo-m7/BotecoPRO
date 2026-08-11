from __future__ import annotations

import os
import platform
import re
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path

from . import flutter
from .adb import AdbClient, AndroidDevice, list_avds
from .config import Settings, find_executable
from .process import CommandResult, Runner


FATAL_PATTERN = re.compile(r"(?i)(FATAL EXCEPTION|AndroidRuntime.*FATAL|Process: com\.example\.botecopro.*has died)")


@dataclass
class EmulatorProcess:
    process: subprocess.Popen[bytes]
    log_handle: object
    serial: str

    def stop(self, adb: AdbClient) -> None:
        if self.process.poll() is None:
            adb.run(["emu", "kill"], serial=self.serial, stream=False, timeout=30)
            try:
                self.process.wait(timeout=20)
            except subprocess.TimeoutExpired:
                self.process.terminate()
                self.process.wait(timeout=10)
        self.log_handle.close()


@dataclass(frozen=True)
class SmokeResult:
    device: AndroidDevice
    metadata: dict[str, str]
    commands: list[CommandResult]
    logcat: str
    screenshot: Path | None
    screenshot_sha256: str | None


def launch_emulator(
    settings: Settings,
    runner: Runner,
    adb: AdbClient,
    avd_name: str,
    log_path: Path,
) -> EmulatorProcess:
    emulator = find_executable("emulator")
    if not emulator:
        raise RuntimeError("Android emulator não encontrado. Execute make android-doctor.")
    if platform.system() == "Linux" and Path("/dev/kvm").exists() and not os.access(Path("/dev/kvm"), os.R_OK | os.W_OK):
        raise RuntimeError("KVM existe, mas está inacessível. Use dispositivo físico ou GitHub Actions.")
    if platform.system() == "Linux" and not Path("/dev/kvm").exists():
        raise RuntimeError("KVM indisponível. Use dispositivo físico ou GitHub Actions.")
    available = list_avds(emulator, settings.root)
    if avd_name not in available:
        found = ", ".join(available) or "nenhum"
        raise RuntimeError(f"AVD {avd_name!r} não existe. Disponíveis: {found}. Consulte scripts/README.md para criá-lo explicitamente.")

    before = {device.serial for device in adb.devices() if device.is_emulator}
    used_ports = {
        int(serial.split("-", 1)[1])
        for serial in before
        if serial.startswith("emulator-") and serial.split("-", 1)[1].isdigit()
    }
    port = next((candidate for candidate in range(5554, 5586, 2) if candidate not in used_ports), None)
    if port is None:
        raise RuntimeError("Nenhuma porta de emulador livre entre 5554 e 5584.")
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_handle = log_path.open("wb")
    profile = settings.android_profile
    command = [
        emulator,
        "-avd",
        avd_name,
        "-no-snapshot-save",
        "-no-boot-anim",
        "-noaudio",
        "-gpu",
        "swiftshader_indirect",
        "-port",
        str(port),
        "-prop",
        f"persist.sys.locale={profile['locale']}",
        "-prop",
        f"persist.sys.language={profile['language']}",
        "-prop",
        f"persist.sys.country={profile['country']}",
    ]
    print(f"[RUN ] {' '.join(command)}")
    process = subprocess.Popen(command, cwd=settings.root, stdout=log_handle, stderr=subprocess.STDOUT)
    try:
        deadline = time.monotonic() + int(profile["boot_timeout_seconds"])
        serial: str | None = None
        while time.monotonic() < deadline:
            if process.poll() is not None:
                log_handle.flush()
                raise RuntimeError(f"Emulador terminou antes do boot (exit={process.returncode}); veja {log_path}")
            current = [device.serial for device in adb.devices() if device.is_emulator and device.serial not in before]
            if current:
                serial = current[0]
                break
            time.sleep(2)
        if not serial:
            raise RuntimeError("Emulador não apareceu no adb antes do timeout.")
        adb.wait_for_boot(serial, int(profile["boot_timeout_seconds"]))
        configure_emulator(adb, serial, settings)
        return EmulatorProcess(process, log_handle, serial)
    except Exception:
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
        log_handle.close()
        raise


def configure_emulator(adb: AdbClient, serial: str, settings: Settings) -> None:
    profile = settings.android_profile
    commands = [
        ["shell", "settings", "put", "global", "window_animation_scale", "0"],
        ["shell", "settings", "put", "global", "transition_animation_scale", "0"],
        ["shell", "settings", "put", "global", "animator_duration_scale", "0"],
        ["shell", "wm", "size", f"{profile['width']}x{profile['height']}"],
        ["shell", "wm", "density", str(profile["density"])],
        ["shell", "settings", "put", "system", "accelerometer_rotation", "0"],
        ["shell", "settings", "put", "system", "user_rotation", "0"],
    ]
    for command in commands:
        adb.run(command, serial=serial, check=True, stream=False)


def apk_path(settings: Settings) -> Path:
    return settings.mobile / "build" / "app" / "outputs" / "flutter-apk" / "app-debug.apk"


def _running_avd(adb: AdbClient, avd_name: str) -> AndroidDevice | None:
    for device in adb.devices():
        if not device.is_emulator or device.state != "device":
            continue
        result = adb.run(["emu", "avd", "name"], serial=device.serial, stream=False)
        reported = next((line.strip() for line in result.stdout.splitlines() if line.strip() and line.strip() != "OK"), "")
        if result.ok and reported == avd_name:
            return device
    return None


def smoke(
    settings: Settings,
    runner: Runner,
    *,
    requested_device: str | None,
    avd_name: str | None,
    build: bool,
    screenshot: Path | None = None,
    reset_app_data: bool = False,
    uninstall_after: bool = False,
    artifact_directory: Path | None = None,
) -> SmokeResult:
    adb = AdbClient(find_executable("adb"), runner, settings.root)
    emulator_process: EmulatorProcess | None = None
    commands: list[CommandResult] = []
    device: AndroidDevice | None = None
    package = str(settings.toolchain["android"]["application_id"])
    activity = str(settings.toolchain["android"]["main_activity"])
    try:
        if avd_name:
            if requested_device:
                raise RuntimeError("Use apenas um entre --device e --avd.")
            device = _running_avd(adb, avd_name)
            if device:
                print(f"[INFO] Reutilizando AVD {avd_name} em {device.serial}; ele não será encerrado pela ferramenta.")
            else:
                emulator_process = launch_emulator(
                    settings,
                    runner,
                    adb,
                    avd_name,
                    settings.artifacts / "emulator.log",
                )
                device = adb.select(emulator_process.serial)
        else:
            device = adb.select(requested_device)
            adb.wait_for_boot(device.serial, int(settings.android_profile["boot_timeout_seconds"]))
            if device.is_emulator:
                configure_emulator(adb, device.serial, settings)

        if build:
            flutter.pub_get(runner, settings)
            commands.append(flutter.build_apk(runner, settings))
        apk = apk_path(settings)
        if not apk.is_file():
            raise RuntimeError(f"APK não encontrado em {apk}. Execute make android-build.")

        already_installed = adb.package_installed(device.serial, package)
        if reset_app_data and already_installed:
            commands.append(adb.clear_package(device.serial, package))
        commands.append(adb.install(device.serial, apk))
        adb.logcat(device.serial, clear=True)
        commands.append(adb.force_stop(device.serial, package))
        commands.append(adb.launch(device.serial, activity))
        time.sleep(4)
        pid = adb.pid(device.serial, package)
        logs = adb.logcat(device.serial).stdout
        if artifact_directory:
            artifact_directory.mkdir(parents=True, exist_ok=True)
            (artifact_directory / "logcat.txt").write_text(logs, encoding="utf-8")
        if not pid:
            raise RuntimeError("O processo do aplicativo não permaneceu ativo após o lançamento.")
        if FATAL_PATTERN.search(logs):
            raise RuntimeError("Exceção fatal detectada no logcat após o lançamento.")
        digest = adb.screenshot(device.serial, screenshot) if screenshot else None
        integration_tests = sorted((settings.mobile / "integration_test").glob("*_test.dart")) if (settings.mobile / "integration_test").is_dir() else []
        if integration_tests:
            commands.append(
                flutter.test(
                    runner,
                    settings,
                    extra_args=["integration_test", "-d", device.serial],
                )
            )
        else:
            print("[INFO] Nenhum integration_test Flutter disponível; smoke de processo/renderização concluído.")
        result = SmokeResult(device, adb.properties(device.serial), commands, logs, screenshot, digest)
        if uninstall_after:
            commands.append(adb.uninstall(device.serial, package))
        return result
    except Exception:
        if artifact_directory and device:
            artifact_directory.mkdir(parents=True, exist_ok=True)
            failure_logs = adb.logcat(device.serial).stdout
            (artifact_directory / "logcat.txt").write_text(failure_logs, encoding="utf-8")
        raise
    finally:
        if emulator_process:
            emulator_process.stop(adb)
