import unittest
from infrastructure.octopus import get_request_headers


class TestGetRequestHeaders(unittest.TestCase):
    def test_get_cloud_request_headers(self):
        api_key = "API-123456"
        octopus_url = "https://example.octopus.app"

        headers = get_request_headers(api_key, octopus_url)
        self.assertIsNotNone(headers.get("X-Octopus-ApiKey"))
        self.assertIsNone(headers.get("X_REDIRECTION_SERVICE_API_KEY"))

    def test_get_local_request_headers(self):
        api_key = "API-123456"
        octopus_url = "https://localhost"

        headers = get_request_headers(api_key, octopus_url)
        self.assertIsNotNone(headers.get("X-Octopus-ApiKey"))
        self.assertIsNone(headers.get("X_REDIRECTION_SERVICE_API_KEY"))

    def test_get_onprem_request_headers(self):
        api_key = "API-123456"
        octopus_url = "https://myinstance.com"

        headers = get_request_headers(api_key, octopus_url)
        self.assertIsNotNone(headers.get("X-Octopus-ApiKey"))
        self.assertIsNotNone(headers.get("X_REDIRECTION_SERVICE_API_KEY"))


if __name__ == "__main__":
    unittest.main()
