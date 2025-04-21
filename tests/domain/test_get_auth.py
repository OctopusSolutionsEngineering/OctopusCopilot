import unittest
from domain.octopus.authorization import get_auth


class TestGetAuth(unittest.TestCase):
    def test_get_auth_with_api_key(self):
        api_key, access_token = get_auth("api-12345")
        self.assertEqual(api_key, "api-12345")
        self.assertEqual(access_token, "")

    def test_get_auth_with_api_key_upper(self):
        api_key, access_token = get_auth("API-12345")
        self.assertEqual(api_key, "API-12345")
        self.assertEqual(access_token, "")

    def test_get_auth_with_access_token(self):
        api_key, access_token = get_auth("67890")
        self.assertEqual(api_key, "")
        self.assertEqual(access_token, "67890")

    def test_get_auth_with_whitespace(self):
        api_key, access_token = get_auth("   api-12345   ")
        self.assertEqual(api_key, "api-12345")
        self.assertEqual(access_token, "")

    def test_get_auth_empty_string(self):
        api_key, access_token = get_auth("")
        self.assertEqual(api_key, "")
        self.assertEqual(access_token, "")


if __name__ == "__main__":
    unittest.main()
