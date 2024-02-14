from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from tests.infrastructure.tools.octopus_projects import get_octopus_projects


def build_test_tools():
    return FunctionDefinitions([
        FunctionDefinition(get_octopus_projects),
    ])
