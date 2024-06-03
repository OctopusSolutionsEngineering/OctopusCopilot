import urllib.parse


def quote_safe(string):
    """
    Safely quote a string to be included in a URL
    :param string: The string to be quoted
    :return: The URL quoted string
    """
    return urllib.parse.quote(string, safe='')
