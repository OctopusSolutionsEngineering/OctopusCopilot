import unittest

from domain.converters.string_to_int import string_to_int


class StringToInt(unittest.TestCase):
    def test_parsing(self):
        self.assertEqual(string_to_int('1'), 1)
        self.assertEqual(string_to_int('1 '), 1)
        self.assertEqual(string_to_int(' 1'), 1)
        self.assertEqual(string_to_int(' 1 '), 1)
        self.assertEqual(string_to_int(1), 1)
        self.assertIsNone(string_to_int('a'))
        self.assertIsNone(string_to_int(''))
        self.assertIsNone(string_to_int(None))
