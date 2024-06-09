import argparse
import json
import os

from domain.config.openai import max_context
from domain.context.github_docs import get_docs_context
from domain.context.octopus_context import collect_llm_context, max_chars
from domain.converters.string_to_int import string_to_int
from domain.errors.error_handling import handle_error
from domain.logging.query_loggin import log_query
from domain.messages.docs_messages import docs_prompt
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_list, sanitize_environments, none_if_falesy_or_all, \
    get_item_or_none, sanitize_names_fuzzy, sanitize_projects, sanitize_tenants, sanitize_space, sanitize_name_fuzzy, \
    sanitize_log_steps, sanitize_log_lines
from domain.tools.wrapper.certificates_query import answer_certificates_wrapper
from domain.tools.wrapper.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.wrapper.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from domain.tools.wrapper.how_to import how_to_wrapper
from domain.tools.wrapper.project_logs import answer_project_deployment_logs_wrapper
from domain.tools.wrapper.project_variables import answer_project_variables_wrapper, \
    answer_project_variables_usage_wrapper
from domain.tools.wrapper.releases_and_deployments import answer_releases_and_deployments_wrapper
from domain.tools.wrapper.targets_query import answer_machines_wrapper
from domain.transformers.chat_responses import get_octopus_project_names_response
from domain.transformers.deployments_from_release import get_deployments_for_project
from infrastructure.github import search_repo
from infrastructure.octopus import get_octopus_project_names_base, get_raw_deployment_process, get_dashboard, \
    get_deployment_logs, get_space_id_and_name_from_name, get_projects_generator, get_spaces_generator, \
    activity_logs_to_string
from infrastructure.openai import llm_tool_query, llm_message_query


def init_argparse():
    """
    Returns the arguments passed to the application.
    :return: The application arguments
    """
    parser = argparse.ArgumentParser(
        usage='%(prog)s [OPTION] [FILE]...',
        description='Query the Octopus Copilot agent'
    )
    parser.add_argument('--wrapper', action='store')
    return parser.parse_known_args()


parser, _ = init_argparse()


def get_api_key():
    """
    A function that extracts the API key from an environment variable
    :return: The Octopus API key
    """
    return os.environ.get('OCTOPUS_CLI_API_KEY')


def get_github_token():
    """
    A function that extracts the Github token from an environment variable
    :return: The Octopus API key
    """
    return os.environ.get('GH_TEST_TOKEN')


def get_octopus_api():
    """
    A function that extarcts the Octopus URL from an environment variable
    :return: The Octopus URL
    """
    return os.environ.get('OCTOPUS_CLI_SERVER')


def get_octopus_project_names_cli(space_name):
    """Return a list of project names in an Octopus space

        Args:
            space_name: The name of the space containing the projects
    """

    actual_space_name, projects = get_octopus_project_names_base(space_name, get_api_key(), get_octopus_api())
    return get_octopus_project_names_response(actual_space_name, projects)


def get_deployment_process_raw_json_cli(space_name: None, project_name: None):
    """Returns the raw JSON for the deployment process of a project.

        Args:
            space_name: The name of the space containing the projects.
            If this value is not defined, the default value will be used.

            project_name: The name of the project.
            If this value is not defined, the default value will be used.
    """
    return get_raw_deployment_process(space_name, project_name, get_api_key(), get_octopus_api())


def general_query_callback(original_query, body, messages):
    sanitized_space = sanitize_name_fuzzy(lambda: get_spaces_generator(get_api_key(), get_octopus_api()),
                                          sanitize_space(original_query, body["space_name"]))

    space = get_default_argument(sanitized_space["matched"] if sanitized_space else None, "Space")

    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, get_api_key(), get_octopus_api())

    sanitized_projects = sanitize_names_fuzzy(
        lambda: get_projects_generator(space_id, get_api_key(), get_octopus_api()),
        sanitize_projects(body["project_names"]))

    project_names = [project["matched"] for project in sanitized_projects]

    return collect_llm_context(original_query,
                               messages,
                               context,
                               space_id,
                               project_names,
                               body['runbook_names'],
                               body['target_names'],
                               body['tenant_names'],
                               body['library_variable_sets'],
                               body['environment_names'],
                               body['feed_names'],
                               body['account_names'],
                               body['certificate_names'],
                               body['lifecycle_names'],
                               body['workerpool_names'],
                               body['machinepolicy_names'],
                               body['tagset_names'],
                               body['projectgroup_names'],
                               body['channel_names'],
                               body['release_versions'],
                               body['step_names'],
                               body['variable_names'],
                               body['dates'],
                               get_api_key(),
                               get_octopus_api(),
                               logging)


def logs_callback(original_query, messages, space, projects, environments, channel, tenants, release, steps, lines):
    space = get_default_argument(space, 'Space')

    activity_logs = get_deployment_logs(space, get_item_or_none(sanitize_list(projects), 0),
                                        get_item_or_none(sanitize_list(environments), 0),
                                        get_item_or_none(sanitize_list(tenants), 0), release,
                                        get_api_key(),
                                        get_octopus_api())

    sanitized_steps = sanitize_log_steps(steps, original_query, activity_logs)

    logs = activity_logs_to_string(activity_logs, sanitized_steps)

    # Get the end of the logs if we have exceeded our context limit
    logs = logs[-max_chars:]

    # return the last n lines of the logs
    log_lines = sanitize_log_lines(string_to_int(lines), original_query)
    if log_lines and log_lines > 0:
        logs = "\n".join(logs.split("\n")[-log_lines:])

    context = {"input": original_query, "context": logs}

    return llm_message_query(messages, context, log_query)


def literal_logs_callback(space, projects, environments, channel, tenants, release):
    space = get_default_argument(space, 'Space')

    activity_logs = get_deployment_logs(space,
                                        get_item_or_none(sanitize_list(projects), 0),
                                        get_item_or_none(sanitize_list(environments), 0),
                                        get_item_or_none(sanitize_list(tenants), 0),
                                        release,
                                        get_api_key(),
                                        get_octopus_api())

    logs = activity_logs_to_string(activity_logs, None)

    return logs


def resource_specific_callback(original_query, messages, space, projects, runbooks, targets,
                               tenants, environments, accounts, certificates, workerpools, machinepolicies, tagsets,
                               steps):
    space = get_default_argument(space, 'Space')

    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, get_api_key(), get_octopus_api())

    return collect_llm_context(original_query,
                               messages,
                               context,
                               space_id,
                               projects,
                               runbooks,
                               targets,
                               tenants,
                               None,
                               ["<all>"] if none_if_falesy_or_all(environments) else environments,
                               None,
                               accounts,
                               certificates,
                               None,
                               workerpools,
                               machinepolicies,
                               tagsets,
                               None,
                               None,
                               None,
                               steps,
                               None,
                               None,
                               get_api_key(),
                               get_octopus_api(),
                               logging)


def variable_query_callback(original_query, messages, space, projects, variables):
    space = get_default_argument(space, 'Space')

    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, get_api_key(), get_octopus_api())

    chat_response = collect_llm_context(parser.query,
                                        messages,
                                        context,
                                        space_id,
                                        projects,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        ["<all>"] if none_if_falesy_or_all(variables) else variables,
                                        None,
                                        get_api_key(),
                                        get_octopus_api(),
                                        logging)

    return chat_response


def releases_query_callback(original_query, messages, space, projects, environments, channels, releases, tenants,
                            dates):
    space = get_default_argument(space, 'Space')

    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, get_api_key(), get_octopus_api())

    # We need some additional JSON data to answer this question
    if projects:
        # We only need the deployments, so strip out the rest of the JSON
        deployments = timing_wrapper(lambda: get_deployments_for_project(space_id,
                                                                         get_item_or_none(sanitize_list(projects), 0),
                                                                         sanitize_environments(parser.query,
                                                                                               environments),
                                                                         sanitize_tenants(tenants),
                                                                         get_api_key(),
                                                                         get_octopus_api(),
                                                                         dates,
                                                                         max_context), "Deployments")
        context["json"] = json.dumps(deployments, indent=2)
    else:
        context["json"] = get_dashboard(space_id, get_api_key(), get_octopus_api())

    chat_response = collect_llm_context(parser.query,
                                        messages,
                                        context,
                                        space_id,
                                        projects,
                                        None,
                                        None,
                                        tenants,
                                        None,
                                        environments,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        channels,
                                        releases,
                                        None,
                                        None,
                                        dates,
                                        get_api_key(),
                                        get_octopus_api(),
                                        logging)

    return chat_response


def how_to_callback(original_query, keywords):
    results = search_repo("OctopusDeploy/docs", "markdown", keywords, get_github_token())
    text = get_docs_context(results)
    messages = docs_prompt(text)

    context = {"input": original_query}

    chat_response = llm_message_query(messages, context, logging)

    return chat_response


def get_default_argument(argument, default_name):
    if argument:
        return argument

    if default_name == "Space":
        return 'Octopus Copilot'

    return ""


def logging(prefix, message):
    print(prefix + " " + ",".join(sanitize_list(message)))


def build_tools(tool_query):
    """
    Builds the set of tools configured for use when called as a CLI application
    :return: The OpenAI tools
    """
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query_wrapper(tool_query, general_query_callback, log_query),
                           AnswerGeneralQuery),
        FunctionDefinition(answer_project_variables_wrapper(tool_query, variable_query_callback, log_query)),
        FunctionDefinition(answer_project_variables_usage_wrapper(tool_query, variable_query_callback, log_query)),
        FunctionDefinition(
            answer_releases_and_deployments_wrapper(tool_query, releases_query_callback, None, log_query)),
        FunctionDefinition(answer_project_deployment_logs_wrapper(tool_query, logs_callback, log_query)),
        FunctionDefinition(answer_machines_wrapper(tool_query, resource_specific_callback, log_query)),
        FunctionDefinition(answer_certificates_wrapper(tool_query, resource_specific_callback, log_query))],
        fallback=FunctionDefinition(how_to_wrapper(tool_query, how_to_callback, log_query))
    )


try:
    result = llm_tool_query(parser.query, build_tools(parser.query),
                            lambda x, y: print(x + " " + ",".join(sanitize_list(y)))).call_function()

    if isinstance(result, CopilotResponse):
        print(result.response)
    else:
        print(result)
except Exception as e:
    handle_error(e)
