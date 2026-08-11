#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path

from devtools import android, doctor, evidence, flutter, integration, report
from devtools.config import ConfigError, load_settings
from devtools.privacy import audit_paths
from devtools.process import CommandFailed, Runner


def _run_id() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def _device_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--device", help="serial exato mostrado por adb devices")
    parser.add_argument("--avd", help="nome exato de um AVD existente")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="botecopro",
        description="CLI canônica de desenvolvimento do monorepo BotecoPRO.",
    )
    parser.add_argument("--verbose", action="store_true", help="mostra contexto adicional sem imprimir o ambiente")
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("doctor", help="diagnóstico read-only completo")
    subparsers.add_parser("bootstrap-info", help="mostra versões e caminhos normativos")
    subparsers.add_parser("tooling-test", help="executa testes unitários da CLI Python")
    subparsers.add_parser("flutter-get", help="instala dependências Flutter")
    subparsers.add_parser("flutter-format", help="verifica formatação Dart")
    subparsers.add_parser("flutter-analyze", help="executa analyzer com fatal infos")
    subparsers.add_parser("flutter-check", help="pub get, format check e analyze")
    test_parser = subparsers.add_parser("flutter-test", help="executa testes Flutter")
    test_parser.add_argument("tests", nargs="*", help="arquivos/diretórios de teste opcionais")
    subparsers.add_parser("flutter-build", help="gera APK debug")
    subparsers.add_parser("flutter-web-build", help="gera build Web release sem credenciais")
    subparsers.add_parser("android-doctor", help="diagnóstico Android read-only")
    subparsers.add_parser("android-build", help="instala dependências e gera APK debug")

    smoke_parser = subparsers.add_parser("android-smoke", help="build/install/launch/render no Android")
    _device_options(smoke_parser)
    smoke_parser.add_argument("--no-build", action="store_true", help="reutiliza APK debug existente")
    smoke_parser.add_argument("--reset-app-data", action="store_true", help="apaga dados locais apenas do APK de desenvolvimento")
    smoke_parser.add_argument("--uninstall-after", action="store_true", help="desinstala explicitamente o APK de desenvolvimento ao terminar")

    integration_parser = subparsers.add_parser(
        "android-integration",
        help="executa o jornada Flutter sintética completa no Android",
    )
    _device_options(integration_parser)
    integration_parser.add_argument("--repeat", type=int, default=1)
    integration_parser.add_argument("--run-id")

    evidence_parser = subparsers.add_parser("android-evidence", help="captura evidência Android rastreável")
    _device_options(evidence_parser)
    evidence_parser.add_argument("--evidence-source", choices=("synthetic", "real"), default="synthetic")
    evidence_parser.add_argument("--run-id")
    evidence_parser.add_argument("--repeat", type=int, default=1)
    evidence_parser.add_argument("--reset-app-data", action="store_true", help="obrigatório para evidência sintética determinística")

    audit_parser = subparsers.add_parser("evidence-audit", help="audita textos de uma execução por segredos óbvios")
    audit_parser.add_argument("run", nargs="?", help="RUN_ID ou caminho; padrão: execução mais recente")
    report_parser = subparsers.add_parser("report", help="regenera report.md e report.json")
    report_parser.add_argument("run", nargs="?", help="RUN_ID ou caminho; padrão: execução mais recente")

    verify_parser = subparsers.add_parser("verify", help="verificação rápida completa, sem iniciar emulador")
    verify_parser.add_argument("--android", action="store_true", help="também executa smoke em dispositivo já disponível")
    _device_options(verify_parser)
    return parser


def _resolve_run(settings, value: str | None) -> Path:
    base = (settings.artifacts / "evidence").resolve()
    if value:
        candidate = Path(value)
        if not candidate.is_absolute() and len(candidate.parts) == 1:
            candidate = base / candidate
        else:
            candidate = (settings.root / candidate).resolve() if not candidate.is_absolute() else candidate.resolve()
    else:
        runs = sorted(path for path in base.glob("*") if path.is_dir()) if base.exists() else []
        if not runs:
            raise RuntimeError("Nenhuma execução de evidência encontrada.")
        candidate = runs[-1]
    resolved = candidate.resolve()
    if resolved.parent != base:
        raise RuntimeError(f"Execução deve estar diretamente sob {base}")
    if not resolved.is_dir():
        raise RuntimeError(f"Execução não encontrada: {resolved}")
    return resolved


def _bootstrap_info(settings) -> int:
    print(json.dumps({
        "repository_root": str(settings.root),
        "mobile_root": str(settings.mobile),
        "venv": str(settings.root / ".tools" / "devtools-venv"),
        "toolchain": settings.toolchain,
        "android_profile": settings.android_profile,
        "flutter_executable": flutter.flutter_executable(),
        "dart_executable": flutter.dart_executable(),
    }, indent=2, ensure_ascii=False))
    return 0


def _flutter_check(settings, runner: Runner) -> int:
    flutter.pub_get(runner, settings)
    flutter.format_check(runner, settings)
    flutter.analyze(runner, settings)
    return 0


def _tooling_test(settings, runner: Runner) -> int:
    runner.run(
        [sys.executable, "-m", "unittest", "discover", "-s", "scripts/tests", "-t", "scripts", "-p", "test_*.py", "-v"],
        cwd=settings.root,
        check=True,
    )
    return 0


def _android_smoke(settings, runner: Runner, args) -> int:
    destination = settings.artifacts / "android-smoke" / _run_id()
    screenshot = destination / "01-launch.png"
    result = android.smoke(
        settings,
        runner,
        requested_device=args.device,
        avd_name=args.avd,
        build=not args.no_build,
        screenshot=screenshot,
        reset_app_data=args.reset_app_data,
        uninstall_after=args.uninstall_after,
        artifact_directory=destination,
    )
    environment = evidence.environment_data(settings, runner, result.metadata)
    destination.mkdir(parents=True, exist_ok=True)
    (destination / "environment.json").write_text(json.dumps(environment, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"[PASS] Android smoke: {destination}")
    return 0


def _android_integration(settings, runner: Runner, args) -> int:
    result = integration.run(
        settings,
        runner,
        requested_device=args.device,
        avd_name=args.avd,
        repeat=args.repeat,
        run_id=args.run_id,
    )
    label = "PASS" if result.ok else "FAIL"
    print(f"[{label}] Android integration: {result.directory}")
    return 0 if result.ok else 1


def _verify(settings, runner: Runner, args) -> int:
    _tooling_test(settings, runner)
    _flutter_check(settings, runner)
    flutter.test(runner, settings)
    flutter.build_web(runner, settings)
    flutter.build_apk(runner, settings)
    if args.android:
        android.smoke(
            settings,
            runner,
            requested_device=args.device,
            avd_name=args.avd,
            build=False,
            artifact_directory=settings.artifacts / "android-smoke" / _run_id(),
        )
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        settings = load_settings()
        runner = Runner(verbose=args.verbose)
        if args.command == "doctor":
            return doctor.run(settings, runner)
        if args.command == "bootstrap-info":
            return _bootstrap_info(settings)
        if args.command == "tooling-test":
            return _tooling_test(settings, runner)
        if args.command == "flutter-get":
            flutter.pub_get(runner, settings)
            return 0
        if args.command == "flutter-format":
            flutter.format_check(runner, settings)
            return 0
        if args.command == "flutter-analyze":
            flutter.pub_get(runner, settings)
            flutter.analyze(runner, settings)
            return 0
        if args.command == "flutter-check":
            return _flutter_check(settings, runner)
        if args.command == "flutter-test":
            flutter.pub_get(runner, settings)
            flutter.test(runner, settings, extra_args=args.tests)
            return 0
        if args.command == "flutter-build":
            flutter.pub_get(runner, settings)
            flutter.build_apk(runner, settings)
            return 0
        if args.command == "flutter-web-build":
            flutter.pub_get(runner, settings)
            flutter.build_web(runner, settings)
            return 0
        if args.command == "android-doctor":
            return doctor.run(settings, runner)
        if args.command == "android-build":
            flutter.pub_get(runner, settings)
            flutter.build_apk(runner, settings)
            return 0
        if args.command == "android-smoke":
            return _android_smoke(settings, runner, args)
        if args.command == "android-integration":
            return _android_integration(settings, runner, args)
        if args.command == "android-evidence":
            if args.evidence_source == "synthetic":
                return _android_integration(settings, runner, args)
            destination, manifest = evidence.capture(
                settings,
                runner,
                source=args.evidence_source,
                requested_device=args.device,
                avd_name=args.avd,
                run_id=args.run_id,
                reset_app_data=args.reset_app_data,
            )
            print(f"[PASS] Evidência capturada: {destination}")
            if manifest["command_result"] == "CAPTURED_REVIEW_REQUIRED":
                print("[INFO] Captura REAL_INSTANCE exige revisão visual manual antes de qualquer publicação.")
            return 0
        if args.command == "evidence-audit":
            run = _resolve_run(settings, args.run)
            findings = audit_paths(path for path in run.rglob("*") if path.is_file())
            if findings:
                for finding in findings:
                    print(f"[FAIL] {finding.path}:{finding.line} possível segredo")
                return 1
            print(f"[PASS] Nenhum padrão textual óbvio de segredo em {run}")
            manifest = json.loads((run / "manifest.json").read_text(encoding="utf-8"))
            if manifest.get("evidence_classification") == "REAL_INSTANCE":
                print("[INFO] Imagens reais ainda exigem revisão visual manual; OCR não é garantia.")
            return 0
        if args.command == "report":
            run = _resolve_run(settings, args.run)
            paths = report.generate(run)
            print(f"[PASS] Relatórios: {paths[0]} e {paths[1]}")
            return 0
        if args.command == "verify":
            return _verify(settings, runner, args)
        parser.error(f"Comando não implementado: {args.command}")
    except (CommandFailed, ConfigError, RuntimeError, ValueError) as error:
        print(f"[FAIL] {error}", file=sys.stderr)
        if isinstance(error, CommandFailed):
            return error.result.return_code or 1
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
