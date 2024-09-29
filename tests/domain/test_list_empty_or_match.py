import unittest

from domain.filter.list_filter import list_empty_or_match


class ListFilterTest(unittest.TestCase):
    def test_list_empty_or_match(self):
        self.assertTrue(list_empty_or_match([{"Id": "123"}], lambda x: x["Id"], "123"))
        self.assertTrue(list_empty_or_match([], lambda x: x["Id"], "123"))
        self.assertFalse(list_empty_or_match([{"Id": "123"}], lambda x: x["Id"], "1233"))
