from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments
from domain.response.copilot_response import CopilotResponse
from infrastructure.octopus import run_published_runbook_fuzzy


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
        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        run_published_runbook_fuzzy(space_id, sanitized_project_names[0], runbook_name, sanitized_environment_names[0],
                                    tenant_name, api_key, url)

    return run_runbook
