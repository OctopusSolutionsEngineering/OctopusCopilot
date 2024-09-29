import unittest

from domain.validation.int_validation import is_int


class TestIsInt(unittest.TestCase):
    def test_is_int_valid_integer(self):
        self.assertTrue(is_int("123"))

    def test_is_int_negative_integer(self):
        self.assertTrue(is_int("-123"))

    def test_is_int_zero(self):
        self.assertTrue(is_int("0"))

    def test_is_int_invalid_string(self):
        self.assertFalse(is_int("abc"))

    def test_is_int_empty_string(self):
        self.assertFalse(is_int(""))

    def test_is_int_float_string(self):
        self.assertFalse(is_int("123.45"))

    def test_is_int_none(self):
        self.assertFalse(is_int(None))
