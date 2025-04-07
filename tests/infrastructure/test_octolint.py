import os
import unittest
from unittest.mock import patch

from infrastructure.octolint import redirections_enabled, get_headers, get_api


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

    @patch.dict(os.environ, {"APPLICATION_OCTOLINT_URL": "https://example.com"})
    def test_get_headers_without_redirections(self):
        headers = get_headers(
            use_redirections=False,
            api_key="test_api_key",
            octopus_url="https://octopus.example.com",
            access_token="test_access_token",
            redirections=None,
            redirections_apikey=None,
        )
        expected_headers = {
            "X-Octopus-ApiKey": "test_api_key",
            "X-Octopus-Url": "https://octopus.example.com",
            "X-Octopus-AccessToken": "test_access_token",
        }
        self.assertEqual(headers, expected_headers)

    @patch.dict(
        os.environ,
        {
            "APPLICATION_OCTOLINT_URL": "https://example.com",
            "REDIRECTION_SERVICE_APIKEY": "test_service_apikey",
        },
    )
    def test_get_headers_with_redirections(self):
        headers = get_headers(
            use_redirections=True,
            api_key="test_api_key",
            octopus_url="https://octopus.example.com",
            access_token="test_access_token",
            redirections="test_redirections",
            redirections_apikey="test_redirections_apikey",
        )
        expected_headers = {
            "X-Octopus-ApiKey": "test_api_key",
            "X-Octopus-Url": "https://octopus.example.com",
            "X-Octopus-AccessToken": "test_access_token",
            "X_REDIRECTION_REDIRECTIONS": "test_redirections",
            "X_REDIRECTION_UPSTREAM_HOST": "example.com",
            "X_REDIRECTION_API_KEY": "test_redirections_apikey",
            "X_REDIRECTION_SERVICE_API_KEY": "test_service_apikey",
        }
        self.assertEqual(headers, expected_headers)

    @patch.dict(os.environ, {"APPLICATION_OCTOLINT_URL": "https://example.com"})
    def test_get_api_without_redirections(self):
        api_url = get_api(use_redirections=False)
        self.assertEqual(api_url, "https://example.com/api/octolint")

    @patch.dict(os.environ, {"REDIRECTION_HOST": "redirection.example.com"})
    def test_get_api_with_redirections(self):
        api_url = get_api(use_redirections=True)
        self.assertEqual(api_url, "https://redirection.example.com/api/octolint")


if __name__ == "__main__":
    unittest.main()
