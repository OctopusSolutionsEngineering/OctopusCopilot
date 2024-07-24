import json
import uuid

from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments, lookup_tenants
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import get_project, create_release_fuzzy, \
    get_project_version_controlled_branch, get_default_channel, \
    get_version_controlled_project_release_template, get_channel_by_name, \
    get_release_template_and_default_branch, get_environment, get_lifecycle, deploy_release_fuzzy


def create_release_confirm_callback_wrapper(github_user, url, api_key, log_query):
    def create_release_confirm_callback(space_id, project_name, project_id, git_ref, release_version, channel_name,
                                        environment_name, tenant_name):
        debug_text = get_params_message(github_user, True,
                                        create_release_confirm_callback.__name__,
                                        space_id=space_id,
                                        project_name=project_name,
                                        project_id=project_id,
                                        git_ref=git_ref,
                                        release_version=release_version,
                                        channel_name=channel_name,
                                        environment_name=environment_name,
                                        tenant_name=tenant_name)

        log_query("create_release_confirm_callback", f"""
            Space: {space_id}
            Project Name: {project_name}
            Project Id: {project_id}
            GitRef: {git_ref}
            Version: {release_version}
            Channel Name: {channel_name}
            Environment Name: {environment_name}
            Tenant Name: {tenant_name}""")

        response_text = []

        # create release
        response = create_release_fuzzy(space_id,
                                        project_name,
                                        git_ref,
                                        release_version,
                                        channel_name,
                                        api_key,
                                        url,
                                        log_query)
        response_release_version = response['Version']
        release_id = response['Id']
        response_text.append(
            f"{project_name}\n\n* [Release {response_release_version}]({url}/app#/{space_id}/projects/{project_id}/deployments/releases/{response_release_version})")

        # Only deploy if environment specified
        deployment_id = None
        if environment_name:
            deploy_response = deploy_release_fuzzy(space_id,
                                                   project_id,
                                                   release_id,
                                                   environment_name,
                                                   tenant_name,
                                                   api_key,
                                                   url,
                                                   log_query)

            response_text.append(
                f'* [Deployment of {project_name} release {response_release_version} to {environment_name} {"for " + tenant_name if tenant_name else ""}]({url}/app#/{space_id}/tasks/{deploy_response["TaskId"]})')

        debug_text = get_params_message(github_user, False,
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
                                        deployment_id=deployment_id)

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return create_release_confirm_callback


def create_release_wrapper(url, api_key, github_user, original_query, connection_string, log_query):
    def create_release(space_name=None, project_name=None, git_ref=None, release_version=None, channel_name=None,
                       environment_name=None, tenant_name=None):
        """
        Create a release in Octopus Deploy.

        Args:
        space_name: The name of the space
        project_name: The name of the project
        git_ref: The git reference for the release if the project is version-controlled
        release_version: The release version
        channel_name: The name of the channel
        environment_name: The (optional) name of the environment to deploy to.
        tenant_name: The (optional) name of the tenant to deploy to.
        """
        debug_text = get_params_message(github_user, True,
                                        create_release.__name__,
                                        space_name=space_name,
                                        project_name=project_name,
                                        git_ref=git_ref,
                                        release_version=release_version,
                                        channel_name=channel_name,
                                        environment_name=environment_name,
                                        tenant_name=tenant_name)

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_tenant_names = lookup_tenants(url, api_key, github_user, original_query, space_id, tenant_name)
        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)

        if not channel_name:
            channel = get_default_channel(space_id, project['Id'], api_key, url)
            warnings.append(f"The query did not specify a channel, so the default channel was assumed.")
        else:
            channel = get_channel_by_name(space_id, project['Id'], channel_name, api_key, url)

        release_template, default_branch = get_release_template_and_default_branch(
            space_id, project, channel['Id'], git_ref, api_key,
            url)

        if not release_version:
            release_version = release_template['NextVersionIncrement']

        if project['IsVersionControlled']:
            if not git_ref:
                git_ref = default_branch
                warnings.append(
                    f"The query did not specify a GitRef for the version-controlled project, so the default "
                    f"branch named {default_branch} was assumed.")
        else:
            if git_ref:
                warnings.append(f"The query specified a GitRef for a project that isn't under version-control, "
                                f"so this was ignored.")
                git_ref = None

        # Validate deployment environment if supplied
        if environment_name:
            sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                              environment_name)
            lifecycle_id = channel['LifecycleId']
            if not lifecycle_id:
                lifecycle_id = project['LifecycleId']

            lifecycle = get_lifecycle(api_key, url, space_id, lifecycle_id)
            lifecycle_environments = [target for phase in lifecycle['Phases'] for target in
                                      (phase["AutomaticDeploymentTargets"] + phase["OptionalDeploymentTargets"]) if
                                      target]
            project_environments = [get_environment(space_id, x, api_key, url)["Name"] for x in
                                    lifecycle_environments]
            valid = any(filter(lambda x: x == sanitized_environment_names[0], project_environments))
            if not valid:
                return CopilotResponse(
                    f"The environment \"{sanitized_environment_names[0]}\" is not valid for the project \"{sanitized_project_names[0]}\". "
                    + "Valid environments are " + ", ".join(project_environments) + ".")

            # TODO: Consider adding a check for tenant being connected to this project and deployment environment

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "git_ref": git_ref,
            "release_version": release_version,
            "channel_name": channel["Name"],
            "environment_name": sanitized_environment_names[0] if sanitized_environment_names else None,
            "tenant_name": sanitized_tenant_names[0] if sanitized_tenant_names else None
        }

        log_query("create_release", f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}
            Project Id: {arguments["project_id"]}
            GitRef: {arguments["git_ref"]}
            Version: {arguments["release_version"]}
            Channel Name: {arguments["channel_name"]}
            Environment Name: {arguments["environment_name"]}
            Tenant Name: {arguments["tenant_name"]}""")

        debug_text = get_params_message(github_user, False,
                                        create_release.__name__,
                                        space_name=actual_space_name,
                                        space_id=space_id,
                                        project_name=sanitized_project_names,
                                        project_id=project["Id"],
                                        git_ref=git_ref,
                                        release_version=release_version,
                                        channel_name=channel['Name'],
                                        environment_name=sanitized_environment_names,
                                        tenant_name=sanitized_tenant_names)
        save_callback(github_user,
                      create_release.__name__,
                      callback_id,
                      json.dumps(arguments),
                      original_query,
                      connection_string)

        response = ["Create a release"]
        response.extend(warnings)
        response.extend(debug_text)

        prompt_title = [
            f"Do you want to create a release in the project \"{sanitized_project_names[0]}\" with version \"{release_version}\" ",
            f"in the space \"{actual_space_name}\"?"]
        prompt_message = ["Please confirm the details below are correct before proceeding:"
                          f"\n* Project: **{sanitized_project_names[0]}**"
                          f"\n* Channel: **{channel['Name']}**"
                          f"\n* Version: **{release_version}**"]
        if git_ref:
            prompt_message.append(f"\n* GitRef: **{git_ref}**")
        if environment_name:
            prompt_message.append(f"\n* Deployment environment: **{sanitized_environment_names[0]}**")
        if tenant_name:
            prompt_message.append(f"\nDeployment Tenant: **{sanitized_tenant_names[0]}**")

        prompt_message.append(f"\n* Space: **{actual_space_name}**")
        return CopilotResponse("\n\n".join(response), "".join(prompt_title), "".join(prompt_message), callback_id)

    return create_release
