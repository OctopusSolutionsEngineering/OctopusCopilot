import unittest

from domain.sanitizers.escape_messages import escape_message


class TestEscapeMessage(unittest.TestCase):
    def test_escape_message_no_special_characters(self):
        message = "This is a test message."
        result = escape_message(message)
        self.assertEqual(result, "This is a test message.")

    def test_escape_message_with_curly_braces(self):
        message = "This is a {test} message."
        result = escape_message(message)
        self.assertEqual(result, "This is a {{test}} message.")

    def test_escape_message_with_multiple_curly_braces(self):
        message = "This {is} a {test} message."
        result = escape_message(message)
        self.assertEqual(result, "This {{is}} a {{test}} message.")

    def test_escape_message_empty_string(self):
        message = ""
        result = escape_message(message)
        self.assertEqual(result, "")

    def test_escape_message_only_curly_braces(self):
        message = "{}"
        result = escape_message(message)
        self.assertEqual(result, "{{}}")
