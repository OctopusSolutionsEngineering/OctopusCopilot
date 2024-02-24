import unittest

from domain.errors.error_handling import sanitize_message


class SanitizeTests(unittest.TestCase):
    def test_api_key_removed(self):
        self.assertNotIn("API-ABCDEFG", sanitize_message("Api key is API-ABCDEFG"))
        self.assertEqual("Api key is *****", sanitize_message("Api key is API-ABCDEFG"))

    def test_message_not_changed(self):
        self.assertEqual("Api key is ABCDEFG", sanitize_message("Api key is ABCDEFG"))