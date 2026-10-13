import os
import unittest
from unittest import mock

from domain.url.build_url import build_url


class TestGetRequestHeaders(unittest.TestCase):
    def setUp(self):
        # The redirector settings are read from the environment, and a shell configured for the remote tests sets
        # REDIRECTION_FORCE=true, which adds the redirector headers to cloud and local requests. Pin them to the defaults.
        patcher = mock.patch.dict(os.environ, {"REDIRECTION_FORCE": "false", "REDIRECTION_DISABLE": "false"})
        patcher.start()
        self.addCleanup(patcher.stop)

    def test_get_cloud_request_headers(self):
        api_key = "API-123456"
        octopus_url = "https://example.octopus.app"

        api, headers = build_url(octopus_url, api_key, "/")
        self.assertIsNotNone(headers.get("X-Octopus-ApiKey"))
        self.assertIsNone(headers.get("X_REDIRECTION_SERVICE_API_KEY"))

    def test_get_local_request_headers(self):
        api_key = "API-123456"
        octopus_url = "https://localhost"

        api, headers = build_url(octopus_url, api_key, "/")
        self.assertIsNotNone(headers.get("X-Octopus-ApiKey"))
        self.assertIsNone(headers.get("X_REDIRECTION_SERVICE_API_KEY"))

    def test_get_onprem_request_headers(self):
        api_key = "API-123456"
        octopus_url = "https://myinstance.com"

        api, headers = build_url(octopus_url, api_key, "/")
        self.assertIsNotNone(headers.get("X-Octopus-ApiKey"))
        self.assertIsNotNone(headers.get("X_REDIRECTION_SERVICE_API_KEY"))


if __name__ == "__main__":
    unittest.main()
