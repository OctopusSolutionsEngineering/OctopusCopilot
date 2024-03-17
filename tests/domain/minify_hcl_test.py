import unittest

from domain.transformers.minify_hcl import minify_hcl


class MinifyTest(unittest.TestCase):
    def test_minify(self):
        result = minify_hcl("  This is a test \n   \nblah  test")
        self.assertEqual(result, " This is a test \nblah test")
