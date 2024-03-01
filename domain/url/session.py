import json

from domain.b64.b64_encoder import encode_string_b64, decode_string_b64
from domain.encrption.encryption import encrypt_eax, decrypt_eax


def create_session_blob(state, password, salt):
    """
    Creates a session blob that can be stored client side.
    :param state: The session state
    :param password: An encryption password
    :param salt: An encryption salt
    :return: A base64 encoded json blob that has the encrypted state, tag, and nonce
    """

    # Encrypt the user id
    encrypted_id, tag, nonce = encrypt_eax(state, password, salt)

    # The session is persisted client side as an encrypted cookie that expires in a few hours. This is inspired by
    # Quarkus which uses client side state to support serverless web apps:
    # https://quarkus.io/guides/security-authentication-mechanisms#form-auth
    session = {
        "state": encrypted_id,
        "tag": tag,
        "nonce": nonce
    }
    return encode_string_b64(json.dumps(session))


def extract_session_blob(session, password, salt):
    session = json.loads(decode_string_b64(session))
    return decrypt_eax(password,
                       session["state"],
                       session["tag"],
                       session["nonce"],
                       salt)
