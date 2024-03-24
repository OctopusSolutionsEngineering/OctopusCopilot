import unittest

from domain.errors.error_handling import sanitize_message
from domain.sanitizers.sanitized_list import get_item_or_none, is_re_match, none_if_falesy


class SanitizeTests(unittest.TestCase):
    def test_api_key_removed(self):
        self.assertNotIn("API-ABCDEFG", sanitize_message("Api key is API-ABCDEFG"))
        self.assertNotIn("api-AbCD123", sanitize_message("Api key is api-AbCD123"))
        self.assertNotIn("aPi-AbCD123", sanitize_message("Api key is aPi-AbCD123"))
        self.assertEqual("Api key is *****", sanitize_message("Api key is API-ABCDEFG"))

    def test_message_creds_removed(self):
        self.assertEqual("Api key is <RANDOM_STRING>", sanitize_message("Api key is ABCDEFG"))

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
