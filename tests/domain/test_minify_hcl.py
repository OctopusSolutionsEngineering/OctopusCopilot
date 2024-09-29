import unittest

from domain.transformers.minify_strings import minify_strings


class MinifyTest(unittest.TestCase):
    def test_minify(self):
        result = minify_strings("  This is a test \n   \nblah  test")
        self.assertEqual(result, " This is a test \nblah test")
