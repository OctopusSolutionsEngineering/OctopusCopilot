import asyncio
import json
import uuid

from domain.config.database import get_functions_connection_string
from domain.lookup.octopus_lookups import (
    lookup_space,
)
from domain.octopus.authorization import get_auth
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.escape_messages import escape_message
from domain.sanitizers.markdown_remove import remove_markdown_code_block
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.openai import llm_message_query
from infrastructure.space_builder import create_terraform_plan, create_terraform_apply
from infrastructure.terraform_context import load_terraform_context


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

            response_text.append(
                "```\n" + response["data"]["attributes"]["apply_text"] + "\n```"
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
                url, auth, github_user, original_query, space_name
            )

            if not space_id:
                return CopilotResponse(
                    "The name of the space to create the project in must be defined."
                )

            # We need to call the LLM to get the Terraform configuration
            context = {"input": original_query}
            messages = k8s_project_context()
            configuration = remove_markdown_code_block(
                llm_message_query(messages, context, log_query)
            )

            # We can then save the Terraform plan as a callback
            callback_id = str(uuid.uuid4())

            response = await create_terraform_plan(
                api_key,
                access_token,
                url,
                space_id,
                configuration,
                redirections,
                redirector_api_key,
            )

            arguments = {
                "plan_id": response["data"]["id"],
            }

            log_query(
                "create_k8s_project",
                f"""
                Plan ID: {arguments["plan_id"]}
                Plan: {response["data"]["attributes"]["plan_text"]}""",
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
                "Please confirm the details below are correct before proceeding."
                f"\n\nSpace: **{actual_space_name}**"
                f"\n\nPlan:\n\n```{response['data']['attributes']['plan_text']}```"
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


def k8s_project_context():
    """
    Builds the messages used when building a k8s project
    :return: The LLM messages
    """

    # The general space context is split into two rows because of a 32k limit on azure storage table rows
    space_general_1 = load_terraform_context(
        "space_general_1", get_functions_connection_string()
    )
    space_general_2 = load_terraform_context(
        "space_general_2", get_functions_connection_string()
    )
    space_general_3 = load_terraform_context(
        "space_general_3", get_functions_connection_string()
    )

    # This context is an example k8s project
    project_kubernetes_raw_yaml = load_terraform_context(
        "project_kubernetes_raw_yaml", get_functions_connection_string()
    )

    # This is the system message
    project_kubernetes_raw_yaml_system = load_terraform_context(
        "project_kubernetes_raw_yaml_system", get_functions_connection_string()
    )

    return [
        (
            "system",
            project_kubernetes_raw_yaml_system,
        ),
        (
            "system",
            "Example Octopus Terraform Configuration: ###\n"
            + escape_message(space_general_1)
            + "\n###",
        ),
        (
            "system",
            "Example Octopus Terraform Configuration: ###\n"
            + escape_message(space_general_2)
            + "\n###",
        ),
        (
            "system",
            "Example Octopus Terraform Configuration: ###\n"
            + escape_message(space_general_3)
            + "\n###",
        ),
        (
            "system",
            "Example Octopus Kubernetes Project Terraform Configuration: ###\n"
            + escape_message(project_kubernetes_raw_yaml)
            + "\n###",
        ),
        ("user", "Question: {input}"),
        ("user", "Terraform Configuration:"),
    ]
