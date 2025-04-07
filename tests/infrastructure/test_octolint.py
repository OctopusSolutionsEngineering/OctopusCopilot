import unittest
from infrastructure.octolint import redirections_enabled


class TestRedirectionsEnabled(unittest.TestCase):
    def test_redirections_enabled(self):
        self.assertTrue(redirections_enabled("some_redirection", "some_apikey"))
        self.assertFalse(redirections_enabled(None, "some_apikey"))
        self.assertFalse(redirections_enabled("some_redirection", None))
        self.assertFalse(redirections_enabled("", "some_apikey"))
        self.assertFalse(redirections_enabled("some_redirection", ""))
        self.assertFalse(redirections_enabled("", ""))
        self.assertFalse(redirections_enabled(" ", ""))
        self.assertFalse(redirections_enabled(" ", " "))


if __name__ == "__main__":
    unittest.main()
