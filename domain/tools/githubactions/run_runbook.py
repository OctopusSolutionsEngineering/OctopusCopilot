import json
import uuid

from domain.exceptions.prompted_variable_match_error import (
    PromptedVariableMatchingError,
)
from domain.exceptions.runbook_not_published import RunbookNotPublished
from domain.lookup.octopus_lookups import (
    lookup_space,
    lookup_projects,
    lookup_environments,
    lookup_tenants,
    lookup_runbooks,
)
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import (
    run_published_runbook_fuzzy,
    get_project,
    get_runbook_fuzzy,
    runbook_environment_valid,
    match_runbook_variables,
    get_space,
)


def run_runbook_confirm_callback_wrapper(github_user, octopus_details, log_query):
    def run_runbook_confirm_callback(
        space_id,
        project_name,
        project_id,
        runbook_name,
        environment_name,
        tenant_name,
        variables,
    ):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            run_runbook_confirm_callback.__name__,
            space_id=space_id,
            project_name=project_name,
            runbook_name=runbook_name,
            environment_name=environment_name,
            tenant_name=tenant_name,
            variables=variables,
        )

        log_query(
            "run_runbook_confirm_callback",
            f"""
            Space: {space_id}
            Project Names: {project_name}
            Runbook Names: {runbook_name}
            Tenant Names: {tenant_name}
            Environment Names: {environment_name}
            Variables: {variables}""",
        )

        space = get_space(space_id, api_key, url)

        response_text = []

        try:
            response = run_published_runbook_fuzzy(
                space_id,
                project_name,
                runbook_name,
                environment_name,
                tenant_name,
                variables,
                api_key,
                url,
                log_query,
            )

            response_text.append(
                f"{runbook_name}\n\n[Runbook Run]({url}/app#/{space_id}/projects/{project_id}/operations/runbooks/{response['RunbookId']}/snapshots/{response['RunbookSnapshotId']}/runs/{response['Id']})"
            )
        except RunbookNotPublished as e:
            response_text.append(f'The runbook "{runbook_name}" must be published')
        except PromptedVariableMatchingError as e:
            response_text.append(f"❌ {e.error_message}")

        response_text.extend(
            [
                "### Suggested Prompts",
                f'* Show me the runbook dashboard for "{runbook_name}" in the project "{project_name}" in the space "{space["Name"]}"',
                f'* Summarize the execution logs of the latest run of runbook "{runbook_name}" in the project "{project_name}" in the space "{space["Name"]}" in the "{environment_name}" environment',
            ]
        )

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return run_runbook_confirm_callback


def run_runbook_callback(octopus_details, github_user, connection_string, log_query):
    def run_runbook(
        original_query,
        space_name=None,
        project_name=None,
        runbook_name=None,
        environment_name=None,
        tenant_name=None,
        variables=None,
    ):

        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            run_runbook.__name__,
            space_name=space_name,
            project_name=project_name,
            runbook_name=runbook_name,
            environment_name=environment_name,
            tenant_name=tenant_name,
            variables=variables,
        )

        space_id, actual_space_name, warnings = lookup_space(
            url, api_key, github_user, original_query, space_name
        )
        sanitized_project_names, sanitized_projects = lookup_projects(
            url, api_key, github_user, original_query, space_id, project_name
        )

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_tenant_names = lookup_tenants(
            url, api_key, github_user, original_query, space_id, tenant_name
        )
        sanitized_environment_names = lookup_environments(
            url, api_key, github_user, original_query, space_id, environment_name
        )
        sanitized_runbook_names = lookup_runbooks(
            url,
            api_key,
            github_user,
            original_query,
            space_id,
            project["Id"],
            runbook_name,
        )

        if not sanitized_runbook_names:
            return CopilotResponse("Please specify a runbook name in the query.")

        runbook = get_runbook_fuzzy(
            space_id, project["Id"], sanitized_runbook_names[0], api_key, url
        )

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        valid, error_message = runbook_environment_valid(
            space_id,
            project["Id"],
            runbook,
            sanitized_environment_names[0],
            api_key,
            url,
        )

        if not valid:
            return CopilotResponse(error_message)

        # TODO: Add validation if a runbook has required prompted variables and none are supplied in the prompt
        matching_variables = None
        if variables is not None:
            try:

                prompted_variables, variable_warning = match_runbook_variables(
                    space_id,
                    project["Id"],
                    sanitized_runbook_names[0],
                    runbook["PublishedRunbookSnapshotId"],
                    sanitized_environment_names[0],
                    variables,
                    api_key,
                    url,
                )
                # We return the names here (instead of ID), as they'll be returned to the copilot extension
                matching_variables = {
                    v["Name"]: v["Value"] for k, v in prompted_variables.items()
                }

                if variable_warning:
                    warnings.append(variable_warning)

            except PromptedVariableMatchingError as e:
                return CopilotResponse(f"❌ {e.error_message}")
            except RunbookNotPublished as e:
                return CopilotResponse("❌ Runbook is not published")

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "runbook_name": sanitized_runbook_names[0],
            "environment_name": sanitized_environment_names[0],
            "tenant_name": (
                sanitized_tenant_names[0] if sanitized_tenant_names else None
            ),
            "variables": matching_variables,
        }

        log_query(
            "run_runbook",
            f"""
            Space: {arguments["space_id"]}
            Project Names: {arguments["project_name"]}
            Runbook Names: {arguments["runbook_name"]}
            Tenant Names: {arguments["tenant_name"]}
            Environment Names: {arguments["environment_name"]}
            Variables: {arguments["variables"]}""",
        )

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                run_runbook.__name__,
                space_name=actual_space_name,
                project_name=sanitized_project_names,
                runbook_name=sanitized_runbook_names,
                environment_name=environment_name,
                tenant_name=sanitized_tenant_names,
                variables=variables,
            )
        )

        save_callback(
            github_user,
            run_runbook.__name__,
            callback_id,
            json.dumps(arguments),
            original_query,
            connection_string,
        )

        prompt_title = "Do you want to continue running the runbook?"
        prompt_message = [
            "Please confirm the details below are correct before proceeding:"
            f"\n* Project: **{sanitized_project_names[0]}**"
            f"\n* Runbook: **{sanitized_runbook_names[0]}**",
            f"\n* Environment: **{sanitized_environment_names[0]}**",
        ]
        if arguments["tenant_name"]:
            prompt_message.append(f"\n* Tenant: **{arguments['tenant_name']}**")
        if matching_variables is not None:
            prompt_message.append(f"\n* Variables:")
            for variable in matching_variables.keys():
                prompt_message.append(f"\n\t* **{variable}** = {variables[variable]}")

        prompt_message.append(f"\n* Space: **{actual_space_name}**")

        response = ["Run a runbook"]
        response.extend(debug_text)
        response.extend(warnings)
        return CopilotResponse(
            "\n\n".join(response), prompt_title, "".join(prompt_message), callback_id
        )

    return run_runbook
