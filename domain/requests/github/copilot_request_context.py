import os

import azure.functions as func
from azure.core.exceptions import HttpResponseError

from domain.config.database import get_functions_connection_string
from domain.config.users import get_admin_users
from domain.config.zendesk import get_zendesk_user, get_zendesk_token
from domain.encryption.encryption import decrypt_eax, generate_password
from domain.exceptions.user_not_configured import UserNotConfigured
from domain.exceptions.user_not_loggedin import UserNotLoggedIn, OctopusApiKeyInvalid
from domain.logging.app_logging import configure_logging
from domain.logging.query_loggin import log_query
from domain.security.security import is_admin_user
from domain.tools.githubactions.approve_manual_intervention import approve_manual_intervention_callback, \
    approve_manual_intervention_confirm_callback_wrapper
from domain.tools.githubactions.cancel_deployment import cancel_deployment_callback
from domain.tools.githubactions.cancel_runbook_run import cancel_runbook_run_callback
from domain.tools.githubactions.cancel_task import cancel_task_confirm_callback_wrapper, cancel_task_callback
from domain.tools.githubactions.create_release import create_release_confirm_callback_wrapper, create_release_callback
from domain.tools.githubactions.dashboard import get_dashboard_callback
from domain.tools.githubactions.default_values import default_value_callbacks
from domain.tools.githubactions.deploy_release import deploy_release_confirm_callback_wrapper, deploy_release_callback
from domain.tools.githubactions.deployment_logs import logs_callback
from domain.tools.githubactions.general_query import general_query_callback
from domain.tools.githubactions.generate_terraform import generate_terraform_callback_wrapper
from domain.tools.githubactions.github_job_summary import get_job_summary_callback
from domain.tools.githubactions.github_logs import get_github_logs_callback
from domain.tools.githubactions.how_to import how_to_callback
from domain.tools.githubactions.logout import logout
from domain.tools.githubactions.project_dashboard import get_project_dashboard_callback
from domain.tools.githubactions.provide_help import provide_help_wrapper
from domain.tools.githubactions.reject_manual_intervention import reject_manual_intervention_confirm_callback_wrapper, \
    reject_manual_intervention_callback
from domain.tools.githubactions.releases import releases_query_callback, releases_query_messages
from domain.tools.githubactions.resource_specific_callback import resource_specific_callback
from domain.tools.githubactions.run_runbook import run_runbook_confirm_callback_wrapper, run_runbook_callback
from domain.tools.githubactions.runbook_logs import get_runbook_logs_wrapper
from domain.tools.githubactions.runbooks_dashboard import get_runbook_dashboard_callback
from domain.tools.githubactions.suggest_solution import suggest_solution_callback_wrapper
from domain.tools.githubactions.task_summary import get_task_summary_callback
from domain.tools.githubactions.variables import variable_query_callback
from domain.tools.wrapper.approve_manual_intervention import approve_manual_intervention_wrapper
from domain.tools.wrapper.cancel_deployment import cancel_deployment_wrapper
from domain.tools.wrapper.cancel_runbook_run import cancel_runbook_run_wrapper
from domain.tools.wrapper.cancel_task import cancel_task_wrapper
from domain.tools.wrapper.certificates_query import answer_certificates_wrapper
from domain.tools.wrapper.create_release import create_release_wrapper
from domain.tools.wrapper.dashboard_wrapper import show_space_dashboard_wrapper
from domain.tools.wrapper.deploy_release import deploy_release_wrapper
from domain.tools.wrapper.function_definition import FunctionDefinition, FunctionDefinitions
from domain.tools.wrapper.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from domain.tools.wrapper.generate_terraform import generate_terraform_wrapper
from domain.tools.wrapper.github_job_summary_wrapper import show_github_job_summary_wrapper
from domain.tools.wrapper.github_logs import answer_github_logs_wrapper
from domain.tools.wrapper.how_to import how_to_wrapper
from domain.tools.wrapper.project_dashboard_wrapper import show_project_dashboard_wrapper
from domain.tools.wrapper.project_logs import answer_project_deployment_logs_wrapper
from domain.tools.wrapper.project_variables import answer_project_variables_wrapper, \
    answer_project_variables_usage_wrapper
from domain.tools.wrapper.reject_manual_intervention import reject_manual_intervention_wrapper
from domain.tools.wrapper.releases_and_deployments import answer_releases_and_deployments_wrapper
from domain.tools.wrapper.run_runbook import run_runbook_wrapper
from domain.tools.wrapper.runbook_logs import answer_runbook_run_logs_wrapper
from domain.tools.wrapper.runbooks_dashboard_wrapper import show_runbook_dashboard_wrapper
from domain.tools.wrapper.step_features import answer_step_features_wrapper
from domain.tools.wrapper.suggest_solution import suggest_solution_wrapper
from domain.tools.wrapper.targets_query import answer_machines_wrapper
from domain.tools.wrapper.task_summary_wrapper import show_task_summary_wrapper
from infrastructure.github import get_github_user
from infrastructure.users import get_users_details

logger = configure_logging(__name__)


def get_apikey_and_server(req: func.HttpRequest):
    """
    When testing we supply the octopus details directly. This removes the need to use a GitHub token, as GitHub
    tokens have radiatively small rate limits. Load tests will pass these headers in to simulate a chat without
    triggering GitHub API rate limits
    :return:
    """
    api_key = req.headers.get("X-Octopus-ApiKey")
    server = req.headers.get("X-Octopus-Server")
    return api_key, server


def get_github_token(req: func.HttpRequest):
    return req.headers.get("X-GitHub-Token")


def get_github_user_from_form(req: func.HttpRequest):
    return get_github_user(get_github_token(req))


def get_api_key_and_url(req: func.HttpRequest):
    try:
        # First try to get the details from the headers
        api_key, server = get_apikey_and_server(req)

        if api_key and server:
            return api_key, server

        # Then get the details saved for a user
        github_username = get_github_user_from_form(req)

        if not github_username:
            raise UserNotLoggedIn()

        try:
            github_user = get_users_details(github_username, get_functions_connection_string())

            # We need to configure the Octopus details first because we need to know the service account id
            # before attempting to generate an ID token.
            if "OctopusUrl" not in github_user or "OctopusApiKey" not in github_user or "EncryptionTag" not in github_user or "EncryptionNonce" not in github_user:
                logger.info("No OctopusUrl, OctopusApiKey, EncryptionTag, or EncryptionNonce")
                raise UserNotConfigured()

        except HttpResponseError as e:
            # assume any exception means the user must log in
            raise UserNotConfigured()

        tag = github_user["EncryptionTag"]
        nonce = github_user["EncryptionNonce"]
        api_key = github_user["OctopusApiKey"]

        decrypted_api_key = decrypt_eax(
            generate_password(os.environ.get("ENCRYPTION_PASSWORD"), os.environ.get("ENCRYPTION_SALT")),
            api_key,
            tag,
            nonce,
            os.environ.get("ENCRYPTION_SALT"))

        return decrypted_api_key, github_user["OctopusUrl"]

    except ValueError as e:
        logger.info("Encryption password must have changed because the api key could not be decrypted")
        raise OctopusApiKeyInvalid()


def build_form_tools(query, req: func.HttpRequest):
    """
    Builds a set of tools configured for use with HTTP requests (i.e. API key
    and URL extracted from an HTTP request body).
    :param: query The query sent to the LLM
    :return: The OpenAI tools
    """

    api_key, url = get_api_key_and_url(req)

    # A bunch of functions that do the same thing
    help_functions = [FunctionDefinition(tool) for tool in provide_help_wrapper(
        get_github_user_from_form(req),
        url,
        api_key,
        log_query)]

    # A bunch of functions that search the docs
    docs_functions = [FunctionDefinition(tool) for tool in
                      how_to_wrapper(query,
                                     how_to_callback(get_github_token(req), get_github_user_from_form(req), log_query),
                                     log_query)]

    # tools to handle approval of manual intervention
    approval_interruption_functions = [
        FunctionDefinition(tool, callback=approve_manual_intervention_confirm_callback_wrapper(
            get_github_user_from_form(req), url, api_key,
            log_query))
        for tool in approve_manual_intervention_wrapper(query,
                                                        approve_manual_intervention_callback(
                                                            url, api_key,
                                                            get_github_user_from_form(req),
                                                            get_functions_connection_string(),
                                                            log_query),
                                                        log_query)]
    # tools to handle rejection of manual intervention
    reject_interruption_functions = [
        FunctionDefinition(tool, callback=reject_manual_intervention_confirm_callback_wrapper(
            get_github_user_from_form(req), url, api_key,
            log_query))
        for tool in reject_manual_intervention_wrapper(query,
                                                       reject_manual_intervention_callback(
                                                           url, api_key,
                                                           get_github_user_from_form(req),
                                                           get_functions_connection_string(),
                                                           log_query),
                                                       log_query)]

    # Functions related to the default values
    set_default_value, remove_default_value, get_default_value, get_all_default_values = default_value_callbacks(
        get_github_user_from_form(req))

    # The order of the tools can make a difference. The dashboard tools are supplied first, as this
    # appears to give them a higher precedence.
    # This behaviour is undocumented as far as I can tell - I only found out through trial and error.
    return FunctionDefinitions([
        FunctionDefinition(show_space_dashboard_wrapper(
            query,
            api_key,
            url,
            get_dashboard_callback(get_github_token(req), get_github_user_from_form(req), log_query),
            log_query)),
        FunctionDefinition(show_runbook_dashboard_wrapper(
            query,
            api_key,
            url,
            get_runbook_dashboard_callback(get_github_user_from_form(req)),
            log_query)),
        FunctionDefinition(show_project_dashboard_wrapper(query,
                                                          api_key,
                                                          url,
                                                          get_project_dashboard_callback(
                                                              get_github_user_from_form(req),
                                                              get_github_token(req),
                                                              log_query),
                                                          log_query)),
        FunctionDefinition(
            answer_general_query_wrapper(
                query,
                general_query_callback(get_github_user_from_form(req),
                                       api_key,
                                       url,
                                       log_query),
                log_query),
            schema=AnswerGeneralQuery),
        FunctionDefinition(answer_step_features_wrapper(
            query, general_query_callback(get_github_user_from_form(req),
                                          api_key,
                                          url,
                                          log_query),
            log_query)),
        FunctionDefinition(
            answer_project_variables_wrapper(query,
                                             variable_query_callback(get_github_user_from_form(req),
                                                                     api_key,
                                                                     url,
                                                                     log_query),
                                             log_query)),
        FunctionDefinition(
            answer_project_variables_usage_wrapper(query,
                                                   variable_query_callback(get_github_user_from_form(req),
                                                                           api_key,
                                                                           url,
                                                                           log_query),
                                                   log_query)),
        FunctionDefinition(answer_project_deployment_logs_wrapper(query,
                                                                  logs_callback(get_github_user_from_form(req),
                                                                                api_key,
                                                                                url,
                                                                                log_query),
                                                                  log_query)),
        FunctionDefinition(show_task_summary_wrapper(query,
                                                     get_task_summary_callback(get_github_user_from_form(req),
                                                                               api_key,
                                                                               url,
                                                                               log_query),
                                                     log_query)),
        FunctionDefinition(answer_runbook_run_logs_wrapper(
            query,
            get_runbook_logs_wrapper(
                get_github_user_from_form(req),
                api_key,
                url,
                log_query),
            log_query)),
        FunctionDefinition(
            answer_releases_and_deployments_wrapper(
                query,
                releases_query_callback(get_github_user_from_form(req),
                                        api_key,
                                        url,
                                        log_query),
                releases_query_messages(get_github_user_from_form(req)),
                log_query)),
        FunctionDefinition(answer_machines_wrapper(query, resource_specific_callback(get_github_user_from_form(req),
                                                                                     api_key,
                                                                                     url,
                                                                                     log_query),
                                                   log_query)),
        FunctionDefinition(
            answer_certificates_wrapper(query, resource_specific_callback(get_github_user_from_form(req),
                                                                          api_key,
                                                                          url,
                                                                          log_query),
                                        log_query)),
        FunctionDefinition(logout(get_github_user_from_form(req), get_functions_connection_string())),
        FunctionDefinition(set_default_value),
        FunctionDefinition(get_default_value),
        FunctionDefinition(get_all_default_values),
        FunctionDefinition(remove_default_value),
        *help_functions,
        FunctionDefinition(run_runbook_wrapper(query,
                                               callback=run_runbook_callback(url, api_key,
                                                                             get_github_user_from_form(req),
                                                                             get_functions_connection_string(),
                                                                             log_query),
                                               logging=log_query),
                           callback=run_runbook_confirm_callback_wrapper(get_github_user_from_form(req), url, api_key,
                                                                         log_query)),
        FunctionDefinition(create_release_wrapper(query,
                                                  callback=create_release_callback(url, api_key,
                                                                                   get_github_user_from_form(req),
                                                                                   get_functions_connection_string(),
                                                                                   log_query),
                                                  logging=log_query),
                           callback=create_release_confirm_callback_wrapper(get_github_user_from_form(req), url,
                                                                            api_key,
                                                                            log_query)),
        FunctionDefinition(deploy_release_wrapper(query,
                                                  callback=deploy_release_callback(url, api_key,
                                                                                   get_github_user_from_form(req),
                                                                                   get_functions_connection_string(),
                                                                                   log_query),
                                                  logging=log_query),
                           callback=deploy_release_confirm_callback_wrapper(get_github_user_from_form(req), url,
                                                                            api_key,
                                                                            log_query)),
        *approval_interruption_functions,
        *reject_interruption_functions,
        FunctionDefinition(cancel_task_wrapper(query,
                                               callback=cancel_task_callback(url, api_key,
                                                                             get_github_user_from_form(req),
                                                                             get_functions_connection_string(),
                                                                             log_query),
                                               logging=log_query),
                           callback=cancel_task_confirm_callback_wrapper(get_github_user_from_form(req), url, api_key,
                                                                         log_query)),
        FunctionDefinition(cancel_deployment_wrapper(query,
                                                     callback=cancel_deployment_callback(url, api_key,
                                                                                         get_github_user_from_form(req),
                                                                                         get_functions_connection_string(),
                                                                                         log_query),
                                                     logging=log_query),
                           callback=cancel_task_confirm_callback_wrapper(get_github_user_from_form(req), url, api_key,
                                                                         log_query)),
        FunctionDefinition(cancel_runbook_run_wrapper(query,
                                                      callback=cancel_runbook_run_callback(url, api_key,
                                                                                           get_github_user_from_form(
                                                                                               req),
                                                                                           get_functions_connection_string(),
                                                                                           log_query),
                                                      logging=log_query),
                           callback=cancel_task_confirm_callback_wrapper(get_github_user_from_form(req), url, api_key,
                                                                         log_query)),
        FunctionDefinition(
            show_github_job_summary_wrapper(query,
                                            get_job_summary_callback(get_github_user_from_form(req),
                                                                     get_github_token(req)),
                                            log_query)),
        FunctionDefinition(
            answer_github_logs_wrapper(query,
                                       get_github_logs_callback(get_github_user_from_form(req),
                                                                get_github_token(req)),
                                       log_query)),
        FunctionDefinition(
            generate_terraform_wrapper(query, generate_terraform_callback_wrapper(), get_github_token(req), log_query)),
        FunctionDefinition(
            suggest_solution_wrapper(query, suggest_solution_callback_wrapper(get_github_user_from_form(req)),
                                     get_github_token(req),
                                     get_zendesk_user(),
                                     get_zendesk_token()),
            is_enabled=is_admin_user(get_github_user_from_form(req), get_admin_users())
        )
    ],
        fallback=FunctionDefinitions(docs_functions),
        invalid=FunctionDefinition(
            answer_general_query_wrapper(query,
                                         general_query_callback(get_github_user_from_form(req),
                                                                api_key,
                                                                url,
                                                                log_query),
                                         log_query),
            schema=AnswerGeneralQuery)
    )
