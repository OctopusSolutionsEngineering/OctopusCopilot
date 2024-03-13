import os

from langchain.agents import OpenAIFunctionsAgent
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import AzureChatOpenAI

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


def handle_copilot_query(query, space_name, project_names, runbook_names, target_names, tenant_names,
                         library_variable_sets, api_key,
                         octopus_url, log_query, step_by_step=False):
    ensure_string_not_empty(query, 'query must be a non-empty string (handle_copilot_query).')
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (handle_copilot_query).')

    if log_query:
        log_query("handle_copilot_query", "-----------------------------")
        log_query("Query:", query)
        log_query("Space Name:", space_name)
        log_query("Project Names:", project_names)
        log_query("Runbook Names:", runbook_names)
        log_query("Target Names:", target_names)
        log_query("Tenant Names:", tenant_names)
        log_query("Library Variable Set Names:", library_variable_sets)

    hcl = get_octoterra_space(query,
                              space_name,
                              project_names,
                              runbook_names,
                              target_names,
                              tenant_names,
                              library_variable_sets,
                              api_key,
                              octopus_url)

    return query_llm(hcl, query, log_query, step_by_step)


def query_llm(hcl, query, log_query=None, step_by_step=False):
    llm = AzureChatOpenAI(
        temperature=0,
        azure_deployment=os.environ["OPENAI_API_DEPLOYMENT"],
        openai_api_key=os.environ["OPENAI_API_KEY"],
        azure_endpoint=os.environ["OPENAI_ENDPOINT"],
        api_version="2024-03-01-preview",
    )

    messages = [
        ("system",
         "You understand Terraform modules defining Octopus Deploy resources."
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
            "system",
            "You are a concise and helpful agent. Respond only with the answer to the question."))

    prompt = ChatPromptTemplate.from_messages(messages)

    chain = prompt | llm

    # We'll minify and truncate the HCL to avoid hitting the token limit.
    minified_hcl = minify_hcl(hcl)
    truncated_hcl = minified_hcl[0:max_chars]
    percent_truncated = round((len(minified_hcl) - len(truncated_hcl)) / len(minified_hcl) * 100, 2) if len(
        minified_hcl) != 0 else 0

    if percent_truncated > 0:
        log_query("query_llm", "----------------------------------------")
        log_query("HCL:", hcl)
        log_query("Query:", query)
        log_query("Context truncation:", str(percent_truncated) + "%")
        return 0, "Your query was too broad. Please ask a more specific question."

    response = chain.invoke({"input": query, "hcl": truncated_hcl}).content

    if log_query:
        log_query("query_llm", "----------------------------------------")
        log_query("HCL:", hcl)
        log_query("Query:", query)
        log_query("Response:", response)

    return percent_truncated, response


def handle_copilot_tools_execution(query, llm_tools, log_query=None):
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

    action = agent.plan([], input=query)

    # In the event that there was no matched function, return a canned response
    if not hasattr(action, "tool"):
        return FunctionCall(lambda: NO_FUNCTION_RESPONSE, {})

    return FunctionCall(functions.get_function(action.tool), action.tool_input)
