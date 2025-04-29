import json
import os
from http.cookies import SimpleCookie

import azure.functions as func
from azure.core.exceptions import HttpResponseError

from domain.b64.b64_encoder import decode_string_b64
from domain.config.database import get_functions_connection_string
from domain.config.servers import get_admin_servers
from domain.config.storyblok import get_storyblok_token
from domain.config.users import get_admin_users
from domain.config.zendesk import get_zendesk_user, get_zendesk_token
from domain.encryption.encryption import decrypt_eax, generate_password
from domain.exceptions.none_on_exception import none_on_exception
from domain.exceptions.request_failed import GitHubRequestFailed
from domain.exceptions.slack_not_logged_in import SlackTokenInvalid
from domain.exceptions.user_not_configured import UserNotConfigured
from domain.exceptions.user_not_loggedin import UserNotLoggedIn, OctopusApiKeyInvalid
from domain.jwt.oidc import parse_jwt
from domain.logging.app_logging import configure_logging
from domain.logging.query_logging import log_query
from domain.security.security import is_admin_user, is_admin_server
from domain.tools.githubactions.approve_manual_intervention import (
    approve_manual_intervention_callback,
    approve_manual_intervention_confirm_callback_wrapper,
)
from domain.tools.githubactions.cancel_deployment import cancel_deployment_callback
from domain.tools.githubactions.cancel_runbook_run import cancel_runbook_run_callback
from domain.tools.githubactions.cancel_task import (
    cancel_task_confirm_callback_wrapper,
    cancel_task_callback,
)
from domain.tools.githubactions.create_release import (
    create_release_confirm_callback_wrapper,
    create_release_callback,
)
from domain.tools.githubactions.dashboard import get_dashboard_callback
from domain.tools.githubactions.default_values import default_value_callbacks
from domain.tools.githubactions.deploy_release import (
    deploy_release_confirm_callback_wrapper,
    deploy_release_callback,
)
from domain.tools.githubactions.deployment_logs import logs_callback
from domain.tools.githubactions.general_query import general_query_callback
from domain.tools.githubactions.generate_terraform import (
    generate_terraform_callback_wrapper,
)
from domain.tools.githubactions.github_job_summary import get_job_summary_callback
from domain.tools.githubactions.github_logs import get_github_logs_callback
from domain.tools.githubactions.how_to import how_to_callback
from domain.tools.githubactions.logout import logout
from domain.tools.githubactions.octolint_unused_projects import (
    octolint_callback,
)
from domain.tools.githubactions.project_dashboard import get_project_dashboard_callback
from domain.tools.githubactions.projects.create_template_project import (
    create_template_project_callback,
    create_template_project_confirm_callback_wrapper,
)
from domain.tools.githubactions.provide_help import provide_help_wrapper
from domain.tools.githubactions.reject_manual_intervention import (
    reject_manual_intervention_confirm_callback_wrapper,
    reject_manual_intervention_callback,
)
from domain.tools.githubactions.release_what_changed import (
    release_what_changed_callback_wrapper,
)
from domain.tools.githubactions.resource_specific_callback import (
    resource_specific_callback,
)
from domain.tools.githubactions.run_runbook import (
    run_runbook_confirm_callback_wrapper,
    run_runbook_callback,
)
from domain.tools.githubactions.runbook_logs import get_runbook_logs_wrapper
from domain.tools.githubactions.runbooks_dashboard import get_runbook_dashboard_callback
from domain.tools.githubactions.suggest_solution import (
    suggest_solution_callback_wrapper,
)
from domain.tools.githubactions.task_summary import get_task_summary_callback
from domain.tools.githubactions.variables import variable_query_callback
from domain.tools.wrapper.approve_manual_intervention import (
    approve_manual_intervention_wrapper,
)
from domain.tools.wrapper.cancel_deployment import cancel_deployment_wrapper
from domain.tools.wrapper.cancel_runbook_run import cancel_runbook_run_wrapper
from domain.tools.wrapper.cancel_task import cancel_task_wrapper
from domain.tools.wrapper.certificates_query import answer_certificates_wrapper
from domain.tools.wrapper.create_release import create_release_wrapper
from domain.tools.wrapper.dashboard_wrapper import show_space_dashboard_wrapper
from domain.tools.wrapper.deploy_release import deploy_release_wrapper
from domain.tools.wrapper.function_definition import (
    FunctionDefinition,
    FunctionDefinitions,
)
from domain.tools.wrapper.general_query import (
    answer_general_query_wrapper,
    AnswerGeneralQuery,
)
from domain.tools.wrapper.generate_terraform import generate_terraform_wrapper
from domain.tools.wrapper.github_job_summary_wrapper import (
    show_github_job_summary_wrapper,
)
from domain.tools.wrapper.github_logs import answer_github_logs_wrapper
from domain.tools.wrapper.how_to import how_to_wrapper
from domain.tools.wrapper.octolint_direct_tenant_references import (
    octolint_direct_tenant_references_wrapper,
)
from domain.tools.wrapper.octolint_duplicate_variables import (
    octolint_duplicate_variables_wrapper,
)
from domain.tools.wrapper.octolint_empty_projects import octolint_empty_projects_wrapper
from domain.tools.wrapper.octolint_unhealthy_targets import (
    octolint_unhealthy_targets_wrapper,
)
from domain.tools.wrapper.octolint_unrotated_accounts import (
    octolint_unrotated_accounts_wrapper,
)
from domain.tools.wrapper.octolint_unused_projects import (
    octolint_unused_projects_wrapper,
)
from domain.tools.wrapper.octolint_unused_targets import octolint_unused_targets_wrapper
from domain.tools.wrapper.octolint_unused_tenants import octolint_unused_tenants_wrapper
from domain.tools.wrapper.octolint_unused_variables import (
    octolint_unused_variables_wrapper,
)
from domain.tools.wrapper.project_dashboard_wrapper import (
    show_project_dashboard_wrapper,
)
from domain.tools.wrapper.project_logs import answer_project_deployment_logs_wrapper
from domain.tools.wrapper.project_variables import (
    answer_project_variables_wrapper,
    answer_project_variables_usage_wrapper,
)
from domain.tools.wrapper.projects.create_k8s_project import create_k8s_project_wrapper
from domain.tools.wrapper.reject_manual_intervention import (
    reject_manual_intervention_wrapper,
)
from domain.tools.wrapper.release_what_changed import release_what_changed_wrapper
from domain.tools.wrapper.run_runbook import run_runbook_wrapper
from domain.tools.wrapper.runbook_logs import answer_runbook_run_logs_wrapper
from domain.tools.wrapper.runbooks_dashboard_wrapper import (
    show_runbook_dashboard_wrapper,
)
from domain.tools.wrapper.step_features import answer_step_features_wrapper
from domain.tools.wrapper.suggest_solution import suggest_solution_wrapper
from domain.tools.wrapper.targets_query import answer_machines_wrapper
from domain.tools.wrapper.task_summary_wrapper import show_task_summary_wrapper
from infrastructure.github import get_github_user
from infrastructure.octopus import logging_wrapper, get_current_user
from infrastructure.users import get_users_details, get_users_slack_details

logger = configure_logging(__name__)


def get_server(req: func.HttpRequest):
    api_key, server = get_apikey_and_server(req)

    if api_key and server:
        return server

    access_token, server = get_access_token_and_server(req)

    if access_token and server:
        return server

    return None


def get_apikey_and_server(req: func.HttpRequest):
    """
    When testing we supply the octopus details directly. This removes the need to use a GitHub token, as GitHub
    tokens have radiatively small rate limits. Load tests will pass these headers in to simulate a chat without
    triggering GitHub API rate limits
    """
    api_key = req.headers.get("X-Octopus-ApiKey")
    server = req.headers.get("X-Octopus-Server")

    if server and api_key:
        # The api key and server have to be valid, which we validate with an API call
        if none_on_exception(lambda: get_current_user(api_key, server)):
            return api_key, server

    return None, None


def get_access_token_and_server(req: func.HttpRequest):
    """
    The OctoAI integration will pass through an access token in the headers. We use the aud claim
    in the access token to determine the server.
    """
    access_token = req.headers.get("X-Octopus-AccessToken")
    server = req.headers.get("X-Octopus-Server")

    if access_token and server:
        if none_on_exception(lambda: get_current_user(access_token, server)):
            return access_token, server

    return None, None


def get_slack_token_from_request(req: func.HttpRequest):
    """
    When testing we supply the Slack token directly.
    :return:
    """
    return req.headers.get("X-Slack-Token")


def get_github_token(req: func.HttpRequest):
    # First try to get the session from a cookie. Session cookies are used by public facing
    # web forms.
    try:
        cookie = SimpleCookie()
        cookie_header = req.headers.get("Cookie")

        if cookie_header:
            cookie.load(cookie_header)
            session = cookie.get("session")

            if session:
                encrypted_token = json.loads(decode_string_b64(session.value))

                return decrypt_eax(
                    generate_password(
                        os.environ.get("ENCRYPTION_PASSWORD"),
                        os.environ.get("ENCRYPTION_SALT"),
                    ),
                    encrypted_token.get("state"),
                    encrypted_token.get("tag"),
                    encrypted_token.get("nonce"),
                    os.environ.get("ENCRYPTION_SALT"),
                )
    except Exception as e:
        logger.info("State cookie could not be decoded")

    # The token may have been sent in an encrypted form from an untrusted client.
    # This is how the web based interface can send a token.
    try:
        if req.headers.get("X-GitHub-Encrypted-Token"):
            encrypted_token = json.loads(
                decode_string_b64(req.headers.get("X-GitHub-Encrypted-Token", ""))
            )
            return decrypt_eax(
                generate_password(
                    os.environ.get("ENCRYPTION_PASSWORD"),
                    os.environ.get("ENCRYPTION_SALT"),
                ),
                encrypted_token.get("state"),
                encrypted_token.get("tag"),
                encrypted_token.get("nonce"),
                os.environ.get("ENCRYPTION_SALT"),
            )
    except ValueError as e:
        logger.info(
            "Encryption password must have changed because the token could not be decrypted"
        )

    # Otherwise the token should be sent in the header. This is how Copilot sends the tokens.
    if req.headers.get("X-GitHub-Token"):
        return req.headers.get("X-GitHub-Token")

    return None


def get_server_from_form(req: func.HttpRequest):
    return get_server(req)


def get_github_user_from_form(req: func.HttpRequest):
    try:
        return get_github_user(get_github_token(req))
    except GitHubRequestFailed:
        # Maybe there was an old cookie or token. If the end user is mixing
        # Copilot requests with other clients, then this is possible.
        # This must not fail the request, as it is possible to send all the required
        # authentication details in the request headers and not rely on a GitHub token.
        return None


def get_redirections(req: func.HttpRequest):
    return req.headers.get("X_REDIRECTION_REDIRECTIONS")


def get_redirections_api_key(req: func.HttpRequest):
    return req.headers.get("X_REDIRECTION_API_KEY")


def get_api_key_and_url(req: func.HttpRequest):
    try:
        # First try to get the details from the headers
        api_key, server = get_apikey_and_server(req)

        if api_key and server:
            return api_key, server

        # Next we try to get the access token and server from the headers
        access_token, server = get_access_token_and_server(req)

        if access_token and server:
            return access_token, server

        # Then get the details saved for a user
        github_username = get_github_user_from_form(req)

        if not github_username:
            raise UserNotLoggedIn()

        try:
            github_user = get_users_details(
                github_username, get_functions_connection_string()
            )

            # We need to configure the Octopus details first because we need to know the service account id
            # before attempting to generate an ID token.
            if (
                "OctopusUrl" not in github_user
                or "OctopusApiKey" not in github_user
                or "EncryptionTag" not in github_user
                or "EncryptionNonce" not in github_user
            ):
                logger.info(
                    "No OctopusUrl, OctopusApiKey, EncryptionTag, or EncryptionNonce"
                )
                raise UserNotConfigured()

        except HttpResponseError as e:
            # assume any exception means the user must log in
            raise UserNotConfigured()

        tag = github_user["EncryptionTag"]
        nonce = github_user["EncryptionNonce"]
        api_key = github_user["OctopusApiKey"]

        decrypted_api_key = decrypt_eax(
            generate_password(
                os.environ.get("ENCRYPTION_PASSWORD"), os.environ.get("ENCRYPTION_SALT")
            ),
            api_key,
            tag,
            nonce,
            os.environ.get("ENCRYPTION_SALT"),
        )

        return decrypted_api_key, github_user["OctopusUrl"]

    except ValueError as e:
        logger.info(
            "Encryption password must have changed because the api key could not be decrypted"
        )
        raise OctopusApiKeyInvalid()


def get_slack_token(req: func.HttpRequest):
    try:
        # First try to get the details from the headers
        token = get_slack_token_from_request(req)

        if token:
            return token

        # Then get the details saved for a user
        github_username = get_github_user_from_form(req)

        # If there is no GitHub token, and we have not embedded the Slack token in the request,
        # then there is no way to retrieve a Slack token from the database.
        if not github_username:
            return None

        try:
            slack_user = get_users_slack_details(
                github_username, get_functions_connection_string()
            )

            # Validate the returned fields
            if (
                "SlackAccessToken" not in slack_user
                or "EncryptionTag" not in slack_user
                or "EncryptionNonce" not in slack_user
            ):
                logger.info("No SlackAccessToken, EncryptionTag, or EncryptionNonce")
                return None

        except HttpResponseError as e:
            # assume any exception means the user must log in
            return None

        tag = slack_user["EncryptionTag"]
        nonce = slack_user["EncryptionNonce"]
        token = slack_user["SlackAccessToken"]

        decrypted_token = decrypt_eax(
            generate_password(
                os.environ.get("ENCRYPTION_PASSWORD"), os.environ.get("ENCRYPTION_SALT")
            ),
            token,
            tag,
            nonce,
            os.environ.get("ENCRYPTION_SALT"),
        )

        return decrypted_token

    except ValueError as e:
        logger.info(
            "Encryption password must have changed because the token could not be decrypted"
        )
        raise SlackTokenInvalid()


def build_form_tools(query, req: func.HttpRequest):
    """
    Builds a set of tools configured for use with HTTP requests (i.e. API key
    and URL extracted from an HTTP request body).
    :param: query The query sent to the LLM
    :return: The OpenAI tools
    """

    slack_token = get_slack_token(req)

    # A bunch of functions that do the same thing
    help_functions = [
        FunctionDefinition(tool)
        for tool in provide_help_wrapper(
            get_github_user_from_form(req), lambda: get_api_key_and_url(req), log_query
        )
    ]

    # A bunch of functions that search the docs
    docs_functions = [
        FunctionDefinition(tool)
        for tool in how_to_wrapper(
            query,
            how_to_callback(
                get_github_token(req), get_github_user_from_form(req), log_query
            ),
            log_query,
        )
    ]

    # tools to handle approval of manual intervention
    approval_interruption_functions = [
        FunctionDefinition(
            tool,
            callback=approve_manual_intervention_confirm_callback_wrapper(
                get_github_user_from_form(req),
                lambda: get_api_key_and_url(req),
                log_query,
            ),
        )
        for tool in approve_manual_intervention_wrapper(
            query,
            approve_manual_intervention_callback(
                lambda: get_api_key_and_url(req),
                get_github_user_from_form(req),
                get_functions_connection_string(),
                log_query,
            ),
            log_query,
        )
    ]
    # tools to handle rejection of manual intervention
    reject_interruption_functions = [
        FunctionDefinition(
            tool,
            callback=reject_manual_intervention_confirm_callback_wrapper(
                get_github_user_from_form(req),
                lambda: get_api_key_and_url(req),
                log_query,
            ),
        )
        for tool in reject_manual_intervention_wrapper(
            query,
            reject_manual_intervention_callback(
                lambda: get_api_key_and_url(req),
                get_github_user_from_form(req),
                get_functions_connection_string(),
                log_query,
            ),
            log_query,
        )
    ]

    deployment_functions = [
        FunctionDefinition(tool)
        for tool in release_what_changed_wrapper(
            query,
            release_what_changed_callback_wrapper(
                is_admin_user(get_github_user_from_form(req), get_admin_users()),
                get_github_user_from_form(req),
                get_github_token(req),
                get_zendesk_user(),
                get_zendesk_token(),
                lambda: get_api_key_and_url(req),
                log_query,
            ),
            log_query,
        )
    ]

    # Functions related to the default values
    (
        set_default_value,
        remove_default_value,
        get_default_value,
        get_all_default_values,
        save_defaults_as_profile,
        load_defaults_from_profile,
        list_profiles,
    ) = default_value_callbacks(
        get_github_user_from_form(req), get_functions_connection_string()
    )

    # The order of the tools can make a difference. The dashboard tools are supplied first, as this
    # appears to give them a higher precedence.
    # This behaviour is undocumented as far as I can tell - I only found out through trial and error.
    return FunctionDefinitions(
        [
            FunctionDefinition(
                show_space_dashboard_wrapper(
                    query,
                    lambda: get_api_key_and_url(req),
                    get_dashboard_callback(
                        lambda: get_github_token(req),
                        lambda: get_github_user_from_form(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                show_runbook_dashboard_wrapper(
                    query,
                    lambda: get_api_key_and_url(req),
                    get_runbook_dashboard_callback(get_github_user_from_form(req)),
                    log_query,
                )
            ),
            FunctionDefinition(
                show_project_dashboard_wrapper(
                    query,
                    lambda: get_api_key_and_url(req),
                    get_project_dashboard_callback(
                        get_github_user_from_form(req), get_github_token(req), log_query
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_general_query_wrapper(
                    query,
                    general_query_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                ),
                schema=AnswerGeneralQuery,
            ),
            FunctionDefinition(
                answer_step_features_wrapper(
                    query,
                    general_query_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_project_variables_wrapper(
                    query,
                    variable_query_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_project_variables_usage_wrapper(
                    query,
                    variable_query_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_project_deployment_logs_wrapper(
                    query,
                    logs_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                show_task_summary_wrapper(
                    query,
                    get_task_summary_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_runbook_run_logs_wrapper(
                    query,
                    get_runbook_logs_wrapper(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_machines_wrapper(
                    query,
                    resource_specific_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_certificates_wrapper(
                    query,
                    resource_specific_callback(
                        get_github_user_from_form(req),
                        lambda: get_api_key_and_url(req),
                        log_query,
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                logout(
                    get_github_user_from_form(req), get_functions_connection_string()
                )
            ),
            FunctionDefinition(set_default_value),
            FunctionDefinition(get_default_value),
            FunctionDefinition(get_all_default_values),
            FunctionDefinition(remove_default_value),
            FunctionDefinition(save_defaults_as_profile),
            FunctionDefinition(load_defaults_from_profile),
            FunctionDefinition(list_profiles),
            *help_functions,
            FunctionDefinition(
                run_runbook_wrapper(
                    query,
                    callback=run_runbook_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        get_functions_connection_string(),
                        log_query,
                    ),
                    logging=log_query,
                ),
                callback=run_runbook_confirm_callback_wrapper(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                ),
            ),
            FunctionDefinition(
                create_release_wrapper(
                    query,
                    callback=create_release_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        get_functions_connection_string(),
                        log_query,
                    ),
                    logging=log_query,
                ),
                callback=create_release_confirm_callback_wrapper(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                ),
            ),
            FunctionDefinition(
                deploy_release_wrapper(
                    query,
                    callback=deploy_release_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        get_functions_connection_string(),
                        log_query,
                    ),
                    logging=log_query,
                ),
                callback=deploy_release_confirm_callback_wrapper(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                ),
            ),
            *approval_interruption_functions,
            *reject_interruption_functions,
            FunctionDefinition(
                cancel_task_wrapper(
                    query,
                    callback=cancel_task_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        get_functions_connection_string(),
                        log_query,
                    ),
                    logging=log_query,
                ),
                callback=cancel_task_confirm_callback_wrapper(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                ),
            ),
            FunctionDefinition(
                cancel_deployment_wrapper(
                    query,
                    callback=cancel_deployment_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        get_functions_connection_string(),
                        log_query,
                    ),
                    logging=log_query,
                ),
                callback=cancel_task_confirm_callback_wrapper(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                ),
            ),
            FunctionDefinition(
                cancel_runbook_run_wrapper(
                    query,
                    callback=cancel_runbook_run_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        get_functions_connection_string(),
                        log_query,
                    ),
                    logging=log_query,
                ),
                callback=cancel_task_confirm_callback_wrapper(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                ),
            ),
            FunctionDefinition(
                show_github_job_summary_wrapper(
                    query,
                    get_job_summary_callback(
                        get_github_user_from_form(req), get_github_token(req)
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                answer_github_logs_wrapper(
                    query,
                    get_github_logs_callback(
                        get_github_user_from_form(req), get_github_token(req)
                    ),
                    log_query,
                )
            ),
            FunctionDefinition(
                generate_terraform_wrapper(
                    query,
                    generate_terraform_callback_wrapper(),
                    get_github_token(req),
                    log_query,
                )
            ),
            FunctionDefinition(
                suggest_solution_wrapper(
                    query,
                    suggest_solution_callback_wrapper(get_github_user_from_form(req)),
                    is_admin_user(get_github_user_from_form(req), get_admin_users()),
                    get_github_user_from_form(req),
                    get_github_token(req),
                    get_zendesk_user(),
                    get_zendesk_token(),
                    lambda: get_slack_token(req),
                    get_storyblok_token(),
                    os.environ.get("ENCRYPTION_PASSWORD"),
                    os.environ.get("ENCRYPTION_SALT"),
                    log_query,
                ),
                is_enabled=is_admin_user(
                    get_github_user_from_form(req), get_admin_users()
                ),
            ),
            *deployment_functions,
            FunctionDefinition(
                octolint_unused_projects_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintUnusedProjects",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_unused_targets_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintUnusedTargets",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_empty_projects_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintEmptyProject",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_unused_variables_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintUnusedVariables",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_duplicate_variables_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintDuplicatedVariables",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_unhealthy_targets_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintUnhealthyTargets",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_unrotated_accounts_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintUnrotatedAccounts",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_direct_tenant_references_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintDirectTenantReferences",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            FunctionDefinition(
                octolint_unused_tenants_wrapper(
                    octolint_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        query,
                        "OctoLintUnusedTenants",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    log_query,
                ),
            ),
            *docs_functions,
            FunctionDefinition(
                create_k8s_project_wrapper(
                    query,
                    callback=create_template_project_callback(
                        lambda: get_api_key_and_url(req),
                        get_github_user_from_form(req),
                        get_functions_connection_string(),
                        log_query,
                        ["context.tf", "everystep.tf"],
                        "k8s.tf",
                        "Example Octopus Kubernetes Project Terraform Configuration",
                        "k8ssystemprompt.txt",
                        get_redirections(req),
                        get_redirections_api_key(req),
                    ),
                    logging=log_query,
                ),
                callback=create_template_project_confirm_callback_wrapper(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                    get_redirections(req),
                    get_redirections_api_key(req),
                )
                or is_admin_server(get_server(req), get_admin_servers()),
            ),
        ],
        fallback=FunctionDefinitions(docs_functions),
        invalid=FunctionDefinition(
            answer_general_query_wrapper(
                query,
                general_query_callback(
                    get_github_user_from_form(req),
                    lambda: get_api_key_and_url(req),
                    log_query,
                ),
                log_query,
            ),
            schema=AnswerGeneralQuery,
        ),
    )
