import os

import boto3
import openai
from botocore.config import Config as BotoConfig, Config
from langchain_aws import ChatBedrockConverse
from langchain_classic.agents import create_openai_tools_agent
from langchain_core.messages import HumanMessage
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_openai import AzureChatOpenAI
from openai import RateLimitError
from retry import retry

from domain.exceptions.openai_error import (
    OpenAIContentFilter,
    OpenAITokenLengthExceeded,
    OpenAIBadRequest,
)
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitize_logs import sanitize_message
from domain.tools.wrapper.function_call import FunctionCall
from domain.validation.argument_validation import (
    ensure_string_not_empty,
    ensure_not_falsy,
)

NO_FUNCTION_RESPONSE = (
    "Sorry, I did not understand that request. View the documentation at "
    + "https://github.com/OctopusSolutionsEngineering/OctopusCopilot/wiki/Prompt-Engineering-with-Octopus "
    + "to learn how to interact with the Octopus AI agent."
)


@retry(RateLimitError, tries=3, delay=5)
def llm_message_query(
    message_prompt,
    context,
    log_query=None,
    deployment=None,
    api_key=None,
    endpoint=None,
    custom_version=None,
    temperature=0,
    use_responses_api=False,
):
    # We can use a specific deployment to answer a query, or fallback to the default
    deployment = (
        deployment
        or os.environ.get("AISERVICES_DEPLOYMENT_QUERY")
        or os.environ["AISERVICES_DEPLOYMENT"]
    )
    version = (
        custom_version
        or os.environ.get("AISERVICES_DEPLOYMENT_QUERY_VERSION")
        or "2025-04-01-preview"  # https://learn.microsoft.com/en-us/azure/ai-services/openai/api-version-deprecation#latest-preview-api-releases
    )

    # llm = AzureChatOpenAI(
    #     temperature=temperature,
    #     azure_deployment=deployment,
    #     api_key=(api_key or os.environ["AISERVICES_KEY"]),
    #     azure_endpoint=(endpoint or os.environ["AISERVICES_ENDPOINT"]),
    #     api_version=version,
    #     use_responses_api=use_responses_api,
    # )

    model = (
        os.environ.get("BEDROCK_MODEL_ID")
        or "us.anthropic.claude-haiku-4-5-20251001-v1:0"
    )
    region = os.environ.get("BEDROCK_MODEL_REGION") or "us-east-2"

    bedrock_config = Config(read_timeout=600)
    client = boto3.client("bedrock-runtime", region_name=region, config=bedrock_config)

    llm = ChatBedrockConverse(client=client, model_id=model, temperature=0)

    prompt = ChatPromptTemplate.from_messages(message_prompt)

    chain = prompt | llm

    try:
        response = timing_wrapper(lambda: chain.invoke(context).content, "Query")
    except openai.BadRequestError as e:
        return handle_openai_exception(e)
    except openai.APITimeoutError as e:
        return handle_openai_exception(e)

    # The response might be text or an array depending on the model and settings. GPT 5 codex for example returns an array of items.
    if isinstance(response, list):
        response = next(
            item.get("text") for item in response if item.get("type") == "text"
        )

    # ensure known sensitive variables are not returned
    client_response = sanitize_message(response).strip()

    return client_response.strip()


def handle_openai_exception(exception):
    # This will be something like:
    # {'error': {'message': "This model's maximum context length is 16384 tokens. However, your messages resulted in 17570 tokens. Please reduce the length of the messages.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
    if exception.body and "message" in exception.body:
        return exception.body.get("message")
    return exception.message


def llm_tool_query(
    query,
    functions,
    log_query=None,
    extra_prompt_messages=None,
    use_responses_api=False,
    temperature=0,
):
    """
    This is the handler that responds to a chat request.
    :param log_query: The function used to log the query
    :param query: The pain text query
    :param functions: The set of tools used by OpenAI
    :param extra_prompt_messages: Additional messages to pass to the LLM
    :return: The result of the function, defined by the set of tools, that was called in response to the query
    """

    ensure_string_not_empty(
        query, "query must be a non-empty string (handle_copilot_tools_execution)."
    )
    ensure_not_falsy(
        query, "llm_tools must not be None (handle_copilot_tools_execution)."
    )

    tools = functions.get_tools()

    # Version comes from https://learn.microsoft.com/en-us/azure/ai-services/openai/api-version-deprecation#latest-ga-api-release
    # These models support function calling: https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/function-calling#function-calling-support

    # We can use a specific deployment to select a tool, or fallback to the default
    deployment = (
        os.environ.get("AISERVICES_DEPLOYMENT_FUNCTIONS")
        or os.environ["AISERVICES_DEPLOYMENT"]
    )
    version = os.environ.get("OPENAI_API_DEPLOYMENT_FUNCTIONS_VERSION") or "2024-10-21"

    llm = AzureChatOpenAI(
        temperature=temperature,
        azure_deployment=deployment,
        openai_api_key=os.environ["AISERVICES_KEY"],
        azure_endpoint=os.environ["AISERVICES_ENDPOINT"],
        api_version=version,
        use_responses_api=use_responses_api,
    )

    prompt = ChatPromptTemplate.from_messages(
        [
            ("system", "You are a helpful assistant"),
            *(extra_prompt_messages or []),
            ("human", "{input}"),
            MessagesPlaceholder("agent_scratchpad"),
        ]
    )

    try:
        agent_runnable = create_openai_tools_agent(llm, tools, prompt)
        action = agent_runnable.invoke({"input": query, "intermediate_steps": []})
        # Get the last action if there are multiple
        if isinstance(action, list):
            action = action[-1]
    except openai.BadRequestError as e:
        # This will be something like:
        # {'error': {'message': "This model's maximum context length is 16384 tokens. However, your messages resulted in 17570 tokens. Please reduce the length of the messages.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
        # {'error': {'message': "The response was filtered due to the prompt triggering Azure OpenAI's content management policy. Please modify your prompt and retry. To learn more about our content filtering policies please read our documentation: https://go.microsoft.com/fwlink/?linkid=2198766", 'type': None, 'param': 'prompt', 'code': 'content_filter', 'status': 400, 'innererror': {'code': 'ResponsibleAIPolicyViolation', 'content_filter_result': {'hate': {'filtered': True, 'severity': 'high'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': True, 'severity': 'medium'}}}}}

        if log_query:
            log_query("OpenAI Exception", str(e))

        if e.body and "code" in e.body:
            if e.body.get("code") == "content_filter":
                raise OpenAIContentFilter(e)
            if e.body.get("code") == "context_length_exceeded":
                raise OpenAITokenLengthExceeded(e)

        raise OpenAIBadRequest(e)
    except Exception as e:
        raise e

    # We always want to match a tool. This is a big part of how we prevent the extension from returning
    # undesirable answers unrelated to Octopus.
    if hasattr(action, "tool"):
        if log_query:
            log_query("Tool", action.tool)
        return FunctionCall(
            functions.get_function(action.tool), action.tool, action.tool_input
        )

    # Either no tool was matched, or the LLM returned an answer rather than a list of tools.
    # We don't want answers, as any general questions must be served by our own tools.
    # The fallback process will typically run through a more generic set of tools to try and
    # respond to general queries.
    if functions.has_fallback():
        return llm_tool_query(
            query, functions.get_fallback_tool(), log_query, extra_prompt_messages
        )

    # If no tool was found and there was no fallback, we return a generic apology.
    # We will never ask a general question of the LLM, because we don't want to answer questions unrelated to Octopus.
    return FunctionCall(lambda: CopilotResponse(NO_FUNCTION_RESPONSE), "none", {})
