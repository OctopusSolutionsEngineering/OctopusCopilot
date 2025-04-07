import os
from urllib.parse import urlparse

from domain.url.build_url import is_octopus_cloud_local_or_example


def get_redirect_headers(octopus_url):
    try:
        parsed = urlparse(octopus_url)
        if not is_octopus_cloud_local_or_example(parsed):
            return {
                "X_REDIRECTION_SERVICE_API_KEY": os.environ.get(
                    "REDIRECTION_SERVICE_APIKEY", "Unknown"
                ),
                "X_REDIRECTION_UPSTREAM_HOST": parsed.hostname,
            }
    except Exception:
        # If the URL is invalid, we don't need to add any headers.
        # This shouldn't happen, but some of the tests might not have a valid URL.
        pass

    return {}
