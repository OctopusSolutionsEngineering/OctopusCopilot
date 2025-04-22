import time
import unittest

import jwt

from domain.jwt.oidc import parse_jwt


class JwtTests(unittest.TestCase):
    def test_decoding(self):
        token = jwt.encode(
            {"sub": "1234567890", "name": "John Doe", "iat": 1516239022},
            "secret",
            algorithm="HS256",
        )
        decoded = parse_jwt(token)
        self.assertEqual(
            decoded, {"sub": "1234567890", "name": "John Doe", "iat": 1516239022}
        )

    def test_decoding_octopus_access(self):
        token = "eyJhbGciOiJQUzI1NiIsImtpZCI6IjA3N2IxYjViMjA0NTQyYzZhOWRiOTMxZTE2MzFlYjYyIiwidHlwIjoiSldUIn0.eyJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjgwODAiLCJpc3MiOiJodHRwOi8vbG9jYWxob3N0OjgwODAiLCJleHAiOjE3NDUyOTg3NzksImlhdCI6MTc0NTI5NTE3OSwibmJmIjoxNzQ1Mjk1MTc5LCJqdGkiOiIyNDJkMWQ0NjRkZjk0ZDNiYTAxNTlmMGYzZGZiNjg1ZiIsInN1YiI6IjQyNTdlN2NhLWM2ZTUtNDUyZC1hNGI0LTFmMWIzMGFkMjBjMyJ9.k3T0FOv3Brg6hMJSciOoUCt5H8Nptdh6f4rh0026k46p5EdrrK3ENLltOnFVr32uo8mh8HVR3pALmGKx1RZXhao5RgRi-Kslp-G7MpRsJBeIdEvtZOuujUdwIRVFjkZRbuIr_5JApPyP6ijfXYPGcgEvIg41QnVnrpemQK423hKMTc75ZD2yeyoarAY3EOJcjck5YDnXOtg8Q8awW8ohacS8orr-RyiYV2J1YTKAMm3bryYm-ZBGk9MbzV0IiC46WaBD4MvDWKY82T5aLc79OdJEIPkx2xW2WmU6e1lp8DiMkaLeIbe76c8EqSxc0JJBSHoFLcRdsAlgpfWAr9EvbQ"
        decoded = parse_jwt(token, test_expired=False)
        self.assertEqual(
            decoded,
            {
                "aud": "http://localhost:8080",
                "exp": 1745298779,
                "iat": 1745295179,
                "iss": "http://localhost:8080",
                "jti": "242d1d464df94d3ba0159f0f3dfb685f",
                "nbf": 1745295179,
                "sub": "4257e7ca-c6e5-452d-a4b4-1f1b30ad20c3",
            },
        )

    def test_expired(self):
        yesterday = time.time() - 24 * 60 * 60
        token = jwt.encode(
            {"sub": "1234567890", "name": "John Doe", "exp": yesterday},
            "secret",
            algorithm="HS256",
        )
        with self.assertRaises(jwt.ExpiredSignatureError):
            parse_jwt(token)

    def test_not_expired(self):
        tomorrow = time.time() + 24 * 60 * 60
        token = jwt.encode(
            {
                "sub": "1234567890",
                "name": "John Doe",
                "iat": 1516239022,
                "exp": tomorrow,
            },
            "secret",
            algorithm="HS256",
        )
        decoded = parse_jwt(token)
        self.assertEqual(
            decoded,
            {
                "sub": "1234567890",
                "name": "John Doe",
                "iat": 1516239022,
                "exp": tomorrow,
            },
        )
