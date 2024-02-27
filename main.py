import argparse
import os

from domain.handlers.copilot_handler import handle_copilot_chat
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.transformers.chat_responses import get_octopus_project_names_response
from infrastructure.octopus import get_octopus_project_names_base


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


def build_tools():
    """
    Builds the set of tools configured for use when called as a CLI application
    :return: The OpenAI tools
    """
    return FunctionDefinitions([
        FunctionDefinition(get_octopus_project_names_cli),
    ])


try:
    result = handle_copilot_chat(parser.query, build_tools).call_function()
    print(result)
except Exception as e:
    print(e)
