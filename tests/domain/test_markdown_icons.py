import unittest
from domain.view.markdown.markdown_icons import (
    get_github_state_icon,
    get_state_icon,
    get_activity_log_state_icon,
)


class TestMarkdownIcons(unittest.TestCase):

    def test_get_github_state_icon(self):
        self.assertEqual(get_github_state_icon("in_progress", None), "🔵")
        self.assertEqual(get_github_state_icon("queued", None), "🟣")
        self.assertEqual(get_github_state_icon("completed", "success"), "🟢")
        self.assertEqual(get_github_state_icon("completed", "failure"), "🔴")
        self.assertEqual(get_github_state_icon("completed", "timed_out"), "🔴")
        self.assertEqual(get_github_state_icon("completed", "action_required"), "🟠")
        self.assertEqual(get_github_state_icon("completed", "cancelled"), "⚪")
        self.assertEqual(get_github_state_icon("completed", "neutral"), "⚪")
        self.assertEqual(get_github_state_icon("completed", "skipped"), "⚪")
        self.assertEqual(get_github_state_icon("completed", None), "⚪")

    def test_get_state_icon(self):
        self.assertEqual(get_state_icon("Executing", False, False), "🔵")
        self.assertEqual(get_state_icon("Success", False, False), "🟢")
        self.assertEqual(get_state_icon("Success", True, False), "🟡")
        self.assertEqual(get_state_icon("Failed", False, False), "🔴")
        self.assertEqual(get_state_icon("Canceled", False, False), "⚪")
        self.assertEqual(get_state_icon("TimedOut", False, False), "🔴")
        self.assertEqual(get_state_icon("Cancelling", False, False), "🔴")
        self.assertEqual(get_state_icon("Queued", False, False), "🟣")
        self.assertEqual(get_state_icon("Queued", False, True), "🟠")
        self.assertEqual(get_state_icon("Unknown", False, False), "⚪")

    def test_get_activity_log_state_icon(self):
        self.assertEqual(get_activity_log_state_icon("Running"), "🔵")
        self.assertEqual(get_activity_log_state_icon("SuccessWithWarning"), "🟡")
        self.assertEqual(get_activity_log_state_icon("Success"), "🟢")
        self.assertEqual(get_activity_log_state_icon("Failed"), "🔴")
        self.assertEqual(get_activity_log_state_icon("Canceled"), "⚪")
        self.assertEqual(get_activity_log_state_icon("TimedOut"), "🔴")
        self.assertEqual(get_activity_log_state_icon("Cancelling"), "🔴")
        self.assertEqual(get_activity_log_state_icon("Queued"), "🟣")
        self.assertEqual(get_activity_log_state_icon("Pending"), "⌛")
        self.assertEqual(get_activity_log_state_icon("Unknown"), "⚪")


if __name__ == "__main__":
    unittest.main()
