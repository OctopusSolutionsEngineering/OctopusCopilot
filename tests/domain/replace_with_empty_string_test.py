import unittest

from domain.sanitizers.sanitize_strings import strip_leading_whitespace


class StringSanitizationTest(unittest.TestCase):
    def test_strip_leading_whitespace(self):
        self.assertEqual("hello\nthere", strip_leading_whitespace("""  hello
                                                                        there"""))
        self.assertEqual("hello\nthere", strip_leading_whitespace("""  hello
                                                                        \tthere"""))
        self.assertEqual("hello", strip_leading_whitespace("  hello"))
        self.assertEqual("hello\nthere", strip_leading_whitespace("  hello\n   there"))
