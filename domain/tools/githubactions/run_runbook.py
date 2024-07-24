import json
import uuid

from domain.exceptions.runbook_not_published import RunbookNotPublished
from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments, lookup_tenants, \
    lookup_runbooks
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import run_published_runbook_fuzzy, get_project, get_runbook_fuzzy, get_environment


def run_runbook_confirm_callback_wrapper(github_user, url, api_key, log_query):
    def run_runbook_confirm_callback(space_id, project_name, project_id, runbook_name, environment_name, tenant_name):
        debug_text = get_params_message(github_user, True,
                                        run_runbook_confirm_callback.__name__,
                                        space_id=space_id,
                                        project_name=project_name,
                                        runbook_name=runbook_name,
                                        environment_name=environment_name,
                                        tenant_name=tenant_name)

        log_query("run_runbook_confirm_callback", f"""
            Space: {space_id}
            Project Names: {project_name}
            Runbook Names: {runbook_name}
            Tenant Names: {tenant_name}
            Environment Names: {environment_name}""")

        response_text = []

        try:
            response = run_published_runbook_fuzzy(space_id,
                                                   project_name,
                                                   runbook_name,
                                                   environment_name,
                                                   tenant_name,
                                                   api_key,
                                                   url,
                                                   log_query)

            response_text.append(
                f"{runbook_name}\n\n[Runbook Run]({url}/app#/{space_id}/projects/{project_id}/operations/runbooks/{response['RunbookId']}/snapshots/{response['RunbookSnapshotId']}/runs/{response['Id']})")
        except RunbookNotPublished as e:
            response_text.append(f"The runbook {runbook_name} must be published")

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return run_runbook_confirm_callback


def run_runbook_wrapper(url, api_key, github_user, original_query, connection_string, log_query):
    def run_runbook(space_name=None, project_name=None, runbook_name=None, environment_name=None, tenant_name=None, **kwargs):
        """
        Runs a published runbook in Octopus Deploy.

        Args:
        space_name: The name of the space
        project_name: The name of the project
        runbook_name: The name of the runbook
        environment_name: The name of the environment
        tenant_name: The optional name of the tenant
        """

        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

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

        # Make sure the environment was valid
        runbook = get_runbook_fuzzy(space_id, project["Id"], sanitized_runbook_names[0], api_key, url)
        runbook_environments = [get_environment(space_id, x, api_key, url)["Name"] for x in
                                runbook["Environments"]]
        valid = any(filter(lambda x: x == sanitized_environment_names[0], runbook_environments))
        if not valid:
            return CopilotResponse(
                f"The environment \"{sanitized_environment_names[0]}\" is not valid for the runbook \"{sanitized_runbook_names[0]}\". "
                + "Valid environments are " + ", ".join(runbook_environments) + ".")

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

        if arguments["tenant_name"]:
            return CopilotResponse("Run a runbook",
                                   f"Do you want to continue running the runbook \"{sanitized_runbook_names[0]}\" "
                                   + f"in the project \"{sanitized_project_names[0]}\" for the environment \"{sanitized_environment_names[0]}\" and tenant \"{arguments['tenant_name']}\" in the space \"{actual_space_name}\"?",
                                   "Please confirm the runbook name, project name, tenant name, and space name are correct before proceeding.",
                                   callback_id)

        return CopilotResponse("Run a runbook",
                               f"Do you want to continue running the runbook \"{sanitized_runbook_names[0]}\" "
                               + f"in the project \"{sanitized_project_names[0]}\" for the environment \"{sanitized_environment_names[0]}\" in the space \"{actual_space_name}\"?",
                               "Please confirm the runbook name, project name, and space name are correct before proceeding.",
                               callback_id)

    return run_runbook
