import os


def get_codefresh_url():
    """
    returns the url for the codefresh API control plane
    :return: The codefresh api url
    """
    default_value = "https://g.codefresh.io"
    url = os.environ.get("CODEFRESH_URL")
    return url.strip() if url and url.strip() else default_value
