import unittest

from domain.transformers.clean_response import strip_before_first_curly_bracket


class TestStripBeforeFirstCurlyBracket(unittest.TestCase):
    def test_strip_before_first_curly_bracket_basic(self):
        text = "Answer: {\"key\": \"value\"}"
        result = strip_before_first_curly_bracket(text)
        self.assertEqual(result, "{\"key\": \"value\"}")

    def test_strip_before_first_curly_bracket_no_curly_bracket(self):
        text = "Answer: No JSON here"
        result = strip_before_first_curly_bracket(text)
        self.assertEqual(result, "Answer: No JSON here")

    def test_strip_before_first_curly_bracket_empty_string(self):
        text = ""
        result = strip_before_first_curly_bracket(text)
        self.assertEqual(result, "")

    def test_strip_before_first_curly_bracket_none(self):
        with self.assertRaises(ValueError):
            strip_before_first_curly_bracket(None)

    def test_strip_before_first_curly_bracket_trailing_text(self):
        text = "Answer: {\"key\": \"value\"} Some trailing text"
        result = strip_before_first_curly_bracket(text)
        self.assertEqual(result, "{\"key\": \"value\"}")

    def test_strip_before_first_curly_bracket_multiple_curly_brackets(self):
        text = "Answer: {\"key\": {\"nested_key\": \"nested_value\"}}"
        result = strip_before_first_curly_bracket(text)
        self.assertEqual(result, "{\"key\": {\"nested_key\": \"nested_value\"}}")

    def test_strip_after_first_curly_bracket_multiple_curly_brackets(self):
        text = "Answer: {\"key\": {\"nested_key\": \"nested_value\"}} some debug text here"
        result = strip_before_first_curly_bracket(text)
        self.assertEqual(result, "{\"key\": {\"nested_key\": \"nested_value\"}}")
