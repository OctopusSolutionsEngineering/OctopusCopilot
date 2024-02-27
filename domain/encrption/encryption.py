import hashlib
import os

from Crypto.Cipher import AES
from Crypto.Protocol.KDF import PBKDF2


def generate_key(password):
    salt = os.environ.get("SALT")  # Salt you generated
    return PBKDF2(password, str.encode(salt), dkLen=32)


def generate_password(token):
    return hashlib.sha512(token + os.environ.get("SALT")).hexdigest()


def encrypt_eax(api_key, password):
    key = generate_key(password)
    cipher = AES.new(key, AES.MODE_EAX)
    ciphered_data, tag = cipher.encrypt_and_digest(api_key)
    return ciphered_data, tag, cipher.nonce


def decrypt_eax(password, ciphered_data, tag, nonce):
    key = generate_key(password)
    cipher = AES.new(key, AES.MODE_EAX, nonce)
    return cipher.decrypt_and_verify(ciphered_data, tag)
