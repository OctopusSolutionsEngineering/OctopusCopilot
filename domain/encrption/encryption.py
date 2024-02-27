import hashlib
from base64 import b64encode, b64decode

from Crypto.Cipher import AES
from Crypto.Protocol.KDF import PBKDF2


def generate_key(password, salt):
    return PBKDF2(password, str.encode(salt), dkLen=32)


def generate_password(token, salt):
    m = hashlib.sha512()
    m.update(bytearray(token, encoding='utf-8'))
    m.update(bytearray(salt, encoding='utf-8'))
    return m.hexdigest()


def encrypt_eax(api_key, password, salt):
    """
    https://nitratine.net/blog/post/python-encryption-and-decryption-with-pycryptodome/#eax-example_1
    :param api_key: The api key to be encrypted
    :param password: The password (a hashed GitHub token)
    :param salt: The salt to apply to the encrypted value
    :return: The encrypted value, tag, and nonce (all base 64 encoded)
    """
    key = generate_key(password, salt)
    cipher = AES.new(key, AES.MODE_EAX)
    ciphered_data, tag = cipher.encrypt_and_digest(bytearray(api_key, encoding='utf-8'))
    return b64encode(ciphered_data).decode(), b64encode(tag).decode(), b64encode(cipher.nonce).decode()


def decrypt_eax(password, ciphered_data, tag, nonce, salt):
    """
    https://nitratine.net/blog/post/python-encryption-and-decryption-with-pycryptodome/#eax-example_1
    :param ciphered_data: The base 64 encoded api key
    :param password: The password (a hashed GitHub token)
    :param salt: The salt to apply to the encrypted value
    :param tag: The base 64 encoded tag generated during encryption
    :param nonce: The base 64 encoded nonce generated during encryption
    :return: The decrypted value
    """
    key = generate_key(password, salt)
    cipher = AES.new(key, AES.MODE_EAX, b64decode(nonce))
    return cipher.decrypt_and_verify(b64decode(ciphered_data), b64decode(tag))
