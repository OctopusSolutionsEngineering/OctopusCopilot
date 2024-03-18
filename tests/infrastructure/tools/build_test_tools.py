from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.general_query import answer_general_query_callback, AnswerGeneralQuery
from tests.infrastructure.tools.octopus_projects import get_mock_octopus_projects


def general_query_handler(body):
    return body


def build_mock_test_tools():
    return FunctionDefinitions([
        FunctionDefinition(get_mock_octopus_projects),
        FunctionDefinition(answer_general_query_callback(general_query_handler), AnswerGeneralQuery)
    ])
