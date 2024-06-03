from domain.defaults.defaults import get_default_argument
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space, sanitize_names_fuzzy, \
    sanitize_projects
from infrastructure.octopus import get_spaces_generator, get_space_id_and_name_from_name, get_projects_generator, \
    get_environments_generator


def lookup_space(url, api_key, github_user, original_query, space_name):
    """
    Find the space id and name from the space name. Does fuzzy matching and uses any default values.
    """

    sanitized_space = sanitize_name_fuzzy(lambda: get_spaces_generator(api_key, url),
                                          sanitize_space(original_query, space_name))

    space_name = get_default_argument(github_user,
                                      sanitized_space["matched"] if sanitized_space else None, "Space")

    warnings = []

    if not space_name:
        space_name = next(get_spaces_generator(api_key, url), {"Name": "Default"}).get("Name")
        warnings.append(f"The query did not specify a space so the so the space named {space_name} was assumed.")

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, url)

    return space_id, actual_space_name, warnings


def lookup_projects(url, api_key, github_user, original_query, space_id, project_name):
    sanitized_projects = sanitize_names_fuzzy(lambda: get_projects_generator(space_id, api_key, url),
                                              sanitize_projects(project_name))

    return get_default_argument(github_user,
                                [project["matched"] for project in sanitized_projects], "Project")


def lookup_environments(url, api_key, github_user, original_query, space_id, environment_name):
    sanitized_environments = sanitize_names_fuzzy(lambda: get_environments_generator(space_id, api_key, url),
                                                  sanitize_projects(environment_name))

    return get_default_argument(github_user,
                                [environment["matched"] for environment in sanitized_environments], "Environment")
