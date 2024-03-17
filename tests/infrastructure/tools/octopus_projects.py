from domain.validation.argument_validation import ensure_string_not_empty


def get_mock_octopus_projects(space_name):
    """Return a list of projects in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_mock_octopus_projects).')
    return ["Project1", "Project2"]
