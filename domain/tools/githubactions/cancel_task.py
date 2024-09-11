import asyncio
import json
import uuid

from domain.exceptions.none_on_exception import none_on_exception
from domain.lookup.octopus_lookups import lookup_space, lookup_projects
from domain.response.copilot_response import CopilotResponse
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import (
    get_project,
    cancel_server_task,
    get_task_details_async,
)


def cancel_task_confirm_callback_wrapper(github_user, octopus_details, log_query):
    def cancel_task_confirm_callback(space_id, project_name, project_id, task_id):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            cancel_task_confirm_callback.__name__,
            space_id=space_id,
            project_name=project_name,
            project_id=project_id,
            task_id=task_id,
        )

        log_query(
            "cancel_task_confirm_callback",
            f"""
            Space Id: {space_id}
            Project Name: {project_name}
            Project Id: {project_id}
            Task Id: {task_id}""",
        )

        cancel_response = cancel_server_task(space_id, task_id, api_key, url)

        if cancel_response is None:
            response = f"Unable to cancel task. Please check and retry\n\n[View task]({url}/app#/{space_id}/tasks/{task_id}"
            return CopilotResponse(response)

        response_text = [
            f"{project_name}\n\n⛔ Task canceled\n\n[View task]({url}/app#/{space_id}/tasks/{cancel_response['Id']})"
        ]

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                cancel_task_confirm_callback.__name__,
                space_id=space_id,
                project_name=project_name,
                project_id=project_id,
                task_id=cancel_response["Id"],
            )
        )

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return cancel_task_confirm_callback


def cancel_task_callback(octopus_details, github_user, connection_string, log_query):
    def cancel_task(original_query, space_name=None, project_name=None, task_id=None):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            cancel_task.__name__,
            space_name=space_name,
            task_id=task_id,
            project_name=project_name,
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

        if task_id.startswith("ServerTasks-"):
            task_response = none_on_exception(
                lambda: asyncio.run(
                    get_task_details_async(space_id, task_id, api_key, url)
                )
            )
            if task_response is None:
                return CopilotResponse(
                    "⚠️ Unable to determine task to cancel from query."
                )
            else:
                task = task_response["Task"]
                actual_task_id = task["Id"]
        else:
            return CopilotResponse(
                f'⚠️ Unable to determine task to cancel from: "{task_id}".'
            )

        if task["State"] == "Canceled" or task["State"] == "Cancelling":
            return CopilotResponse("⚠️ Task already cancelled.")

        callback_id = str(uuid.uuid4())

        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "task_id": actual_task_id,
        }

        log_query(
            "cancel_task",
            f"""
            Space: {arguments["space_id"]}
            Project Name: {arguments["project_name"]}
            Project Id: {arguments["project_id"]}
            Task Id: {arguments["task_id"]}""",
        )

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                cancel_task.__name__,
                space_name=actual_space_name,
                space_id=space_id,
                project_name=sanitized_project_names,
                project_id=project["Id"],
                task_id=actual_task_id,
            )
        )

        save_callback(
            github_user,
            cancel_task.__name__,
            callback_id,
            json.dumps(arguments),
            original_query,
            connection_string,
        )

        response = ["Cancel task"]
        response.extend(warnings)
        response.extend(debug_text)

        prompt_title = f"Do you want to cancel the task?"
        prompt_message = [
            "Please confirm the details below are correct before proceeding:"
            f"\n* Project: **{sanitized_project_names[0]}**",
            f"\n* Space: **{actual_space_name}**",
            f"\n* Task: **{task['Description']}**",
        ]

        return CopilotResponse(
            "\n\n".join(response), prompt_title, "".join(prompt_message), callback_id
        )

    return cancel_task
