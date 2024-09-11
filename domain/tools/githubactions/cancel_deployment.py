import json
import uuid

from domain.lookup.octopus_lookups import (
    lookup_space,
    lookup_projects,
    lookup_environments,
    lookup_tenants,
)
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.octopus import get_project, get_deployment_logs


def cancel_deployment_callback(
    octopus_details, github_user, connection_string, log_query
):
    def cancel_deployment(
        original_query,
        space_name=None,
        project_name=None,
        release_version=None,
        environment_name=None,
        tenant_name=None,
    ):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            cancel_deployment.__name__,
            space_name=space_name,
            project_name=project_name,
            release_version=release_version,
            environment_name=environment_name,
            tenant_name=tenant_name,
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

        sanitized_tenant_names = lookup_tenants(
            url, api_key, github_user, original_query, space_id, tenant_name
        )

        task, activity_logs, actual_release_version = timing_wrapper(
            lambda: get_deployment_logs(
                actual_space_name,
                sanitized_project_names[0],
                sanitized_environment_names[0],
                get_item_or_none(sanitized_tenant_names, 0),
                release_version,
                api_key,
                url,
            ),
            "Deployment logs",
        )

        if task is None:
            return CopilotResponse("⚠️ Deployment not found.")

        if task["State"] == "Canceled":
            return CopilotResponse("⚠️ Deployment already cancelled.")

        callback_id = str(uuid.uuid4())

        arguments = {
            "space_id": space_id,
            "project_name": sanitized_project_names[0],
            "project_id": project["Id"],
            "task_id": task["Id"],
        }

        log_query(
            "cancel_deployment",
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
                cancel_deployment.__name__,
                space_name=actual_space_name,
                space_id=space_id,
                project_name=sanitized_project_names,
                project_id=project["Id"],
                release_version=actual_release_version,
                environment_name=sanitized_environment_names,
                tenant_name=sanitized_tenant_names,
                task_id=task["Id"],
            )
        )

        save_callback(
            github_user,
            cancel_deployment.__name__,
            callback_id,
            json.dumps(arguments),
            original_query,
            connection_string,
        )

        response = ["Cancel deployment"]
        response.extend(warnings)
        response.extend(debug_text)

        prompt_title = f"Do you want to cancel the deployment?"
        prompt_message = [
            "Please confirm the details below are correct before proceeding:"
            f"\n* Project: **{sanitized_project_names[0]}**",
            f"\n* Environment: **{sanitized_environment_names[0]}**",
        ]

        if sanitized_tenant_names:
            prompt_message.append(f"\n* Tenant: **{sanitized_tenant_names[0]}**")

        prompt_message.append(f"\n* Space: **{actual_space_name}**")
        prompt_message.append(f"\n* Task: **{task['Description']}**")
        return CopilotResponse(
            "\n\n".join(response), prompt_title, "".join(prompt_message), callback_id
        )

    return cancel_deployment
