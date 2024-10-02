import unittest

from domain.validation.argument_validation import (
    ensure_string_not_empty,
    ensure_string,
    ensure_not_falsy,
    ensure_string_starts_with,
)


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
            ensure_not_falsy(None, "message")

    def test_ensure_string_starts_with_valid(self):
        # Test with valid string and prefix
        try:
            ensure_string_starts_with(
                "example", "ex", "Error: String does not start with prefix"
            )
        except ValueError:
            self.fail("ensure_string_starts_with raised ValueError unexpectedly!")

    def test_ensure_string_starts_with_invalid(self):
        # Test with string that does not start with the prefix
        with self.assertRaises(ValueError):
            ensure_string_starts_with(
                "example", "no", "Error: String does not start with prefix"
            )

    def test_ensure_string_starts_with_empty_string(self):
        # Test with empty string
        with self.assertRaises(ValueError):
            ensure_string_starts_with(
                "", "ex", "Error: String does not start with prefix"
            )

    def test_ensure_string_starts_with_none(self):
        # Test with None
        with self.assertRaises(ValueError):
            ensure_string_starts_with(
                None, "ex", "Error: String does not start with prefix"
            )

    def test_ensure_string_starts_with_non_string(self):
        # Test with non-string value
        with self.assertRaises(ValueError):
            ensure_string_starts_with(
                123, "ex", "Error: String does not start with prefix"
            )
