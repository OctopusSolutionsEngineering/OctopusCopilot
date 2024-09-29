import unittest

from domain.sanitizers.url_sanitizer import quote_safe


class QuoteSafeTest(unittest.TestCase):
    def test_quote_safe(self):
        self.assertEqual(quote_safe("hi/there"), "hi%2Fthere")
        self.assertEqual(quote_safe("hithere"), "hithere")
        self.assertEqual(quote_safe(1), "1")
        self.assertEqual(quote_safe(True), "True")
        self.assertEqual(quote_safe(None), "")
        self.assertEqual(quote_safe({}), "")
        self.assertEqual(quote_safe([]), "")
