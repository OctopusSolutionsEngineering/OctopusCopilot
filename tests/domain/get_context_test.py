import unittest

from domain.transformers.text_to_context import (
    get_context_from_text_array,
    get_context_from_string,
)


class TestGetContextFromTextArray(unittest.TestCase):
    def test_get_context_from_text_array_valid(self):
        items = ["item1", "item2"]
        type = "example"
        result = get_context_from_text_array(items, type)
        expected = [
            ("system", "example: ###\nitem1\n###"),
            ("system", "example: ###\nitem2\n###"),
        ]
        self.assertEqual(result, expected)

    def test_get_context_from_text_array_empty_list(self):
        items = []
        type = "example"
        result = get_context_from_text_array(items, type)
        self.assertEqual(result, [])

    def test_get_context_from_text_array_none(self):
        items = None
        type = "example"
        result = get_context_from_text_array(items, type)
        self.assertEqual(result, [])

    def test_get_context_from_text_array_non_string_items(self):
        items = ["item1", 123, "item2"]
        type = "example"
        result = get_context_from_text_array(items, type)
        expected = [
            ("system", "example: ###\nitem1\n###"),
            ("system", "example: ###\nitem2\n###"),
        ]
        self.assertEqual(result, expected)

    def test_get_context_from_string_valid(self):
        item = "item1"
        type = "example"
        result = get_context_from_string(item, type)
        expected = [("system", "example: ###\nitem1\n###")]
        self.assertEqual(result, expected)

    def test_get_context_from_string_empty_string(self):
        item = ""
        type = "example"
        result = get_context_from_string(item, type)
        self.assertEqual(result, [])

    def test_get_context_from_string_none(self):
        item = None
        type = "example"
        result = get_context_from_string(item, type)
        self.assertEqual(result, [])

    def test_get_context_from_string_special_characters(self):
        item = "item1 {with} special characters"
        type = "example"
        result = get_context_from_string(item, type)
        expected = [("system", "example: ###\nitem1 {{with}} special characters\n###")]
        self.assertEqual(result, expected)
