from urllib.parse import urlunsplit, urlparse, urlencode

import urllib3
from retry import retry
from urllib3.exceptions import HTTPError

from domain.exceptions.request_failed import RequestFailed
from domain.exceptions.space_not_found import SpaceNotFound

TAKE_ALL = 10000
http = urllib3.PoolManager()


def get_headers(my_get_api_key):
    return {
        "X-Octopus-ApiKey": my_get_api_key()
    }


def build_octopus_url(my_get_octopus_api, path, query):
    parsed = urlparse(my_get_octopus_api())
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


def get_space_id_from_name(space_name, my_get_octopus_api, my_get_api_key):
    api = build_octopus_url(my_get_octopus_api, "api/spaces", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_headers(my_get_api_key))

    if resp.status != 200:
        raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()

    filtered_spaces = list(filter(lambda s: s["Name"] == space_name, json["Items"]))
    if len(filtered_spaces) == 1:
        return filtered_spaces[0]["Id"]

    # try case-insensitive match and stripping and whitespace
    filtered_spaces = list(filter(lambda s: s["Name"].lower().strip() == space_name.lower().strip(), json["Items"]))
    if len(filtered_spaces) == 1:
        return filtered_spaces[0]["Id"]

    raise SpaceNotFound(f"No space with name '{space_name}' found")


@retry(HTTPError, tries=3, delay=2)
def get_octopus_project_names_base(space_name, my_get_api_key, my_get_octopus_api):
    space_id = get_space_id_from_name(space_name, my_get_octopus_api, my_get_api_key)
    api = build_octopus_url(my_get_octopus_api, "api/" + space_id + "/Projects", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_headers(my_get_api_key))
    json = resp.json()
    projects = list(map(lambda p: p["Name"], json["Items"]))

    return projects
