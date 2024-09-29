import os
import os
import unittest

import azure.functions as func

from domain.encryption.encryption import generate_password
from domain.requests.github.copilot_request_context import get_github_token
from domain.url.session import create_session_blob


class GitHubTokenTests(unittest.TestCase):
    def test_extract_regular_token(self):
        token = get_github_token(
            func.HttpRequest(
                method="GET",
                url="https://example.org",
                body="".encode("utf8"),
                headers={"X-GitHub-Token": "TestToken"},
            )
        )

        self.assertEqual(token, "TestToken")

    def test_extract_encrypted_token(self):
        session_json = create_session_blob(
            "EncryptedToken",
            os.environ.get("ENCRYPTION_PASSWORD"),
            os.environ.get("ENCRYPTION_SALT"),
        )

        token = get_github_token(
            func.HttpRequest(
                method="GET",
                url="https://example.org",
                body="".encode("utf8"),
                headers={"X-GitHub-Encrypted-Token": session_json},
            )
        )

        self.assertEqual(token, "EncryptedToken")
