from domain.function_definition import FunctionDefinition, FunctionDefinitions
from tests.infrastructure.octopus_projects import get_octopus_projects


def build_test_tools():
    return FunctionDefinitions([FunctionDefinition(get_octopus_projects)])
