import argparse
import os

from domain.config.zendesk import get_zendesk_user, get_zendesk_token
from domain.errors.error_handling import handle_error
from domain.logging.query_logging import log_query
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_list
from domain.tools.cli.general_query_cli import general_query_cli_callback
from domain.tools.cli.github_job_summary import get_job_summary_cli_callback
from domain.tools.cli.how_to import how_to_cli_callback
from domain.tools.cli.logs import logs_cli_callback
from domain.tools.cli.resource_specific import resource_specific_cli_callback
from domain.tools.cli.task_summary import get_task_summary_cli_callback
from domain.tools.cli.variable_query_cli import variable_query_cli_callback
from domain.tools.githubactions.project_dashboard import get_project_dashboard_callback
from domain.tools.githubactions.release_what_changed import (
    release_what_changed_callback_wrapper,
)
from domain.tools.wrapper.certificates_query import answer_certificates_wrapper
from domain.tools.wrapper.function_definition import (
    FunctionDefinitions,
    FunctionDefinition,
)
from domain.tools.wrapper.general_query import (
    answer_general_query_wrapper,
    AnswerGeneralQuery,
)
from domain.tools.wrapper.github_job_summary_wrapper import (
    show_github_job_summary_wrapper,
)
from domain.tools.wrapper.how_to import how_to_wrapper
from domain.tools.wrapper.project_dashboard_wrapper import (
    show_project_dashboard_wrapper,
)
from domain.tools.wrapper.project_logs import answer_project_deployment_logs_wrapper
from domain.tools.wrapper.project_variables import (
    answer_project_variables_wrapper,
    answer_project_variables_usage_wrapper,
)
from domain.tools.wrapper.release_what_changed import release_what_changed_wrapper
from domain.tools.wrapper.targets_query import answer_machines_wrapper
from domain.tools.wrapper.task_summary_wrapper import show_task_summary_wrapper
from infrastructure.openai import llm_tool_query


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
                ),
                AnswerGeneralQuery,
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
            FunctionDefinition(
                release_what_changed_wrapper(
                    tool_query,
                    release_what_changed_callback_wrapper(
                        True,
                        get_github_user(),
                        get_github_token(),
                        get_zendesk_user(),
                        get_zendesk_token(),
                        lambda: (get_api_key(), get_octopus_api()),
                        log_query,
                    ),
                    log_query,
                )
            ),
        ],
        fallback=FunctionDefinitions(help_functions),
    )


try:
    result = llm_tool_query(
        parser.query,
        build_tools(parser.query),
        lambda x, y: print(x + " " + ",".join(sanitize_list(y))),
    ).call_function()

    if isinstance(result, CopilotResponse):
        print(result.response)
    else:
        print(result)
except Exception as e:
    handle_error(e)
