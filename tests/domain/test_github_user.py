import unittest
from domain.sanitizers.github_user import get_github_user_for_callback


class GitHubUserTest(unittest.TestCase):
    def test_get_redirect_page(self):
        # Test with a valid GitHub user
        self.assertTrue(get_github_user_for_callback("  TestUser  ") == "testuser")

        # Test with an empty string
        self.assertTrue(get_github_user_for_callback("") == "Unknown")

        # Test with None
        self.assertTrue(get_github_user_for_callback(None) == "Unknown")

        # Test with a string containing only spaces
        self.assertTrue(get_github_user_for_callback("   ") == "Unknown")
