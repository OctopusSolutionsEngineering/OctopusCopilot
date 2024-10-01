import json
import uuid

from domain.exceptions.prompted_variable_match_error import (
    PromptedVariableMatchingError,
)
from domain.lookup.octopus_lookups import (
    lookup_space,
    lookup_projects,
    lookup_environments,
    lookup_tenants,
)
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import (
    get_project,
    get_environment,
    get_lifecycle,
    deploy_release_fuzzy,
    get_environment_fuzzy,
    get_release_fuzzy,
    get_channel,
    get_release,
    match_deployment_variables,
    get_space,
)


def deploy_release_confirm_callback_wrapper(github_user, octopus_details, log_query):
    def deploy_release_confirm_callback(
        space_id,
        project_name,
        project_id,
        release_version,
        release_id,
        environment_name,
        environment_id,
        tenant_name,
        variables,
    ):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            deploy_release_confirm_callback.__name__,
            space_id=space_id,
            project_name=project_name,
            project_id=project_id,
            release_version=release_version,
            release_id=release_id,
            environment_name=environment_name,
            environment_id=environment_id,
            tenant_name=tenant_name,
            variables=variables,
        )

        log_query(
            "deploy_release_confirm_callback",
            f"""
            Space: {space_id}
            Project Name: {project_name}
            Project Id: {project_id}
            Version: {release_version}
            Release Id: {release_id}
            Environment Name: {environment_name}
            Environment Id: {environment_id}
            Tenant Name: {tenant_name}
            Variables: {variables}""",
        )

        response_text = []

        # Get release
        release = get_release(space_id, release_id, api_key, url)

        space = get_space(space_id, api_key, url)

        if release is None:
            return CopilotResponse("The release was not found.")

        deployment_id = None
        matching_variables = None
        # deploy release
        try:
            environment = get_environment_fuzzy(
                space_id, environment_name, api_key, url
            )

            if variables is not None:
                matching_variables = {
                    k: v["Value"]
                    for k, v in match_deployment_variables(
                        space_id, release_id, environment["Id"], variables, api_key, url
                    )[0].items()
                }
            response = deploy_release_fuzzy(
                space_id,
                project_id,
                release["Id"],
                environment["Id"],
                tenant_name,
                matching_variables,
                api_key,
                url,
                log_query,
            )
            deployment_id = response["Id"]

            response_text.append(
                f'* [Deployment of {project_name} release {release_version} to {environment_name} {"for " + tenant_name if tenant_name else ""}]({url}/app#/{space_id}/tasks/{response["TaskId"]})'
            )

        except PromptedVariableMatchingError as e:
            response_text.append(f"❌ {e.error_message}")

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                deploy_release_confirm_callback.__name__,
                space_id=space_id,
                project_name=project_name,
                project_id=project_id,
                release_version=release_version,
                release_id=release["Id"],
                environment_name=environment_name,
                environment_id=environment_id,
                tenant_name=tenant_name,
                deployment_id=deployment_id,
            )
        )

        response_text.extend(
            [
                "### Suggested Prompts",
                f'* Show me the project dashboard for "{project_name}" in the space "{space["Name"]}"',
                f'* Show me the task summary for the latest release of the project "{project_name}" in the "{environment_name}" environment in the space "{space["Name"]}"',
                f'* Summarize the deployment logs for the latest deployment for the project "{project_name}" in the "{environment_name}" environment in the space "{space["Name"]}"',
            ]
        )

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return deploy_release_confirm_callback


def deploy_release_callback(octopus_details, github_user, connection_string, log_query):
    def deploy_release(
        original_query,
        space_name=None,
        project_name=None,
        release_version=None,
        environment_name=None,
        tenant_name=None,
        variables=None,
    ):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            deploy_release.__name__,
            space_name=space_name,
            project_name=project_name,
            release_version=release_version,
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

        sanitized_environment_names = lookup_environments(
            url, api_key, github_user, original_query, space_id, environment_name
        )

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        actual_environment = get_environment_fuzzy(
            space_id, sanitized_environment_names[0], api_key, url
        )

        if not release_version:
            return CopilotResponse("Please specify a release version in the query.")

        # get release
        release = get_release_fuzzy(
            space_id, project["Id"], release_version, api_key, url
        )

        # get (optional) tenant
        sanitized_tenant_names = None
        if tenant_name:
            sanitized_tenant_names = lookup_tenants(
                url, api_key, github_user, original_query, space_id, tenant_name
            )

        # get channel and lifecycle
        channel = get_channel(space_id, release["ChannelId"], api_key, url)
        lifecycle_id = channel["LifecycleId"]
        if not lifecycle_id:
            lifecycle_id = project["LifecycleId"]

        lifecycle = get_lifecycle(api_key, url, space_id, lifecycle_id)
        lifecycle_environments = [
            target
            for phase in lifecycle["Phases"]
            for target in (
                phase["AutomaticDeploymentTargets"] + phase["OptionalDeploymentTargets"]
            )
            if target
        ]
        project_environments = [
            get_environment(space_id, x, api_key, url)["Name"]
            for x in lifecycle_environments
        ]
        valid = any(
            filter(lambda x: x == sanitized_environment_names[0], project_environments)
        )
        if not valid:
            return CopilotResponse(
                f'The environment "{sanitized_environment_names[0]}" is not valid for the project "{sanitized_project_names[0]}". '
                + "Valid environments are "
                + ", ".join(project_environments)
                + "."
            )

        # TODO: 1. Consider adding a check for tenant being connected to this project and deployment environment
        # TODO: 2. Add validation if a runbook has required prompted variables and none are supplied in the prompt

        matching_variables = None
        if variables is not None:
            try:
                prompted_variables, variable_warning = match_deployment_variables(
                    space_id,
                    release["Id"],
                    actual_environment["Id"],
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

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "release_version": release_version,
            "release_id": release["Id"],
            "environment_name": actual_environment["Name"],
            "environment_id": actual_environment["Id"],
            "tenant_name": (
                sanitized_tenant_names[0] if sanitized_tenant_names else None
            ),
            "variables": matching_variables,
        }

        log_query(
            "deploy_release",
            f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}
            Project Id: {arguments["project_id"]}
            Version: {arguments["release_version"]}
            Release Id: {arguments["release_id"]}
            Environment Name: {arguments["environment_name"]}
            Environment Id: {arguments["environment_id"]}
            Tenant Name: {arguments["tenant_name"]}
            Variables: {arguments["variables"]}""",
        )

        debug_text = get_params_message(
            github_user,
            False,
            deploy_release.__name__,
            space_name=actual_space_name,
            space_id=space_id,
            project_name=sanitized_project_names,
            project_id=project["Id"],
            release_version=release_version,
            release_id=release["Id"],
            environment_name=actual_environment["Name"],
            tenant_name=sanitized_tenant_names,
            variables=variables,
        )
        save_callback(
            github_user,
            deploy_release.__name__,
            callback_id,
            json.dumps(arguments),
            original_query,
            connection_string,
        )

        response = ["Deploy a release"]
        response.extend(warnings)
        response.extend(debug_text)

        prompt_title = "Do you want to continue to deploy a release?"
        prompt_message = [
            "Please confirm the details below are correct before proceeding:"
            f"\n* Project: **{sanitized_project_names[0]}**"
            f"\n* Version: **{release_version}**"
            f"\n* Environment: **{actual_environment['Name']}**"
        ]
        if tenant_name:
            prompt_message.append(f"\n* Tenant: **{sanitized_tenant_names[0]}**")

        if matching_variables is not None:
            prompt_message.append(f"\n* Variables:")
            for variable in matching_variables.keys():
                prompt_message.append(f"\n\t* **{variable}** = {variables[variable]}")

        prompt_message.append(f"\n* Space: **{actual_space_name}**")
        return CopilotResponse(
            "\n\n".join(response), prompt_title, "".join(prompt_message), callback_id
        )

    return deploy_release
