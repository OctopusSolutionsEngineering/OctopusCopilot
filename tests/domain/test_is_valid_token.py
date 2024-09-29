import unittest

from domain.validation.codefresh_validation import is_valid_token


class TestIsValidToken(unittest.TestCase):
    def test_is_valid_token_valid(self):
        token = "a1b2c3d4e5f6g7h8i9j0k1l2.m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8"
        self.assertTrue(is_valid_token(token))

    def test_is_valid_token_invalid_format(self):
        token = "invalid.token.format"
        self.assertFalse(is_valid_token(token))

    def test_is_valid_token_none(self):
        self.assertFalse(is_valid_token(None))

    def test_is_valid_token_empty_string(self):
        self.assertFalse(is_valid_token(""))

    def test_is_valid_token_non_string(self):
        self.assertFalse(is_valid_token(1234567890))
