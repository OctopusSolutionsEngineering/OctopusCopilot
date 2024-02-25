import unittest

from domain.validation.argument_validation import ensure_string_not_empty, ensure_string, ensure_not_falsy


class EnsureTests(unittest.TestCase):
    def test_ensure_string_not_empty(self):
        ensure_string_not_empty("hi", "message")

        with self.assertRaises(ValueError):
            ensure_string_not_empty("", "message")

        with self.assertRaises(ValueError):
            ensure_string_not_empty(123, "message")

        with self.assertRaises(ValueError):
            ensure_string_not_empty(" ", "message")

    def test_ensure_string(self):
        ensure_string("hi", "message")
        ensure_string("", "message")

        with self.assertRaises(ValueError):
            ensure_string(None, "message")

        with self.assertRaises(ValueError):
            ensure_string(123, "message")

    def test_ensure_not_falsy(self):
        ensure_not_falsy("hi", "message")
        ensure_not_falsy("  ", "message")
        ensure_not_falsy(123, "message")
        ensure_not_falsy({"hi": "there"}, "message")
        ensure_not_falsy([123], "message")
        ensure_not_falsy(True, "message")

        with self.assertRaises(ValueError):
            ensure_string(None, "message")
