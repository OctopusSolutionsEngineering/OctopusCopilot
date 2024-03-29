import argparse
import json
import os

from domain.context.octopus_context import collect_llm_context, max_chars
from domain.logging.query_loggin import log_query
from domain.messages.deployment_logs import build_plain_text_prompt
from domain.messages.deployments_and_releases import build_deployments_and_releases_prompt
from domain.messages.general import build_hcl_prompt
from domain.sanitizers.sanitized_list import sanitize_list, sanitize_environments, none_if_falesy_or_all, \
    get_item_or_none
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.general_query import answer_general_query_callback, AnswerGeneralQuery
from domain.tools.logs import answer_logs_callback
from domain.tools.project_variables import answer_project_variables_callback, answer_project_variables_usage_callback
from domain.tools.releases_and_deployments import answer_releases_and_deployments_callback
from domain.transformers.chat_responses import get_octopus_project_names_response
from domain.transformers.deployments_from_progression import get_deployment_array_from_progression
from infrastructure.octopus import get_octopus_project_names_base, get_raw_deployment_process, get_project_progression, \
    get_dashboard, get_deployment_logs
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


def general_query_handler(body):
    space = get_default_argument(body['space_name'], 'Space')

    messages = build_hcl_prompt()
    context = {"input": parser.query}

    return collect_llm_context(parser.query,
                               messages,
                               context,
                               space,
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


def logs_handler(original_query, enriched_query, space, projects, environments, channel, tenants):
    space = get_default_argument(space, 'Space')

    logs = get_deployment_logs(space, get_item_or_none(sanitize_list(projects), 0),
                               get_item_or_none(sanitize_list(environments), 0),
                               get_item_or_none(sanitize_list(tenants), 0), "latest", get_api_key(), get_octopus_api())
    # Get the end of the logs if we have exceeded our context limit
    logs = logs[-max_chars:]

    messages = build_plain_text_prompt()
    context = {"input": enriched_query, "context": logs}

    return llm_message_query(messages, context, log_query)


def variable_query_handler(original_query, enriched_query, space, projects, variables):
    space = get_default_argument(space, 'Space')

    messages = build_hcl_prompt()
    context = {"input": enriched_query}

    chat_response = collect_llm_context(parser.query,
                                        messages,
                                        context,
                                        space,
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


def releases_query_handler(original_query, enriched_query, space, projects, environments, channels, releases):
    space = get_default_argument(space, 'Space')

    messages = build_deployments_and_releases_prompt()
    context = {"input": enriched_query}

    # We need some additional JSON data to answer this question
    if projects:
        # We only need the deployments, so strip out the rest of the JSON
        deployments = get_deployment_array_from_progression(
            json.loads(get_project_progression(space, get_item_or_none(sanitize_list(projects), 0), get_api_key(),
                                               get_octopus_api())),
            sanitize_environments(environments),
            3)
        context["json"] = json.dumps(deployments, indent=2)
    else:
        context["json"] = get_dashboard(space, get_api_key(), get_octopus_api())

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


def build_tools():
    """
    Builds the set of tools configured for use when called as a CLI application
    :return: The OpenAI tools
    """
    return FunctionDefinitions([
        FunctionDefinition(answer_general_query_callback(general_query_handler, log_query), AnswerGeneralQuery),
        FunctionDefinition(answer_project_variables_callback(parser.query, variable_query_handler, log_query)),
        FunctionDefinition(answer_project_variables_usage_callback(parser.query, variable_query_handler, log_query)),
        FunctionDefinition(answer_releases_and_deployments_callback(parser.query, releases_query_handler, log_query)),
        FunctionDefinition(answer_logs_callback(parser.query, logs_handler, log_query))
    ])


try:
    result = llm_tool_query(parser.query, build_tools,
                            lambda x, y: print(x + " " + ",".join(sanitize_list(y)))).call_function()
    print(result)
except Exception as e:
    print(e)
