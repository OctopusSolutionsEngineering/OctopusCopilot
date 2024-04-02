import re
from urllib.parse import urlparse


def is_hosted_octopus(octopus_url):
    """
    Validates that a string is a cloud octopus URL
    :param octopus_url:
    :return: True if the URL is valid and false otherwise
    """
    if not octopus_url:
        return False

    parsed_url = urlparse(octopus_url.strip())
    return parsed_url.netloc.endswith(".octopus.app") or parsed_url.netloc.endswith(".testoctopus.app")


def is_api_key(api_key):
    if not api_key or not isinstance(api_key, str):
        return False

    pattern = r"API-[A-Z0-9a-z]+"

    return re.match(pattern, api_key)
