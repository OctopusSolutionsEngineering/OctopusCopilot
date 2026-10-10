import unittest

from domain.errors.error_handling import sanitize_message
from domain.sanitizers.sanitize_logs import anonymize_message
from domain.sanitizers.sanitized_list import (
    get_item_or_none,
    is_re_match,
    none_if_falesy,
)


class SanitizeTests(unittest.TestCase):
    def test_api_key_removed(self):
        self.assertNotIn("API-ABCDEFGHIJKLMNOPQRSTUVWXYZ", sanitize_message("Api key is API-ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
        self.assertNotIn("api-ABCD1234ABCD1234ABCD12", sanitize_message("Api key is api-ABCD1234ABCD1234ABCD12"))
        self.assertNotIn("aPi-ABCD1234ABCD1234ABCD12", sanitize_message("Api key is aPi-ABCD1234ABCD1234ABCD12"))
        self.assertEqual("Api key is *****", sanitize_message("Api key is API-ABCDEFGHIJKLMNOPQRSTUVWXYZ"))

    def test_api_words_in_names_are_kept(self):
        self.assertEqual(
            'Create a target called "ledger-api-prod"',
            sanitize_message('Create a target called "ledger-api-prod"'),
        )
        self.assertEqual("Deploy orders-api-v2 and api-gateway", sanitize_message("Deploy orders-api-v2 and api-gateway"))

    def test_message_email_removed(self):
        self.assertTrue(
            "example@example.org"
            not in anonymize_message("Email is example@example.org")
        )

    def test_get_item_or_none(self):
        self.assertEqual("item1", get_item_or_none(["item1"], 0))
        self.assertEqual(None, get_item_or_none(["item1"], 1))

    def test_is_re_match(self):
        self.assertTrue(is_re_match("item1", "item[0-9]"))
        self.assertFalse(is_re_match("item1", "item[a-z]"))
        self.assertFalse(is_re_match("item1", None))

    def test_none_if_falesy(self):
        self.assertEqual(None, none_if_falesy(""))
        self.assertEqual(None, none_if_falesy([]))
        self.assertEqual(None, none_if_falesy(0))
        self.assertEqual(None, none_if_falesy(False))
        self.assertEqual("test", none_if_falesy("test"))
        self.assertEqual(["test"], none_if_falesy(["test"]))
        self.assertEqual(True, none_if_falesy(True))
        self.assertEqual(1, none_if_falesy(1))

    def test_get_item_or_none_none_array(self):
        self.assertEqual(None, get_item_or_none(None, 0))

    def test_sanitize_message_api_key(self):
        message = "Api key is API-ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        sanitized_message = sanitize_message(message)
        self.assertEqual(sanitized_message, "Api key is *****")

    def test_sanitize_message_github_pat(self):
        message = "GitHub PAT is ghp_abcdefghijklmnopqrstuvwxyzABCD012345"
        sanitized_message = sanitize_message(message)
        self.assertEqual(sanitized_message, "GitHub PAT is *****")

    def test_sanitize_message_empty(self):
        message = ""
        sanitized_message = sanitize_message(message)
        self.assertEqual(sanitized_message, "")

    def test_sanitize_message_none(self):
        message = None
        sanitized_message = sanitize_message(message)
        self.assertEqual(sanitized_message, None)

    def test_sanitize_message_no_sensitive_data(self):
        message = "This is a safe message."
        sanitized_message = sanitize_message(message)
        self.assertEqual(sanitized_message, "This is a safe message.")

    def test_sanitize_message_multiple_sensitive_data(self):
        message = "Api key is API-ABCDEFGHIJKLMNOPQRSTUVWXYZ and GitHub PAT is ghp_abcdefghijklmnopqrstuvwxyzABCD012345"
        sanitized_message = sanitize_message(message)
        self.assertEqual(sanitized_message, "Api key is ***** and GitHub PAT is *****")
