import asyncio

from domain.lookup.octopus_multi_lookup import lookup_space_level_resources
from infrastructure.octolint import run_octolint_check_async


def octolint_empty_projects_wrapper(callback, logging):
    def octolint_empty_projects(space=None, projects=None, **kwargs):
        """
        Checks for empty projects with no steps or runbooks in the space. Example prompts include:
        * Check for empty projects in the space "MySpace".
        * Find projects with no steps or runbooks space "MySpace".

        Args:
        space: The name of the space to run the check in.
        projects: The name of the projects to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_empty_projects")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space, projects)

    return octolint_empty_projects
