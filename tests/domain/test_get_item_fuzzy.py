import unittest

from domain.sanitizers.sanitized_list import get_item_fuzzy


class FuzzyItemTest(unittest.TestCase):
    def test_get_item_fuzzy(self):
        self.assertEqual(get_item_fuzzy([{"Name": "hi"}, {"Name": "there"}], "hi"), {"Name": "hi"})
        self.assertEqual(get_item_fuzzy([{"Name": "hi"}, {"Name": "there"}], "Hi"), {"Name": "hi"})
        self.assertEqual(get_item_fuzzy([{"Name": "hi"}, {"Name": "there"}], " Hi"), {"Name": "hi"})
        self.assertEqual(get_item_fuzzy([{"Name": "hi"}, "there"], "hi"), {"Name": "hi"})
        self.assertEqual(get_item_fuzzy([{"Name": "hi"}, {"Name": "there"}], "hi1"), {"Name": "hi"})
        self.assertEqual(get_item_fuzzy([{"Name": "hi"}, {"Name": "there"}], "the"), {"Name": "there"})
        self.assertEqual(get_item_fuzzy([{"Name": "hi"}, {"Name": "there"}], None), None)
        self.assertEqual(get_item_fuzzy(["hi", {"Name": "there"}], None), None)
        self.assertEqual(get_item_fuzzy([], "the"), None)
        self.assertEqual(get_item_fuzzy(None, "the"), None)
