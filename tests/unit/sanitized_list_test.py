import unittest

from domain.strings.sanitized_list import sanitize_list


class SanitizeList(unittest.TestCase):
    def test_sanitize_list(self):
        self.assertFalse(sanitize_list(["*"]))
        self.assertFalse(sanitize_list([" ", "  ", "   "]))
        self.assertTrue(sanitize_list([" ", "  ", "  i "]))
        self.assertFalse(sanitize_list([]))
        self.assertFalse(sanitize_list(None))
        self.assertFalse(sanitize_list(""))
        self.assertFalse(sanitize_list(" "))
        self.assertTrue(sanitize_list("hi"))
