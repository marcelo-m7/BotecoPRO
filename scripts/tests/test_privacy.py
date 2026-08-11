from __future__ import annotations

import unittest

from devtools.privacy import audit_text, redact, redact_command


class PrivacyTests(unittest.TestCase):
    def test_redacts_nested_sensitive_keys(self) -> None:
        value = {"safe": "yes", "headers": {"Authorization": "Bearer secret"}, "api_key": "secret"}
        redacted = redact(value)
        self.assertEqual(redacted["safe"], "yes")
        self.assertEqual(redacted["headers"]["Authorization"], "[REDACTED]")
        self.assertEqual(redacted["api_key"], "[REDACTED]")

    def test_redacts_cli_secret_value(self) -> None:
        self.assertEqual(redact_command(["tool", "--api-key", "secret"]), ["tool", "--api-key", "[REDACTED]"])

    def test_audit_finds_authorization_and_env_key(self) -> None:
        findings = audit_text("Authorization: Bearer abcdefgh\nODOO_ONLINE_API_KEY=secret")
        self.assertEqual(len(findings), 2)

    def test_audit_ignores_policy_words_without_values(self) -> None:
        self.assertEqual(audit_text("Never print Authorization, tokens or API keys."), [])

    def test_audit_distinguishes_http_cookie_from_android_handle(self) -> None:
        self.assertEqual(
            audit_text("BiometricService: state: 0, cookie: 34"),
            [],
        )
        self.assertEqual(
            len(audit_text("Cookie: session_id=synthetic-value")),
            1,
        )


if __name__ == "__main__":
    unittest.main()
