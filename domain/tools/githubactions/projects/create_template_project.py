import asyncio
import hashlib
import json
import os
import uuid

from domain.exceptions.none_on_exception import none_on_exception
from domain.exceptions.spacebuilder import SpaceBuilderRequestFailed
from domain.lookup.octopus_lookups import (
    lookup_space,
)
from domain.octopus.authorization import get_auth
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.escape_messages import escape_message
from domain.sanitizers.markdown_remove import remove_markdown_code_block
from domain.sanitizers.sanitize_strings import empty_if_none
from domain.sanitizers.terraform import (
    sanitize_kuberenetes_yaml_step_config,
    sanitize_account_type,
    sanitize_name_attributes,
    fix_single_line_lifecycle,
    fix_single_line_retention_policy,
    remove_duplicate_definitions,
    fix_single_line_tentacle_retention_policy,
    fix_bad_logic_characters,
    fix_lifecycle,
    fix_properties_block,
    fix_execution_properties_block,
    fix_empty_execution_properties_block,
    fix_empty_properties_block,
    fix_script_source,
    fix_empty_strings,
    replace_passwords,
    replace_certificate_data,
    sanitize_slugs,
    sanitize_primary_package,
    replace_resource_names_with_digit,
    fix_double_comma,
    fix_variable_type,
    add_space_id_variable,
    fix_single_line_lifecycle_phase,
    fix_single_line_variable,
    fix_empty_teams,
)
from domain.tools.debug import get_params_message
from infrastructure.callbacks import save_callback
from infrastructure.llm import llm_message_query, AZURE_PROJECT_SERVICE
from infrastructure.space_builder import (
    create_terraform_plan,
    create_terraform_apply,
    create_terraform_autoapply,
)
from infrastructure.terraform_context import (
    load_terraform_context,
    load_terraform_cache,
    cache_terraform,
)

project_prompt_error_message = "The Octopus resources could not be generated from the prompt. This is usually because the prompt is too complex or the LLM is not able to generate a valid Terraform configuration. Please try again with a simpler prompt."


def create_template_project_confirm_callback_wrapper(
    original_prompt,
    github_user,
    octopus_details,
    log_query,
    redirections,
    redirector_api_key,
):
    def create_template_project_confirm_callback(plan_id):
        async def inner_function():
            auth, url = octopus_details()
            api_key, access_token = get_auth(auth)

            debug_text = get_params_message(
                github_user,
                True,
                create_template_project_confirm_callback_wrapper.__name__,
                plan_id=plan_id,
            )

            log_query(
                create_template_project_confirm_callback_wrapper.__name__,
                f"""
                Plan ID: {plan_id}""",
            )

            debug_text.extend(
                get_params_message(
                    github_user,
                    False,
                    create_template_project_confirm_callback_wrapper.__name__,
                    plan_id=plan_id,
                )
            )

            try:
                response = await create_terraform_apply(
                    api_key,
                    access_token,
                    url,
                    plan_id,
                    original_prompt,
                    redirections,
                    redirector_api_key,
                )
            except SpaceBuilderRequestFailed as e:
                log_query(
                    create_template_project_confirm_callback_wrapper.__name__, str(e)
                )
                return CopilotResponse(project_prompt_error_message)

            response_text = []
            response_text.append(
                "Your project was created successfully. The next step is to create and deploy a release. The deployment logs provide instructions and links to help you customize your project further."
            )
            response_text.append("The following resources were created:")
            response_text.append(
                "```\n" + response["data"]["attributes"]["apply_text"] + "\n```"
            )

            response_text.extend(debug_text)
            return CopilotResponse("\n\n".join(response_text))

        return asyncio.run(inner_function())

    return create_template_project_confirm_callback


def create_general_resources_callback(
    octopus_details,
    github_user,
    connection_string,
    log_query,
    general_examples,
    general_system_message,
    redirections,
    redirector_api_key,
):
    """
    This function is used to create general resources in Octopus Deploy, such as feeds, accounts, lifecycles etc.
    It is not used to create projects.
    :param octopus_details: A function to get the Octopus server URL and credentials
    :param github_user: The github user id
    :param connection_string: The connection string to the storage account
    :param log_query: A logging function
    :param general_examples: The RowKeys that contain general examples of Octopus projects in Terraform. This can be an empty list when using an LLM that has been fine-tuned on Octopus Deploy projects.
    :param general_system_message: The system message to pass to the LLM when generating the Terraform configuration
    :param redirections: Any redirection headers
    :param redirector_api_key: The redirection api key
    :return: The response to send to the client
    """

    return create_template_project_callback(
        octopus_details,
        github_user,
        connection_string,
        log_query,
        general_examples,
        project_example=None,
        project_example_context_name=None,
        general_system_message=general_system_message,
        project_system_message=None,
        redirections=redirections,
        redirector_api_key=redirector_api_key,
    )


def create_template_project_callback(
    octopus_details,
    github_user,
    connection_string,
    log_query,
    general_examples,
    project_example,
    project_example_context_name,
    general_system_message,
    project_system_message,
    redirections,
    redirector_api_key,
):
    """
    This function is used to create a template project in Octopus Deploy. This function is generic and can be used
    to build any type of project in Octopus Deploy. All the sample Terraform and LLM messages are stored in the
    database to make it easy to add and edit examples.

    :param octopus_details: A function to get the Octopus server URL and credentials
    :param github_user: The github user id
    :param connection_string: The connection string to the storage account
    :param log_query: A logging function
    :param general_examples: The RowKeys that contain general examples of Octopus projects in Terraform. This can be an empty list when using an LLM that has been fine-tuned on Octopus Deploy projects.
    :param project_example: The RowKey that contains an example of a project in Terraform
    :param project_example_context_name: The name of the context item that contains the project example
    :param general_system_message: The system message to pass to the LLM when generating the Terraform configuration
    :param project_system_message: The system message to pass to the LLM describing a specific project type
    :param redirections: Any redirection headers
    :param redirector_api_key: The redirection api key
    :return: The response to send to the client
    """

    def create_template_project(
        callback_name,
        original_query,
        space_name=None,
        project_name=None,
        auto_apply=False,
    ):
        """

        :param callback_name: The name of the tool that is calling this function. This is used to ensure approvals are linked up correctly, as there are multiple tools calling the same callback
        :param original_query: The prompt that was used to call this function
        :param space_name: The name of the space
        :return: An response for approval
        """

        async def inner_function():

            auth, url = octopus_details()
            api_key, access_token = get_auth(auth)

            debug_text = get_params_message(
                github_user,
                True,
                create_template_project.__name__,
                space_name=space_name,
            )

            space_id, actual_space_name, warnings = lookup_space(
                url, auth, github_user, original_query, space_name
            )

            if not space_id:
                return CopilotResponse(
                    "The name of the space to create the project in must be defined."
                )

            debug_text.extend(
                get_params_message(
                    github_user,
                    False,
                    create_template_project.__name__,
                    space_name=actual_space_name,
                    space_id=space_id,
                )
            )

            # We need to call the LLM to get the Terraform configuration
            context = {"input": original_query}

            general_examples_values = [
                load_terraform_context(context, connection_string)
                for context in general_examples
                if context.strip()
            ]

            # A sample project is only required for project generation.
            # Other Octopus resources are based on the general examples.
            project_example_values = (
                load_terraform_context(project_example, connection_string)
                if project_example
                else None
            )

            general_system_message_values = load_terraform_context(
                general_system_message, connection_string
            )

            project_system_message_values = (
                load_terraform_context(project_system_message, connection_string)
                if project_system_message
                else None
            )

            # We build a unique sha for the inputs that generate a terraform configuration
            cache_key = (
                original_query
                + "\n"
                + "\n".join(general_examples_values)
                + "\n"
                + empty_if_none(project_example_values)
                + "\n"
                + empty_if_none(general_system_message_values)
                + "\n"
                + empty_if_none(project_system_message_values)
            )
            cache_sha = hashlib.sha256(cache_key.encode("utf-8")).hexdigest()

            # Attempt to load a previously cached terraform configuration,
            # unless the cache is disabled.
            configuration = (
                None
                if os.getenv(
                    "AISERVICES_CACHE_DISABLED_PROJECT_GEN", "false"
                ).casefold()
                == "true"
                else load_terraform_cache(cache_sha, connection_string)
            )

            if not configuration:
                # These are the general examples of projects, feeds, accounts etc
                base_messages = generate_base_messages(
                    general_examples_values, general_system_message_values
                )

                # These are examples of specific project types, like Kubernetes, Azure Web Apps etc
                project_messages = generate_project_messages(
                    base_messages,
                    project_example_values,
                    project_example_context_name,
                    project_system_message_values,
                )

                # These are the common messages used to generate the final configuration
                messages = final_messages(project_messages)

                configuration = llm_message_query(
                    messages,
                    context,
                    log_query,
                    purpose=os.getenv("PROJECT_GEN_SERVICE") or AZURE_PROJECT_SERVICE,
                )

                # Replace anything that looks like a password
                configuration = replace_passwords(configuration)

                # Fix up invalid resource and data names
                configuration = replace_resource_names_with_digit(configuration)

                # The certificate data needs to be valid but generic to prevent leaking sensitive information
                configuration = replace_certificate_data(configuration)

                # Deal with the LLM returning code in markdown code blocks
                configuration = remove_markdown_code_block(configuration)

                # Deal with the LLM adding asterisks as placeholders in K8s configuration
                configuration = sanitize_kuberenetes_yaml_step_config(configuration)

                # Deal with the LLM using the wrong capitalisation for the account type
                configuration = sanitize_account_type(configuration)

                # Remove invalid slugs
                configuration = sanitize_slugs(configuration)

                # Add the space ID variable
                configuration = add_space_id_variable(configuration)

                # Fix up half created primary package definitions
                configuration = sanitize_primary_package(configuration)

                # Deal with the LLM using invalid characters for names
                configuration = sanitize_name_attributes(configuration)

                # Deal with the LLM returning a single line for a lifecycle block
                configuration = fix_single_line_lifecycle(configuration)

                # Deal with the LLM returning a single line for a release_retention_policy block
                configuration = fix_single_line_retention_policy(configuration)

                # Deal with the LLM returning a single line for a phase blocks
                configuration = fix_single_line_lifecycle_phase(configuration)

                # Deal with the LLM returning a single line for a variable
                configuration = fix_single_line_variable(configuration)

                # Deal with the LLM returning empty teams in a manual intervention block
                configuration = fix_empty_teams(configuration)

                # Deal with the LLM returning a single line for a tentacle_retention_policy block
                configuration = fix_single_line_tentacle_retention_policy(configuration)

                # Deal with bad count attributes
                configuration = fix_bad_logic_characters(configuration)

                # Remove lifecycle blocks
                configuration = fix_lifecycle(configuration)

                # Deal with the LLM returning a duplicate blocks
                configuration = remove_duplicate_definitions(configuration)

                # Deal with the LLM returning a duplicate blocks
                configuration = remove_duplicate_definitions(configuration)

                # Deal with the LLM returning a properties blocks
                configuration = fix_properties_block(configuration)

                # Deal with double commas in parameters blocks
                configuration = fix_double_comma(configuration)

                # Fix the variable type
                configuration = fix_variable_type(configuration)

                # Deal with the LLM returning a execution_properties blocks
                configuration = fix_execution_properties_block(configuration)

                # Deal with the LLM returning an empty execution_properties blocks
                configuration = fix_empty_execution_properties_block(configuration)

                # Deal with the LLM returning an empty properties blocks
                configuration = fix_empty_properties_block(configuration)

                # Remove invalid script configuration
                configuration = fix_script_source(configuration)

                # Remove empty string default values
                configuration = fix_empty_strings(configuration)

            try:
                if auto_apply:
                    response = await create_terraform_autoapply(
                        api_key,
                        access_token,
                        url,
                        space_id,
                        project_name,
                        original_query,
                        configuration,
                        redirections,
                        redirector_api_key,
                    )

                    response_text = [
                        "Auto-apply was enabled, so validate the resources in Octopus Deploy to ensure they were created successfully.",
                        "The following resources were created:",
                        "```\n"
                        + response["data"]["attributes"]["apply_text"]
                        + "\n```",
                    ]
                    response_text.extend(debug_text)
                    return CopilotResponse("\n\n".join(response_text))

                response = await create_terraform_plan(
                    api_key,
                    access_token,
                    url,
                    space_id,
                    project_name,
                    original_query,
                    configuration,
                    redirections,
                    redirector_api_key,
                )
            except SpaceBuilderRequestFailed as e:
                log_query(create_template_project_callback.__name__, str(e))
                return CopilotResponse(project_prompt_error_message)
            finally:
                # Cache the template if it resulted in a valid plan.
                # If the plan is particularly big (over the limit of 32K characters), the save operation might fail.
                # This is a best effort operation, so we silently ignore exceptions.
                none_on_exception(
                    lambda: cache_terraform(cache_sha, configuration, connection_string)
                )

            arguments = {
                "plan_id": response["data"]["id"],
            }

            log_query(
                create_template_project.__name__,
                f"""
                Plan ID: {arguments["plan_id"]}
                Plan: {response["data"]["attributes"]["plan_text"]}""",
            )

            # We can then save the Terraform plan as a callback
            callback_id = str(uuid.uuid4())

            save_callback(
                github_user,
                callback_name,
                callback_id,
                json.dumps(arguments),
                original_query,
                connection_string,
            )

            prompt_title = "Do you want to continue to create the resources?"
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

    return create_template_project


def generate_base_messages(general_examples, general_system_message_values):
    general_examples_messages = [
        (
            "system",
            "# Example Octopus Terraform Configuration:\n" + escape_message(example),
        )
        for example in general_examples
    ]

    return [
        (
            "system",
            "You are an expert in generating Terraform configurations for Octopus Deploy projects.",
        ),
        *general_examples_messages,
        (
            "system",
            escape_message(general_system_message_values),
        ),
    ]


def generate_project_messages(
    base_messages,
    project_example,
    project_example_context_name,
    project_system_message_values,
):
    if not (
        project_example
        and project_example_context_name
        and project_system_message_values
    ):
        return base_messages

    project_example_message = (
        "system",
        f"# Example Octopus {project_example_context_name} Terraform Configuration"
        + "\n"
        + escape_message(project_example)
        + "\n"
        + escape_message(project_system_message_values),
    )

    return [
        *base_messages,
        project_example_message,
        # The LLM was constantly removing the sample resources when the prompt indicated that a new resource, like a new lifecycle, should be created.
        # We reinforce the need to keep any template resources by adding this message after the user prompt.
        (
            "user",
            f'If the prompt specifies that tenants, targets, machines, feeds, accounts, lifecycles, phases, or any other kind of resources are to be created or added, they must be created in addition to the resources from the "{project_example_context_name}".',
        ),
        (
            "user",
            f'You must include all the resources from the "{project_example_context_name}" unless the prompt explicitly asks to remove them.',
        ),
    ]


def final_messages(base_messages):
    return [
        *base_messages,
        ("user", "Question: {input}"),
        ("user", f"Generated Terraform Configuration:"),
    ]
