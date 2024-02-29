from urllib.parse import urlparse, urlencode, urlunsplit


def build_url(base_url, path, query=None):
    """
    Create a URL from the Octopus URL, additional path, and query params
    :param base_url: The Octopus URL
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    if base_url is None:
        raise ValueError('base_url must be the a a base URL e.g. https://example.org.')

    parsed = urlparse(base_url)
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))
