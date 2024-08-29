import json

from domain.b64.b64_encoder import encode_string_b64, decode_string_b64
from domain.encryption.encryption import encrypt_eax, decrypt_eax, generate_password
from domain.validation.argument_validation import ensure_string_not_empty


def create_session_blob(session, password, salt):
    """
    Creates a session blob that can be stored client side.
    :param session: The session state
    :param password: An encryption password
    :param salt: An encryption salt
    :return: A base64 encoded json blob that has the encrypted state, tag, and nonce
    """

    ensure_string_not_empty(
        session, "state must be the session state to encrypt (create_session_blob)."
    )
    ensure_string_not_empty(
        password,
        "password must be the password used for encryption (create_session_blob).",
    )
    ensure_string_not_empty(
        salt, "salt must be the salt used for encryption (create_session_blob)."
    )

    salted_password = generate_password(password, salt)

    # Encrypt the user id
    encrypted_id, tag, nonce = encrypt_eax(session, salted_password, salt)

    # The session is persisted client side as an encrypted cookie that expires in a few hours. This is inspired by
    # Quarkus which uses client side state to support serverless web apps:
    # https://quarkus.io/guides/security-authentication-mechanisms#form-auth
    session = {"state": encrypted_id, "tag": tag, "nonce": nonce}
    return encode_string_b64(json.dumps(session))


def extract_session_blob(session, password, salt):
    """
    Extracts an encrypted session blob
    :param session:  The session json blob
    :param password: The password used for decryption
    :param salt: The salt used for decryption
    :return: The decrypted session state
    """
    ensure_string_not_empty(
        session, "state must be the session state to encrypt (extract_session_blob)."
    )
    ensure_string_not_empty(
        password,
        "password must be the password used for encryption (extract_session_blob).",
    )
    ensure_string_not_empty(
        salt, "salt must be the salt used for encryption (extract_session_blob)."
    )

    session = json.loads(decode_string_b64(session))
    return decrypt_eax(
        password, session["state"], session["tag"], session["nonce"], salt
    )
