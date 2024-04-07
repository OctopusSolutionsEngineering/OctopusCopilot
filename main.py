import argparse
import json
import os

from domain.config.openai import max_context
from domain.context.octopus_context import collect_llm_context, max_chars
from domain.logging.query_loggin import log_query
from domain.sanitizers.sanitized_list import sanitize_list, sanitize_environments, none_if_falesy_or_all, \
    get_item_or_none
from domain.tools.certificates_query import answer_certificates_wrapper
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from domain.tools.literal_logs import answer_literal_logs_wrapper
from domain.tools.logs import answer_logs_wrapper
from domain.tools.project_variables import answer_project_variables_wrapper, answer_project_variables_usage_wrapper
from domain.tools.releases_and_deployments import answer_releases_and_deployments_wrapper
from domain.tools.targets_query import answer_machines_wrapper
from domain.transformers.chat_responses import get_octopus_project_names_response
from domain.transformers.deployments_from_release import get_deployments_for_project
from infrastructure.octopus import get_octopus_project_names_base, get_raw_deployment_process, get_dashboard, \
    get_deployment_logs, get_space_id_and_name_from_name
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
    parser.add_argument('--query', action='store')
    return parser.parse_known_args()


parser, _ = init_argparse()


def get_api_key():
    """
    A function that extracts the API key from an environment variable
    :return: The Octopus API key
    """
    return os.environ.get('OCTOPUS_CLI_API_KEY')


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
    space = get_default_argument(body['space_name'], 'Space')

    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, get_api_key(), get_octopus_api())

    return collect_llm_context(original_query,
                               messages,
                               context,
                               space_id,
                               body['project_names'],
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
                               get_api_key(),
                               get_octopus_api(),
                               logging)


def logs_callback(original_query, messages, space, projects, environments, channel, tenants, release):
    space = get_default_argument(space, 'Space')

    logs = get_deployment_logs(space, get_item_or_none(sanitize_list(projects), 0),
                               get_item_or_none(sanitize_list(environments), 0),
                               get_item_or_none(sanitize_list(tenants), 0), "latest", get_api_key(), get_octopus_api())
    # Get the end of the logs if we have exceeded our context limit
    logs = logs[-max_chars:]

    context = {"input": original_query, "context": logs}

    return llm_message_query(messages, context, log_query)


def literal_logs_callback(space, projects, environments, channel, tenants, release):
    space = get_default_argument(space, 'Space')

    logs = get_deployment_logs(space,
                               get_item_or_none(sanitize_list(projects), 0),
                               get_item_or_none(sanitize_list(environments), 0),
                               get_item_or_none(sanitize_list(tenants), 0),
                               release,
                               get_api_key(),
                               get_octopus_api())

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
                                        get_api_key(),
                                        get_octopus_api(),
                                        logging)

    return chat_response


def releases_query_callback(original_query, messages, space, projects, environments, channels, releases):
    space = get_default_argument(space, 'Space')

    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, get_api_key(), get_octopus_api())

    # We need some additional JSON data to answer this question
    if projects:
        # We only need the deployments, so strip out the rest of the JSON
        deployments = get_deployments_for_project(space_id,
                                                  get_item_or_none(sanitize_list(projects), 0),
                                                  sanitize_environments(environments),
                                                  get_api_key(),
                                                  get_octopus_api(),
                                                  max_context)
        context["json"] = json.dumps(deployments, indent=2)
    else:
        context["json"] = get_dashboard(space_id, get_api_key(), get_octopus_api())

    chat_response = collect_llm_context(parser.query,
                                        messages,
                                        context,
                                        space,
                                        projects,
                                        None,
                                        None,
                                        None,
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
                                        None,
                                        None,
                                        None,
                                        None,
                                        get_api_key(),
                                        get_octopus_api(),
                                        logging)

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
        FunctionDefinition(answer_general_query_wrapper(general_query_callback, log_query), AnswerGeneralQuery),
        FunctionDefinition(answer_project_variables_wrapper(tool_query, variable_query_callback, log_query)),
        FunctionDefinition(answer_project_variables_usage_wrapper(tool_query, variable_query_callback, log_query)),
        FunctionDefinition(
            answer_releases_and_deployments_wrapper(tool_query, releases_query_callback, None, log_query)),
        FunctionDefinition(answer_logs_wrapper(tool_query, logs_callback, log_query)),
        FunctionDefinition(answer_literal_logs_wrapper(tool_query, literal_logs_callback, log_query)),
        FunctionDefinition(answer_machines_wrapper(tool_query, resource_specific_callback, log_query)),
        FunctionDefinition(answer_certificates_wrapper(tool_query, resource_specific_callback, log_query))
    ])


try:
    result = llm_tool_query(parser.query, build_tools,
                            lambda x, y: print(x + " " + ",".join(sanitize_list(y)))).call_function()
    print(result)
except Exception as e:
    print(e)
