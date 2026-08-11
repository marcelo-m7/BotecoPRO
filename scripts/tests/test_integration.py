from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path

from devtools.config import load_settings
from devtools.flutter import integration_drive_command
from devtools.integration import (
    EXPECTED_SCREENSHOTS,
    parse_integration_response,
    register_screenshots,
    validate_app_logcat,
)


class IntegrationLogicTests(unittest.TestCase):
    def test_parses_scenario_result(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "integration-response.json"
            path.write_text(
                json.dumps(
                    {
                        "scenario_result": {
                            "scenario": "synthetic-connected-offline-cart",
                            "status": "passed",
                            "steps": [{"name": "catalog", "status": "passed"}],
                        }
                    }
                ),
                encoding="utf-8",
            )
            result = parse_integration_response(path)
            self.assertEqual(result["status"], "passed")
            self.assertEqual(result["steps"][0]["name"], "catalog")

    def test_missing_response_is_machine_readable_failure(self) -> None:
        result = parse_integration_response(Path("/does/not/exist"))
        self.assertEqual(result["status"], "failed")
        self.assertEqual(result["failed_step"], "driver-response")

    def test_registers_asserted_screenshot_with_hash(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            run = Path(temporary)
            attempt = run / "repeats" / "attempt-02"
            screenshots = attempt / "screenshots"
            screenshots.mkdir(parents=True)
            (screenshots / "02-catalog.png").write_bytes(b"\x89PNG\r\n\x1a\nfixture")
            registered = register_screenshots(
                attempt,
                [
                    {
                        "name": "catalog",
                        "status": "passed",
                        "screenshot": "02-catalog.png",
                    }
                ],
                run_directory=run,
                attempt=2,
            )
            self.assertEqual(registered[0]["step"], "catalog")
            self.assertEqual(
                registered[0]["filename"],
                "repeats/attempt-02/screenshots/02-catalog.png",
            )
            self.assertEqual(registered[0]["assertion_status"], "passed")
            self.assertEqual(len(registered[0]["sha256"]), 64)

    def test_logcat_flags_app_failures_but_ignores_other_processes(self) -> None:
        unrelated = "AndroidRuntime: FATAL EXCEPTION main\nProcess: com.android.systemui"
        self.assertEqual(validate_app_logcat(unrelated), [])
        application = (
            "AndroidRuntime: FATAL EXCEPTION main\n"
            "AndroidRuntime: Process: com.example.botecopro\n"
            "E/flutter: Unhandled Exception: synthetic failure\n"
            "A RenderFlex overflowed by 12 pixels"
        )
        self.assertEqual(
            validate_app_logcat(application),
            [
                "android_fatal_exception",
                "flutter_render_overflow",
                "flutter_unhandled_exception",
            ],
        )

    def test_drive_command_selects_device_and_prebuilt_apk(self) -> None:
        settings = load_settings()
        command = integration_drive_command(
            settings,
            device="emulator-5554",
            failure_screenshot_directory=Path("/tmp/failures"),
            application_binary=Path("/tmp/integration.apk"),
        )
        self.assertIn("emulator-5554", command)
        self.assertIn("integration_test/connected_offline_cart_flow_test.dart", command)
        self.assertEqual(command[-2:], ["--use-application-binary", "/tmp/integration.apk"])

    def test_expected_evidence_has_nine_asserted_steps(self) -> None:
        self.assertEqual(len(EXPECTED_SCREENSHOTS), 9)


if __name__ == "__main__":
    unittest.main()
