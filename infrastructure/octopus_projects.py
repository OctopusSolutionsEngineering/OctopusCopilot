import os
from urllib.parse import urlunsplit, urlparse, urlencode

import urllib3
from retry import retry
from urllib3.exceptions import HTTPError

from domain.exceptions.space_not_found import SpaceNotFound

TAKE_ALL = 10000
http = urllib3.PoolManager()


def get_api_key():
    return os.environ.get('OCTOPUS_CLI_API_KEY')


def get_octopus_api():
    return os.environ.get('OCTOPUS_CLI_SERVER')


def get_headers():
    return {
        "X-Octopus-ApiKey": get_api_key()
    }


def build_octopus_url(api, path, query):
    parsed = urlparse(api)
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


def get_space_id_from_name(space_name):
    api = build_octopus_url(get_octopus_api(), "api/spaces", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_headers())
    json = resp.json()

    filtered_spaces = list(filter(lambda s: s["Name"] == space_name, json["Items"]))
    if len(filtered_spaces) == 1:
        return filtered_spaces[0]["Id"]

    raise SpaceNotFound(f"No space with name '{space_name}' found")


@retry(HTTPError, tries=3, delay=2)
def get_octopus_project_names(space_name):
    """Return a list of project names in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """

    space_id = get_space_id_from_name(space_name)
    api = build_octopus_url(get_octopus_api(), "api/" + space_id + "/Projects", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_headers())
    json = resp.json()
    projects = list(map(lambda p: p["Name"], json["Items"]))

    return projects
