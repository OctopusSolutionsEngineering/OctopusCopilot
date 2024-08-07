import json
import uuid

from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_environments
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import get_project


def manual_intervention_confirm_callback_wrapper(github_user, url, api_key, log_query):
    def manual_intervention_confirm_callback(space_id, project_name, project_id, approve, reject, release_version,
                                             environment_name):
        debug_text = get_params_message(github_user, True,
                                        manual_intervention_confirm_callback.__name__,
                                        space_id=space_id,
                                        project_name=project_name,
                                        project_id=project_id,
                                        approve=approve,
                                        reject=reject,
                                        release_version=release_version,
                                        environment_name=environment_name)

        log_query("manual_intervention_confirm_callback", f"""
            Space: {space_id}
            Project Name: {project_name}
            Project Id: {project_id}
            Version: {release_version}
            Approve: {approve}
            Reject: {reject}
            Environment Name: {environment_name}""")

        operation = "approved" if approve else "rejected"

        response_text = []

        # TODO: Actually approve or reject manual intervention
        server_taskid = ""
        response_text.append(
            f"{project_name}\n\nManual intervention {operation}—[View task]({url}/app#/{space_id}/tasks/{server_taskid})")

        debug_text.extend(get_params_message(github_user, False,
                                             manual_intervention_confirm_callback.__name__,
                                             space_id=space_id,
                                             project_name=project_name,
                                             project_id=project_id,
                                             approve=approve,
                                             reject=reject,
                                             release_version=release_version,
                                             environment_name=environment_name,
                                             task_id=server_taskid))

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return manual_intervention_confirm_callback


def manual_intervention_wrapper(url, api_key, github_user, original_query, connection_string, log_query):
    def manual_intervention(space_name=None, project_name=None, approve=None, reject=None, release_version=None,
                            environment_name=None, **kwargs):
        """
        Handles a manual intervention request

        Args:
        space_name: The name of the space
        project_name: The name of the project
        approve: Boolean indicating if the manual intervention should be approved.
        reject: Boolean indicating if the manual intervention should be rejected.
        release_version: The release version
        environment_name: The name of the environment to deploy to.
        """
        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")


        debug_text = get_params_message(github_user, True,
                                        manual_intervention.__name__,
                                        space_name=space_name,
                                        project_name=project_name,
                                        approve=approve,
                                        reject=reject,
                                        release_version=release_version,
                                        environment_name=environment_name)

        space_id, actual_space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not approve and not reject:
            return CopilotResponse("Please specify whether to approve or reject the manual intervention.")

        if not release_version:
            return CopilotResponse("Please specify a release version in the query.")

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "approve": approve,
            "reject": reject,
            "release_version": release_version,
            "environment_name": sanitized_environment_names[0]
        }

        log_query("manual_intervention", f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}
            Project Id: {arguments["project_id"]}
            Approve: {arguments["approve"]}
            Reject: {arguments["reject"]}
            Version: {arguments["release_version"]}
            Environment Name: {arguments["environment_name"]}""")

        debug_text.extend(get_params_message(github_user, False,
                                             manual_intervention.__name__,
                                             space_name=actual_space_name,
                                             space_id=space_id,
                                             project_name=sanitized_project_names,
                                             project_id=project["Id"],
                                             release_version=release_version,
                                             approve=approve,
                                             reject=reject,
                                             environment_name=sanitized_environment_names))
        save_callback(github_user,
                      manual_intervention.__name__,
                      callback_id,
                      json.dumps(arguments),
                      original_query,
                      connection_string)

        response = ["Manual intervention"]
        response.extend(warnings)
        response.extend(debug_text)
        operation = "approve" if approve else "reject"

        prompt_title = [f"Do you want to {operation} the manual intervention?"]
        prompt_message = ["Please confirm the details below are correct before proceeding:"
                          f"\n* Project: **{sanitized_project_names[0]}**"
                          f"\n* Version: **{release_version}**"
                          f"\n* Environment: **{sanitized_environment_names[0]}**",
                          f"\n* Space: **{actual_space_name}**"]

        return CopilotResponse("\n\n".join(response), "".join(prompt_title), "".join(prompt_message), callback_id)

    return manual_intervention
