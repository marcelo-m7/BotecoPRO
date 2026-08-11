from __future__ import annotations

import os
import tempfile
import unittest
from pathlib import Path

from devtools.config import ConfigError, find_executable, load_settings, repository_root


class ConfigTests(unittest.TestCase):
    def test_repository_root_resolves_from_nested_path(self) -> None:
        settings = load_settings()
        self.assertEqual(repository_root(settings.mobile / "lib"), settings.root)

    def test_repository_root_rejects_unrelated_directory(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            with self.assertRaises(ConfigError):
                repository_root(Path(temporary))

    def test_find_executable_uses_flutter_root(self) -> None:
        with tempfile.TemporaryDirectory() as temporary:
            executable = Path(temporary) / "bin" / "flutter"
            executable.parent.mkdir()
            executable.write_text("#!/bin/sh\n", encoding="utf-8")
            executable.chmod(0o755)
            found = find_executable("flutter", {"PATH": "", "FLUTTER_ROOT": temporary})
            self.assertEqual(found, str(executable))

    def test_normative_android_versions_match_profile(self) -> None:
        settings = load_settings()
        self.assertEqual(settings.toolchain["android"]["compile_sdk"], settings.android_profile["api_level"])

    def test_normative_gradle_versions_match_mobile_project(self) -> None:
        settings = load_settings()
        android = settings.toolchain["android"]
        gradle_settings = (settings.mobile / "android" / "settings.gradle").read_text(encoding="utf-8")
        wrapper = (settings.mobile / "android" / "gradle" / "wrapper" / "gradle-wrapper.properties").read_text(encoding="utf-8")
        app_gradle = (settings.mobile / "android" / "app" / "build.gradle").read_text(encoding="utf-8")
        self.assertIn(f'version "{android["android_gradle_plugin"]}"', gradle_settings)
        self.assertIn(f'version "{android["kotlin"]}"', gradle_settings)
        self.assertIn(f'gradle-{android["gradle"]}-', wrapper)
        self.assertIn(f'JavaVersion.VERSION_{settings.toolchain["java"]}', app_gradle)


if __name__ == "__main__":
    unittest.main()
