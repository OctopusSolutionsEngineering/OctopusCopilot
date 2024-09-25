import re


def is_valid_token(token):
    """
    Tests if a string is a valid codefresh token
    :param token: The value to test
    :return: True if the string is a codefresh token, False otherwise
    """
    if not token or not isinstance(token, str):
        return False

    pattern = r"[a-z0-9]{24}\.[a-z0-9]{32}"

    return re.match(pattern, token)
