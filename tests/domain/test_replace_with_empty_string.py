import unittest

from domain.sanitizers.sanitize_strings import (
    strip_leading_whitespace,
    remove_empty_lines,
    remove_double_whitespace,
    add_spaces_before_capitals,
    replace_with_empty_string,
    to_lower_case_or_none,
)


class StringSanitizationTest(unittest.TestCase):
    def test_strip_leading_whitespace(self):
        self.assertEqual(
            "hello\nthere",
            strip_leading_whitespace(
                """  hello
                                                                        there"""
            ),
        )
        self.assertEqual(
            "hello\nthere",
            strip_leading_whitespace(
                """  hello
                                                                        \tthere"""
            ),
        )
        self.assertEqual("hello", strip_leading_whitespace("  hello"))
        self.assertEqual("hello\nthere", strip_leading_whitespace("  hello\n   there"))
        self.assertEqual(
            strip_leading_whitespace("  line1\n\tline2\n  line3"), "line1\nline2\nline3"
        )
        self.assertEqual(strip_leading_whitespace("line1\nline2"), "line1\nline2")
        self.assertEqual(strip_leading_whitespace("  \n\t"), "")

    def test_remove_empty_lines(self):
        self.assertEqual(remove_empty_lines("line1\n\nline2\n\n"), "line1\nline2")
        self.assertEqual(remove_empty_lines("line1\nline2"), "line1\nline2")
        self.assertEqual(remove_empty_lines("\n\n"), "")

    def test_remove_double_whitespace(self):
        self.assertEqual(
            remove_double_whitespace("This  is  a  test"), "This is a test"
        )
        self.assertEqual(
            remove_double_whitespace("No  double  spaces"), "No double spaces"
        )
        self.assertEqual(remove_double_whitespace("Single space"), "Single space")

    def test_add_spaces_before_capitals(self):
        self.assertEqual(add_spaces_before_capitals("ThisIsATest"), "This Is A Test")
        self.assertEqual(add_spaces_before_capitals("thisisatest"), "thisisatest")
        self.assertEqual(add_spaces_before_capitals("Nocapitals"), "Nocapitals")
        self.assertEqual(add_spaces_before_capitals(""), "")

    def test_replace_with_empty_string(self):
        self.assertEqual(
            replace_with_empty_string("This is a test", "test"), "This is a "
        )
        self.assertEqual(
            replace_with_empty_string("Remove all digits 123", r"\d"),
            "Remove all digits ",
        )
        self.assertEqual(
            replace_with_empty_string("Nothing to replace", "xyz"), "Nothing to replace"
        )

    def test_to_lower_case_or_none(self):
        self.assertEqual(to_lower_case_or_none("TEST"), "test")
        self.assertEqual(to_lower_case_or_none("Test"), "test")
        self.assertIsNone(to_lower_case_or_none(None))
