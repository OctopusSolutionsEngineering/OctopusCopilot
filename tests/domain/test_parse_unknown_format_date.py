import unittest
from datetime import datetime, timezone, timedelta
from domain.date.parse_dates import parse_unknown_format_date, is_offset_aware


class TestParseDates(unittest.TestCase):
    def test_parse_unknown_format_date_with_timezone(self):
        date_string = "2023-10-01T12:00:00+00:00"
        expected_date = datetime(2023, 10, 1, 12, 0, 0, tzinfo=timezone.utc)
        self.assertEqual(parse_unknown_format_date(date_string), expected_date)

    def test_parse_unknown_format_date_without_timezone(self):
        date_string = "2023-10-01T12:00:00"
        expected_date = datetime(2023, 10, 1, 12, 0, 0, tzinfo=timezone.utc)
        self.assertEqual(parse_unknown_format_date(date_string), expected_date)

    def test_parse_unknown_format_date_invalid(self):
        date_string = "invalid-date"
        self.assertIsNone(parse_unknown_format_date(date_string))

    def test_is_offset_aware_with_timezone(self):
        date = datetime(2023, 10, 1, 12, 0, 0, tzinfo=timezone(timedelta(hours=1)))
        self.assertTrue(is_offset_aware(date))

    def test_is_offset_aware_without_timezone(self):
        date = datetime(2023, 10, 1, 12, 0, 0)
        self.assertFalse(is_offset_aware(date))


if __name__ == "__main__":
    unittest.main()
