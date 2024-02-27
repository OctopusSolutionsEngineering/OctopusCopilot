import unittest

from domain.encrption.encryption import generate_password, encrypt_eax, decrypt_eax


class EncryptionTests(unittest.TestCase):
    def test_encryption(self):
        text = "This is a test"
        password = generate_password("password", "salt")
        ciphered_data, tag, nonce = encrypt_eax(text, password, "salt")
        decrypted = decrypt_eax(password, ciphered_data, tag, nonce, "salt")

        self.assertEqual(decrypted.decode(), text)
