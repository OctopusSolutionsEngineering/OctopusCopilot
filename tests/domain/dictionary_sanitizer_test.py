import unittest

from domain.sanitizers.dictionary_sanitizer import dictionary_has_value


class DictionarySanitizer(unittest.TestCase):
    def test_dictionary_sanitizer(self):
        value = dictionary_has_value("key", {"key": "value"})
        self.assertTrue(value)

    def test_key_not_present(self):
        value = dictionary_has_value("missing_key", {"key": "value"})
        self.assertFalse(value)

    def test_empty_dictionary(self):
        value = dictionary_has_value("key", {})
        self.assertFalse(value)

    def test_value_is_none(self):
        value = dictionary_has_value("key", {"key": None})
        self.assertFalse(value)

    def test_value_is_empty_string(self):
        value = dictionary_has_value("key", {"key": ""})
        self.assertFalse(value)

    def test_value_is_list(self):
        value = dictionary_has_value("key", {"key": []})
        self.assertFalse(value)

    def test_value_is_dict(self):
        value = dictionary_has_value("key", {"key": {}})
        self.assertFalse(value)
