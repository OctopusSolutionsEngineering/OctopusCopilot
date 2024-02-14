from domain.function_definition import FunctionDefinitions, FunctionDefinition


def build_tools():
    return FunctionDefinitions([FunctionDefinition(get_octopus_projects)])