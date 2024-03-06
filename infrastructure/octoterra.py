import json

from retry import retry
from urllib3.exceptions import HTTPError

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http
from infrastructure.octopus import handle_response, get_space_id_and_name_from_name

logger = configure_logging(__name__)


@retry(HTTPError, tries=3, delay=2)
def get_octoterra_space(query, space_name, project_names, runbook_names, target_names, tenant_names,
                        library_variable_sets,
                        api_key, octopus_url):
    """
    Returns the terraform representation of a space
    :param space_name: The name of the space.
    :param project_names: The names of the projects to limit the export to.
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The space terraform module
    """
    logger.info("get_octoterra_space - Enter")

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_octoterra_space).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    # We want to restrict the size of the exported Terraform configuration as much as possible,
    # so we make heavy use of the options to exclude resources unless they were mentioned in the query.
    exclude_targets = True if not target_names and "target" not in query.lower() and "machine" not in query.lower() else False
    exclude_runbooks = True if not runbook_names and "runbook" not in query.lower() else False
    exclude_tenants = True if not tenant_names and "tenant" not in query.lower() else False
    exclude_projects = True if not project_names and "project" not in query.lower() else False
    exclude_library_variable_sets = True if not library_variable_sets and "library" not in query.lower() else False

    body = {
        "space": space_id,
        "url": octopus_url,
        "apiKey": api_key,
        "ignoreCacManagedValues": False,
        "excludeCaCProjectSettings": True,
        "excludeProjectsExcept": ",".join(project_names) if project_names else "",
        "excludeTenantsExcept": ",".join(tenant_names) if tenant_names else "",
        "excludeAllProjects": exclude_projects,
        "excludeAllTenant": exclude_tenants,
        "excludeAllTargets": exclude_targets,
        "excludeAllRunbooks": exclude_runbooks,
        "excludeAllLibraryVariableSets": exclude_library_variable_sets,
        "limitAttributeLength": 100
    }

    resp = handle_response(lambda: http.request("POST",
                                                "https://octoterraproduction.azurewebsites.net/api/octoterra",
                                                body=json.dumps(body)))

    return (resp.data.decode("utf-8")
            + "\nAs an AI model, I often make mistakes. "
            + "Verify the information I provide before performing any destructive actions.")
