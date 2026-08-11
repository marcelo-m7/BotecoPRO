from __future__ import annotations

import unittest

from devtools.adb import parse_devices
from devtools.flutter import parse_framework_revision, parse_versions


class ParsingTests(unittest.TestCase):
    def test_flutter_and_dart_versions(self) -> None:
        output = "Flutter 3.44.9 • channel stable\nFramework • revision 6b182d2c75\nTools • Dart 3.12.2 • DevTools 2.57.0"
        self.assertEqual(parse_versions(output), ("3.44.9", "3.12.2"))
        self.assertEqual(parse_framework_revision(output), "6b182d2c75")

    def test_adb_devices_include_state_and_metadata(self) -> None:
        output = """List of devices attached
emulator-5554 device product:sdk_gphone model:sdk_gphone64_x86_64 transport_id:1
R58M offline usb:1-1 product:phone model:Pixel_6
"""
        devices = parse_devices(output)
        self.assertEqual([device.serial for device in devices], ["emulator-5554", "R58M"])
        self.assertTrue(devices[0].is_emulator)
        self.assertEqual(devices[0].details["model"], "sdk_gphone64_x86_64")
        self.assertEqual(devices[1].state, "offline")


if __name__ == "__main__":
    unittest.main()
