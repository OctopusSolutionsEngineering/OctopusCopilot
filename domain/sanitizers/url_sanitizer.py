import urllib.parse


def quote_safe(string):
    """
    Safely quote a string to be included in a URL
    :param string: The string to be quoted
    :return: The URL quoted string
    """
    if not string:
        return ""

    if isinstance(string, str):
        return urllib.parse.quote(string, safe='')

    if isinstance(string, (int, float, complex, bool)):
        return str(string)

    # If something other than a string or number is passed, assume something
    # unsafe was passed in, and return an empty string
    return ""
