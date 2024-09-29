import unittest
from domain.sanitizers.sanitize_prompt import sanitize_prompt


class TestSanitizePrompt(unittest.TestCase):
    def test_remove_octopus_prefix(self):
        self.assertEqual(
            sanitize_prompt("@octopus-ai-app This is a test prompt."),
            " This is a test prompt.",
        )

    def test_no_prefix(self):
        self.assertEqual(
            sanitize_prompt("This is a test prompt."), "This is a test prompt."
        )

    def test_empty_string(self):
        self.assertEqual(sanitize_prompt(""), "")

    def test_none_input(self):
        self.assertEqual(sanitize_prompt(None), "")

    def test_prefix_in_middle(self):
        self.assertEqual(
            sanitize_prompt("This is a @octopus-ai-app test prompt."),
            "This is a @octopus-ai-app test prompt.",
        )
