from domain.exceptions.runbook_not_published import RunbookNotPublished
from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments, lookup_tenants, \
    lookup_runbooks
from domain.response.copilot_response import CopilotResponse
from infrastructure.octopus import run_published_runbook_fuzzy, get_project


def run_runbook_wrapper(url, api_key, github_user, original_query):
    def run_runbook(space_name, project_name, runbook_name, environment_name, tenant_name):
        """
        Runs a published runbook in Octopus Deploy.

        Args:
        space_name: The name of the space
        project_name: The name of the project
        runbook_name: The name of the runbook
        environment_name: The name of the environment
        tenant_name: The optional name of the tenant
        """

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names = lookup_projects(url, api_key, github_user, original_query, space_id, project_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_tenant_names = lookup_tenants(url, api_key, github_user, original_query, space_id, tenant_name)
        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)
        sanitized_runbook_names = lookup_runbooks(url, api_key, github_user, original_query, space_id, project["Id"],
                                                  runbook_name)

        if not sanitized_runbook_names:
            return CopilotResponse("Please specify a runbook name in the query.")

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        try:
            response = run_published_runbook_fuzzy(space_id, sanitized_project_names[0],
                                                   sanitized_runbook_names[0],
                                                   sanitized_environment_names[0],
                                                   sanitized_tenant_names[0] if sanitized_tenant_names else None,
                                                   api_key,
                                                   url)

            return CopilotResponse(
                f"[Runbook Run]({url}/app#/{space_id}/projects/{project['Id']}/operations/runbooks/{response['RunbookId']}/snapshots/{response['RunbookSnapshotId']}/runs/{response['Id']})")
        except RunbookNotPublished as e:
            return CopilotResponse(f"The runbook {sanitized_runbook_names[0]} must be published")

    return run_runbook
