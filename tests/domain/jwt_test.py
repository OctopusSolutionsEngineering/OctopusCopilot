import time
import unittest

import jwt

from domain.jwt.oidc import parse_jwt


class JwtTests(unittest.TestCase):
    def test_decoding(self):
        token = jwt.encode({'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022}, "secret", algorithm="HS256")
        decoded = parse_jwt(token)
        self.assertEqual(decoded, {'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022})

    def test_expired(self):
        yesterday = time.time() - 24 * 60 * 60
        token = jwt.encode({'sub': '1234567890', 'name': 'John Doe', 'exp': yesterday}, "secret", algorithm="HS256")
        with self.assertRaises(jwt.ExpiredSignatureError):
            parse_jwt(token)

    def test_not_expired(self):
        tomorrow = time.time() + 24 * 60 * 60
        token = jwt.encode({'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022, 'exp': tomorrow},
                           "secret",
                           algorithm="HS256")
        decoded = parse_jwt(token)
        self.assertEqual(decoded,
                         {'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022, 'exp': tomorrow})
