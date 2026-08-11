from __future__ import annotations

import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from devtools.config import load_settings
from devtools.evidence import safe_run_directory, sha256_file
from devtools.report import generate


class EvidenceTests(unittest.TestCase):
    def test_sha256_file(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            path = Path(temporary) / "sample.bin"
            path.write_bytes(b"botecopro")
            self.assertEqual(sha256_file(path), hashlib.sha256(b"botecopro").hexdigest())

    def test_safe_evidence_path(self) -> None:
        settings = load_settings()
        path = safe_run_directory(settings, "20260811T102300Z-test")
        self.assertEqual(path.parent, (settings.artifacts / "evidence").resolve())

    def test_rejects_path_traversal(self) -> None:
        with self.assertRaises(ValueError):
            safe_run_directory(load_settings(), "../../outside")

    def test_report_generation(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            run = Path(temporary)
            (run / "manifest.json").write_text(
                json.dumps(
                    {
                        "run_id": "20260811T102300Z-test",
                        "command_result": "PASSED",
                        "evidence_classification": "SYNTHETIC",
                        "screenshots": [],
                        "privacy": {"text_audit": "passed"},
                    }
                ),
                encoding="utf-8",
            )
            markdown, machine = generate(run)
            self.assertTrue(markdown.is_file())
            self.assertEqual(json.loads(machine.read_text(encoding="utf-8"))["failures"], [])


if __name__ == "__main__":
    unittest.main()
