import os


def get_codefresh_url():
    """
    returns the url for the codefresh API control plane
    :return: The codefresh api url
    """
    default_value = "https://g.codefresh.io"
    url = os.environ.get("CODEFRESH_URL", default_value)
    return url if url else default_value
