import json
import uuid

from domain.lookup.octopus_lookups import lookup_space, lookup_projects
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import get_project, create_release_fuzzy


def create_release_confirm_callback_wrapper(github_user, url, api_key, log_query):
    def create_release_confirm_callback(space_id, project_name, project_id):
        debug_text = get_params_message(github_user, True,
                                        create_release_confirm_callback.__name__,
                                        space_id=space_id,
                                        project_name=project_name)

        log_query("create_release_confirm_callback", f"""
            Space: {space_id}
            Project Names: {project_name}""")

        response_text = []

        response = create_release_fuzzy(space_id,
                                               project_name,
                                               api_key,
                                               url,
                                               log_query)

        response_text.append(
            f"\n\n[Release]({url}/app#/{space_id}/projects/{project_id}/deployments/releases/{response['Version']})")

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return create_release_confirm_callback


def create_release_wrapper(url, api_key, github_user, original_query, connection_string, log_query):
    def create_release(space_name=None, project_name=None):
        """
        Create a release in Octopus Deploy.

        Args:
        space_name: The name of the space
        project_name: The name of the project
        """

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"]
        }

        log_query("create_release", f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}""")

        save_callback(github_user,
                      create_release.__name__,
                      callback_id,
                      json.dumps(arguments),
                      original_query,
                      connection_string)


        return CopilotResponse("Create a release",
                               f"Do you want to continue to create a release "
                               + f"in the project \"{sanitized_project_names[0]}\" in the space \"{actual_space_name}\"?",
                               "Please confirm the project name, and space name are correct before proceeding.",
                               callback_id)

    return create_release
