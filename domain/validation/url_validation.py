from urllib.parse import urlparse


def validate_url(url):
    """
    Tests that the string is a valid URL
    :param url: The value to test
    :return: True if the string is a URL and False otherwise
    """
    if not url or not isinstance(url, str):
        return False

    try:
        result = urlparse(url)
        # Strings like "blah" do parse correctly. But we only consider a URL valid if it has a scheme and a netloc
        return result.scheme and result.netloc
    except ValueError:
        return False
