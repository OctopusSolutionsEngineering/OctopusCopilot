import unittest

from domain.validation.octopus_validation import is_api_key


class ApiKeyTest(unittest.TestCase):
    def test_api_key_validation(self):
        self.assertTrue(is_api_key("API-XXXXXXXXX"))
        self.assertTrue(is_api_key("API-ABCDEFG1234"))
        self.assertFalse(is_api_key("blah"))
        self.assertFalse(is_api_key("javascript:alert('hello')"))
        self.assertFalse(is_api_key(""))
        self.assertFalse(is_api_key("     "))
        self.assertFalse(is_api_key(None))
        self.assertFalse(is_api_key([]))
        self.assertFalse(is_api_key({}))
