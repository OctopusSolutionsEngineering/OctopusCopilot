import os
from urllib.parse import urlparse, urlencode, urlunsplit

from domain.validation.argument_validation import ensure_string_not_empty


def build_url(base_url, path, query=None):
    """
    Create a URL from the Octopus URL, additional path, and query params
    :param base_url: The Octopus URL
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    ensure_string_not_empty(
        base_url,
        "base_url must be the a base URL e.g. https://example.org (build_url).",
    )

    if path is None:
        path = ""

    parsed = urlparse(base_url)
    query = urlencode(query) if query is not None else ""

    if is_octopus_cloud_local_or_example(parsed):
        return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))

    # For everyone else, we have to route requests through the redirection service
    return urlunsplit(("https", os.environ.get("REDIRECTION_HOST"), path, query, ""))


def is_octopus_cloud_local_or_example(url):
    """
    Check if the URL is a cloud octopus URL, localhost, or the example domain
    :param url: The URL
    :return: True if the URL is a cloud octopus URL, localhost, or the example domain, and False otherwise
    """
    return (
        url.hostname.endswith(".octopus.app")
        or url.hostname.endswith(".testoctopus.com")
        or url.hostname == "localhost"
        or url.hostname == "example.org"
        or url.hostname == "127.0.0.1"
    )
