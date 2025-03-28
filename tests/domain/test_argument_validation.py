import unittest

from domain.validation.argument_validation import ensure_api_key


class ArgumentValidationTest(unittest.TestCase):
    def test_ensure_api_key(self):
        ensure_api_key("API-aaa", "Invalid API key")
        with self.assertRaises(ValueError):
            ensure_api_key("blah", "Invalid API key")
