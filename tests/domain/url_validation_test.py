import unittest

from domain.validation.url_validation import validate_url


class UrlValidation(unittest.TestCase):
    def test_url_validation(self):
        self.assertTrue(validate_url("http://example.org"))
        self.assertTrue(validate_url("https://example.org"))
        self.assertTrue(validate_url("https://example.org/blah"))
        self.assertTrue(validate_url("ftp://example.org"))
        self.assertFalse(validate_url(None))
        self.assertFalse(validate_url([]))
        self.assertFalse(validate_url({}))
        self.assertFalse(validate_url("blah"))
        self.assertFalse(validate_url("javascript:alert('hello')"))
