import unittest

from domain.errors.error_handling import sanitize_message
from domain.sanitizers.sanitize_logs import anonymize_message
from domain.sanitizers.sanitized_list import get_item_or_none, is_re_match, none_if_falesy


class SanitizeTests(unittest.TestCase):
    def test_api_key_removed(self):
        self.assertNotIn("API-ABCDEFG", sanitize_message("Api key is API-ABCDEFG"))
        self.assertNotIn("api-AbCD123", sanitize_message("Api key is api-AbCD123"))
        self.assertNotIn("aPi-AbCD123", sanitize_message("Api key is aPi-AbCD123"))
        self.assertEqual("Api key is *****", sanitize_message("Api key is API-ABCDEFG"))

    def test_message_email_removed(self):
        self.assertTrue("example@example.org" not in anonymize_message("Email is example@example.org"))

    def test_access_key_removed(self):
        self.assertTrue("AKIAIOSFODNN7ABFRDS" not in anonymize_message("Access key is AKIAIOSFODNN7ABFRDS"))
        self.assertTrue("wJalrXUtnFEMI" not in anonymize_message("Secret key is wJalrXUtnFEMI/K7MDENG/bPxRfiCY"))
        self.assertTrue("K7MDENG" not in anonymize_message("Secret key is wJalrXUtnFEMI/K7MDENG/bPxRfiCY"))
        self.assertTrue("bPxRfiCY" not in anonymize_message("Secret key is wJalrXUtnFEMI/K7MDENG/bPxRfiCY"))
        self.assertTrue("7328afad" not in anonymize_message("Tenant ID 7328afad-4ddc-422e-93bb-d465a5dd5c25"))

    def test_get_item_or_none(self):
        self.assertEqual('item1', get_item_or_none(['item1'], 0))
        self.assertEqual(None, get_item_or_none(['item1'], 1))

    def test_is_re_match(self):
        self.assertTrue(is_re_match('item1', 'item[0-9]'))
        self.assertFalse(is_re_match('item1', 'item[a-z]'))
        self.assertFalse(is_re_match('item1', None))

    def test_none_if_falesy(self):
        self.assertEqual(None, none_if_falesy(''))
        self.assertEqual(None, none_if_falesy([]))
        self.assertEqual(None, none_if_falesy(0))
        self.assertEqual(None, none_if_falesy(False))
        self.assertEqual('test', none_if_falesy('test'))
        self.assertEqual(['test'], none_if_falesy(['test']))
        self.assertEqual(True, none_if_falesy(True))
        self.assertEqual(1, none_if_falesy(1))

    def test_get_item_or_none_none_array(self):
        self.assertEqual(None, get_item_or_none(None, 0))

    def test_sanitize_message_api_key(self):
        message = "Api key is API-ABCDEFG"
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
        message = "Api key is API-ABCDEFG and GitHub PAT is ghp_abcdefghijklmnopqrstuvwxyzABCD012345"
        sanitized_message = sanitize_message(message)
        self.assertEqual(sanitized_message, "Api key is ***** and GitHub PAT is *****")
