import os

import ollama
import openai
from langchain_anthropic import ChatAnthropic
from langchain_classic.agents import create_openai_tools_agent
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_ollama import ChatOllama
from langchain_openai import AzureChatOpenAI
from openai import RateLimitError
from retry import retry

from domain.converters.string_to_int import string_to_int
from domain.exceptions.openai_error import (
    OpenAIContentFilter,
    OpenAITokenLengthExceeded,
    OpenAIBadRequest,
)
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitize_logs import sanitize_message
from domain.sanitizers.sanitize_strings import to_lower_case_strip_or_none
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

AZURE_PROJECT_SERVICE = "azure_project"
AZURE_PROJECT_ANTHROPIC_SERVICE = "azure_project_anthropic"
OLLAMA_PROJECT_SERVICE = "ollama_project"
AZURE_GENERAL_SERVICE = "azure_general"
AZURE_GENERAL_QUERY_SMALL_LLM = "azure_general_query_small"
EUROPE_REGION = "Europe"
US_REGION = "US"
GLOBAL_REGION = "Global"
SIMPLE_PROMPT = 100
DETAILED_PROJECT_PROMPT_LENGTH = 2000
VERY_DETAILED_PROJECT_PROMPT_LENGTH = 5000


def validate_region(region):
    """Validate that region is None, empty string, GLOBAL_REGION, EUROPE_REGION, or US_REGION."""
    if (
        region is not None
        and region != ""
        and region.lower() != GLOBAL_REGION.lower()
        and region.lower() != EUROPE_REGION.lower()
        and region.lower() != US_REGION.lower()
    ):
        raise ValueError(
            f"Invalid region specified: {region}. Must be either {EUROPE_REGION}, {US_REGION}, {GLOBAL_REGION}, empty string, or None."
        )


def get_project_gen_deployment(region=None):
    """Get the project generation deployment name based on the region."""
    validate_region(region)

    fixed_region = to_lower_case_strip_or_none(region)

    if fixed_region == EUROPE_REGION.lower():
        return os.getenv("AISERVICES_DEPLOYMENT_EUROPE_PROJECT_GEN")
    elif fixed_region == US_REGION.lower():
        return os.getenv("AISERVICES_DEPLOYMENT_US_PROJECT_GEN")
    else:
        return os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN")


def get_functions_deployment(region=None):
    """Get the function selection deployment name based on the region."""
    validate_region(region)

    fixed_region = to_lower_case_strip_or_none(region)

    if fixed_region == EUROPE_REGION.lower():
        return os.getenv("AISERVICES_DEPLOYMENT_EUROPE_FUNCTIONS")
    elif fixed_region == US_REGION.lower():
        return os.getenv("AISERVICES_DEPLOYMENT_US_FUNCTIONS")
    else:
        return os.getenv("AISERVICES_DEPLOYMENT_FUNCTIONS")


def get_deployment(region=None):
    """Get the general query deployment name based on the region."""
    validate_region(region)

    fixed_region = to_lower_case_strip_or_none(region)

    if fixed_region == EUROPE_REGION.lower():
        return os.getenv("AISERVICES_EUROPE_DEPLOYMENT")
    elif fixed_region == US_REGION.lower():
        return os.getenv("AISERVICES_US_DEPLOYMENT")
    else:
        return os.getenv("AISERVICES_DEPLOYMENT")


def get_small_deployment(region=None):
    """Get the small general query deployment name based on the region."""
    validate_region(region)

    fixed_region = to_lower_case_strip_or_none(region)

    if fixed_region == EUROPE_REGION.lower():
        return os.getenv("AISERVICES_DEPLOYMENT_EUROPE_GENERAL_QUERY_SMALL")
    elif fixed_region == US_REGION.lower():
        return os.getenv("AISERVICES_DEPLOYMENT_US_GENERAL_QUERY_SMALL")
    else:
        return os.getenv("AISERVICES_DEPLOYMENT_GENERAL_QUERY_SMALL")


def get_endpoint_and_key(region=None):
    validate_region(region)

    fixed_region = to_lower_case_strip_or_none(region)

    if fixed_region == EUROPE_REGION.lower():
        return (
            os.environ["AISERVICES_EUROPE_ENDPOINT"],
            os.environ["AISERVICES_EUROPE_KEY"],
        )
    elif fixed_region == US_REGION.lower():
        return os.environ["AISERVICES_US_ENDPOINT"], os.environ["AISERVICES_US_KEY"]
    else:
        return os.environ["AISERVICES_ENDPOINT"], os.environ["AISERVICES_KEY"]


def get_ollama_endpoint():
    """Get the Ollama host root, falling back to the localhost default."""
    endpoint = os.getenv("OLLAMA_ENDPOINT", "http://localhost:11434").rstrip("/")
    # The native Ollama API is served from the host root. Strip any OpenAI-compatible /v1 suffix
    # so endpoints configured for the OpenAI client continue to work.
    return endpoint.removesuffix("/v1")


def get_ollama_model():
    """Get the Ollama model to query, falling back to the default model."""
    return os.getenv("OLLAMA_MODEL", "qwen3.8:27b-mlx")


def get_ollama_context_length():
    """Get the Ollama context window in tokens, defaulting to 256K."""
    return string_to_int(os.getenv("OLLAMA_CONTEXT_LENGTH", "262144"), 262144)


def get_ollama_temperature():
    """Get the Ollama temperature, following the string_to_int convention used by the other builders."""
    return (
        None
        if os.getenv("OLLAMA_TEMPERATURE", "") == "None"
        else string_to_int(os.getenv("OLLAMA_TEMPERATURE", "0"), 0)
    )


def get_ollama_reasoning():
    """
    Get the Ollama reasoning mode, defaulting to "medium".
    "True" and "False" toggle reasoning, "None" uses the model default, and any other value
    (e.g. "low", "medium", "high") is passed through as the reasoning level.
    """
    reasoning = os.getenv("OLLAMA_REASONING", "medium").strip()
    lower = reasoning.lower()
    if lower == "none":
        return None
    if lower == "true":
        return True
    if lower == "false":
        return False
    return reasoning


def build_llm(purpose, region=None, prompt=None):
    if purpose == AZURE_PROJECT_SERVICE:
        return build_azure_project_llm(region, prompt)

    if purpose == AZURE_GENERAL_QUERY_SMALL_LLM:
        return build_azure_general_small_query(region)

    # Anthropic LLMs only offer global standard
    if purpose == AZURE_PROJECT_ANTHROPIC_SERVICE:
        return build_azure_anthropic_project_llm(prompt)

    # Ollama serves a local model on localhost, so it likewise has no regional variants.
    if purpose == OLLAMA_PROJECT_SERVICE:
        return build_ollama_llm()

    return build_azure_general_llm(region)


def build_ollama_llm():
    # We use the native Ollama API rather than the OpenAI-compatible /v1 endpoint, because
    # only the native API allows the context window (num_ctx) to be set with each request.
    # The Ollama default context window is too small for the project generation prompts.
    return ChatOllama(
        temperature=get_ollama_temperature(),
        model=get_ollama_model(),
        base_url=get_ollama_endpoint(),
        num_ctx=get_ollama_context_length(),
        reasoning=get_ollama_reasoning(),
    )


def build_azure_anthropic_project_llm(prompt=None):
    deployment = os.getenv("AISERVICES_DEPLOYMENT_ANTHROPIC_PROJECT_GEN")
    api_key = os.environ["AISERVICES_KEY"]
    endpoint = os.environ["AISERVICES_ANTHROPIC_ENDPOINT"]
    temperature = (
        None
        if os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN_TEMPERATURE", "") == "None"
        else string_to_int(
            os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN_TEMPERATURE", "0"),
            0,
        )
    )
    max_tokens = (
        None
        if os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN_TOKENS", "") == "None"
        else string_to_int(
            os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN_TOKENS", "128000"),
            128000,
        )
    )

    # Enable effort for large project prompts
    def get_effort(prompt):
        length = len(prompt)
        if length < SIMPLE_PROMPT:
            return "low"
        if length < DETAILED_PROJECT_PROMPT_LENGTH:
            return "medium"
        if length < VERY_DETAILED_PROJECT_PROMPT_LENGTH:
            return "high"
        return "xhigh"

    return ChatAnthropic(
        temperature=temperature,
        model=deployment,
        base_url=endpoint,
        api_key=api_key,
        max_tokens=max_tokens,
        thinking={
            "type": "adaptive"
        },
        output_config={
            "effort": get_effort(prompt)
        }
    )


def build_azure_project_llm(region=None, prompt=None):
    version = (
        os.environ.get("AISERVICES_DEPLOYMENT_QUERY_VERSION")
        or "2025-04-01-preview"  # https://learn.microsoft.com/en-us/azure/ai-services/openai/api-version-deprecation#latest-preview-api-releases
    )

    temperature = (
        None
        if os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN_TEMPERATURE", "") == "None"
        else string_to_int(
            os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN_TEMPERATURE", "0"),
            0,
        )
    )

    use_responses_api = (
        os.getenv("AISERVICES_DEPLOYMENT_PROJECT_GEN_RESPONSES", "").casefold()
        == "true"
    )

    deployment = get_project_gen_deployment(region)

    endpoint, api_key = get_endpoint_and_key(region)

    # "minimal" is not accepted by every model, which rejects the request with a 400. "low" is the
    # lowest effort supported by all the models used for project generation.
    thinking = "low" if len(prompt) < DETAILED_PROJECT_PROMPT_LENGTH else "medium"

    return AzureChatOpenAI(
        temperature=temperature,
        azure_deployment=deployment,
        api_key=api_key,
        azure_endpoint=endpoint,
        api_version=version,
        use_responses_api=use_responses_api,
        reasoning_effort=thinking if not use_responses_api else None,
        reasoning=(
            {
                "effort": thinking,
                "summary": "concise",
            }
            if use_responses_api
            else None
        ),
    )


def build_azure_general_small_query(region=None):
    version = (
        os.environ.get("AISERVICES_DEPLOYMENT_GENERAL_QUERY_SMALL_VERSION")
        or "2025-04-01-preview"  # https://learn.microsoft.com/en-us/azure/ai-services/openai/api-version-deprecation#latest-preview-api-releases
    )

    temperature = (
        None
        if os.getenv("AISERVICES_DEPLOYMENT_GENERAL_QUERY_SMALL_TEMPERATURE", "")
        == "None"
        else string_to_int(
            os.getenv("AISERVICES_DEPLOYMENT_GENERAL_QUERY_SMALL_TEMPERATURE", "1"),
            1,
        )
    )

    use_responses_api = (
        os.getenv("AISERVICES_DEPLOYMENT_GENERAL_QUERY_SMALL_RESPONSES", "").casefold()
        == "true"
    )

    deployment = get_small_deployment(region)
    endpoint, api_key = get_endpoint_and_key(region)

    return AzureChatOpenAI(
        temperature=temperature,
        azure_deployment=deployment,
        api_key=api_key,
        azure_endpoint=endpoint,
        api_version=version,
        use_responses_api=use_responses_api,
        reasoning_effort="medium",
    )


def build_azure_general_llm(region=None):
    deployment = get_deployment(region)

    version = "2025-04-01-preview"

    temperature = os.environ.get("AISERVICES_DEPLOYMENT_TEMPERATURE") or 0

    use_responses_api = False

    endpoint, api_key = get_endpoint_and_key(region)

    return AzureChatOpenAI(
        temperature=temperature,
        azure_deployment=deployment,
        api_key=api_key,
        azure_endpoint=endpoint,
        api_version=version,
        use_responses_api=use_responses_api,
    )


@retry(RateLimitError, tries=3, delay=5)
def llm_message_query(
    message_prompt, context, log_query=None, purpose=AZURE_GENERAL_SERVICE, region=None
):

    llm = build_llm(purpose, region, prompt=message_prompt)

    prompt = ChatPromptTemplate.from_messages(message_prompt)

    chain = prompt | llm

    try:
        response = timing_wrapper(
            lambda: chain.invoke(context).content, "Query with " + purpose
        )
    except openai.BadRequestError as e:
        # Errors must be raised rather than returned, as callers can't distinguish an error message from a
        # genuine response. For example, project creation would treat the error as a Terraform configuration.
        raise_bad_request_exception(e, log_query)
    except ollama.ResponseError as e:
        raise_ollama_exception(e, log_query)

    # The response might be text or an array depending on the model and settings. GPT 5 codex for example returns an array of items.
    if isinstance(response, list):
        response = next(
            item.get("text") for item in response if item.get("type") == "text"
        )

    # ensure known sensitive variables are not returned
    client_response = sanitize_message(response).strip()

    return client_response.strip()


def raise_bad_request_exception(exception, log_query=None):
    # This will be something like:
    # {'error': {'message': "This model's maximum context length is 16384 tokens. However, your messages resulted in 17570 tokens. Please reduce the length of the messages.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
    # {'error': {'message': "The response was filtered due to the prompt triggering Azure OpenAI's content management policy. Please modify your prompt and retry. To learn more about our content filtering policies please read our documentation: https://go.microsoft.com/fwlink/?linkid=2198766", 'type': None, 'param': 'prompt', 'code': 'content_filter', 'status': 400, 'innererror': {'code': 'ResponsibleAIPolicyViolation', 'content_filter_result': {'hate': {'filtered': True, 'severity': 'high'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': True, 'severity': 'medium'}}}}}
    # Other providers, like Ollama, may not return a code, so the message is also checked for errors like:
    # input length (20000 tokens) exceeds the model's maximum context length (16384 tokens)

    if log_query:
        log_query("OpenAI Exception", str(exception))

    body = exception.body if isinstance(exception.body, dict) else {}
    code = body.get("code")
    message = str(body.get("message") or exception.message)

    if code == "content_filter":
        raise OpenAIContentFilter(exception)
    if code == "context_length_exceeded" or "maximum context length" in message:
        raise OpenAITokenLengthExceeded(exception)

    raise OpenAIBadRequest(exception)


def raise_ollama_exception(exception, log_query=None):
    # The native Ollama API reports errors like:
    # input length (20000 tokens) exceeds the model's maximum context length (16384 tokens)

    if log_query:
        log_query("Ollama Exception", str(exception))

    if "maximum context length" in str(exception.error):
        raise OpenAITokenLengthExceeded(exception)

    raise exception


def llm_tool_query(
    query,
    functions,
    log_query=None,
    extra_prompt_messages=None,
    use_responses_api=False,
    region=None,
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
    deployment = get_functions_deployment(region)
    endpoint, api_key = get_endpoint_and_key(region)
    version = os.environ.get("OPENAI_API_DEPLOYMENT_FUNCTIONS_VERSION") or "2024-10-21"
    temperature = os.environ.get("AISERVICES_DEPLOYMENT_FUNCTIONS_TEMPERATURE") or 0

    llm = AzureChatOpenAI(
        temperature=temperature,
        azure_deployment=deployment,
        openai_api_key=api_key,
        azure_endpoint=endpoint,
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
        raise_bad_request_exception(e, log_query)
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
