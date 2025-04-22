from urllib.parse import urlparse


def get_hostname_from_url(url):
    if not url:
        return None

    try:
        parsed_url = urlparse(url)
        return parsed_url.hostname
    except Exception:
        return None
