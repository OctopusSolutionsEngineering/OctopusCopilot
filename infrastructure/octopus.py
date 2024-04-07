import datetime
import json

import pytz
from retry import retry
from urllib3.exceptions import HTTPError

from domain.config.openai import max_context
from domain.exceptions.request_failed import OctopusRequestFailed
from domain.exceptions.resource_not_found import ResourceNotFound
from domain.exceptions.space_not_found import SpaceNotFound
from domain.exceptions.user_not_loggedin import OctopusApiKeyInvalid
from domain.logging.app_logging import configure_logging
from domain.query.query_inspector import release_is_latest
from domain.sanitizers.sanitized_list import flatten_list
from domain.url.build_url import build_url
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http, TAKE_ALL

logger = configure_logging()


def logging_wrapper(func):
    def wrapper():
        try:
            print(func.__name__ + " Enter")
            func()
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

    api = build_url(my_octopus_api, "api/" + space_id + "/Projects", dict(take=TAKE_ALL))
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

    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_octopus_project_names_base).')
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_octopus_project_names_base).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_octopus_project_names_base).')

    api = build_url(my_octopus_api, "api/" + space_id + "/Dashboard",
                    dict(highestLatestVersionPerProjectAndEnvironment="true"))
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
def get_projects(my_api_key, my_octopus_api, space_id):
    """
    Returns the projects in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of projects
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_projects).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_projects).')
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_projects).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Projects?take=10000")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(my_api_key)))

    json = resp.json()
    return json["Items"]


@logging_wrapper
def get_tenants(my_api_key, my_octopus_api, space_id):
    """
    Returns the tenants in a space
    :param my_api_key: The Octopus API key
    :param my_octopus_api: The Octopus URL
    :return: The list of tenants
    """
    ensure_string_not_empty(my_octopus_api, 'my_octopus_api must be the Octopus Url (get_tenants).')
    ensure_string_not_empty(my_api_key, 'my_api_key must be the Octopus Api key (get_tenants).')
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_tenants).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Tenants?take=10000")
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
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_feeds).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Feeds?take=10000")
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
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_accounts).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Accounts?take=10000")
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
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_machines).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Machines?take=10000")
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
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_certificates).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Certificates?take=10000")
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
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_environments).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Environments?take=10000")
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
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_project_channel).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Projects/{project_id}/Channels")
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
    ensure_string_not_empty(my_api_key, 'space_id must be the space ID (get_lifecycle).')

    api = build_url(my_octopus_api, f"/api/{space_id}/Lifecycles/{lifecycle_id}")
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

    api = build_url(my_octopus_api, "/api/users/" + user + "/apikeys")
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

    api = build_url(octopus_url, "api/" + space_id + "/Projects", dict(partialname=project_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    project = get_item_ignoring_case(resp.json()["Items"], project_name)

    if project is None:
        raise ResourceNotFound("Project", project_name)

    api = build_url(octopus_url, f"api/{space_id}/Projects/{project['Id']}/DeploymentProcesses")
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

    api = build_url(octopus_url, "api/" + space_id + "/Projects", dict(partialname=project_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    project = get_item_ignoring_case(resp.json()["Items"], project_name)

    if project is None:
        raise ResourceNotFound("Project", project_name)

    api = build_url(octopus_url, f"api/{space_id}/Projects/{project['Id']}/Progression")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    return resp.data.decode("utf-8")


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
    ensure_string_not_empty(space_id, 'space_id must be a non-empty string (get_project_releases).')
    ensure_string_not_empty(project_name, 'project_name must be a non-empty string (get_project_releases).')

    api = build_url(octopus_url, "api/" + space_id + "/Projects", dict(partialname=project_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    project = get_item_ignoring_case(resp.json()["Items"], project_name)

    if project is None:
        raise ResourceNotFound("Project", project_name)

    return project


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

    api = build_url(octopus_url, f"api/{space_id}/Projects/{project_id}/Releases?take={take}")
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

    api = build_url(octopus_url, f"api/{space_id}/Releases/{release_id}/Deployments")
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

    api = build_url(octopus_url, f"api/{space_id}/Tasks/{task_id}")
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

    api = build_url(octopus_url, f"api/{space_id}/Projects/{project_id}/Progression")
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

    api = build_url(octopus_url, "api/" + space_id + "/Projects", dict(partialname=project_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    project = get_item_ignoring_case(resp.json()["Items"], project_name)

    if project is None:
        raise ResourceNotFound("Project", project_name)

    api = build_url(octopus_url, "api/" + space_id + "/Environments", dict(partialname=environment_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    environment = get_item_ignoring_case(resp.json()["Items"], environment_name)

    if environment is None:
        raise ResourceNotFound("Environment", environment_name)

    api = build_url(octopus_url, f"api/{space_id}/Projects/{project['Id']}/Progression")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    releases = list(filter(lambda r: environment["Id"] in r["Deployments"], resp.json()["Releases"]))

    if len(releases) == 0:
        raise ResourceNotFound("Deployment", f"{project_name} in {environment_name}")

    return actual_space_name, environment['Name'], project['Name'], releases[0]["Deployments"][environment['Id']][0]


def get_item_ignoring_case(items, name):
    case_insensitive_items = list(filter(lambda p: p["Name"].casefold() == name.casefold(), items))
    case_sensitive_items = list(filter(lambda p: p["Name"] == name, case_insensitive_items))

    if len(case_sensitive_items) != 0:
        return case_sensitive_items[0]

    if len(case_insensitive_items) != 0:
        return case_insensitive_items[0]

    return None


@retry(HTTPError, tries=3, delay=2)
@logging_wrapper
def get_deployment_logs(space_name, project_name, environment_name, tenant_name, release_version, api_key, octopus_url):
    """
    Returns a logs for a deployment to an environment.
    :param space_name: The name of the space.
    :param project_name: The name of the project
    :param environment_name: The name of the environment
    :param tenant_name: The name of the tenant
    :param release_version: The name of the release
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
        environment = get_environment(space_id, environment_name, octopus_url, api_key)

    tenant = None
    if tenant_name:
        tenant = get_tenant(space_id, tenant_name, octopus_url, api_key)

    api = build_url(octopus_url, f"api/{space_id}/Projects/{project['Id']}/Progression")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))

    releases = json.loads(resp.data.decode("utf-8"))

    if "Releases" not in releases:
        return ""

    if environment:
        # Only releases to the environment are a candidate
        filtered_releases = list(filter(lambda r: environment["Id"] in r["Deployments"].keys(), releases["Releases"]))
        deployments = flatten_list(map(lambda r: r["Deployments"][environment['Id']], filtered_releases))
    else:
        # Every deployment is a candidate
        deployments = flatten_list(map(lambda r: r["Deployments"][environment['Id']], releases))

    if tenant:
        deployments = list(filter(lambda d: d["TenantId"] == tenant["Id"], deployments))

    task_id = None
    if release_is_latest(release_version):
        if deployments:
            task_id = deployments[0]["TaskId"]
    else:
        specific_deployment = list(filter(lambda d: d["ReleaseVersion"] == release_version.strip(), deployments))
        if specific_deployment:
            task_id = specific_deployment[0]["TaskId"]

    if not task_id:
        return ""

    api = build_url(octopus_url, f"api/{space_id}/Tasks/{task_id}/details")
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    task = json.loads(resp.data.decode("utf-8"))

    logs = "\n".join(list(map(lambda i: get_logs(i, 0), task["ActivityLogs"])))

    return logs


def get_logs(log_item, depth):
    if depth == 0 and len(log_item["LogElements"]) == 0 and len(log_item["Children"]) == 0:
        return f"No logs found (status: {log_item['Status']})."

    logs = "\n".join(list(map(lambda e: e["MessageText"], log_item["LogElements"])))
    if log_item["Children"]:
        for child in log_item["Children"]:
            logs += get_logs(child, depth + 1)

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
    if response.status != 200:
        logger.info(response.data.decode('utf-8'))
        raise OctopusRequestFailed(f"Request failed with " + response.data.decode('utf-8'))

    return response


@logging_wrapper
def get_environment(space_id, environment_name, octopus_url, api_key):
    api = build_url(octopus_url, "api/" + space_id + "/Environments", dict(partialname=environment_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    environment = get_item_ignoring_case(resp.json()["Items"], environment_name)

    if environment is None:
        raise ResourceNotFound("Environment", environment_name)

    return environment


@logging_wrapper
def get_tenant(space_id, tenant_name, octopus_url, api_key):
    api = build_url(octopus_url, "api/" + space_id + "/Tenants", dict(partialname=tenant_name))
    resp = handle_response(lambda: http.request("GET", api, headers=get_octopus_headers(api_key)))
    tenant = get_item_ignoring_case(resp.json()["Items"], tenant_name)

    if tenant is None:
        raise ResourceNotFound("Tenant", tenant_name)

    return tenant
