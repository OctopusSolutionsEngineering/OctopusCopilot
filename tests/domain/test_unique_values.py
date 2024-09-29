import unittest

from domain.sanitizers.sanitize_keywords import get_unique_values


class TestGetUniqueValues(unittest.TestCase):
    def test_get_unique_values_basic(self):
        input_list = ["apple", "banana", "apple", "orange"]
        result = get_unique_values(input_list)
        self.assertEqual(result, ["apple", "banana", "orange"])

    def test_get_unique_values_empty_list(self):
        input_list = []
        result = get_unique_values(input_list)
        self.assertEqual(result, [])

    def test_get_unique_values_no_duplicates(self):
        input_list = ["apple", "banana", "orange"]
        result = get_unique_values(input_list)
        self.assertEqual(result, ["apple", "banana", "orange"])

    def test_get_unique_values_all_duplicates(self):
        input_list = ["apple", "apple", "apple"]
        result = get_unique_values(input_list)
        self.assertEqual(result, ["apple"])

    def test_get_unique_values_mixed_types(self):
        input_list = ["apple", 1, "apple", 2, 1]
        result = get_unique_values(input_list)
        self.assertEqual(result, ["apple", 1, 2])

    def test_get_unique_values_none(self):
        input_list = None
        result = get_unique_values(input_list)
        self.assertEqual(result, [])
