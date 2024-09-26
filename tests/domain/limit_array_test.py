import unittest

import azure.functions as func

from domain.transformers.limit_array import limit_array_to_max_char_length
from domain.view.html.html_pages import get_redirect_page, get_login_page


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
