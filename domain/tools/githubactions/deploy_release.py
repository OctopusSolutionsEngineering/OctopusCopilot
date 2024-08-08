import json
import uuid

from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments, lookup_tenants
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import get_project, get_environment, get_lifecycle, deploy_release_fuzzy, \
    get_environment_fuzzy, get_release_fuzzy, get_channel, get_release


def deploy_release_confirm_callback_wrapper(github_user, url, api_key, log_query):
    def deploy_release_confirm_callback(space_id, project_name, project_id, release_version, release_id,
                                        environment_name, environment_id, tenant_name):
        debug_text = get_params_message(github_user, True,
                                        deploy_release_confirm_callback.__name__,
                                        space_id=space_id,
                                        project_name=project_name,
                                        project_id=project_id,
                                        release_version=release_version,
                                        release_id=release_id,
                                        environment_name=environment_name,
                                        environment_id=environment_id,
                                        tenant_name=tenant_name)

        log_query("deploy_release_confirm_callback", f"""
            Space: {space_id}
            Project Name: {project_name}
            Project Id: {project_id}
            Version: {release_version}
            Release Id: {release_id}
            Environment Name: {environment_name}
            Environment Id: {environment_id}
            Tenant Name: {tenant_name}""")

        response_text = []

        # Get release
        release = get_release(space_id, release_id, api_key, url)

        if release is None:
            return CopilotResponse("The release was not found.")

        # deploy release
        response = deploy_release_fuzzy(space_id,
                                        project_id,
                                        release['Id'],
                                        environment_name,
                                        tenant_name,
                                        api_key,
                                        url,
                                        log_query)

        response_text.append(
            f'* [Deployment of {project_name} release {release_version} to {environment_name} {"for " + tenant_name if tenant_name else ""}]({url}/app#/{space_id}/tasks/{response["TaskId"]})')

        debug_text.extend(get_params_message(github_user, False,
                                             deploy_release_confirm_callback.__name__,
                                             space_id=space_id,
                                             project_name=project_name,
                                             project_id=project_id,
                                             release_version=release_version,
                                             release_id=release['Id'],
                                             environment_name=environment_name,
                                             environment_id=environment_id,
                                             tenant_name=tenant_name,
                                             deployment_id=response['Id']))

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return deploy_release_confirm_callback


def deploy_release_wrapper(url, api_key, github_user, original_query, connection_string, log_query):
    def deploy_release(space_name=None, project_name=None, release_version=None, environment_name=None,
                       tenant_name=None, **kwargs):
        """
        Deploy a release in Octopus Deploy.

        Args:
        space_name: The name of the space
        project_name: The name of the project
        release_version: The release version
        environment_name: The name of the environment to deploy to.
        tenant_name: The (optional) name of the tenant to deploy to.
        """
        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        debug_text = get_params_message(github_user, True,
                                        deploy_release.__name__,
                                        space_name=space_name,
                                        project_name=project_name,
                                        release_version=release_version,
                                        environment_name=environment_name,
                                        tenant_name=tenant_name)

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        actual_environment = get_environment_fuzzy(space_id, environment_name, api_key, url)

        if not release_version:
            return CopilotResponse("Please specify a release version in the query.")

        # get release
        release = get_release_fuzzy(space_id, project['Id'], release_version, api_key, url)

        # get environment
        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)
        # get (optional) tenant
        sanitized_tenant_names = None
        if tenant_name:
            sanitized_tenant_names = lookup_tenants(url, api_key, github_user, original_query, space_id, tenant_name)

        # get channel and lifecycle
        channel = get_channel(space_id, release['ChannelId'], api_key, url)
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
            "release_version": release_version,
            "release_id": release['Id'],
            "environment_name": actual_environment['Name'],
            "environment_id": actual_environment['Id'],
            "tenant_name": sanitized_tenant_names[0] if sanitized_tenant_names else None
        }

        log_query("deploy_release", f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}
            Project Id: {arguments["project_id"]}
            Version: {arguments["release_version"]}
            Release Id: {arguments["release_id"]}
            Environment Name: {arguments["environment_name"]}
            Environment Id: {arguments["environment_id"]}
            Tenant Name: {arguments["tenant_name"]}""")

        debug_text = get_params_message(github_user, False,
                                        deploy_release.__name__,
                                        space_name=actual_space_name,
                                        space_id=space_id,
                                        project_name=sanitized_project_names,
                                        project_id=project["Id"],
                                        release_version=release_version,
                                        release_id=release['Id'],
                                        environment_name=actual_environment['Name'],
                                        tenant_name=sanitized_tenant_names)
        save_callback(github_user,
                      deploy_release.__name__,
                      callback_id,
                      json.dumps(arguments),
                      original_query,
                      connection_string)

        response = ["Deploy a release"]
        response.extend(warnings)
        response.extend(debug_text)

        prompt_title = "Do you want to continue to deploy a release?"
        prompt_message = ["Please confirm the details below are correct before proceeding:"
                          f"\n* Project: **{sanitized_project_names[0]}**"
                          f"\n* Version: **{release_version}**"
                          f"\n* Environment: **{actual_environment['Name']}**"]
        if tenant_name:
            prompt_message.append(f"\n* Tenant: **{sanitized_tenant_names[0]}**")

        prompt_message.append(f"\n* Space: **{actual_space_name}**")
        return CopilotResponse("\n\n".join(response), prompt_title, "".join(prompt_message), callback_id)

    return deploy_release
