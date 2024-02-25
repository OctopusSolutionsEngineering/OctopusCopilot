import datetime
from urllib.parse import urlunsplit, urlparse, urlencode

import pytz
from retry import retry
from urllib3.exceptions import HTTPError

from domain.exceptions.request_failed import OctopusRequestFailed
from domain.exceptions.space_not_found import SpaceNotFound
from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http, TAKE_ALL

logger = configure_logging()


def get_octopus_headers(my_api_key):
    """
    Build the headers used to make an Octopus API request
    :param my_api_key: The function used to get the Octopus API key
    :return: The headers required to call the Octopus API
    """

    if my_api_key is None:
        raise ValueError('my_api_key must be the Octopus API key.')

    return {
        "X-Octopus-ApiKey": my_api_key
    }


def build_octopus_url(my_octopus_api, path, query=None):
    """
    Create a URL from the Octopus URL, additional path, and query params
    :param my_octopus_api: The Octopus URL
    :param path: The additional path
    :param query: Additional query params
    :return: The URL combining all the inputs
    """

    if my_octopus_api is None:
        raise ValueError('my_get_api_key must be the Octopus Url.')

    parsed = urlparse(my_octopus_api)
    query = urlencode(query) if query is not None else ""
    return urlunsplit((parsed.scheme, parsed.netloc, path, query, ""))


def get_space_id_and_name_from_name(space_name, my_api_key, my_octopus_api):
    """
    Gets a space ID and actual space name from a name extracted from a query.
    Note that we are quite lenient here in terms of whitespace and capitalisation.
    :param space_name: The name of the space
    :param my_octopus_api: The Octopus URL
    :param my_api_key: The Octopus API key
    :return: The space ID and actual name
    """

    logger.info("get_space_id_and_name_from_name - Enter")

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_space_id_and_name_from_name).')
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_space_id_and_name_from_name).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_space_id_and_name_from_name).')

    api = build_octopus_url(my_octopus_api, "api/spaces", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_octopus_headers(my_api_key))

    if resp.status != 200:
        raise OctopusRequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

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
def get_octopus_project_names_base(space_name, my_api_key, my_octopus_api):
    """
    The base function used to get a list of project names.
    :param space_name: The name of the Octopus space containing the projects
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of projects in the space
    """

    logger.info("get_octopus_project_names_base - Enter")

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_octopus_project_names_base).')
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_octopus_project_names_base).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_octopus_project_names_base).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, my_api_key, my_octopus_api)
    api = build_octopus_url(my_octopus_api, "api/" + space_id + "/Projects", dict(take=TAKE_ALL))
    resp = http.request("GET", api, headers=get_octopus_headers(my_api_key))

    if resp.status != 200:
        raise OctopusRequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

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


def get_current_user(my_api_key, my_octopus_api):
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_current_user).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_current_user).')

    api = build_octopus_url(my_octopus_api, "/api/users/me")
    resp = http.request("GET", api, headers=get_octopus_headers(my_api_key))
    if resp.status != 200:
        raise OctopusRequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()
    return json["Id"]


def create_limited_api_key(user, my_api_key, my_octopus_api):
    """
    This function creates an API key that expires tomorrow.
    :param user: The current user
    :param my_api_key: The API key
    :param my_octopus_api: The Octopus URL
    :return:
    """

    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (create_limited_api_key).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (create_limited_api_key).')

    tomorrow = datetime.datetime.now(pytz.UTC) + datetime.timedelta(days=1)

    api_key = {
        'Purpose': "Octopus Copilot temporary API key",
        'Expires': tomorrow.isoformat()
    }

    api = build_octopus_url(my_octopus_api, "/api/users/" + user + "/apikeys")
    resp = http.request("POST", api, json=api_key, headers=get_octopus_headers(my_api_key))
    if resp.status != 200:
        raise OctopusRequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

    json = resp.json()
    return json["ApiKey"]
