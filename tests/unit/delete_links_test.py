import unittest

from domain.transformers.delete_links import delete_links


class AdminUser(unittest.TestCase):
    def test_delete_links_top(self):
        stripped = delete_links({"Blah": "hi", "Links": "test"})
        self.assertFalse('Links' in stripped)

    def test_delete_links_nested(self):
        stripped = delete_links({"Blah": "hi", "Nested": {"Blah": "hi", "Links": "test"}, "Links": "test"})
        self.assertFalse('Links' in stripped["Nested"])

    def test_delete_links_array(self):
        stripped = delete_links({"Blah": "hi", "Nested": [{"Blah": "hi", "Links": "test"}], "Links": "test"})
        self.assertFalse('Links' in stripped["Nested"][0])

    def test_delete_links_none(self):
        stripped = delete_links(None)
        self.assertIsNone(stripped)

    def test_delete_links_string(self):
        stripped = delete_links("whatever")
        self.assertEqual(stripped, "whatever")
