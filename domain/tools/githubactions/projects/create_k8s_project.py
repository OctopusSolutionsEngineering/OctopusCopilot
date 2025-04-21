import asyncio
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
from infrastructure.space_builder import create_terraform_plan, create_terraform_apply


def create_k8s_project_confirm_callback_wrapper(
    github_user,
    octopus_details,
    log_query,
    redirections,
    redirector_api_key,
):
    def create_k8s_project_confirm_callback(plan_id):
        async def inner_function():
            auth, url = octopus_details()
            api_key, access_token = get_auth(auth)

            debug_text = get_params_message(
                github_user, True, create_k8s_project_callback.__name__, plan_id=plan_id
            )

            log_query(
                "create_k8s_project_callback",
                f"""
                Plan ID: {plan_id}""",
            )

            response_text = []

            debug_text.extend(
                get_params_message(
                    github_user,
                    False,
                    create_k8s_project_callback.__name__,
                    plan_id=plan_id,
                )
            )

            response = await create_terraform_apply(
                api_key,
                access_token,
                url,
                plan_id,
                redirections,
                redirector_api_key,
            )

            response_text.extend(debug_text)
            return CopilotResponse("\n\n".join(response_text))

        return asyncio.run(inner_function())

    return create_k8s_project_confirm_callback


def create_k8s_project_callback(
    octopus_details,
    github_user,
    connection_string,
    log_query,
    redirections,
    redirector_api_key,
):
    def create_k8s_project(
        original_query,
        space_name=None,
    ):
        async def inner_function():

            auth, url = octopus_details()
            api_key, access_token = get_auth(auth)

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

            # We need to call the LLM to get the Terraform configuration
            configuration = ""

            # We can then save the Terraform plan as a callback
            callback_id = str(uuid.uuid4())

            response = await create_terraform_plan(
                api_key,
                access_token,
                space_id,
                configuration,
                redirections,
                redirector_api_key,
            )

            arguments = {
                "plan_id": space_id,
            }

            log_query(
                "create_k8s_project",
                f"""
                Space: {arguments["space_id"]}
                Plan: {response["attributes"]["plan_text"]}""",
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
                f"\n* Plan: **{response["attributes"]["plan_text"]}**"
            ]

            response = ["Create a project"]
            response.extend(warnings)
            response.extend(debug_text)

            return CopilotResponse(
                "\n\n".join(response),
                prompt_title,
                "".join(prompt_message),
                callback_id,
            )

        return asyncio.run(inner_function())

    return create_k8s_project
