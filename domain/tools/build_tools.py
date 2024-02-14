from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from infrastructure.octopus_projects import get_octopus_project_names


def build_tools():
    return FunctionDefinitions([FunctionDefinition(get_octopus_project_names)])