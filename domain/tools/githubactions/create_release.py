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
    create_release_fuzzy,
    get_default_channel,
    get_channel_by_name_fuzzy,
    get_release_template_and_default_branch,
    get_environment,
    get_lifecycle,
    deploy_release_fuzzy,
    get_releases_by_version,
    match_deployment_variables,
    get_environment_fuzzy,
)


def create_release_confirm_callback_wrapper(github_user, octopus_details, log_query):
    def create_release_confirm_callback(
        space_id,
        project_name,
        project_id,
        git_ref,
        release_version,
        channel_name,
        environment_name,
        tenant_name,
        variables,
    ):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            create_release_confirm_callback.__name__,
            space_id=space_id,
            project_name=project_name,
            project_id=project_id,
            git_ref=git_ref,
            release_version=release_version,
            channel_name=channel_name,
            environment_name=environment_name,
            tenant_name=tenant_name,
            variables=variables,
        )

        log_query(
            "create_release_confirm_callback",
            f"""
            Space: {space_id}
            Project Name: {project_name}
            Project Id: {project_id}
            GitRef: {git_ref}
            Version: {release_version}
            Channel Name: {channel_name}
            Environment Name: {environment_name}
            Tenant Name: {tenant_name}
            Variables: {variables}""",
        )

        response_text = []

        # create release
        response = create_release_fuzzy(
            space_id,
            project_name,
            git_ref,
            release_version,
            channel_name,
            api_key,
            url,
            log_query,
        )
        response_release_version = response["Version"]
        release_id = response["Id"]
        response_text.append(
            f"{project_name}\n\n* [Release {response_release_version}]({url}/app#/{space_id}/projects/{project_id}/deployments/releases/{response_release_version})"
        )

        # Only deploy if environment specified
        deployment_id = None
        matching_variables = None
        if environment_name:
            try:
                # Get environment
                actual_environment = get_environment_fuzzy(
                    space_id, environment_name, api_key, url
                )
                if variables is not None:
                    matching_variables = {
                        k: v["Value"]
                        for k, v in match_deployment_variables(
                            space_id,
                            release_id,
                            actual_environment["Id"],
                            variables,
                            api_key,
                            url,
                        )[0].items()
                    }

                deploy_response = deploy_release_fuzzy(
                    space_id,
                    project_id,
                    release_id,
                    actual_environment["Id"],
                    tenant_name,
                    matching_variables,
                    api_key,
                    url,
                    log_query,
                )
                response_text.append(
                    f'* [Deployment of {project_name} release {response_release_version} to {environment_name} {"for " + tenant_name if tenant_name else ""}]({url}/app#/{space_id}/tasks/{deploy_response["TaskId"]})'
                )

            except PromptedVariableMatchingError as e:
                response_text.append(f"❌ {e.error_message}")

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                create_release_confirm_callback.__name__,
                space_id=space_id,
                project_name=project_name,
                project_id=project_id,
                git_ref=git_ref,
                release_version=response_release_version,
                release_id=release_id,
                channel_name=channel_name,
                environment_name=environment_name,
                tenant_name=tenant_name,
                deployment_id=deployment_id,
            )
        )

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return create_release_confirm_callback


def create_release_callback(octopus_details, github_user, connection_string, log_query):
    def create_release(
        original_query,
        space_name=None,
        project_name=None,
        git_ref=None,
        release_version=None,
        channel_name=None,
        environment_name=None,
        tenant_name=None,
        variables=None,
    ):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            create_release.__name__,
            space_name=space_name,
            project_name=project_name,
            git_ref=git_ref,
            release_version=release_version,
            channel_name=channel_name,
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

        if not channel_name:
            channel = get_default_channel(space_id, project["Id"], api_key, url)
            warnings.append(
                f"The query did not specify a channel, so the default channel was assumed."
            )
        else:
            channel = get_channel_by_name_fuzzy(
                space_id, project["Id"], channel_name, api_key, url
            )

        release_template, default_branch = get_release_template_and_default_branch(
            space_id, project, channel["Id"], git_ref, api_key, url
        )

        if release_version:
            existing_releases = get_releases_by_version(
                space_id, project["Id"], release_version, api_key, url
            )
            if existing_releases is not None:
                return CopilotResponse(
                    f'⚠️ Release version "{release_version}" already exists.'
                )
        else:
            release_version = release_template["NextVersionIncrement"]

        if project["IsVersionControlled"]:
            if not git_ref:
                git_ref = default_branch
                warnings.append(
                    f"The query did not specify a GitRef for the version-controlled project, so the default "
                    f"branch named {default_branch} was assumed."
                )
        else:
            if git_ref:
                warnings.append(
                    f"The query specified a GitRef for a project that isn't under version-control, "
                    f"so this was ignored."
                )
                git_ref = None

        # Validate deployment environment if supplied
        if environment_name:
            sanitized_environment_names = lookup_environments(
                url, api_key, github_user, original_query, space_id, environment_name
            )
            lifecycle_id = channel["LifecycleId"]
            if not lifecycle_id:
                lifecycle_id = project["LifecycleId"]

            lifecycle = get_lifecycle(api_key, url, space_id, lifecycle_id)
            lifecycle_environments = [
                target
                for phase in lifecycle["Phases"]
                for target in (
                    phase["AutomaticDeploymentTargets"]
                    + phase["OptionalDeploymentTargets"]
                )
                if target
            ]
            project_environments = [
                get_environment(space_id, x, api_key, url)["Name"]
                for x in lifecycle_environments
            ]
            valid = any(
                filter(
                    lambda x: x == sanitized_environment_names[0], project_environments
                )
            )
            # TODO: Consider adding a check for tenant being connected to this project and deployment environment
            if not valid:
                return CopilotResponse(
                    f'The environment "{sanitized_environment_names[0]}" is not valid for the project "{sanitized_project_names[0]}". '
                    + "Valid environments are "
                    + ", ".join(project_environments)
                    + "."
                )

            # We have to defer variable checks until after the release is created, as the release Id is needed for
            # a preview of prompted variables.

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "git_ref": git_ref,
            "release_version": release_version,
            "channel_name": channel["Name"],
            "environment_name": (
                sanitized_environment_names[0] if sanitized_environment_names else None
            ),
            "tenant_name": (
                sanitized_tenant_names[0] if sanitized_tenant_names else None
            ),
            "variables": variables,
        }

        log_query(
            "create_release",
            f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}
            Project Id: {arguments["project_id"]}
            GitRef: {arguments["git_ref"]}
            Version: {arguments["release_version"]}
            Channel Name: {arguments["channel_name"]}
            Environment Name: {arguments["environment_name"]}
            Tenant Name: {arguments["tenant_name"]}
            Variables: {arguments["variables"]}""",
        )

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                create_release.__name__,
                space_name=actual_space_name,
                space_id=space_id,
                project_name=sanitized_project_names,
                project_id=project["Id"],
                git_ref=git_ref,
                release_version=release_version,
                channel_name=channel["Name"],
                environment_name=sanitized_environment_names,
                tenant_name=sanitized_tenant_names,
            )
        )
        save_callback(
            github_user,
            create_release.__name__,
            callback_id,
            json.dumps(arguments),
            original_query,
            connection_string,
        )

        prompt_title = "Do you want to continue to create a release?"
        prompt_message = [
            "Please confirm the details below are correct before proceeding:"
            f"\n* Project: **{sanitized_project_names[0]}**"
            f"\n* Channel: **{channel['Name']}**"
            f"\n* Version: **{release_version}**"
        ]
        if git_ref:
            prompt_message.append(f"\n* GitRef: **{git_ref}**")
        if sanitized_environment_names:
            prompt_message.append(
                f"\n* Deployment environment: **{sanitized_environment_names[0]}**"
            )
        if sanitized_tenant_names:
            prompt_message.append(
                f"\n* Deployment Tenant: **{sanitized_tenant_names[0]}**"
            )
        if variables is not None:
            warnings.append(
                f"The query provided variable values. These will be validated once the release has been "
                f"created."
            )
            if isinstance(variables, dict):
                prompt_message.append(f"\n* Variables:")
                for variable in variables.keys():
                    prompt_message.append(
                        f"\n\t* **{variable}** = {variables[variable]}"
                    )

        prompt_message.append(f"\n* Space: **{actual_space_name}**")

        response = ["Create a release"]
        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse(
            "\n\n".join(response), prompt_title, "".join(prompt_message), callback_id
        )

    return create_release
