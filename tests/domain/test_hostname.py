import unittest
from domain.url.hostname import get_hostname_from_url


class TestGetHostnameFromUrl(unittest.TestCase):
    def test_valid_url(self):
        self.assertEqual(
            get_hostname_from_url("https://example.com/path?query=123"), "example.com"
        )

    def test_url_without_hostname(self):
        self.assertIsNone(get_hostname_from_url("invalid-url"))

    def test_empty_string(self):
        self.assertIsNone(get_hostname_from_url(""))

    def test_none_input(self):
        self.assertIsNone(get_hostname_from_url(None))

    def test_url_with_subdomains(self):
        self.assertEqual(
            get_hostname_from_url("https://sub.example.com"), "sub.example.com"
        )


if __name__ == "__main__":
    unittest.main()
