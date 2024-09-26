import unittest

from domain.transformers.clean_response import strip_before_first_curly_bracket


class CleanResponse(unittest.TestCase):
    def test_remove_prefix(self):
        url = strip_before_first_curly_bracket('Answer: {"key": "value"}')
        self.assertEqual('{"key": "value"}', url)

    def test_remove_suffix(self):
        url = strip_before_first_curly_bracket(
            'Answer: {"key": "value"} Some more text'
        )
        self.assertEqual('{"key": "value"}', url)

    def test_no_curly(self):
        url = strip_before_first_curly_bracket("Answer:")
        self.assertEqual("Answer:", url)

    def test_none(self):
        with self.assertRaises(ValueError):
            strip_before_first_curly_bracket(None)
