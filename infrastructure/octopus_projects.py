from urllib.parse import urlunsplit, urlparse, urlencode

from retry import retry
from urllib3.exceptions import HTTPError

from domain.exceptions.request_failed import RequestFailed
from domain.exceptions.space_not_found import SpaceNotFound
from infrastructure.http_pool import http, TAKE_ALL


def get_octopus_headers(my_get_api_key):
    """
    Build the headers used to make an Octopus API request
    :param my_get_api_key: The function used to get the Octopus API key
    :return: The headers required to call the Octopus API
    """

    if my_get_api_key is None:
        raise ValueError('my_get_api_key must be function returning the Octopus API key.')

    return {
        "X-Octopus-ApiKey": my_get_api_key()
    }


def build_octopus_url(my_get_octopus_api, path, query):
    """
    Create a URL from the Octopus URL, additional path, and query params
    :param my_get_octopus_api: The Octopus UR:
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    if my_get_octopus_api is None:
        raise ValueError('my_get_api_key must be function returning the Octopus Url.')

    parsed = urlparse(my_get_octopus_api())
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


def get_space_id_and_name_from_name(space_name, my_get_octopus_api, my_get_api_key):
    """
    Gets a space ID and actual space name from a name extracted from a query.
    Note that we are quite lenient here in terms of whitespace and capitalisation.
    :param space_name: The name of the space
    :param my_get_api_key: The function used to get the Octopus API key
    :param my_get_octopus_api: The function used to get the Octopus URL
    :return: The space ID and actual name
    """

    if not space_name or not isinstance(space_name, str) or not space_name.strip():
        raise ValueError('space_name must be a non-empty string.')

    if my_get_api_key is None:
        raise ValueError('my_get_api_key must be function returning the Octopus API key.')

    if my_get_octopus_api is None:
        raise ValueError('my_get_api_key must be function returning the Octopus Url.')

    api = build_octopus_url(my_get_octopus_api, "api/spaces", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_octopus_headers(my_get_api_key))

    if resp.status != 200:
        raise RequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()

    filtered_spaces = list(filter(lambda s: s["Name"] == space_name, json["Items"]))
    if len(filtered_spaces) == 1:
        return filtered_spaces[0]["Id"], filtered_spaces[0]["Name"]

    # try case-insensitive match and stripping and whitespace
    filtered_spaces = list(filter(lambda s: s["Name"].lower().strip() == space_name.lower().strip(), json["Items"]))
    if len(filtered_spaces) == 1:
        return filtered_spaces[0]["Id"], filtered_spaces[0]["Name"]

    raise SpaceNotFound(f"No space with name '{space_name}' found")


@retry(HTTPError, tries=3, delay=2)
def get_octopus_project_names_base(space_name, my_get_api_key, my_get_octopus_api):
    """
    The base function used to get a list of project names.
    :param space_name: The name of the Octopus space containing the projects
    :param my_get_api_key: The function used to get the Octopus API key
    :param my_get_octopus_api: The function used to get the Octopus URL
    :return: The list of projects in the space
    """

    if not space_name or not isinstance(space_name, str):
        raise ValueError('space_name must be a non-empty string.')

    if my_get_api_key is None:
        raise ValueError('my_get_api_key must be function returning the Octopus API key.')

    if my_get_octopus_api is None:
        raise ValueError('my_get_octopus_api must be function returning the Octopus Url.')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, my_get_octopus_api, my_get_api_key)
    api = build_octopus_url(my_get_octopus_api, "api/" + space_id + "/Projects", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_octopus_headers(my_get_api_key))
    json = resp.json()
    projects = list(map(lambda p: p["Name"], json["Items"]))

    return actual_space_name, projects


def get_octopus_project_names_response(space_name, projects):
    """
    Provides a conversational response to the list of projects
    :param space_name: The name of the space containing the projects
    :param projects: The list of projects
    :return: A conversational response
    """

    if not projects and (space_name is None or not space_name.strip()):
        return "I found no projects."

    if not projects:
        return f"I found no projects in the space {space_name}."

    if space_name is None or not space_name.strip():
        return f"I found {len(projects)} projects:\n* " + "\n * ".join(projects)

    return f"I found {len(projects)} projects in the space \"{space_name.strip()}\":\n* " + "\n* ".join(projects)
