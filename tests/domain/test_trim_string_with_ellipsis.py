import unittest

from domain.transformers.trim_strings import trim_string_with_ellipsis


class TestTrimStringWithEllipsis(unittest.TestCase):
    def test_trim_string_with_ellipsis_short_string(self):
        string = "short"
        max_length = 10
        result = trim_string_with_ellipsis(string, max_length)
        self.assertEqual(result, "short")

    def test_trim_string_with_ellipsis_exact_length(self):
        string = "exactlength"
        max_length = 11
        result = trim_string_with_ellipsis(string, max_length)
        self.assertEqual(result, "exactlength")

    def test_trim_string_with_ellipsis_long_string(self):
        string = "this is a very long string"
        max_length = 10
        result = trim_string_with_ellipsis(string, max_length)
        self.assertEqual(result, "this is a ...")

    def test_trim_string_with_ellipsis_empty_string(self):
        string = ""
        max_length = 5
        result = trim_string_with_ellipsis(string, max_length)
        self.assertEqual(result, "")

    def test_trim_string_with_ellipsis_zero_length(self):
        string = "nonempty"
        max_length = 0
        result = trim_string_with_ellipsis(string, max_length)
        self.assertEqual(result, "...")
