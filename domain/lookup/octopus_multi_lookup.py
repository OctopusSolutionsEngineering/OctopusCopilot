from domain.lookup.octopus_lookups import (
    lookup_space,
    lookup_projects,
    lookup_environments,
    lookup_tenants,
)


def lookup_space_level_resources(
    url,
    api_key,
    github_user,
    original_query,
    space,
    projects=None,
    environments=None,
    tenants=None,
):
    """
    Many queries relate to a collection of projects, environments, and tenants in a space. This function
    resolves all these space level resources, taking into account any default values, and dealing with fuzzy
    lookups.
    """

    space_id, actual_space_name, warnings = lookup_space(
        url, api_key, github_user, original_query, space
    )

    sanitized_project_names, sanitized_projects = lookup_projects(
        url, api_key, github_user, original_query, space_id, projects
    )

    sanitized_environment_names = lookup_environments(
        url, api_key, github_user, original_query, space_id, environments
    )

    sanitized_tenant_names = lookup_tenants(
        url, api_key, github_user, original_query, space_id, tenants
    )

    return {
        "space_id": space_id,
        "space_name": actual_space_name,
        "warnings": warnings,
        "project_names": sanitized_project_names,
        "projects": sanitized_projects,
        "environment_names": sanitized_environment_names,
        "tenant_names": sanitized_tenant_names,
    }
