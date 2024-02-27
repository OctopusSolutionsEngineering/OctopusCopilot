from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from tests.infrastructure.tools.octopus_projects import get_mock_octopus_projects, get_octopus_project_names, \
    set_octopus_details, get_octopus_user, get_deployment_status


def build_mock_test_tools():
    return FunctionDefinitions([
        FunctionDefinition(get_mock_octopus_projects),
    ])


def build_live_test_tools():
    return FunctionDefinitions([
        FunctionDefinition(get_octopus_project_names),
        FunctionDefinition(set_octopus_details),
        FunctionDefinition(get_octopus_user),
        FunctionDefinition(get_deployment_status),
    ])
