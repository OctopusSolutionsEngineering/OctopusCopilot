import datetime
import json

import pytz
from fuzzywuzzy import fuzz
from retry import retry
from urllib3.exceptions import HTTPError

from domain.config.openai import max_context
from domain.converters.string_to_int import string_to_int
from domain.exceptions.request_failed import OctopusRequestFailed
from domain.exceptions.resource_not_found import ResourceNotFound
from domain.exceptions.runbook_not_published import RunbookNotPublished
from domain.exceptions.space_not_found import SpaceNotFound
from domain.exceptions.user_not_loggedin import OctopusApiKeyInvalid
from domain.logging.app_logging import configure_logging
from domain.query.query_inspector import release_is_latest
from domain.sanitizers.sanitized_list import get_item_fuzzy, normalize_log_step_name
from domain.sanitizers.url_sanitizer import quote_safe
from domain.url.build_url import build_url
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http, TAKE_ALL

logger = configure_logging()
channel_cache = {}
tenant_cache = {}
environment_cache = {}


def logging_wrapper(func):
    def wrapper(*args, **kwargs):
        try:
            print(func.__name__ + " Enter")
            return func(*args, **kwargs)
        finally:
            print(func.__name__ + " Exit")

    return wrapper


def get_octopus_headers(my_api_key):
    """
    Build the headers used to make an Octopus API request
    :param my_api_key: The function used to get the Octopus API key
    :return: The headers required to call the Octopus API
    """

    if my_api_key is None:
        raise ValueError('my_api_key must be the Octopus API key.')

    return {
        "X-Octopus-ApiKey": my_api_key,
        "User-Agent": "OctopusAI",
    }


@logging_wrapper
def get_space_first_project_and_environment(space_id, api_key, url):
    space_first_project = next(get_projects_generator(space_id, api_key, url), None)
    space_first_environment = next(get_environments_generator(space_id, api_key, url), None)

    # The first space we find with projects and environments is used as the example
    if space_first_project and space_first_environment:
        return space_first_project, space_first_environment

    return None, None


@logging_wrapper
def get_space_id_and_name_from_name(space_name, my_api_key, my_octopus_api):
    """
    Gets a space ID and actual space name from a name extracted from a query.
    Note that we are quite lenient here in terms of whitespace and capitalisation.
    :param space_name: The name of the space
    :param my_octopus_api: The Octopus URL
    :param my_api_key: The Octopus API key
    :return: The space ID and actual name
    """

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_space_id_and_name_from_name).')
    ensure_string_not_empty(my_octopus_api,
                            'my_octopus_api must be the Octopus Url (get_space_id_and_name_from_name).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_space_id_and_name_from_name).')

    api = build_url(my_octopus_api, "api/spaces", dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))
    json = resp.json()

    filtered_spaces = list(filter(lambda s: s["Name"] == space_name, json["Items"]))
    if len(filtered_spaces) == 1:
        return filtered_spaces[0]["Id"], filtered_spaces[0]["Name"]

    # try case-insensitive match and stripping and whitespace
    filtered_spaces = list(filter(lambda s: s["Name"].lower().strip() == space_name.lower().strip(), json["Items"]))
    if len(filtered_spaces) == 1:
        return filtered_spaces[0]["Id"], filtered_spaces[0]["Name"]

    raise SpaceNotFound(space_name)


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_version(octopus_url):
    api = build_url(octopus_url, "api")
    resp = handle_response(lambda: http.request("GET", api))
    return resp.json()["Version"]


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_spaces_batch(skip, take, api_key, octopus_url):
    api = build_url(octopus_url, "api/Spaces", dict(take=take, skip=skip))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()["Items"]


@logging_wrapper
def get_spaces_generator(api_key, octopus_url):
    skip = 0
    take = 30

    while True:
        batch_spaces = get_spaces_batch(skip, take, api_key, octopus_url)

        for space in batch_spaces:
            yield space

        if len(batch_spaces) != take:
            break

        skip += take


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_octopus_project_names_base(space_name, my_api_key, my_octopus_api):
    """
    The base function used to get a list of project names.
    :param space_name: The name of the Octopus space containing the projects
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of projects in the space
    """
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_octopus_project_names_base).')
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_octopus_project_names_base).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_octopus_project_names_base).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, my_api_key, my_octopus_api)

    api = build_url(my_octopus_api, f"api/{quote_safe(space_id)}/Projects", dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    projects = list(map(lambda p: p["Name"], json["Items"]))

    return actual_space_name, projects


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_dashboard(space_id, my_api_key, my_octopus_api):
    """
    The base function used to get the dashboard summary
    :param space_id: The id of the Octopus space containing the projects
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The actual space name and the dashboard summary
    """

    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_dashboard).')
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_dashboard).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_dashboard).')

    api = build_url(my_octopus_api, f"api/{quote_safe(space_id)}/Dashboard",
                    dict(highestLatestVersionPerProjectAndEnvironment="true"))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    return resp.json()


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_runbooks_dashboard(space_id, runbook_id, my_api_key, my_octopus_api):
    """
    The base function used to get the runbooks dashboard summary
    :param space_id: The id of the Octopus space containing the runbook
    :param runbook_id: The id of the runbook
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The actual space name and the dashboard summary
    """

    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_runbooks_dashboard).')
    ensure_string_not_empty(runbook_id, 'runbook_id must be a non-empty string (get_runbooks_dashboard).')
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_runbooks_dashboard).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_runbooks_dashboard).')

    api = build_url(my_octopus_api, f"api/{quote_safe(space_id)}/progression/runbooks/{quote_safe(runbook_id)}")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    return resp.json()


@logging_wrapper
def get_current_user(my_api_key, my_octopus_api):
    """
    Returns the ID of the octopus user. This can be used to verify an API key, as even Octopus users with
    no permissions can access this endpoint.
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The Octopus user ID
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_current_user).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_current_user).')

    api = build_url(my_octopus_api, "/api/users/me")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Id"]


@logging_wrapper
@retry(HTTPError, tries=3, delay=2)
def get_projects(space_id, my_api_key, my_octopus_api):
    """
    Returns the projects in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of projects
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_projects).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_projects).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_projects).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Projects", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
@retry(HTTPError, tries=3, delay=2)
def get_tenants(space_id, my_api_key, my_octopus_api):
    """
    Returns the tenants in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of tenants
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_tenants).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_tenants).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_tenants).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Tenants", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_feeds(my_api_key, my_octopus_api, space_id):
    """
    Returns the feeds in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of feeds
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_feeds).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_feeds).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_feeds).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Feeds", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_accounts(my_api_key, my_octopus_api, space_id):
    """
    Returns the accounts in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of accounts
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_accounts).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_accounts).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_accounts).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Accounts", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_machines(my_api_key, my_octopus_api, space_id):
    """
    Returns the machines in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of machines
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_machines).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_machines).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_machines).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Machines", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_certificates(my_api_key, my_octopus_api, space_id):
    """
    Returns the certificate in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of certificate
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_certificates).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_certificates).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_certificates).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Certificates", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_environments(my_api_key, my_octopus_api, space_id):
    """
    Returns the environments in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of environments
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_environments).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_environments).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_environments).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Environments", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_tenants(my_api_key, my_octopus_api, space_id):
    """
    Returns the environments in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of environments
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_environments).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_environments).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_environments).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Tenants", query=dict(take=TAKE_ALL))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_project_channel(my_api_key, my_octopus_api, space_id, project_id):
    """
    Returns the channels associated with a project
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The channels associated with the project
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_project_channel).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_project_channel).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_project_channel).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Projects/{quote_safe(project_id)}/Channels")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_lifecycle(my_api_key, my_octopus_api, space_id, lifecycle_id):
    """
    Return the lifecycle with the given ID
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of projects
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_lifecycle).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_lifecycle).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (get_lifecycle).')

    api = build_url(my_octopus_api, f"/api/{quote_safe(space_id)}/Lifecycles/{quote_safe(lifecycle_id)}")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json


@logging_wrapper
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
    ensure_string_not_empty(user, 'user must be the Octopus user ID (create_limited_api_key).')

    tomorrow = datetime.datetime.now(pytz.UTC) + datetime.timedelta(days=1)

    api_key = {
        'Purpose': "Octopus Copilot temporary API key",
        'Expires': tomorrow.isoformat()
    }

    api = build_url(my_octopus_api, f"/api/users/{quote_safe(user)}/apikeys")
    resp = handle_response(lambda: http.request("POST", api, json=api_key, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["ApiKey"]


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_raw_deployment_process(space_name, project_name, api_key, octopus_url):
    """
    Returns a deployment process as raw JSON.
    :param space_name: The name of the space.
    :param project_name: The name of the project
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment process raw JSON
    """
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_raw_deployment_process).')
    ensure_string_not_empty(project_name, 'project_name must be a non-empty string (get_raw_deployment_process).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    project = get_project(space_id, project_name, api_key, octopus_url)

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects/{quote_safe(project['Id'])}/DeploymentProcesses")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    return resp.data.decode("utf-8")


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_project_progression(space_name, project_name, api_key, octopus_url):
    """
    Returns a deployment progression for a project.
    :param space_name: The name of the space.
    :param project_name: The name of the project
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment progression raw JSON
    """
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_project_progression).')
    ensure_string_not_empty(project_name, 'project_name must be a non-empty string (get_project_progression).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    project = get_project(space_id, project_name, api_key, octopus_url)

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects/{quote_safe(project['Id'])}/Progression")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    return resp.data.decode("utf-8")


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_projects_batch(skip, take, space_id, api_key, octopus_url):
    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects", dict(take=take, skip=skip))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()["Items"]


@logging_wrapper
def get_projects_generator(space_id, api_key, octopus_url):
    skip = 0
    take = 30

    while True:
        batch_projects = get_projects_batch(skip, take, space_id, api_key, octopus_url)

        for project in batch_projects:
            yield project

        if len(batch_projects) != take:
            break

        skip += take


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_environments_batch(skip, take, space_id, api_key, octopus_url):
    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Environments", dict(take=take, skip=skip))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()["Items"]


@logging_wrapper
def get_environments_generator(space_id, api_key, octopus_url):
    skip = 0
    take = 30

    while True:
        batch_environments = get_environments_batch(skip, take, space_id, api_key, octopus_url)

        for environment in batch_environments:
            yield environment

        if len(batch_environments) != take:
            break

        skip += take


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_tenants_batch(skip, take, space_id, api_key, octopus_url):
    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Tenants", dict(take=take, skip=skip))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()["Items"]


@logging_wrapper
def get_tenants_generator(space_id, api_key, octopus_url):
    skip = 0
    take = 30

    while True:
        batch_tenants = get_tenants_batch(skip, take, space_id, api_key, octopus_url)

        for tenant in batch_tenants:
            yield tenant

        if len(batch_tenants) != take:
            break

        skip += take


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_runbooks_batch(skip, take, space_id, project_id, api_key, octopus_url):
    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects/{quote_safe(project_id)}/Runbooks",
                    dict(take=take, skip=skip))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()["Items"]


@logging_wrapper
def get_runbooks_generator(space_id, project_id, api_key, octopus_url):
    skip = 0
    take = 30

    while True:
        batch_runbooks = get_runbooks_batch(skip, take, space_id, project_id, api_key, octopus_url)

        for tenant in batch_runbooks:
            yield tenant

        if len(batch_runbooks) != take:
            break

        skip += take


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_project(space_id, project_name, api_key, octopus_url):
    """
    Returns a project resource from the name
    :param space_id: The ID of the space.
    :param project_name: The name of the project
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The project resource
    """
    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_project).')
    ensure_string_not_empty(project_name, 'project_name must be a non-empty string (get_project).')

    base_url = f"api/{quote_safe(space_id)}/Projects"

    api = build_url(octopus_url, base_url, dict(partialname=project_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    project = get_item_fuzzy(resp.json()["Items"], project_name)

    if project is None:
        api = build_url(octopus_url, base_url, dict(take=TAKE_ALL))
        resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
        project = get_item_fuzzy(resp.json()["Items"], project_name)
        if project is None:
            raise ResourceNotFound("Project", project_name)

    return project


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_environment(space_id, environment_id, api_key, octopus_url):
    """
    Returns a environment resource from the id
    :param space_id: The ID of the space.
    :param environment_id: The Id of the environment
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The environment resource
    """
    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_environment).')
    ensure_string_not_empty(environment_id, 'environment_id must be a non-empty string (get_environment).')

    base_url = f"api/{quote_safe(space_id)}/Environments/{quote_safe(environment_id)}"

    api = build_url(octopus_url, base_url)
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_project_releases(space_id, project_id, api_key, octopus_url, take=max_context):
    """
    Returns a deployment progression for a project.
    :param space_id: The ID of the space.
    :param project_id: The ID of the project
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment progression raw JSON
    """
    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_project_releases).')
    ensure_string_not_empty(project_id, 'project_id must be a non-empty string (get_project_releases).')

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects/{quote_safe(project_id)}/Releases",
                    query=dict(take=take))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    return resp.json()


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_release_deployments(space_id, release_id, api_key, octopus_url):
    """
    Returns the deployments of a release.
    :param space_id: The ID of the space.
    :param release_id: The release ID
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment progression raw JSON
    """
    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_release_deployments).')
    ensure_string_not_empty(release_id, 'release_id must be a non-empty string (get_release_deployments).')

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Releases/{quote_safe(release_id)}/Deployments")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    return resp.json()


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_task(space_id, task_id, api_key, octopus_url):
    """
    Returns the deployments of a release.
    :param space_id: The ID of the space.
    :param task_id: The task ID
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment progression raw JSON
    """
    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_task).')
    ensure_string_not_empty(task_id, 'task_id must be a non-empty string (get_task).')

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Tasks/{quote_safe(task_id)}")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    return resp.json()


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_project_progression_from_ids(space_id, project_id, api_key, octopus_url):
    """
    Returns a deployment progression for a project.
    :param space_name: The name of the space.
    :param project_name: The name of the project
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment progression raw JSON
    """
    ensure_string_not_empty(space_id, 'space_name must be a non-empty string (get_project_progression).')
    ensure_string_not_empty(project_id, 'project_name must be a non-empty string (get_project_progression).')

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects/{quote_safe(project_id)}/Progression")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    return resp.json()


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_deployment_status_base(space_name, environment_name, project_name, api_key, octopus_url):
    """
    The base function used to get a list of project names.
    :param space_name: The name of the Octopus space containing the projects
    :param project_name: The name of the Octopus project
    :param environment_name: The name of the Octopus environment
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The list of projects in the space
    """

    logger.info("get_deployment_status - Enter")

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_deployment_status).')
    ensure_string_not_empty(project_name, 'project_name must be a non-empty string (get_deployment_status).')
    ensure_string_not_empty(environment_name,
                            'environment_name must be a non-empty string (get_deployment_status).')
    ensure_string_not_empty(octopus_url, 'octopus_url must be the Octopus Url (get_deployment_status).')
    ensure_string_not_empty(api_key, 'api_key must be the Octopus Api key (get_deployment_status).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    project = get_project(space_id, project_name, api_key, octopus_url)
    environment = get_environment_fuzzy(space_id, environment_name, api_key, octopus_url)

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects/{quote_safe(project['Id'])}/Progression")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    releases = list(filter(lambda r: environment["Id"] in r["Deployments"], resp.json()["Releases"]))

    if len(releases) == 0:
        raise ResourceNotFound("Deployment", f"{project_name} in {environment_name}")

    return actual_space_name, environment['Name'], project['Name'], releases[0]["Deployments"][environment['Id']][0]


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_deployment_logs(space_name, project_name, environment_name, tenant_name, release_version,
                        api_key,
                        octopus_url):
    """
    Returns a logs for a deployment to an environment.
    :param space_name: The name of the space.
    :param project_name: The name of the project
    :param environment_name: The name of the environment
    :param tenant_name: The name of the tenant
    :param release_version: The name of the release
    :param steps: The steps to limit the logs to
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment progression raw JSON
    """
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_deployment_logs).')
    ensure_string_not_empty(project_name, 'project_name must be a non-empty string (get_deployment_logs).')
    ensure_string_not_empty(octopus_url, 'octopus_url must be the Octopus Url (get_deployment_logs).')
    ensure_string_not_empty(api_key, 'api_key must be the Octopus Api key (get_deployment_logs).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    project = get_project(space_id, project_name, api_key, octopus_url)

    environment = None
    if environment_name:
        environment = get_environment_fuzzy(space_id, environment_name, api_key, octopus_url)

    tenant = None
    if tenant_name:
        tenant = get_tenant_fuzzy(space_id, tenant_name, api_key, octopus_url)

    # Find deployment count
    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Deployments", dict(take=0, projects=project['Id']))
    resp_json = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key))).json()
    total_results = resp_json["TotalResults"]
    skip = max(0, total_results - 30)

    # Get the latest deployments
    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Deployments",
                    dict(take=100, skip=skip, projects=project['Id']))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    deployments = json.loads(resp.data.decode("utf-8")).get("Items")

    if environment:
        # Only releases to the environment are a candidate
        deployments = list(filter(lambda d: d["EnvironmentId"] == environment["Id"], deployments))

    if tenant:
        deployments = list(filter(lambda d: d["TenantId"] == tenant["Id"], deployments))

    task_id = None
    if release_is_latest(release_version):
        if deployments:
            task_id = deployments[-1]["TaskId"]
    else:
        # We need to match the release version to a release, and the release to a deployment

        # Start by getting the releases for a project
        api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Projects/{quote_safe(project['Id'])}/Releases",
                        dict(take=100))
        resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
        releases = json.loads(resp.data.decode("utf-8")).get("Items")

        # Find the specific release
        release = next(filter(lambda r: r["Version"] == release_version.strip(), releases), None)

        # If the release is not found, exit
        if not release:
            return ""

        # Find the specific deployment
        specific_deployment = list(filter(lambda d: d["ReleaseId"] == release["Id"], deployments))
        if specific_deployment:
            task_id = specific_deployment[0]["TaskId"]

    if not task_id:
        return ""

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Tasks/{task_id}/details")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    task = json.loads(resp.data.decode("utf-8"))

    return task["ActivityLogs"]


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_runbook_deployment_logs(space_name, project_name, runbook_name, environment_name, tenant_name, release_version,
                                api_key,
                                octopus_url):
    """
    Returns a logs for a deployment to an environment.
    :param space_name: The name of the space.
    :param project_name: The name of the project
    :param environment_name: The name of the environment
    :param tenant_name: The name of the tenant
    :param release_version: The name of the release
    :param steps: The steps to limit the logs to
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The deployment progression raw JSON
    """
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_deployment_logs).')
    ensure_string_not_empty(project_name, 'project_name must be a non-empty string (get_deployment_logs).')
    ensure_string_not_empty(octopus_url, 'octopus_url must be the Octopus Url (get_deployment_logs).')
    ensure_string_not_empty(api_key, 'api_key must be the Octopus Api key (get_deployment_logs).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    project = get_project(space_id, project_name, api_key, octopus_url)

    runbook = get_runbook_fuzzy(space_id, project["Id"], runbook_name, api_key, octopus_url)

    environment = None
    if environment_name:
        environment = get_environment_fuzzy(space_id, environment_name, api_key, octopus_url)

    tenant = None
    if tenant_name:
        tenant = get_tenant_fuzzy(space_id, tenant_name, api_key, octopus_url)

    # Find deployment count
    query = dict(skip=0, project=project['Id'], runbook=runbook["Id"], spaces=space_id,
                 includeSystem="false", environment=environment["Id"])

    if environment:
        query["environment"] = environment["Id"]

    if tenant:
        query["tenant"] = tenant["Id"]

    api = build_url(octopus_url, f"bff/tasks/list", query)
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    runs = json.loads(resp.data.decode("utf-8")).get("Items")

    if not runs:
        return ""

    task_id = runs[0]["Id"] if runs else None

    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Tasks/{task_id}/details")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    task = json.loads(resp.data.decode("utf-8"))

    return task["ActivityLogs"]


def activity_logs_to_string(activity_logs, sanitized_steps):
    if not activity_logs:
        return ""

    logs = "\n".join(list(map(lambda i: get_logs(i, 0, sanitized_steps), activity_logs)))

    return logs


def get_logs(log_item, depth, steps=None):
    if depth == 0 and len(log_item["LogElements"]) == 0 and len(log_item["Children"]) == 0:
        return f"No logs found (status: {log_item['Status']})."

    logs = log_item["Name"] + "\n"
    logs += "\n".join(list(map(lambda e: e["MessageText"], log_item["LogElements"])))

    # limit the result to either step indexes or names
    if depth == 1:
        if steps and len(steps) != 0:
            step_ints = [step for step in steps if string_to_int(step)]
            # Find the logs by index
            found_index = step_ints and len(step_ints) != 0 and len(
                [step_int for step_int in step_ints if log_item["Name"].startswith("Step " + step_int)]) != 0
            # Find the logs by name
            found_name = len([step for step in steps if fuzz.ratio(normalize_log_step_name(step),
                                                                   normalize_log_step_name(
                                                                       log_item["Name"])) > 80]) != 0

            # If none match, don't dig deeper
            if not found_index and not found_name:
                return logs

    if log_item["Children"]:
        for child in log_item["Children"]:
            logs += "\n" + get_logs(child, depth + 1, steps)

    return logs


def handle_response(callback):
    """
    This function maps common HTTP response codes to exceptions
    :param callback: A function that returns a response object
    :return: The response object
    """
    response = callback()
    if response.status == 401:
        logger.info(response.data.decode('utf-8'))
        raise OctopusApiKeyInvalid()
    if response.status != 200 and response.status != 201:
        logger.info(response.data.decode('utf-8'))
        raise OctopusRequestFailed(f"Request failed with " + response.data.decode('utf-8'))

    return response


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_environment_fuzzy(space_id, environment_name, api_key, octopus_url):
    base_url = f"api/{quote_safe(space_id)}/Environments"
    api = build_url(octopus_url, base_url, dict(partialname=environment_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    environment = get_item_fuzzy(resp.json()["Items"], environment_name)

    if environment is None:
        api = build_url(octopus_url, base_url)
        resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
        environment = get_item_fuzzy(resp.json()["Items"], environment_name)
        if environment is None:
            raise ResourceNotFound("Environment", environment_name)

    return environment


@logging_wrapper
def get_environment_cached(space_id, environment_name, api_key, octopus_url):
    if not environment_cache.get(octopus_url):
        environment_cache[octopus_url] = {}

    if not environment_cache[octopus_url].get(space_id):
        environment_cache[octopus_url][space_id] = {}

    if not environment_cache[octopus_url][space_id].get(environment_name):
        environment_cache[octopus_url][space_id][environment_name] = get_environment_fuzzy(space_id, environment_name,
                                                                                           api_key, octopus_url)

    return environment_cache[octopus_url][space_id][environment_name]


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_tenant_fuzzy(space_id, tenant_name, api_key, octopus_url):
    base_url = f"api/{quote_safe(space_id)}/Tenants"
    api = build_url(octopus_url, base_url, dict(partialname=tenant_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    tenant = get_item_fuzzy(resp.json()["Items"], tenant_name)

    if tenant is None:
        api = build_url(octopus_url, base_url)
        resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
        tenant = get_item_fuzzy(resp.json()["Items"], tenant_name)
        if tenant is None:
            raise ResourceNotFound("Tenant", tenant_name)

    return tenant


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_tenant(space_id, tenant_id, api_key, octopus_url):
    base_url = f"api/{quote_safe(space_id)}/Tenants/{quote_safe(tenant_id)}"
    api = build_url(octopus_url, base_url)
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()


@logging_wrapper
def get_tenant_cached(space_id, tenant_name, api_key, octopus_url):
    if not tenant_cache.get(octopus_url):
        tenant_cache[octopus_url] = {}

    if not tenant_cache[octopus_url].get(space_id):
        tenant_cache[octopus_url][space_id] = {}

    if not tenant_cache[octopus_url][space_id].get(tenant_name):
        tenant_cache[octopus_url][space_id][tenant_name] = get_tenant_fuzzy(space_id, tenant_name, api_key, octopus_url)

    return tenant_cache[octopus_url][space_id][tenant_name]


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_channel(space_id, channel_id, api_key, octopus_url):
    api = build_url(octopus_url, f"api/{quote_safe(space_id)}/Channels/{quote_safe(channel_id)}")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    return resp.json()


@logging_wrapper
def get_channel_cached(space_id, channel_id, api_key, octopus_url):
    if not channel_cache.get(octopus_url):
        channel_cache[octopus_url] = {}

    if not channel_cache[octopus_url].get(space_id):
        channel_cache[octopus_url][space_id] = {}

    if not channel_cache[octopus_url][space_id].get(channel_id):
        channel_cache[octopus_url][space_id][channel_id] = get_channel(space_id, channel_id, api_key, octopus_url)

    return channel_cache[octopus_url][space_id][channel_id]


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_project_fuzzy(space_id, project_name, api_key, octopus_url):
    # First try to find a nice match using a partial name lookup.
    # This is a shortcut that means we don't have to loop the entire list of project.
    # This will succeed if any resources match the supplied partial name.
    base_url = f"api/{quote_safe(space_id)}/Projects"
    api = build_url(octopus_url, base_url, dict(partialname=project_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    project = get_item_fuzzy(resp.json()["Items"], project_name)

    # This is a higher cost fallback used when the partial name returns no results.
    if project is None:
        api = build_url(octopus_url, base_url)
        resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
        project = get_item_fuzzy(resp.json()["Items"], project_name)
        if project is None:
            raise ResourceNotFound("Project", project_name)

    return project


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_runbook_fuzzy(space_id, project_id, runbook_name, api_key, octopus_url):
    # First try to find a nice match using a partial name lookup.
    # This is a shortcut that means we don't have to loop the entire list of runbooks.
    # This will succeed if any resources match the supplied partial name.
    base_url = f"api/{quote_safe(space_id)}/Projects/{quote_safe(project_id)}/Runbooks"
    api = build_url(octopus_url, base_url, dict(partialname=runbook_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    runbook = get_item_fuzzy(resp.json()["Items"], runbook_name)

    # This is a higher cost fallback used when the partial name returns no results.
    if runbook is None:
        api = build_url(octopus_url, base_url)
        resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
        runbook = get_item_fuzzy(resp.json()["Items"], runbook_name)
        if runbook is None:
            raise ResourceNotFound("Runbook", runbook_name)

    return runbook


@logging_wrapper
def run_published_runbook_fuzzy(space_id, project_name, runbook_name, environment_name, tenant_name, my_api_key,
                                my_octopus_api, log_query=None):
    """
    Runs a published runbook
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (run_published_runbook_fuzzy).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (run_published_runbook_fuzzy).')
    ensure_string_not_empty(space_id, 'space_id must be the space ID (run_published_runbook_fuzzy).')
    ensure_string_not_empty(project_name, 'project_name must be the project (run_published_runbook_fuzzy).')
    ensure_string_not_empty(runbook_name, 'runbook_name must be the runbook (run_published_runbook_fuzzy).')
    ensure_string_not_empty(environment_name, 'environment_name must be the environment (run_published_runbook_fuzzy).')

    project = get_project_fuzzy(space_id, project_name, my_api_key, my_octopus_api)
    runbook = get_runbook_fuzzy(space_id, project["Id"], runbook_name, my_api_key, my_octopus_api)
    environment = get_environment_fuzzy(space_id, environment_name, my_api_key, my_octopus_api)
    tenant = get_tenant_fuzzy(space_id, tenant_name, my_api_key, my_octopus_api) if tenant_name else None

    if not runbook['PublishedRunbookSnapshotId']:
        raise RunbookNotPublished(runbook_name)

    base_url = f"api/{quote_safe(space_id)}/runbookRuns"
    api = build_url(my_octopus_api, base_url)

    runbook_run = {
        'RunbookId': runbook['Id'],
        'RunbookSnapshotId': runbook['PublishedRunbookSnapshotId'],
        'EnvironmentId': environment['Id'],
        'TenantId': tenant['Id'] if tenant else None,
        'SkipActions': None,
        'SpecificMachineIds': None,
        'ExcludedMachineIds': None
    }

    if log_query:
        log_query("run_published_runbook_fuzzy", f"""
                    Space: {space_id}
                    Project Names: {project_name}
                    Project Id: {project['Id']}
                    Runbook Names: {runbook_name}
                    Runbook Id: {runbook['Id']}
                    Runbook Published Snapshot Id: {runbook['PublishedRunbookSnapshotId']}
                    Tenant Names: {tenant_name}
                    Tenant Id: {tenant['Id'] if tenant else None}
                    Environment Names: {environment_name}
                    Environment Id: {environment['Id']}""")

    response = handle_response(
        lambda: http.request("POST", api, json=runbook_run, headers=get_octopus_headers(my_api_key)))

    return response.json()
