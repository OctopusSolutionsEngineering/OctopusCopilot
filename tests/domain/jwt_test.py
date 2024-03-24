import unittest

import jwt

from domain.jwt.oidc import parse_jwt


class JwtTests(unittest.TestCase):
    def test_decoding(self):
        token = jwt.encode({'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022}, "secret", algorithm="HS256")
        decoded = parse_jwt(token)
        self.assertEqual(decoded, {'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022})
