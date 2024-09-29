import unittest

from domain.sanitizers.sanitized_list import sanitize_bool


class SanitizeBoolTest(unittest.TestCase):
    def test_sanitize_bool(self):
        self.assertTrue(sanitize_bool(True))
        self.assertFalse(sanitize_bool(False))
        self.assertFalse(sanitize_bool("True"))
        self.assertFalse(sanitize_bool("False"))
