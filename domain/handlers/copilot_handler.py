import os

from langchain.agents import OpenAIFunctionsAgent
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import AzureChatOpenAI

from domain.langchain.azure_chat_open_ai_with_tooling import AzureChatOpenAIWithTooling
from domain.logging.app_logging import configure_logging
from domain.strings.minify_hcl import minify_hcl
from domain.strings.sanitized_list import sanitize_list
from domain.tools.detect_data_source import get_data_source, DataSource
from domain.tools.function_call import FunctionCall
from domain.validation.argument_validation import ensure_string_not_empty, ensure_not_falsy
from infrastructure.octopus import get_project_progression, get_dashboard
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


def build_hcl_and_json_prompt(step_by_step=False):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context.
    :param step_by_step: True if the LLM should display its reasoning step by step before the answer. False for concise answers.
    :return: The messages to pass to the llm.
    """
    messages = [
        ("system",
         "You understand Terraform modules and JSON blobs defining Octopus Deploy resources."
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
        ("user", "Answer the question using the HCL and JSON below."),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "JSON: ###\n{json}\n###"),
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


def collect_llm_context(original_query, enriched_query, space_name, project_names, runbook_names, target_names,
                        tenant_names,
                        library_variable_sets, environment_names, feed_names, account_names, certificate_names,
                        lifecycle_names, workerpool_names, machinepolicy_names, tagset_names, projectgroup_names,
                        channel_names, release_versions, api_key,
                        octopus_url, log_query, step_by_step=False):
    """
    We need to source context for the LLM from multiple locations. "Static" resources are defined using Terraform,
    as this is a publicly documented format the LLM may have had an opportunity to scrape that also has the benefit of
    explicitly defining the relationship between resources. "Dynamic" resources like deployments and releases are
    sourced from the Octopus API as these can not be defined in HCL.

    The LLM messages are also tailored here to guide the LLM in how it processes the context.

    :param enriched_query: The LLM query
    :param space_name: The Octopus space name
    :param project_names: The project names found in the query
    :param runbook_names: The runbook names found in the query
    :param target_names: The target names found in the query
    :param tenant_names: The tenant names found in the query
    :param library_variable_sets: The library variable set names found in the query
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :param log_query: A function used to log debug and error messages
    :param step_by_step: True if the LLM should be instructed to explain its reasoning
    :return: The query result
    """
    ensure_string_not_empty(enriched_query, 'query must be a non-empty string (handle_copilot_query).')
    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (handle_copilot_query).')

    if log_query:
        log_query("handle_configuration_query", "-----------------------------")
        log_query("Query:", enriched_query)
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
    hcl = get_octoterra_space(enriched_query,
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

    # The HCL does not have any representation for deployments and releases. So we add JSON returned from the
    # server to expose this information.
    data_source = get_data_source(original_query, project_names)

    context = {"input": enriched_query}
    if data_source == DataSource.PROJECT_PROGRESSION:
        messages = build_hcl_and_json_prompt(step_by_step)
        json = ""
        for project in sanitize_list(project_names):
            json += get_project_progression(space_name, project, api_key, octopus_url) + "\n\n"
        context["json"] = json
        context["hcl"] = hcl
    elif data_source == DataSource.DASHBOARD_PROGRESSION:
        messages = build_hcl_and_json_prompt(step_by_step)
        context["json"] = get_dashboard(space_name, api_key, octopus_url)
        context["hcl"] = hcl
    else:
        messages = build_hcl_prompt(step_by_step)
        context["hcl"] = hcl

    return llm_message_query(messages, context, log_query)


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

    # We'll minify and truncate the HCL to avoid hitting the token limit.
    minified_context = minify_hcl(context["hcl"])
    truncated_context = minified_context[0:max_chars]
    percent_truncated = round((len(minified_context) - len(truncated_context)) / len(minified_context) * 100, 2) if len(
        minified_context) != 0 else 0

    if percent_truncated > 0:
        if log_query:
            log_query("query_llm", "----------------------------------------")
            log_query("HCL:", context.get("hcl"))
            log_query("JSON:", context.get("json"))
            log_query("Text:", context.get("context"))
            log_query("Query:", context.get("input"))
            log_query("Context truncation:", str(percent_truncated) + "%")
        return "Your query was too broad. Please ask a more specific question."

    context["hcl"] = truncated_context

    response = chain.invoke(context).content

    if log_query:
        log_query("query_llm", "----------------------------------------")
        log_query("HCL:", context.get("hcl"))
        log_query("JSON:", context.get("json"))
        log_query("Text:", context.get("context"))
        log_query("Query:", context.get("input"))
        log_query("Response:", response)

    return response


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

    action = agent.plan([], input=query)

    # In the event that there was no matched function, return a canned response
    if not hasattr(action, "tool"):
        return FunctionCall(lambda: NO_FUNCTION_RESPONSE, {})

    return FunctionCall(functions.get_function(action.tool), action.tool_input)
