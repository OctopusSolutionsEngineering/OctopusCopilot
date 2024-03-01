import unittest

from domain.b64.b64_encoder import encode_string_b64, decode_string_b64


class AdminUser(unittest.TestCase):
    def test_encoding(self):
        encoded = encode_string_b64('test')
        decoded = decode_string_b64(encoded)
        self.assertEqual('test', decoded)
