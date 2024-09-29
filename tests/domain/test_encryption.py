import unittest

from domain.encryption.encryption import generate_password, encrypt_eax, decrypt_eax


class EncryptionTests(unittest.TestCase):
    def test_encryption(self):
        text = "This is a test"
        password = generate_password("password", "salt")
        ciphered_data, tag, nonce = encrypt_eax(text, password, "salt")
        decrypted = decrypt_eax(password, ciphered_data, tag, nonce, "salt")

        self.assertEqual(decrypted, text)

    def test_bad_key(self):
        with self.assertRaises(ValueError):
            text = "This is a test"
            password = generate_password("password", "salt")
            password2 = generate_password("password2", "salt")
            ciphered_data, tag, nonce = encrypt_eax(text, password, "salt")
            decrypt_eax(password2, ciphered_data, tag, nonce, "salt")
