import unittest

from domain.counters.counters import count_items_with_data


class CountItemsWithDataTest(unittest.TestCase):
    def test_count_items_with_data_empty_list(self):
        self.assertEqual(0, count_items_with_data([]))

    def test_count_items_with_data_no_exceptions_or_empty(self):
        self.assertEqual(3, count_items_with_data(["a", "b", "c"]))

    def test_count_items_with_data_with_exceptions(self):
        self.assertEqual(2, count_items_with_data(["a", Exception(), "b", Exception()]))

    def test_count_items_with_data_with_empty_strings(self):
        self.assertEqual(2, count_items_with_data(["a", "", "b", ""]))

    def test_count_items_with_data_with_mixed(self):
        self.assertEqual(2, count_items_with_data(["a", "", Exception(), "b", ""]))

    def test_count_items_with_data_all_exceptions(self):
        self.assertEqual(0, count_items_with_data([Exception(), Exception()]))

    def test_count_items_with_data_all_empty(self):
        self.assertEqual(0, count_items_with_data(["", "", ""]))

    def test_count_items_with_data_none(self):
        self.assertEqual(0, count_items_with_data(None))


if __name__ == "__main__":
    unittest.main()
