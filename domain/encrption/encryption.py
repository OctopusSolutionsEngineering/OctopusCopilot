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
    key = generate_key(password, salt)
    cipher = AES.new(key, AES.MODE_EAX)
    ciphered_data, tag = cipher.encrypt_and_digest(bytearray(api_key, encoding='utf-8'))
    return b64encode(ciphered_data).decode(), b64encode(tag).decode(), b64encode(cipher.nonce).decode()


def decrypt_eax(password, ciphered_data, tag, nonce, salt):
    key = generate_key(password, salt)
    cipher = AES.new(key, AES.MODE_EAX, b64decode(nonce))
    return cipher.decrypt_and_verify(b64decode(ciphered_data), b64decode(tag))
