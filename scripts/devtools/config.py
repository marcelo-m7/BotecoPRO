from __future__ import annotations

import json
import os
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping


class ConfigError(RuntimeError):
    pass


def repository_root(start: Path | None = None) -> Path:
    current = (start or Path(__file__)).resolve()
    if current.is_file():
        current = current.parent
    for candidate in (current, *current.parents):
        if (candidate / ".git").exists() and (candidate / "apps" / "mobile").is_dir():
            return candidate
    raise ConfigError(f"Raiz do monorepo não encontrada a partir de {current}")


def _load_json(path: Path) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ConfigError(f"Configuração inválida em {path}: {error}") from error
    if not isinstance(value, dict):
        raise ConfigError(f"Configuração deve ser um objeto JSON: {path}")
    return value


@dataclass(frozen=True)
class Settings:
    root: Path
    toolchain: Mapping[str, Any]
    android_profile: Mapping[str, Any]

    @property
    def mobile(self) -> Path:
        return self.root / "apps" / "mobile"

    @property
    def artifacts(self) -> Path:
        return self.root / ".artifacts"

    @property
    def scripts(self) -> Path:
        return self.root / "scripts"


def load_settings(root: Path | None = None) -> Settings:
    resolved = (root or repository_root()).resolve()
    return Settings(
        root=resolved,
        toolchain=_load_json(resolved / "scripts" / "toolchain.json"),
        android_profile=_load_json(resolved / "scripts" / "profiles" / "android.json"),
    )


def find_executable(name: str, env: Mapping[str, str] | None = None) -> str | None:
    environment = env or os.environ
    direct = shutil.which(name, path=environment.get("PATH"))
    if direct:
        return direct

    candidates: list[Path] = []
    if name in {"flutter", "dart"}:
        flutter_root = environment.get("FLUTTER_ROOT")
        if flutter_root:
            candidates.append(Path(flutter_root) / "bin" / name)
        candidates.extend(
            [
                Path.home() / "flutter" / "bin" / name,
                Path("/opt/flutter/bin") / name,
            ]
        )
    if name in {"adb", "emulator", "sdkmanager"}:
        for variable in ("ANDROID_SDK_ROOT", "ANDROID_HOME"):
            sdk = environment.get(variable)
            if not sdk:
                continue
            base = Path(sdk)
            relative = {
                "adb": Path("platform-tools/adb"),
                "emulator": Path("emulator/emulator"),
                "sdkmanager": Path("cmdline-tools/latest/bin/sdkmanager"),
            }[name]
            candidates.append(base / relative)
    return next((str(path) for path in candidates if path.is_file() and os.access(path, os.X_OK)), None)


def android_sdk_root(env: Mapping[str, str] | None = None) -> Path | None:
    environment = env or os.environ
    for key in ("ANDROID_SDK_ROOT", "ANDROID_HOME"):
        value = environment.get(key)
        if value and Path(value).is_dir():
            return Path(value).resolve()
    adb = find_executable("adb", environment)
    if adb:
        path = Path(adb).resolve()
        if path.parent.name == "platform-tools":
            return path.parent.parent
    return None
