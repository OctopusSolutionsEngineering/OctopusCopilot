import unittest

from domain.encryption.encryption import generate_password
from domain.url.session import create_session_blob, extract_session_blob


class EnsureTests(unittest.TestCase):
    def test_session_blob(self):
        session = create_session_blob("my state", "password", "salt")
        state = extract_session_blob(
            session, generate_password("password", "salt"), "salt"
        )
        self.assertEqual(state, "my state")
