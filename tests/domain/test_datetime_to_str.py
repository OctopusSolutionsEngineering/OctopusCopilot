import unittest
from datetime import datetime

from domain.transformers.date_convert import datetime_to_str


class TestDateTimeToStr(unittest.TestCase):
    def test_datetime_to_str_valid(self):
        dt = datetime(2023, 10, 5, 14, 30, 0)
        result = datetime_to_str(dt)
        self.assertEqual(result, "2023-10-05T14:30:00")

    def test_datetime_to_str_none(self):
        with self.assertRaises(ValueError):
            datetime_to_str(None)

    def test_datetime_to_str_empty_string(self):
        with self.assertRaises(ValueError):
            datetime_to_str("")

    def test_datetime_to_str_invalid_type(self):
        with self.assertRaises(ValueError):
            datetime_to_str("2023-10-05T14:30:00")
