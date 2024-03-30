from domain.logging.app_logging import configure_logging
from domain.transformers.minify_hcl import minify_hcl
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octoterra import get_octoterra_space
from infrastructure.openai import llm_message_query

my_log = configure_logging()

# Each token is roughly four characters for typical English text. OpenAI accepts a max of 16384 tokens.
# We'll allow 13500 tokens for the HCL to avoid an error.
max_chars = 13500 * 4


def collect_llm_context(original_query, messages, context, space_name, project_names, runbook_names, target_names,
                        tenant_names,
                        library_variable_sets, environment_names, feed_names, account_names, certificate_names,
                        lifecycle_names, workerpool_names, machinepolicy_names, tagset_names, projectgroup_names,
                        channel_names, release_versions, step_names, variable_names, api_key,
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
        log_query("Steps:", step_names)
        log_query("Variables:", variable_names)

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
                              step_names,
                              variable_names,
                              api_key,
                              octopus_url)

    minified_hcl = minify_hcl(hcl)
    available_chars = max_chars

    if context.get("json"):
        available_chars -= len(context["json"])

    if context.get("context"):
        available_chars -= len(context["context"])

    # Trim the HCL to fit within the token limit
    context["hcl"] = minified_hcl[:available_chars]
    context["percent_trimmed"] = round((len(minified_hcl) - len(context["hcl"])) / len(minified_hcl) * 100, 2)

    return llm_message_query(messages, context, log_query)
