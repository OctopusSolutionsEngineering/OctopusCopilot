from domain.tools.query.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.query.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from domain.tools.query.how_to import how_to_wrapper


def general_query_handler(query, body, messages):
    return body


def how_to_callback(query, keywords):
    return query, keywords


def build_mock_test_tools(tool_query):
    docs_functions = [FunctionDefinition(tool) for tool in how_to_wrapper(tool_query, how_to_callback, None)]
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query_wrapper(tool_query, general_query_handler), AnswerGeneralQuery)],
        fallback=FunctionDefinitions(docs_functions))
