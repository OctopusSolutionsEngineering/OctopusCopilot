import os

import openai
from langchain.agents import OpenAIFunctionsAgent
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import AzureChatOpenAI
from openai import RateLimitError
from retry import retry

from domain.config.openai import llm_timeout
from domain.exceptions.openai_error import OpenAIContentFilter, OpenAITokenLengthExceeded, OpenAIBadRequest
from domain.langchain.azure_chat_open_ai_with_tooling import AzureChatOpenAIWithTooling
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.tools.query.function_call import FunctionCall
from domain.validation.argument_validation import ensure_string_not_empty, ensure_not_falsy

NO_FUNCTION_RESPONSE = ("Sorry, I did not understand that request. View the documentation at "
                        + "https://github.com/OctopusSolutionsEngineering/OctopusCopilot/wiki/Prompt-Engineering-with-Octopus "
                        + "to learn how to interact with the Octopus AI agent.")


@retry(RateLimitError, tries=3, delay=5)
def llm_message_query(message_prompt, context, log_query=None):
    llm = AzureChatOpenAI(
        temperature=0,
        azure_deployment=os.environ["OPENAI_API_DEPLOYMENT"],
        openai_api_key=os.environ["OPENAI_API_KEY"],
        azure_endpoint=os.environ["OPENAI_ENDPOINT"],
        api_version="2024-02-01",
        request_timeout=llm_timeout
    )

    prompt = ChatPromptTemplate.from_messages(message_prompt)

    chain = prompt | llm

    try:
        response = timing_wrapper(lambda: chain.invoke(context).content, "Query")
    except openai.BadRequestError as e:
        return handle_openai_exception(e)
    except openai.APITimeoutError as e:
        return handle_openai_exception(e)

    client_response = response

    return client_response.strip()


def handle_openai_exception(exception):
    # This will be something like:
    # {'error': {'message': "This model's maximum context length is 16384 tokens. However, your messages resulted in 17570 tokens. Please reduce the length of the messages.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
    if exception.body and 'message' in exception.body:
        return exception.body.get('message')
    return exception.message


def llm_tool_query(query, functions, log_query=None, extra_prompt_messages=None):
    """
    This is the handler that responds to a chat request.
    :param log_query: The function used to log the query
    :param query: The pain text query
    :param functions: The set of tools used by OpenAI
    :param extra_prompt_messages: Additional messages to pass to the LLM
    :return: The result of the function, defined by the set of tools, that was called in response to the query
    """

    ensure_string_not_empty(query, 'query must be a non-empty string (handle_copilot_tools_execution).')
    ensure_not_falsy(query, 'llm_tools must not be None (handle_copilot_tools_execution).')

    tools = functions.get_tools()

    # Version comes from https://github.com/openai/openai-python/issues/926#issuecomment-1839426482
    # Note that for function calling you need 3.5-turbo-16k
    # https://github.com/openai/openai-python/issues/926#issuecomment-1920037903
    agent = OpenAIFunctionsAgent.from_llm_and_tools(
        llm=AzureChatOpenAIWithTooling(temperature=0,
                                       azure_deployment=os.environ["OPENAI_API_DEPLOYMENT"],
                                       openai_api_key=os.environ["OPENAI_API_KEY"],
                                       azure_endpoint=os.environ["OPENAI_ENDPOINT"],
                                       api_version="2024-02-01"),
        tools=tools,
        extra_prompt_messages=extra_prompt_messages
    )

    try:
        action = agent.plan([], input=query)
    except openai.BadRequestError as e:
        # This will be something like:
        # {'error': {'message': "This model's maximum context length is 16384 tokens. However, your messages resulted in 17570 tokens. Please reduce the length of the messages.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
        # {'error': {'message': "The response was filtered due to the prompt triggering Azure OpenAI's content management policy. Please modify your prompt and retry. To learn more about our content filtering policies please read our documentation: https://go.microsoft.com/fwlink/?linkid=2198766", 'type': None, 'param': 'prompt', 'code': 'content_filter', 'status': 400, 'innererror': {'code': 'ResponsibleAIPolicyViolation', 'content_filter_result': {'hate': {'filtered': True, 'severity': 'high'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': True, 'severity': 'medium'}}}}}
        if e.body and 'code' in e.body:
            if e.body.get('code') == 'content_filter':
                raise OpenAIContentFilter(e)
            if e.body.get('code') == 'context_length_exceeded':
                raise OpenAITokenLengthExceeded(e)

        raise OpenAIBadRequest(e)

    # We always want to match a tool. This is a big part of how we prevent the extension from returning
    # undesirable answers unrelated to Octopus.
    if hasattr(action, "tool"):
        return FunctionCall(functions.get_function(action.tool), action.tool, action.tool_input)

    # Either no tool was matched, or the LLM returned an answer rather than a list of tools.
    # We don't want answers, as any general questions must be served by our own tools.
    # The fallback process will typically run through a more generic set of tools to try and
    # respond to general queries.
    if functions.has_fallback():
        return llm_tool_query(query, functions.get_fallback_tool(), log_query, extra_prompt_messages)

    # If no tool was found and there was no fallback, we return a generic apology.
    # We will never ask a general question of the LLM, because we don't want to answer questions unrelated to Octopus.
    return FunctionCall(lambda: CopilotResponse(NO_FUNCTION_RESPONSE), "none", {})
