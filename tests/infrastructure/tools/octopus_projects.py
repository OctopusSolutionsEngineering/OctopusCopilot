from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import get_octopus_project_names_base, get_current_user, create_limited_api_key
from tests.live.octopus_config import Octopus_Api_Key


def get_mock_octopus_projects(space_name):
    """Return a list of projects in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_mock_octopus_projects).')
    return ["Project1", "Project2"]


def get_octopus_project_names(space_name):
    """Return a list of project names in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """

    actual_space_name, projects = get_octopus_project_names_base(space_name,
                                                                 Octopus_Api_Key,
                                                                 "http://localhost:8080")

    return projects


def set_octopus_details(octopus_url, api_key):
    """Create a temporary API key for the Octopus user

        Args:
            octopus_url: The URL of an octopus instance, for example https://myinstance.octopus.app,
            where "myinstance" can be any name

            api_key: The Octopus API key, e.g. API-xxxxxxxxxxxxxxxxxxxxxxx
    """

    user = get_current_user(api_key, octopus_url)
    api_key = create_limited_api_key(user, api_key, octopus_url)

    return api_key


def get_octopus_user(octopus_url, api_key):
    """Gets the details of the current Octopus user

        Args:
            octopus_url: The URL of an octopus instance, for example https://myinstance.octopus.app,
            where "myinstance" can be any name

            api_key: The Octopus API key, e.g. API-xxxxxxxxxxxxxxxxxxxxxxx
    """

    return get_current_user(api_key, octopus_url)
