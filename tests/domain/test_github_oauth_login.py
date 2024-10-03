import unittest
from unittest.mock import patch, MagicMock
from function_app import oauth_callback, oauth_callback_internal


class TestOAuthCallback(unittest.TestCase):
    @patch("function_app.exchange_github_code")
    @patch("function_app.create_session_blob")
    @patch("function_app.get_redirect_page")
    @patch("function_app.base_request_url")
    @patch("function_app.get_cookie_expiration")
    def test_oauth_callback_success(
        self,
        mock_get_cookie_expiration,
        mock_base_request_url,
        mock_get_redirect_page,
        mock_create_session_blob,
        mock_exchange_github_code,
    ):
        # Mock the return values
        mock_exchange_github_code.return_value = "fake_access_token"
        mock_create_session_blob.return_value = "fake_session_blob"
        mock_base_request_url.return_value = "http://example.com"
        mock_get_redirect_page.return_value = "Redirecting..."
        mock_get_cookie_expiration.return_value = "Wed, 21 Oct 2020 07:28:00 GMT"

        # Create a mock request
        req = MagicMock()
        req.params = {"code": "fake_code", "state": "redirect_state"}
        req.headers = {}

        # Call the function
        response = oauth_callback_internal(req)

        # Assertions
        self.assertEqual(response.status_code, 200)
        self.assertIn("Redirecting...", response.get_body().decode())
        self.assertIn("Set-Cookie", response.headers)
        self.assertIn("session=fake_session_blob", response.headers["Set-Cookie"])

    @patch("function_app.exchange_github_code")
    @patch("function_app.create_session_blob")
    @patch("function_app.get_redirect_page")
    @patch("function_app.base_request_url")
    @patch("function_app.get_cookie_expiration")
    def test_oauth_callback_failure(
        self,
        mock_get_cookie_expiration,
        mock_base_request_url,
        mock_get_redirect_page,
        mock_create_session_blob,
        mock_exchange_github_code,
    ):
        # Mock the return values
        mock_exchange_github_code.side_effect = Exception("GitHub exchange failed")

        # Create a mock request
        req = MagicMock()
        req.params = {"code": "fake_code", "state": "redirect_state"}
        req.headers = {}

        # Call the function
        response = oauth_callback_internal(req)

        # Assertions
        self.assertEqual(response.status_code, 500)


if __name__ == "__main__":
    unittest.main()
