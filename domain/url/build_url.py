import os
from urllib.parse import urlparse, urlencode, urlunsplit

from domain.validation.argument_validation import (
    ensure_string_not_empty,
    ensure_api_key,
)


def build_unredirected_url(base_url, path, query=None):
    """
    Create a URL from the URL, additional path, and query params. This URL is not redirected. This is used for services
    that are not behind the redirection service.
    :param base_url: The base URL
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

    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


def get_octopus_headers(api_key_or_access_token):
    """
    Build the headers used to make an Octopus API request. Also validate the API key to prevent
    clearly invalid keys from being used.
    :param api_key_or_access_token: The API key or access token
    :return: The headers required to call the Octopus API
    """

    ensure_api_key(
        api_key_or_access_token,
        "api_key_or_access_token must be the Octopus Api key (get_octopus_headers).",
    )

    if api_key_or_access_token.startswith("API-"):
        return {
            "X-Octopus-ApiKey": api_key_or_access_token,
            "User-Agent": "OctopusAI",
        }

    # Assume an access token instead
    return {
        "Authorization": "Bearer " + api_key_or_access_token,
        "User-Agent": "OctopusAI",
    }


def build_url(base_url, api_key, path, query=None):
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

    disable_redirector = (
        os.environ.get("REDIRECTION_DISABLE", "false").lower() == "true"
    )

    force_redirector = os.environ.get("REDIRECTION_FORCE", "false").lower() == "true"

    headers = get_octopus_headers(api_key) if api_key else {}

    redirector_headers = {
        "X_REDIRECTION_SERVICE_API_KEY": os.environ.get(
            "REDIRECTION_SERVICE_APIKEY", "Unknown"
        ),
        "X_REDIRECTION_UPSTREAM_HOST": parsed.hostname,
    }

    # Forcing the use of the redirector takes precedence over disabling it
    if not force_redirector and (
        disable_redirector or is_octopus_cloud_local_or_example(parsed)
    ):
        return urlunsplit((parsed.scheme, parsed.netloc, path, query, "")), headers

    # For everyone else, we have to route requests through the redirection service
    headers.update(redirector_headers)
    return (
        urlunsplit(("https", os.environ.get("REDIRECTION_HOST"), path, query, "")),
        headers,
    )


def is_octopus_cloud_local_or_example(url):
    """
    Check if the URL is a cloud octopus URL, localhost, or the example domain. We also consider
    ngrok domains to be cloud accessible.
    :param url: The URL
    :return: True if the URL is a cloud octopus URL, localhost, or the example domain, and False otherwise
    """
    return (
        url.hostname.endswith(".octopus.app")
        or url.hostname.endswith(".testoctopus.app")
        or url.hostname.endswith(".ngrok-free.app")
        or url.hostname.endswith(".ngrok.app")
        or url.hostname == "localhost"
        or url.hostname == "example.org"
        or url.hostname == "127.0.0.1"
        or url.hostname == "g.codefresh.io"
    )
