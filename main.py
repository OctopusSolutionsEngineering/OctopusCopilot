import argparse
import os

from domain.handlers.copilot_handler import handle_copilot_chat
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from infrastructure.octopus_projects import get_octopus_project_names_base, get_octopus_project_names_response


def init_argparse():
    parser = argparse.ArgumentParser(
        usage='%(prog)s [OPTION] [FILE]...',
        description='Query the Octopus Copilot agent'
    )
    parser.add_argument('--query', action='store')
    return parser.parse_known_args()


parser, _ = init_argparse()


def get_api_key():
    return os.environ.get('OCTOPUS_CLI_API_KEY')


def get_octopus_api():
    return os.environ.get('OCTOPUS_CLI_SERVER')


def get_octopus_project_names_cli(space_name):
    """Return a list of project names in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """

    projects = get_octopus_project_names_base(space_name, get_api_key, get_octopus_api)
    return get_octopus_project_names_response(space_name, projects)


def build_tools():
    return FunctionDefinitions([
        FunctionDefinition(get_octopus_project_names_cli),
    ])


try:
    result = handle_copilot_chat(parser.query, build_tools).call_function()
    print(result)
except Exception as e:
    print(e)
