from domain.sanitizers.sanitize_keywords import sanitize_keywords
from domain.sanitizers.sanitized_list import sanitize_list
from domain.tools.generic.keywords import get_keywords
from domain.tools.wrapper.function_definition import (
    FunctionDefinitions,
    FunctionDefinition,
)
from infrastructure.openai import llm_tool_query


def nlp_get_keywords(text, max_keywords=10):
    """
    Extracts keywords with an LLM. This will probably need to be replaced with a call to more specific
    keyword extraction tool. But an LLM works for now.
    :param max_keywords: The number of keywords to return
    :param text: The text to extract keywords from
    :return: The keywords from the text.
    """
    if not text:
        return []

    keywords = llm_tool_query(
        "Get the keywords from the following text: " + text,
        FunctionDefinitions([FunctionDefinition(get_keywords)]),
    ).call_function()
    return sanitize_keywords(sanitize_list(keywords), max_keywords)
