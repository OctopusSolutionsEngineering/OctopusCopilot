from domain.tools.githubactions.default_values import default_value_callbacks
from domain.tools.wrapper.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.wrapper.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from domain.tools.wrapper.how_to import how_to_wrapper


def general_query_handler(query, body, messages):
    return body


def how_to_callback(query, keywords):
    return query, keywords


def build_mock_test_tools(tool_query):
    docs_functions = [FunctionDefinition(tool) for tool in how_to_wrapper(tool_query, how_to_callback, None)]
    # Functions related to the default values
    set_default_value, remove_default_value, get_default_value, get_all_default_values = default_value_callbacks(
        lambda: "1234567")
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query_wrapper(tool_query, general_query_handler), AnswerGeneralQuery),
        FunctionDefinition(set_default_value),
        FunctionDefinition(get_default_value),
        FunctionDefinition(get_all_default_values),
        FunctionDefinition(remove_default_value),
    ], fallback=FunctionDefinitions(docs_functions))
