from __future__ import annotations

import os
import re
from pathlib import Path
from typing import Iterable

from .config import Settings, find_executable
from .process import CommandResult, Runner


VERSION_PATTERN = re.compile(r"Flutter\s+(?P<flutter>\S+).*?Dart\s+(?P<dart>\S+)", re.DOTALL)
FORMAT_TARGETS = (
    "lib/main.dart",
    "lib/theme.dart",
    "lib/models/catalog.dart",
    "lib/models/company.dart",
    "lib/models/connection.dart",
    "lib/models/connection_diagnostic.dart",
    "lib/models/currency.dart",
    "lib/models/draft_cart.dart",
    "lib/models/identity.dart",
    "lib/models/pos_config.dart",
    "lib/models/pos_operational_profile.dart",
    "lib/models/restaurant.dart",
    "lib/models/sync_snapshot.dart",
    "lib/pages/connection",
    "lib/pages/odoo",
    "lib/providers",
    "lib/services/odoo",
    "lib/services/storage",
    "lib/widgets/catalog_money_formatter.dart",
    "lib/widgets/odoo_sync_banner.dart",
    "test",
)


def flutter_executable() -> str | None:
    return find_executable("flutter")


def dart_executable() -> str | None:
    direct = find_executable("dart")
    if direct:
        return direct
    flutter = flutter_executable()
    if flutter:
        bundled = Path(flutter).resolve().parent / "dart"
        if bundled.is_file():
            return str(bundled)
    return None


def command_environment() -> dict[str, str]:
    environment = dict(os.environ)
    flutter = flutter_executable()
    if flutter:
        flutter_bin = str(Path(flutter).resolve().parent)
        path_entries = environment.get("PATH", "").split(os.pathsep)
        if flutter_bin not in path_entries:
            environment["PATH"] = os.pathsep.join([flutter_bin, *path_entries])
    return environment


def parse_versions(output: str) -> tuple[str | None, str | None]:
    match = VERSION_PATTERN.search(output)
    if not match:
        return None, None
    return match.group("flutter"), match.group("dart")


def version(runner: Runner, settings: Settings) -> CommandResult | None:
    executable = flutter_executable()
    if not executable:
        return None
    return runner.run(
        [executable, "--version"],
        cwd=settings.mobile,
        env=command_environment(),
        stream=False,
    )


def pub_get(runner: Runner, settings: Settings, *, check: bool = True) -> CommandResult:
    executable = _required_flutter()
    return runner.run(
        [executable, "pub", "get"],
        cwd=settings.mobile,
        env=command_environment(),
        check=check,
    )


def format_check(runner: Runner, settings: Settings, *, check: bool = True) -> CommandResult:
    executable = dart_executable()
    if not executable:
        raise RuntimeError("Dart não encontrado. Instale/ative o Flutter esperado e execute make doctor.")
    return runner.run(
        [executable, "format", "--output=none", "--set-exit-if-changed", *FORMAT_TARGETS],
        cwd=settings.mobile,
        env=command_environment(),
        check=check,
    )


def analyze(runner: Runner, settings: Settings, *, check: bool = True) -> CommandResult:
    executable = _required_flutter()
    return runner.run(
        [executable, "analyze", "--fatal-infos", "--no-pub"],
        cwd=settings.mobile,
        env=command_environment(),
        check=check,
    )


def test(
    runner: Runner,
    settings: Settings,
    *,
    extra_args: Iterable[str] = (),
    check: bool = True,
) -> CommandResult:
    executable = _required_flutter()
    return runner.run(
        [executable, "test", "--no-pub", *extra_args],
        cwd=settings.mobile,
        env=command_environment(),
        check=check,
    )


def build_apk(runner: Runner, settings: Settings, *, check: bool = True) -> CommandResult:
    executable = _required_flutter()
    return runner.run(
        [executable, "build", "apk", "--debug", "--no-pub"],
        cwd=settings.mobile,
        env=command_environment(),
        check=check,
    )


def _required_flutter() -> str:
    executable = flutter_executable()
    if not executable:
        raise RuntimeError(
            "Flutter não encontrado. Instale a versão indicada por "
            "scripts/toolchain.json ou defina FLUTTER_ROOT/PATH; depois execute make doctor."
        )
    return executable
