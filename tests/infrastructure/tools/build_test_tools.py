from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from domain.tools.how_to import how_to_wrapper


def general_query_handler(query, body, messages):
    return body


def how_to_callback(query, keywords):
    return query, keywords


def build_mock_test_tools(tool_query):
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query_wrapper(tool_query, general_query_handler), AnswerGeneralQuery)],
        FunctionDefinition(how_to_wrapper(tool_query, how_to_callback, None)))
