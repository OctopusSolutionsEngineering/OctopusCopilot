import unittest

from domain.jwt.oidc import parse_jwt


class JwtTests(unittest.TestCase):
    def test_decoding(self):
        decoded = parse_jwt(
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c")
        self.assertEqual(decoded, {'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022})
