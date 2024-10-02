import unittest

from domain.transformers.limit_array import (
    limit_array_to_max_char_length,
    limit_array_to_max_items,
    limit_text_in_array,
    count_non_empty_items,
    array_or_empty_if_exception,
    object_or_none_if_exception,
    object_or_default_if_exception,
)


class LimitArrayTest(unittest.TestCase):
    def test_limit_array_to_max_char_length(self):
        input = ["a", "b", "c", "d", "e"]
        result = limit_array_to_max_char_length(input, 3)
        self.assertTrue(result == ["a", "b", "c"], result)

    def test_limit_array_to_max_char_2(self):
        input = ["a", "b", "cd", "d", "e"]
        result = limit_array_to_max_char_length(input, 3)
        self.assertTrue(result == ["a", "b"], result)

    def test_limit_array_to_max_char_length_none(self):
        result = limit_array_to_max_char_length(None, 3)
        self.assertIsNone(result, result)

    def test_limit_array_to_max_items(self):
        self.assertEqual(limit_array_to_max_items(["a", "b", "c"], 2), ["a", "b"])
        self.assertEqual(limit_array_to_max_items(["a", "b", "c"], 5), ["a", "b", "c"])
        self.assertEqual(limit_array_to_max_items(["a", "b", "c"], 0), [])
        self.assertEqual(limit_array_to_max_items("not a list", 2), "not a list")

    def test_limit_text_in_array(self):
        self.assertEqual(limit_text_in_array(["abcdef", "ghijkl"], 3), ["abc", "ghi"])
        self.assertEqual(
            limit_text_in_array(["abcdef", "ghijkl"], 6), ["abcdef", "ghijkl"]
        )
        self.assertEqual(limit_text_in_array(["abcdef", 123], 3), ["abc", 123])
        self.assertEqual(limit_text_in_array("not a list", 3), "not a list")

    def test_count_non_empty_items(self):
        self.assertEqual(count_non_empty_items(["a", "", "b", [], ["c"]]), 3)
        self.assertEqual(count_non_empty_items(["", [], ""]), 0)
        self.assertEqual(count_non_empty_items("not a list"), 0)

    def test_array_or_empty_if_exception(self):
        self.assertEqual(array_or_empty_if_exception(Exception("error")), [])
        self.assertEqual(array_or_empty_if_exception(["a", "b"]), ["a", "b"])

    def test_object_or_none_if_exception(self):
        self.assertIsNone(object_or_none_if_exception(Exception("error")))
        self.assertEqual(object_or_none_if_exception("valid object"), "valid object")

    def test_object_or_default_if_exception(self):
        self.assertEqual(
            object_or_default_if_exception(Exception("error"), "default"), "default"
        )
        self.assertEqual(
            object_or_default_if_exception("valid object", "default"), "valid object"
        )
