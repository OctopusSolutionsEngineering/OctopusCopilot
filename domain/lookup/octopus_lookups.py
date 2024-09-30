from domain.defaults.defaults import get_default_argument
from domain.sanitizers.sanitized_list import (
    sanitize_name_fuzzy,
    sanitize_space,
    sanitize_names_fuzzy,
    sanitize_projects,
    sanitize_environments,
    sanitize_tenants,
    sanitize_runbooks,
    sanitize_list,
)
from infrastructure.octopus import (
    get_spaces_generator,
    get_space_id_and_name_from_name,
    get_projects_generator,
    get_environments_generator,
    get_tenants_generator,
    get_runbooks_generator,
)


def lookup_space(url, api_key, user_id, original_query, sanitized_space_name):
    """
    Find the space id and name from the space name. Does fuzzy matching and uses any default values.
    """

    sanitized_space = sanitize_name_fuzzy(
        lambda: get_spaces_generator(api_key, url),
        sanitize_space(original_query, sanitized_space_name),
    )
    sanitized_space_name = sanitized_space["matched"] if sanitized_space else None

    if user_id:
        sanitized_space_name = get_default_argument(
            user_id, sanitized_space_name, "Space"
        )

    warnings = []

    if not sanitized_space_name:
        sanitized_space_name = next(
            get_spaces_generator(api_key, url), {"Name": "Default"}
        ).get("Name")
        warnings.append(
            f"The query did not specify a space so the so the space named {sanitized_space_name} was assumed."
        )

    space_id, actual_space_name = get_space_id_and_name_from_name(
        sanitized_space_name, api_key, url
    )

    return space_id, actual_space_name, warnings


def lookup_projects(url, api_key, user_id, original_query, space_id, project_name):
    if not project_name and user_id:
        return sanitize_list(get_default_argument(user_id, None, "Project")), []

    sanitized_projects = sanitize_names_fuzzy(
        lambda: get_projects_generator(space_id, api_key, url),
        sanitize_projects(project_name),
    )

    sanitized_project_names = [project["matched"] for project in sanitized_projects]

    if user_id:
        sanitized_project_names = sanitize_list(
            get_default_argument(user_id, sanitized_project_names, "Project")
        )

    return sanitized_project_names, sanitized_projects


def lookup_environments(
    url, api_key, user_id, original_query, space_id, environment_name
):
    if not environment_name and user_id:
        return sanitize_list(get_default_argument(user_id, None, "Environment"))

    sanitized_environments = sanitize_names_fuzzy(
        lambda: get_environments_generator(space_id, api_key, url),
        sanitize_environments(original_query, environment_name),
    )

    sanitized_environment_names = [
        environment["matched"] for environment in sanitized_environments
    ]

    if user_id:
        sanitized_environment_names = sanitize_list(
            get_default_argument(user_id, sanitized_environment_names, "Environment")
        )

    return sanitized_environment_names


def lookup_tenants(url, api_key, user_id, original_query, space_id, tenant_name):
    if not tenant_name and user_id:
        return sanitize_list(get_default_argument(user_id, None, "Tenant"))

    sanitized_tenants = sanitize_names_fuzzy(
        lambda: get_tenants_generator(space_id, api_key, url),
        sanitize_tenants(tenant_name),
    )

    sanitized_tenant_names = [tenant["matched"] for tenant in sanitized_tenants]

    if user_id:
        sanitized_tenant_names = sanitize_list(
            get_default_argument(user_id, sanitized_tenant_names, "Tenant")
        )

    return sanitized_tenant_names


def lookup_runbooks(
    url, api_key, user_id, original_query, space_id, project_id, runbook_name
):
    if not runbook_name and user_id:
        return sanitize_list(get_default_argument(user_id, None, "Runbook"))

    sanitized_runbooks = sanitize_names_fuzzy(
        lambda: get_runbooks_generator(space_id, project_id, api_key, url),
        sanitize_runbooks(runbook_name),
    )

    sanitized_runbook_names = [runbook["matched"] for runbook in sanitized_runbooks]

    if user_id:
        sanitized_runbook_names = sanitize_list(
            get_default_argument(user_id, sanitized_runbook_names, "Runbook")
        )

    return sanitized_runbook_names
