from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.general_query import answer_general_query_callback, AnswerGeneralQuery


def general_query_handler(body):
    return body


def build_mock_test_tools():
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query_callback(general_query_handler), AnswerGeneralQuery)
    ])
