import os

import openai
from langchain.agents import OpenAIFunctionsAgent
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import AzureChatOpenAI
from openai import RateLimitError
from retry import retry

from domain.langchain.azure_chat_open_ai_with_tooling import AzureChatOpenAIWithTooling
from domain.logging.app_logging import configure_logging
from domain.strings.minify_hcl import minify_hcl
from domain.tools.function_call import FunctionCall
from domain.validation.argument_validation import ensure_string_not_empty, ensure_not_falsy
from infrastructure.octoterra import get_octoterra_space

NO_FUNCTION_RESPONSE = "Sorry, I did not understand that request."
my_log = configure_logging()

# Each token is roughly four characters for typical English text. OpenAI accepts a max of 16384 tokens.
# We'll allow 13500 tokens for the HCL to avoid an error.
max_chars = 13500 * 4


def build_hcl_prompt(step_by_step=False):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context.
    :param step_by_step: True if the LLM should display its reasoning step by step before the answer. False for concise answers.
    :return: The messages to pass to the llm.
    """
    messages = [
        ("system",
         "You understand Terraform modules defining Octopus Deploy resources."
         + "The supplied HCL context provides details on Octopus resources like projects, environments, channels, tenants, project groups, lifecycles etc. "
         + "You must assume the Terraform is an accurate representation of the live project. "
         + "Do not mention Terraform in the response. Do not show any Terraform snippets in the response. "
         + "Do not mention that you referenced the Terraform to provide your answer. "
         + "You must assume questions about variables refer to Octopus variables. "
         + "Variables are referenced using the syntax #{{Variable Name}}, $OctopusParameters[\"Variable Name\"], "
         + "Octopus.Parameters[\"Variable Name\"], get_octopusvariable \"Variable Name\", "
         + "or get_octopusvariable(\"Variable Name\"). "
         + "The values of secret variables are not defined in the Terraform configuration. "
         + "Do not mention the fact that the values of secret variables are not defined."),
        ("user", "{input}"),
        ("user", "Answer the question using the HCL below."),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "HCL: ###\n{hcl}\n###")]

    # This message instructs the LLM to display its reasoning step by step before the answer. It can be a useful
    # debugging tool. It doesn't always work though, but you can rerun the query and try again.
    if step_by_step:
        messages.insert(0, ("system", "You are a verbose and helpful agent."))
        messages.append(("user", "Let's think step by step."))
    else:
        messages.insert(0, (
            "system", "You are a concise and helpful agent."))

    return messages


def build_plain_text_prompt():
    """
    Build a message prompt for the LLM that instructs it to parse plain text
    :return: The messages to pass to the llm.
    """
    messages = [
        ("system", "You understand Octopus Deploy log files. "
         + "You are a concise and helpful agent. "
         + "Answer the question given the supplied text. You must assume that the supplied text relates to the project and environment in the question."),
        ("user", "{input}"),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "Text: ###\n{context}\n###")]

    return messages


def collect_llm_context(original_query, messages, context, space_name, project_names, runbook_names, target_names,
                        tenant_names,
                        library_variable_sets, environment_names, feed_names, account_names, certificate_names,
                        lifecycle_names, workerpool_names, machinepolicy_names, tagset_names, projectgroup_names,
                        channel_names, release_versions, api_key,
                        octopus_url, log_query):
    """
    We need to source context for the LLM from multiple locations. "Static" resources are defined using Terraform,
    as this is a publicly documented format the LLM may have had an opportunity to scrape that also has the benefit of
    explicitly defining the relationship between resources. "Dynamic" resources like deployments and releases are
    sourced from the Octopus API as these can not be defined in HCL.

    The LLM messages are also tailored here to guide the LLM in how it processes the context.

    :param space_name: The Octopus space name
    :param project_names: The project names found in the query
    :param runbook_names: The runbook names found in the query
    :param target_names: The target names found in the query
    :param tenant_names: The tenant names found in the query
    :param library_variable_sets: The library variable set names found in the query
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :param log_query: A function used to log debug and error messages
    :return: The query result
    """

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (handle_copilot_query).')

    if log_query:
        log_query("handle_configuration_query", "-----------------------------")
        log_query("Space Name:", space_name)
        log_query("Project Names:", project_names)
        log_query("Runbook Names:", runbook_names)
        log_query("Target Names:", target_names)
        log_query("Tenant Names:", tenant_names)
        log_query("Library Variable Set Names:", library_variable_sets)
        log_query("Environment Names:", environment_names)
        log_query("Feed Names:", feed_names)
        log_query("Account Names:", account_names)
        log_query("Certificate Names:", certificate_names)
        log_query("Worker Pool Names:", workerpool_names)
        log_query("Machine Policy Names:", machinepolicy_names)
        log_query("Tag Set Names:", tagset_names)
        log_query("Project Group Names:", projectgroup_names)
        log_query("Channel Names:", channel_names)
        log_query("Release Versions:", release_versions)

    # This context provides details about resources like projects, environments, feeds, accounts, certificates, etc.
    hcl = get_octoterra_space(original_query,
                              space_name,
                              project_names,
                              runbook_names,
                              target_names,
                              tenant_names,
                              library_variable_sets,
                              environment_names,
                              feed_names,
                              account_names,
                              certificate_names,
                              lifecycle_names,
                              workerpool_names,
                              machinepolicy_names,
                              tagset_names,
                              projectgroup_names,
                              api_key,
                              octopus_url)

    minified_hcl = minify_hcl(hcl)

    available_chars = max_chars - len(context["json"]) - len(context["context"])

    # Trim the HCL to fit within the token limit
    context["hcl"] = minified_hcl[:available_chars]
    context["percent_trimmed"] = round((len(minified_hcl) - len(context["hcl"])) / len(minified_hcl) * 100, 2)

    return llm_message_query(messages, context, log_query)


@retry(RateLimitError, tries=3, delay=5)
def llm_message_query(message_prompt, context, log_query=None):
    llm = AzureChatOpenAI(
        temperature=0,
        azure_deployment=os.environ["OPENAI_API_DEPLOYMENT"],
        openai_api_key=os.environ["OPENAI_API_KEY"],
        azure_endpoint=os.environ["OPENAI_ENDPOINT"],
        api_version="2024-03-01-preview",
    )

    prompt = ChatPromptTemplate.from_messages(message_prompt)

    chain = prompt | llm

    try:
        response = chain.invoke(context).content
    except openai.BadRequestError as e:
        # This will be something like:
        # {'error': {'message': "This model's maximum context length is 16384 tokens. However, your messages resulted in 17570 tokens. Please reduce the length of the messages.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
        if e.body and 'message' in e.body:
            return e.body.get('message')
        return e.message

    if log_query:
        log_query("query_llm", "----------------------------------------")
        log_query("HCL:", context.get("hcl"))
        log_query("JSON:", context.get("json"))
        log_query("Text:", context.get("context"))
        log_query("Query:", context.get("input"))
        log_query("Response:", response)

    client_response = response

    if context.get("percent_trimmed"):
        client_response += f"\n\nThe space context was trimmed by {context['percent_trimmed']}% to fit within the token limit. The answer may be based on incomplete information."

    return client_response


def llm_tool_query(query, llm_tools, log_query=None):
    """
    This is the handler that responds to a chat request.
    :param log_query: The function used to log the query
    :param query: The pain text query
    :param llm_tools: A function that returns the set of tools used by OpenAI
    :return: The result of the function, defined by the set of tools, that was called in response to the query
    """

    ensure_string_not_empty(query, 'query must be a non-empty string (handle_copilot_tools_execution).')
    ensure_not_falsy(query, 'llm_tools must not be None (handle_copilot_tools_execution).')

    functions = llm_tools()
    tools = functions.get_tools()

    # Version comes from https://github.com/openai/openai-python/issues/926#issuecomment-1839426482
    # Note that for function calling you need 3.5-turbo-16k
    # https://github.com/openai/openai-python/issues/926#issuecomment-1920037903
    agent = OpenAIFunctionsAgent.from_llm_and_tools(
        llm=AzureChatOpenAIWithTooling(temperature=0,
                                       azure_deployment=os.environ["OPENAI_API_DEPLOYMENT"],
                                       openai_api_key=os.environ["OPENAI_API_KEY"],
                                       azure_endpoint=os.environ["OPENAI_ENDPOINT"],
                                       api_version="2024-03-01-preview"),
        tools=tools,
    )

    try:
        action = agent.plan([], input=query)
    except openai.BadRequestError as e:
        # This will be something like:
        # {'error': {'message': "This model's maximum context length is 16384 tokens. However, your messages resulted in 17570 tokens. Please reduce the length of the messages.", 'type': 'invalid_request_error', 'param': 'messages', 'code': 'context_length_exceeded'}}
        # {'error': {'message': "The response was filtered due to the prompt triggering Azure OpenAI's content management policy. Please modify your prompt and retry. To learn more about our content filtering policies please read our documentation: https://go.microsoft.com/fwlink/?linkid=2198766", 'type': None, 'param': 'prompt', 'code': 'content_filter', 'status': 400, 'innererror': {'code': 'ResponsibleAIPolicyViolation', 'content_filter_result': {'hate': {'filtered': True, 'severity': 'high'}, 'self_harm': {'filtered': False, 'severity': 'safe'}, 'sexual': {'filtered': False, 'severity': 'safe'}, 'violence': {'filtered': True, 'severity': 'medium'}}}}}
        if e.body and 'message' in e.body:
            return e.body.get('message')
        return e.message

    # In the event that there was no matched function, return a canned response
    if not hasattr(action, "tool"):
        return FunctionCall(lambda: NO_FUNCTION_RESPONSE, {})

    return FunctionCall(functions.get_function(action.tool), action.tool_input)
