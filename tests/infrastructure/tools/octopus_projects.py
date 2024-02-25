from infrastructure.octopus import get_octopus_project_names_base
from tests.live.octopus_config import Octopus_Api_Key


def get_mock_octopus_projects(space_name):
    """Return a list of projects in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """
    return ["Project1", "Project2"]


def get_octopus_project_names_form(space_name):
    """Return a list of project names in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """

    actual_space_name, projects = get_octopus_project_names_base(space_name,
                                                                 Octopus_Api_Key,
                                                                 "http://localhost:8080")

    return projects
