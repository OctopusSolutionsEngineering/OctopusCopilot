import json
import uuid

from domain.exceptions.runbook_not_published import RunbookNotPublished
from domain.logging.query_loggin import log_query
from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments, lookup_tenants, \
    lookup_runbooks
from domain.response.copilot_response import CopilotResponse
from infrastructure.callbacks import save_callback
from infrastructure.octopus import run_published_runbook_fuzzy, get_project


def run_runbook_confirm_callback_wrapper(url, api_key):
    def run_runbook_confirm_callback(space_id, project_name, project_id, runbook_name, environment_name, tenant_name):
        log_query("run_runbook_confirm_callback", f"""
            Space: {space_id}
            Project Names: {project_name}
            Runbook Names: {runbook_name}
            Tenant Names: {environment_name}
            Environment Names: {tenant_name}}""")

        try:
            response = run_published_runbook_fuzzy(space_id,
                                                   project_name,
                                                   runbook_name,
                                                   environment_name,
                                                   tenant_name,
                                                   api_key,
                                                   url)

            return CopilotResponse(
                f"[Runbook Run]({url}/app#/{space_id}/projects/{project_id}/operations/runbooks/{response['RunbookId']}/snapshots/{response['RunbookSnapshotId']}/runs/{response['Id']})")
        except RunbookNotPublished as e:
            return CopilotResponse(f"The runbook {runbook_name} must be published")

    return run_runbook_confirm_callback


def run_runbook_wrapper(url, api_key, github_user, original_query, connection_string):
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

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "runbook_name": sanitized_runbook_names[0],
            "environment_name": sanitized_environment_names[0],
            "tenant_name": sanitized_tenant_names[0] if sanitized_tenant_names else None
        }

        log_query("run_runbook", f"""
Space: {arguments["space_id"]}
Project Names: {arguments["project_name"]}
Runbook Names: {arguments["runbook_name"]}
Tenant Names: {arguments["tenant_name"]}
Environment Names: {arguments["environment_name"]}""")

        save_callback(github_user,
                      run_runbook.__name__,
                      callback_id,
                      json.dumps(arguments),
                      original_query,
                      connection_string)
        return CopilotResponse("Run a runbook",
                               f"Do you want to continue running the runbook {sanitized_runbook_names[0]} "
                               + f"in the project {sanitized_project_names[0]} in the space {actual_space_name}?",
                               "Please confirm the runbook name, project name, and space name are correct before proceeding.",
                               callback_id)

    return run_runbook
