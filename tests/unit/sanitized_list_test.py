import unittest

from domain.strings.sanitized_list import sanitize_list, sanitize_environments


class SanitizeList(unittest.TestCase):
    def test_sanitize_list(self):
        self.assertFalse(sanitize_list(["*"], "\\*"))
        self.assertFalse(sanitize_list([" ", "  ", "   "]))
        self.assertTrue(sanitize_list([" ", "  ", "  i "]))
        self.assertFalse(sanitize_list([]))
        self.assertFalse(sanitize_list(None))
        self.assertFalse(sanitize_list(5))
        self.assertFalse(sanitize_list(5.5))
        self.assertFalse(sanitize_list(True))
        self.assertEqual(0, len(sanitize_list(None)))
        self.assertFalse(sanitize_list(""))
        self.assertFalse(sanitize_list(" "))
        self.assertFalse(sanitize_list("Machine A", "Machine"))
        self.assertTrue(sanitize_list("hi"))
        self.assertTrue(sanitize_list(["hi"]))
        self.assertFalse(sanitize_list([["hi"]]))
        self.assertFalse(sanitize_environments(None))
