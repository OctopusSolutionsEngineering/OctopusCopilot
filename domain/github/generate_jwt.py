import os
import time
import jwt

from domain.b64.b64_encoder import decode_string_b64


def generate_jwt_from_env():
    private_key = os.environ.get("GITHUB_APP_PRIVATEKEY")
    client_id = os.environ.get("GITHUB_CLIENT_ID")

    if private_key and client_id:
        private_key_decoded = decode_string_b64(private_key)
        return generate_github_jwt(private_key_decoded, client_id)

    return None


def generate_github_jwt(signing_key, client_id):
    """
    Generate a JWT (JSON Web Token) for GitHub App authentication.
    https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app
    :param signing_key: The GitHub app private key
    :param client_id: The GitHub app client ID
    :return: The generated JWT
    """
    payload = {
        # Issued at time
        "iat": int(time.time()),
        # JWT expiration time (10 minutes maximum)
        "exp": int(time.time()) + 600,
        # GitHub App's client ID
        "iss": client_id,
    }

    # Create JWT
    return jwt.encode(payload, signing_key, algorithm="RS256")
