import argparse
import os

from domain.handlers.copilot_handler import handle_copilot_tools_execution, handle_copilot_query
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
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


def answer_general_query(space_name=None, project_names=None, runbook_names=None, target_names=None,
                         tenant_names=None, library_variable_sets=None):
    """Answers a general query about Octopus Deploy.

        Args:
            space_name: The name of the space relating to the query.

            project_names: The optional names of one or more projects relating to the query.
            runbook_names: The optional names of one or more runbooks relating to the query.
            target_names: The optional names of one or more targets or machines relating to the query.
            tenant_names: The optional names of one or more tenants relating to the query.
            library_variable_sets: The optional names of one or more library variable sets relating to the query.
    """
    return handle_copilot_query(parser.query,
                                'Octopus Copilot',
                                project_names,
                                runbook_names,
                                target_names,
                                tenant_names,
                                library_variable_sets,
                                get_api_key(),
                                get_octopus_api())


def build_tools():
    """
    Builds the set of tools configured for use when called as a CLI application
    :return: The OpenAI tools
    """
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query)
    ])


try:
    result = handle_copilot_tools_execution(parser.query, build_tools).call_function()
    print(result)
except Exception as e:
    print(e)
