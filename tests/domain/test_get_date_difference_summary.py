import unittest

from domain.date.date_difference import get_date_difference_summary


class DateDifferenceTest(unittest.TestCase):
    def test_date_difference_day(self):
        from datetime import datetime
        date1 = datetime(2024, 1, 1)
        date2 = datetime(2024, 1, 2)
        difference = date2 - date1

        self.assertEqual("1 day", get_date_difference_summary(difference))

    def test_date_difference_days(self):
        from datetime import datetime
        date1 = datetime(2024, 1, 1)
        date2 = datetime(2024, 1, 31)
        difference = date2 - date1

        self.assertEqual("30 days", get_date_difference_summary(difference))

    def test_date_difference_hour(self):
        from datetime import datetime
        date1 = datetime(2024, 1, 1, 1, 1, 1)
        date2 = datetime(2024, 1, 1, 2, 1, 1)
        difference = date2 - date1

        self.assertEqual("60 minutes", get_date_difference_summary(difference))

    def test_date_difference_hours(self):
        from datetime import datetime
        date1 = datetime(2024, 1, 1, 1, 1, 1)
        date2 = datetime(2024, 1, 1, 3, 1, 1)
        difference = date2 - date1

        self.assertEqual("2 hours", get_date_difference_summary(difference))

    def test_date_difference_minutes(self):
        from datetime import datetime
        date1 = datetime(2024, 1, 1, 1, 1, 1)
        date2 = datetime(2024, 1, 1, 1, 3, 1)
        difference = date2 - date1

        self.assertEqual("2 minutes", get_date_difference_summary(difference))

    def test_date_difference_second(self):
        from datetime import datetime
        date1 = datetime(2024, 1, 1, 1, 1, 1)
        date2 = datetime(2024, 1, 1, 1, 1, 2)
        difference = date2 - date1

        self.assertEqual("1 second", get_date_difference_summary(difference))

    def test_date_difference_seconds(self):
        from datetime import datetime
        date1 = datetime(2024, 1, 1, 1, 1, 1)
        date2 = datetime(2024, 1, 1, 1, 1, 3)
        difference = date2 - date1

        self.assertEqual("2 seconds", get_date_difference_summary(difference))
