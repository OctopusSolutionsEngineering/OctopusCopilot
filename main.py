#!/usr/bin/env python3

import argparse
import glob
import json
import os

import azure.functions as func
from domain.config.zendesk import get_zendesk_user, get_zendesk_token
from domain.errors.error_handling import handle_error
from domain.logging.query_logging import log_query
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_list
from domain.tools.cli.general_query_cli import general_query_cli_callback
from domain.tools.cli.github_job_summary import get_job_summary_cli_callback
from domain.tools.cli.how_to import how_to_cli_callback
from domain.tools.cli.spinnaker import spinnaker_cli_callback
from domain.tools.cli.logs import logs_cli_callback
from domain.tools.cli.resource_specific import resource_specific_cli_callback
from domain.tools.cli.task_summary import get_task_summary_cli_callback
from domain.tools.cli.variable_query_cli import variable_query_cli_callback
from domain.tools.githubactions.project_dashboard import get_project_dashboard_callback
from domain.tools.githubactions.projects.create_template_project import (
    create_template_project_callback,
    create_template_project_confirm_callback_wrapper,
)
from domain.tools.githubactions.release_what_changed import (
    release_what_changed_callback_wrapper,
)
from domain.tools.wrapper.certificates_query import answer_certificates_wrapper
from domain.tools.wrapper.function_definition import (
    FunctionDefinitions,
    FunctionDefinition,
)
from domain.tools.wrapper.general_query import answer_general_query_wrapper
from domain.tools.wrapper.github_job_summary_wrapper import (
    show_github_job_summary_wrapper,
)
from domain.tools.wrapper.how_to import how_to_wrapper
from domain.tools.wrapper.spinnaker import spinnaker_wrapper
from domain.tools.wrapper.project_dashboard_wrapper import (
    show_project_dashboard_wrapper,
)
from domain.tools.wrapper.project_logs import answer_project_deployment_logs_wrapper
from domain.tools.wrapper.project_variables import (
    answer_project_variables_wrapper,
    answer_project_variables_usage_wrapper,
)
from domain.tools.wrapper.projects.create_argo_cd_modify_manifest_project_wrapper import (
    create_argocdmodifymanifest_project_wrapper,
)
from domain.tools.wrapper.projects.create_argo_cd_rollouts_project_wrapper import (
    create_argocdrollouts_project_wrapper,
)
from domain.tools.wrapper.projects.create_argo_cd_update_image_tags_project_wrapper import (
    create_argocdimagetag_project_wrapper,
)
from domain.tools.wrapper.projects.create_azure_function_project import (
    create_azure_function_project_wrapper,
)
from domain.tools.wrapper.projects.create_azure_web_app_project import (
    create_azure_web_app_project_wrapper,
)
from domain.tools.wrapper.projects.create_claude_project import (
    create_claude_project_wrapper,
)
from domain.tools.wrapper.projects.create_iis_project import create_iis_project_wrapper
from domain.tools.wrapper.projects.create_k8s_project import create_k8s_project_wrapper
from domain.tools.wrapper.projects.create_lambda_project import (
    create_lambda_project_wrapper,
)
from domain.tools.wrapper.projects.create_llm_project import create_llm_project_wrapper
from domain.tools.wrapper.projects.create_orchestration_project import (
    create_orchestration_project_wrapper,
)
from domain.tools.wrapper.projects.create_progressive_deployment_project import (
    create_progressive_deployment_project_wrapper,
)
from domain.tools.wrapper.projects.create_project import create_project_wrapper
from domain.tools.wrapper.projects.create_runbook_wrapper import create_runbook_wrapper
from domain.tools.wrapper.projects.create_script_project import (
    create_script_project_wrapper,
)
from domain.tools.wrapper.projects.create_terraform_project import (
    create_terraform_project_wrapper,
)
from domain.tools.wrapper.projects.create_tomcat_project_wrapper import (
    create_tomcat_project_wrapper,
)
from domain.tools.wrapper.projects.create_vm_bluegreen_project import (
    create_vm_blue_green_project_wrapper,
)
from domain.tools.wrapper.projects.create_winservice_project import (
    create_winservice_project_wrapper,
)
from domain.tools.wrapper.release_what_changed import release_what_changed_wrapper
from domain.tools.wrapper.targets_query import answer_machines_wrapper
from domain.tools.wrapper.task_summary_wrapper import show_task_summary_wrapper
from domain.transformers.sse_transformers import (
    get_confirmation_id,
    convert_from_sse_response,
)
from function_app import copilot_handler_internal
from infrastructure.llm import llm_tool_query
from infrastructure.terraform_context import save_terraform_context

azurite_connection_string = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"


def init_argparse():
    """
    Returns the arguments passed to the application.
    :return: The application arguments
    """
    parser = argparse.ArgumentParser(
        usage="%(prog)s [OPTION] [FILE]...",
        description="Query the Octopus Copilot agent",
    )
    parser.add_argument("--query", action="store")
    parser.add_argument("--queryFile", action="store")
    return parser.parse_known_args()


parser, _ = init_argparse()


def get_api_key():
    """
    A function that extracts the API key from an environment variable
    :return: The Octopus API key
    """
    return os.environ.get("OCTOPUS_CLI_API_KEY")


def get_github_token():
    """
    A function that extracts the Github token from an environment variable
    :return: The Octopus API key
    """
    return os.environ.get("GH_TEST_TOKEN")


def get_github_user():
    """
    A function that extracts the GitHub token from an environment variable
    :return: The Octopus API key
    """
    return os.environ.get("TEST_GH_USER")


def get_octopus_api():
    """
    A function that extracts the Octopus URL from an environment variable
    :return: The Octopus URL
    """
    return os.environ.get("OCTOPUS_CLI_SERVER")


def get_default_argument(argument, default_name):
    if argument:
        return argument

    if default_name == "Space":
        return "Octopus Copilot"

    return ""


def logging(prefix, message):
    print(prefix + " " + ",".join(sanitize_list(message)))


def build_confirmation_request(body):
    """
    Builds a confirmation request for the Copilot handler.
    """
    return func.HttpRequest(
        method="POST",
        body=json.dumps(body).encode("utf8"),
        url="/api/form_handler",
        params=None,
        headers={
            "X-GitHub-Token": get_github_token(),
            "X-Octopus-ApiKey": get_api_key(),
            "X-Octopus-Server": get_octopus_api(),
        },
    )


def populate_blob_storage():
    # The path changes depending on where the tests are run from.
    context_path = (
        "../../context/" if os.path.exists("../../context/context.tf") else "context/"
    )

    pattern_tf = os.path.join(context_path, "*.tf")
    pattern_txt = os.path.join(context_path, "*.txt")

    all_files = glob.glob(pattern_tf) + glob.glob(pattern_txt)
    all_files.sort()

    for file_path in all_files:
        with open(file_path, "r") as file:
            file_content = file.read()
            filename = os.path.basename(file_path)
            save_terraform_context(filename, file_content, azurite_connection_string)


def build_tools(tool_query):
    """
    Builds the set of tools configured for use when called as a CLI application
    :return: The OpenAI tools
    """

    help_functions = [
        FunctionDefinition(tool)
        for tool in how_to_wrapper(
            tool_query, how_to_cli_callback(get_github_token(), log_query), log_query
        )
    ]

    deployment_functions = [
        FunctionDefinition(tool)
        for tool in release_what_changed_wrapper(
            tool_query,
            release_what_changed_callback_wrapper(
                True,
                get_github_user(),
                get_github_token(),
                None,
                get_zendesk_user(),
                get_zendesk_token(),
                lambda: (get_api_key(), get_octopus_api()),
                log_query,
            ),
            log_query,
        )
    ]

    general_project_examples = [
        "context.tf",
        "everystep.tf",
        "projectsettings1.tf",
        "ephemeral_environments.tf",
    ]

    def template_project(wrapper, project_example, context_name, system_prompt):
        """
        Builds a FunctionDefinition that creates a project from a template, matching the
        configuration used by the web interface in copilot_request_context.py
        """
        return FunctionDefinition(
            wrapper(
                tool_query,
                callback=create_template_project_callback(
                    lambda: (get_api_key(), get_octopus_api()),
                    get_github_user(),
                    None,
                    azurite_connection_string,
                    log_query,
                    general_project_examples,
                    project_example,
                    context_name,
                    "generalinstructions.txt",
                    system_prompt,
                    None,
                    None,
                    ollama_model=None,
                ),
                logging=log_query,
            ),
            callback=create_template_project_confirm_callback_wrapper(
                tool_query,
                get_github_user(),
                lambda: (get_api_key(), get_octopus_api()),
                log_query,
                None,
                None,
            ),
        )

    return FunctionDefinitions(
        [
            FunctionDefinition(
                answer_general_query_wrapper(
                    tool_query,
                    general_query_cli_callback(
                        get_api_key(),
                        get_octopus_api(),
                        get_default_argument,
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_project_variables_wrapper(
                    tool_query,
                    variable_query_cli_callback(
                        get_api_key(),
                        get_octopus_api(),
                        get_default_argument,
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                show_project_dashboard_wrapper(
                    tool_query,
                    lambda: (get_api_key(), get_octopus_api()),
                    get_project_dashboard_callback(
                        get_github_user(), get_github_token()
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_project_variables_usage_wrapper(
                    tool_query,
                    variable_query_cli_callback(
                        get_api_key(),
                        get_octopus_api(),
                        get_default_argument,
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                show_task_summary_wrapper(
                    tool_query,
                    get_task_summary_cli_callback(
                        get_api_key(),
                        get_octopus_api(),
                        get_default_argument,
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_project_deployment_logs_wrapper(
                    tool_query,
                    logs_cli_callback(
                        get_api_key(),
                        get_octopus_api(),
                        get_default_argument,
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_machines_wrapper(
                    tool_query,
                    resource_specific_cli_callback(
                        get_api_key(),
                        get_octopus_api(),
                        get_default_argument,
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_certificates_wrapper(
                    tool_query,
                    resource_specific_cli_callback(
                        get_api_key(),
                        get_octopus_api(),
                        get_default_argument,
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                show_github_job_summary_wrapper(
                    tool_query,
                    get_job_summary_cli_callback(
                        get_github_user(), get_github_token(), log_query
                    ),
                    log_query,
                )
            ),
            *deployment_functions,
            template_project(
                create_k8s_project_wrapper,
                "k8s.tf",
                "Kubernetes",
                "k8ssystemprompt.txt",
            ),
            template_project(
                create_azure_web_app_project_wrapper,
                "azurewebapp.tf",
                "Azure Web App",
                "azurewebappsystemprompt.txt",
            ),
            template_project(
                create_azure_function_project_wrapper,
                "azurefunction.tf",
                "Azure Function",
                "azurefunctionsystemprompt.txt",
            ),
            template_project(
                create_lambda_project_wrapper,
                "awslambda.tf",
                "AWS Lambda",
                "awslambdaystemprompt.txt",
            ),
            template_project(
                create_iis_project_wrapper,
                "windowsiis.tf",
                "Windows IIS",
                "windowsiissystemprompt.txt",
            ),
            template_project(
                create_winservice_project_wrapper,
                "windowsservice.tf",
                "Windows Service",
                "windowsservicesystemprompt.txt",
            ),
            template_project(
                create_orchestration_project_wrapper,
                "deploymentorchestration.tf",
                "Deployment Orchestration",
                "deploymentorchestrationsystemprompt.txt",
            ),
            template_project(
                create_terraform_project_wrapper,
                "terraform.tf",
                "Terraform Deploy",
                "terraformsystemprompt.txt",
            ),
            template_project(
                create_claude_project_wrapper,
                "claude.tf",
                "Claude",
                "claudesystemprompt.txt",
            ),
            template_project(
                create_progressive_deployment_project_wrapper,
                "progressive_deployment.tf",
                "Progressive Deployment",
                "progressive_deploymentsystemprompt.txt",
            ),
            template_project(
                create_script_project_wrapper,
                "script.tf",
                "Script Execution",
                "scriptsystemprompt.txt",
            ),
            template_project(
                create_project_wrapper,
                "emptyproject.tf",
                "Empty",
                "emptyprojectprompt.txt",
            ),
            template_project(
                create_llm_project_wrapper,
                "llm.tf",
                "LLM Kubernetes",
                "llmsystemprompt.txt",
            ),
            template_project(
                create_vm_blue_green_project_wrapper,
                "vmbluegreen.tf",
                "VM Blue/Green",
                "vmbluegreensystemprompt.txt",
            ),
            template_project(
                create_tomcat_project_wrapper,
                "apachetomcat.tf",
                "Apache Tomcat",
                "tomcatsystemprompt.txt",
            ),
            template_project(
                create_argocdimagetag_project_wrapper,
                "argoupdatetags.tf",
                "Argo CD Update Image Tags",
                "argoupdatetagssystemprompt.txt",
            ),
            template_project(
                create_argocdmodifymanifest_project_wrapper,
                "argoupdatemanifest.tf",
                "Argo CD Update Manifest",
                "argoupdatemanifestsystemprompt.txt",
            ),
            template_project(
                create_argocdrollouts_project_wrapper,
                "argocdrollouts.tf",
                "Argo CD Rollouts",
                "argocdrolloutssystemprompt.txt",
            ),
            template_project(
                create_runbook_wrapper,
                "runbook.tf",
                "Runbook",
                "runbookprompt.txt",
            ),
            FunctionDefinition(
                spinnaker_wrapper(
                    tool_query,
                    spinnaker_cli_callback(log_query),
                    log_query,
                )
            ),
        ],
        fallback=FunctionDefinitions(help_functions),
    )


try:
    populate_blob_storage()

    query = parser.query

    if parser.queryFile:
        with open(parser.queryFile, "r") as f:
            query = f.read()

    result = llm_tool_query(
        query,
        build_tools(query),
        lambda x, y: print(x + " " + ",".join(sanitize_list(y))),
    ).call_function()

    if isinstance(result, CopilotResponse):
        print(result.response)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": result.prompt_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )

        print(convert_from_sse_response(run_response.get_body().decode("utf8")))

    else:
        print(result)
except Exception as e:
    handle_error(e)
