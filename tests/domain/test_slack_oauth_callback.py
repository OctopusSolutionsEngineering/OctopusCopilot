import unittest
from unittest.mock import patch, MagicMock

from function_app import slack_oauth_callback_internal


class TestSlackOAuthCallbackInternal(unittest.TestCase):
    @patch("function_app.http.request")
    @patch("function_app.extract_session_blob")
    @patch("function_app.get_github_user")
    @patch("function_app.save_users_slack_login")
    def test_slack_oauth_callback_internal_success(
        self,
        mock_save_users_slack_login,
        mock_get_github_user,
        mock_extract_session_blob,
        mock_http_request,
    ):
        # Mock the return values
        mock_http_request.return_value.status = 200
        mock_http_request.return_value.json.return_value = {
            "authed_user": {"access_token": "fake_slack_token"}
        }
        mock_extract_session_blob.return_value = "fake_github_token"
        mock_get_github_user.return_value = "fake_github_user_id"

        # Create a mock request
        req = MagicMock()
        req.params = {"code": "fake_code", "state": "fake_state"}
        req.headers = {"Cookie": "session=fake_session_blob"}

        # Call the function
        response = slack_oauth_callback_internal(req)

        # Assertions
        self.assertEqual(response.status_code, 200)
        self.assertIn("text/html", response.headers["Content-Type"])

    @patch("function_app.http.request")
    def test_slack_oauth_callback_internal_failure(self, mock_http_request):
        # Mock the return values
        mock_http_request.return_value.status = 400
        mock_http_request.return_value.data.decode.return_value = "Request failed"

        # Create a mock request
        req = MagicMock()
        req.params = {"code": "fake_code", "state": "fake_state"}
        req.headers = {"Cookie": "session=fake_session_blob"}

        # Call the function
        response = slack_oauth_callback_internal(req)

        # Assertions
        self.assertEqual(response.status_code, 500)
        self.assertIn("text/html", response.headers["Content-Type"])


if __name__ == "__main__":
    unittest.main()
