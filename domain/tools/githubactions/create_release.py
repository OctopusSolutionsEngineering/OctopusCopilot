import json
import uuid

from domain.lookup.octopus_lookups import lookup_space, lookup_projects
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import get_project, create_release_fuzzy, \
    get_project_version_controlled_branch, get_default_channel, \
    get_version_controlled_project_release_template, get_channel_by_name, \
    get_release_template_and_default_branch_canonical_name


def create_release_confirm_callback_wrapper(github_user, url, api_key, log_query):
    def create_release_confirm_callback(space_id, project_name, project_id, git_ref, release_version, channel_name):
        debug_text = get_params_message(github_user, True,
                                        create_release_confirm_callback.__name__,
                                        space_id=space_id,
                                        project_name=project_name)

        log_query("create_release_confirm_callback", f"""
            Space: {space_id}
            Project Name: {project_name}""
            Project Id: {project_id}""
            GitRef: {git_ref}"
            Release Version: {release_version}"
            Channel Name: {channel_name}""")

        response_text = []

        response = create_release_fuzzy(space_id,
                                        project_name,
                                        git_ref,
                                        release_version,
                                        channel_name,
                                        api_key,
                                        url,
                                        log_query)

        response_text.append(
            f"{project_name}\n\n[Release {response['Version']}]({url}/app#/{space_id}/projects/{project_id}/deployments/releases/{response['Version']})")

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return create_release_confirm_callback


def create_release_wrapper(url, api_key, github_user, original_query, connection_string, log_query):
    def create_release(space_name=None, project_name=None, git_ref=None, release_version=None, channel_name=None):
        """
        Create a release in Octopus Deploy.

        Args:
        space_name: The name of the space
        project_name: The name of the project
        git_ref: The git reference for the release if the project is version-controlled
        release_version: The release version
        channel_name: The name of the channel
        """

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        if not channel_name:
            channel = get_default_channel(space_id, project['Id'], api_key, url)
            warnings.append(f"The query did not specify a channel, so the default channel was assumed.")
        else:
            channel = get_channel_by_name(space_id, project['Id'], channel_name, api_key, url)

        release_template, default_branch_canonical_name = get_release_template_and_default_branch_canonical_name(
            space_id, project, channel['Id'], git_ref, api_key,
            url)

        if not release_version:
            release_version = release_template['NextVersionIncrement']

        if project['IsVersionControlled']:
            if not git_ref:
                warnings.append(
                    f"The query did not specify a GitRef for the version-controlled project, so the default "
                    f"branch named {default_branch_canonical_name} was assumed.")
        else:
            if git_ref:
                warnings.append(f"The query specified a GitRef for a project that isn't under version-control, "
                                f"so this was ignored.")
                git_ref = None

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "git_ref": git_ref,
            "release_version": release_version,
            "channel_name": channel["Name"],
        }

        log_query("create_release", f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}"
            Project Id: {arguments["project_id"]}"
            GitRef: {arguments["git_ref"]}"
            Release Version: {arguments["release_version"]}"
            Channel Name: {arguments["channel_name"]}""")

        save_callback(github_user,
                      create_release.__name__,
                      callback_id,
                      json.dumps(arguments),
                      original_query,
                      connection_string)

        return CopilotResponse("Create a release",
                               f"Do you want to continue to create a release "
                               + f"in the project \"{sanitized_project_names[0]}\" with version \"{release_version}\" "
                               + f"(GitRef \"{git_ref}\") " if git_ref else "" + f"in the space \"{actual_space_name}\"?",
                               "Please confirm the project name, release version, " + "git ref, " if git_ref else "" + "and space name are correct before proceeding.",
                               callback_id)

    return create_release
