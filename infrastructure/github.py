from urllib.parse import urlparse, urlencode, urlunsplit

from domain.exceptions.request_failed import RequestFailed
from infrastructure.http_pool import http


def get_github_headers(get_token):
    """
    Build the headers used to make an Octopus API request
    :param get_token: The function used to get theGithub token
    :return: The headers required to call the Octopus API
    """

    if get_token is None:
        raise ValueError('get_token must be function returning the Github token.')

    return {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "Authorization": "Bearer {}".format(get_token())
    }


def build_github_url(path, query):
    """
    Create a URL from the GitHub API URL, additional path, and query params
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    parsed = urlparse("https://api.github.com")
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


def get_github_user(get_token):
    """
    Gets the GitHub username from the supplied token
    :param get_token: The function used to get theGithub token
    :return: The GitHub username
    """

    if get_token is None:
        raise ValueError('get_token must be function returning the Github token.')

    api = build_github_url("user", "")

    resp = http.request("GET", api, headers=get_github_headers(get_token))

    if resp.status != 200:
        raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()

    return json["login"]
