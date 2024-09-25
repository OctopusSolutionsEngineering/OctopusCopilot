import os


def get_codefresh_url():
    """
    returns the url for the codefresh API control plane
    :return: The codefresh api url
    """
    return os.environ.get("CODEFRESH_URL", "https://g.codefresh.io")
