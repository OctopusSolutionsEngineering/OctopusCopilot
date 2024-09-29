import unittest

from domain.sanitizers.sanitized_list import sanitize_log_lines


class SanitizeLogLinesTest(unittest.TestCase):
    def test_sanitize(self):
        self.assertEqual(sanitize_log_lines(1, "Get 1 line from logs"), 1)
        self.assertEqual(sanitize_log_lines(1, "Get 2 lines from logs"), None)
        self.assertEqual(sanitize_log_lines(None, "Get 2 lines from logs"), None)
