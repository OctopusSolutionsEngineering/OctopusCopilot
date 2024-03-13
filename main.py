import argparse
import os

from domain.handlers.copilot_handler import handle_copilot_tools_execution, handle_copilot_query
from domain.strings.sanitized_list import sanitize_list
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.general_query import answer_general_query_callback, AnswerGeneralQuery
from domain.tools.project_variables import answer_project_variables_callback, answer_project_variables_usage_callback
from domain.transformers.chat_responses import get_octopus_project_names_response
from infrastructure.octopus import get_octopus_project_names_base, get_raw_deployment_process


def init_argparse():
    """
    Returns the arguments passed to the application.
    :return: The application arguments
    """
    parser = argparse.ArgumentParser(
        usage='%(prog)s [OPTION] [FILE]...',
        description='Query the Octopus Copilot agent'
    )
    parser.add_argument('--query', action='store')
    return parser.parse_known_args()


parser, _ = init_argparse()


def get_api_key():
    """
    A function that extracts the API key from an environment variable
    :return: The Octopus API key
    """
    return os.environ.get('OCTOPUS_CLI_API_KEY')


def get_octopus_api():
    """
    A function that extarcts the Octopus URL from an environment variable
    :return: The Octopus URL
    """
    return os.environ.get('OCTOPUS_CLI_SERVER')


def get_octopus_project_names_cli(space_name):
    """Return a list of project names in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """

    actual_space_name, projects = get_octopus_project_names_base(space_name, get_api_key(), get_octopus_api())
    return get_octopus_project_names_response(actual_space_name, projects)


def get_deployment_process_raw_json_cli(space_name: None, project_name: None):
    """Returns the raw JSON for the deployment process of a project.

        Args:
            space_name: The name of the space containing the projects.
            If this value is not defined, the default value will be used.

            project_name: The name of the project.
            If this value is not defined, the default value will be used.
    """
    return get_raw_deployment_process(space_name, project_name, get_api_key(), get_octopus_api())


def query_handler(percent_truncated, chat_response):
    return chat_response + "\n\n" + f"Percent Truncated: {percent_truncated}"


def general_query_handler(body):
    space = get_default_argument(body['space_name'], 'Space')

    percent_truncated, chat_response = handle_copilot_query(parser.query,
                                                            space,
                                                            body['project_names'],
                                                            body['runbook_names'],
                                                            body['target_names'],
                                                            body['tenant_names'],
                                                            body['library_variable_sets'],
                                                            get_api_key(),
                                                            get_octopus_api(),
                                                            logging,
                                                            False)

    return query_handler(percent_truncated, chat_response)


def variable_query_handler(space, projects, body):
    space = get_default_argument(space, 'Space')

    percent_truncated, chat_response = handle_copilot_query(body,
                                                            space,
                                                            projects,
                                                            None,
                                                            None,
                                                            None,
                                                            None,
                                                            get_api_key(),
                                                            get_octopus_api(),
                                                            logging,
                                                            False)

    return query_handler(percent_truncated, chat_response)


def get_default_argument(argument, default_name):
    if argument:
        return argument

    if default_name == "Space":
        return 'Octopus Copilot'

    return ""


def logging(prefix, message):
    print(prefix + " " + ",".join(sanitize_list(message)))


def build_tools():
    """
    Builds the set of tools configured for use when called as a CLI application
    :return: The OpenAI tools
    """
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query_callback(general_query_handler), AnswerGeneralQuery),
        FunctionDefinition(answer_project_variables_callback(parser.query, variable_query_handler)),
        FunctionDefinition(answer_project_variables_usage_callback(parser.query, variable_query_handler))
    ])


try:
    result = handle_copilot_tools_execution(parser.query, build_tools,
                                            lambda x, y: print(x + " " + ",".join(sanitize_list(y)))).call_function()
    print(result)
except Exception as e:
    print(e)
