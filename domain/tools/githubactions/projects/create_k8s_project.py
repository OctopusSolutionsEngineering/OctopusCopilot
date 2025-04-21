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
from domain.octopus.authorization import get_auth
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


def create_k8s_project_callback_wrapper(github_user, octopus_details, log_query):
    def create_k8s_project_callback(space_id):
        auth, url = octopus_details()
        api_key, access_token = get_auth(auth)

        debug_text = get_params_message(
            github_user, True, create_k8s_project_callback.__name__, space_id=space_id
        )

        log_query(
            "create_k8s_project_callback",
            f"""
            Space: {space_id}""",
        )

        response_text = []

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                create_k8s_project_callback.__name__,
                space_id=space_id,
            )
        )

        response_text.extend(debug_text)
        return CopilotResponse("\n\n".join(response_text))

    return create_k8s_project_callback


def create_k8s_project_callback(
    octopus_details, github_user, connection_string, log_query
):
    def create_k8s_project(
        original_query,
        space_name=None,
    ):
        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            create_k8s_project.__name__,
            space_name=space_name,
        )

        space_id, actual_space_name, warnings = lookup_space(
            url, api_key, github_user, original_query, space_name
        )

        if not space_id:
            return CopilotResponse(
                "The name of the space to create the project in must be defined."
            )

        callback_id = str(uuid.uuid4())
        arguments = {
            "space_id": space_id,
        }

        log_query(
            "create_k8s_project",
            f"""
            Space: {arguments["space_id"]}""",
        )

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                create_k8s_project.__name__,
                space_name=actual_space_name,
                space_id=space_id,
            )
        )
        save_callback(
            github_user,
            create_k8s_project.__name__,
            callback_id,
            json.dumps(arguments),
            original_query,
            connection_string,
        )

        prompt_title = "Do you want to continue to create the project?"
        prompt_message = [
            "Please confirm the details below are correct before proceeding:"
            f"\n* Space: **{actual_space_name}**"
        ]

        response = ["Create a project"]
        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse(
            "\n\n".join(response), prompt_title, "".join(prompt_message), callback_id
        )

    return create_k8s_project
