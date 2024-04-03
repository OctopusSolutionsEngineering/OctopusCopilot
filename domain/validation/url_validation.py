from urllib.parse import urlparse


def validate_url(url):
    if not url or not isinstance(url, str):
        return False

    try:
        result = urlparse(url)
        # Strings like "blah" do parse correctly. But we only consider a URL valid if it has a scheme and a netloc
        return result.scheme and result.netloc
    except ValueError:
        return False
