from domain.logging.app_logging import configure_logging
from domain.transformers.minify_strings import minify_strings
from domain.validation.argument_validation import ensure_string_starts_with
from infrastructure.octoterra import get_octoterra_space
from infrastructure.openai import llm_message_query

my_log = configure_logging()

# Each token is roughly four characters for typical English text. OpenAI accepts a max of 16384 tokens.
# Unfortunately you can't just multiply 16384 by 4 as it turns ouy getting the logs was frequently overrunning the
# limit. So the limit below is fairly conservative.
max_chars = 10000 * 4

# This is the max number of chars for 128k context length. Tokens are roughly 3 or 4 characters each. We also need
# a buffer for the user's prompt.
max_chars_128 = 100000 * 4


def collect_llm_context(
    original_query,
    messages,
    context,
    space_id,
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
    channel_names,
    release_versions,
    step_names,
    variable_names,
    dates,
    api_key,
    octopus_url,
    log_query,
    max_attribute_length=1000,
):
    """
    We need to source context for the LLM from multiple locations. "Static" resources are defined using Terraform,
    as this is a publicly documented format the LLM may have had an opportunity to scrape that also has the benefit of
    explicitly defining the relationship between resources. "Dynamic" resources like deployments and releases are
    sourced from the Octopus API as these can not be defined in HCL.

    The LLM messages are also tailored here to guide the LLM in how it processes the context.

    :param space_id: The Octopus space name
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

    ensure_string_starts_with(
        space_id,
        "Spaces-",
        'space_id must be a non-empty string starting with "Spaces-" (collect_llm_context).',
    )

    if log_query:
        log_query(
            "collect_llm_context",
            f"""
            Space Id: {space_id}
            Project Names: {project_names}
            Runbook Names: {runbook_names}
            Target Names: {target_names}
            Tenant Names: {tenant_names}
            Library Variable Set Names: {library_variable_sets}
            Environment Names: {environment_names}
            Feed Names: {feed_names}
            Account Names: {account_names}
            Certificate Names: {certificate_names}
            Worker Pool Names: {workerpool_names}
            Machine Policy Names: {machinepolicy_names}
            Tag Set Names: {tagset_names}
            Project Group Names: {projectgroup_names}
            Channel Names: {channel_names}
            Release Versions: {release_versions}
            Steps: {step_names}
            Variables: {variable_names}
            Dates: {dates}""",
        )

    # This context provides details about resources like projects, environments, feeds, accounts, certificates, etc.
    hcl, include_all_resources = get_octoterra_space(
        original_query,
        space_id,
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
        octopus_url,
        log_query,
        max_attribute_length,
    )

    minified_hcl = minify_strings(hcl)
    available_chars = max_chars_128

    if context.get("json"):
        available_chars -= len(context["json"])

    if context.get("context"):
        available_chars -= len(context["context"])

    # Trim the HCL to fit within the token limit
    context["hcl"] = minified_hcl[:available_chars]
    context["percent_trimmed"] = round(
        (len(minified_hcl) - len(context["hcl"])) / len(minified_hcl) * 100, 2
    )

    answer = llm_message_query(messages, context, log_query)

    # Broad questions are inaccurate, so add a warning when resources are included in the context in bulk.
    if len(include_all_resources) != 0:
        answer += (
            "\n\nNOTE: The question may be too broad to generate an accurate answer."
            + f"\nProvide specific names for the following resources to generate a more accurate answer: {', '.join(include_all_resources)}."
            + "\nSee https://github.com/OctopusSolutionsEngineering/OctopusCopilot/wiki/Prompt-Engineering-with-Octopus for more details."
        )
    elif context["percent_trimmed"] != 0:
        answer += f"\n\nNOTE: The space context was trimmed by {context['percent_trimmed']}% to fit within the token limit. The answer may be based on incomplete information."

    return answer
