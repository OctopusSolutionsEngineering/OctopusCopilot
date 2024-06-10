import json
import os
import urllib.parse

from azure.core.exceptions import HttpResponseError

import azure.functions as func
from domain.config.database import get_functions_connection_string
from domain.config.octopus import min_octopus_version
from domain.config.users import get_admin_users
from domain.context.github_docs import get_docs_context
from domain.context.octopus_context import llm_message_query
from domain.encryption.encryption import decrypt_eax, generate_password
from domain.errors.error_handling import handle_error
from domain.exceptions.not_authorized import NotAuthorized
from domain.exceptions.openai_error import OpenAIContentFilter, OpenAITokenLengthExceeded
from domain.exceptions.request_failed import GitHubRequestFailed, OctopusRequestFailed
from domain.exceptions.resource_not_found import ResourceNotFound
from domain.exceptions.space_not_found import SpaceNotFound
from domain.exceptions.user_not_configured import UserNotConfigured
from domain.exceptions.user_not_loggedin import OctopusApiKeyInvalid, UserNotLoggedIn, OctopusVersionInvalid
from domain.logging.app_logging import configure_logging
from domain.logging.query_loggin import log_query
from domain.messages.docs_messages import docs_prompt
from domain.messages.general import build_hcl_prompt
from domain.messages.test_message import build_test_prompt
from domain.requestparsing.extract_query import extract_query, extract_confirmation_state_and_id
from domain.response.copilot_response import CopilotResponse
from domain.security.security import is_admin_user
from domain.tools.githubactions.dashboard import get_dashboard_callback
from domain.tools.githubactions.default_values import default_value_callbacks
from domain.tools.githubactions.deployment_logs import logs_callback
from domain.tools.githubactions.general_query import general_query_callback
from domain.tools.githubactions.how_to import how_to_callback
from domain.tools.githubactions.logout import logout
from domain.tools.githubactions.provide_help import provide_help_wrapper
from domain.tools.githubactions.releases import releases_query_callback, releases_query_messages
from domain.tools.githubactions.resource_specific_callback import resource_specific_callback
from domain.tools.githubactions.run_runbook import run_runbook_wrapper, run_runbook_confirm_callback_wrapper
from domain.tools.githubactions.runbook_logs import get_runbook_logs_wrapper
from domain.tools.githubactions.runbooks_dashboard import get_runbook_dashboard_callback
from domain.tools.githubactions.variables import variable_query_callback
from domain.tools.wrapper.certificates_query import answer_certificates_wrapper
from domain.tools.wrapper.dashboard_wrapper import get_dashboard_wrapper
from domain.tools.wrapper.function_call import FunctionCall
from domain.tools.wrapper.function_definition import FunctionDefinitions, FunctionDefinition
from domain.tools.wrapper.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from domain.tools.wrapper.how_to import how_to_wrapper
from domain.tools.wrapper.project_logs import answer_project_deployment_logs_wrapper
from domain.tools.wrapper.project_variables import answer_project_variables_wrapper, \
    answer_project_variables_usage_wrapper
from domain.tools.wrapper.releases_and_deployments import answer_releases_and_deployments_wrapper
from domain.tools.wrapper.runbook_logs import answer_runbook_run_logs_wrapper
from domain.tools.wrapper.runbooks_dashboard_wrapper import get_runbook_dashboard_wrapper
from domain.tools.wrapper.step_features import answer_step_features_wrapper
from domain.tools.wrapper.targets_query import answer_machines_wrapper
from domain.transformers.minify_hcl import minify_hcl
from domain.transformers.sse_transformers import convert_to_sse_response
from domain.url.build_url import build_url
from domain.url.session import create_session_blob, extract_session_blob
from domain.url.url_builder import base_request_url
from domain.versions.octopus_version import octopus_version_at_least
from infrastructure.callbacks import load_callback, delete_callback, delete_old_callbacks
from infrastructure.github import get_github_user, search_repo
from infrastructure.http_pool import http
from infrastructure.octopus import get_current_user, \
    create_limited_api_key, get_version
from infrastructure.openai import llm_tool_query, NO_FUNCTION_RESPONSE
from infrastructure.users import get_users_details, delete_old_user_details, \
    save_users_octopus_url_from_login, database_connection_test

app = func.FunctionApp()
logger = configure_logging(__name__)

GUEST_API_KEY = "API-GUEST"
LOGIN_MESSAGE = (
        f"To continue chatting please click the link below:\n\n[log in](https://github.com/login/oauth/authorize?"
        + f"client_id={os.environ.get('GITHUB_CLIENT_ID')}"
        + f"&redirect_url={urllib.parse.quote(os.environ.get('GITHUB_CLIENT_REDIRECT'))}"
        + "&scope=user&allow_signup=false)")


@app.function_name(name="api_key_cleanup")
@app.timer_trigger(schedule="0 0 * * * *",
                   arg_name="mytimer",
                   run_on_startup=True)
def api_key_cleanup(mytimer: func.TimerRequest) -> None:
    """
    A function handler used to clean up old API keys
    :param mytimer: The Timer request
    """
    try:
        delete_old_user_details(get_functions_connection_string())
    except Exception as e:
        handle_error(e)


@app.function_name(name="callback_cleanup")
@app.timer_trigger(schedule="0 0 * * * *",
                   arg_name="mytimer",
                   run_on_startup=True)
def callback_cleanup(mytimer: func.TimerRequest) -> None:
    """
    A function handler used to clean up old callbacks
    :param mytimer: The Timer request
    """
    try:
        delete_old_callbacks(5, get_functions_connection_string())
    except Exception as e:
        handle_error(e)


@app.route(route="health", auth_level=func.AuthLevel.ANONYMOUS)
def health(req: func.HttpRequest) -> func.HttpResponse:
    """
    A health check endpoint to test that the underlying systems work as expected
    :param req: The HTTP request
    :return: The HTML form
    """
    return health_internal()


def health_internal():
    try:
        database_connection_test(get_functions_connection_string())
        llm_message_query(build_test_prompt(), {"input": "Tell me a joke"}, log_query)
        return func.HttpResponse("Healthy", status_code=200)
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to process health check", status_code=500)


@app.route(route="octopus", auth_level=func.AuthLevel.ANONYMOUS)
def octopus(req: func.HttpRequest) -> func.HttpResponse:
    """
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        with open("html/login.html", "r") as file:
            return func.HttpResponse(file.read(),
                                     headers={"Content-Type": "text/html"})
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read HTML form", status_code=500)


@app.route(route="oauth_callback", auth_level=func.AuthLevel.ANONYMOUS)
def oauth_callback(req: func.HttpRequest) -> func.HttpResponse:
    """
    Responds to the Oauth login callback and redirects to a form to submit the Octopus details.

    We have a challenge with a chat agent in that it is essentially two halves that are not aware of each other and
    share different authentication workflows. The chat agent receives a GitHub token from Copilot directly. The web
    half of the app, where uses enter their Octopus details, uses standard Oauth based login workflows.

    We use the GitHub user ID as the common context for these two halves. The web interface uses Oauth login to
    identify the GitHub user and persist their details, while the chat half uses the supplied GitHub tokens to
    identify the user. We trust that the user IDs are the same and so can exchange information between the two halves.

    Note that we never ask the user for their ID - we always get the ID from a wrapper to the GitHub API.
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        # Exchange the code
        resp = http.request("POST",
                            build_url("https://github.com", "/login/oauth/access_token",
                                      dict(client_id=os.environ.get('GITHUB_CLIENT_ID'),
                                           client_secret=os.environ.get('GITHUB_CLIENT_SECRET'),
                                           code=req.params.get('code'))),
                            headers={"Accept": "application/json"})

        if resp.status != 200:
            raise GitHubRequestFailed(f"Request failed with " + resp.data.decode('utf-8'))

        response_json = resp.json()

        # You can get 200 ok response with a bad request:
        # https://github.com/orgs/community/discussions/57068
        if "access_token" not in response_json:
            raise GitHubRequestFailed(f"Request failed with " + json.dumps(response_json))

        access_token = response_json["access_token"]

        session_json = create_session_blob(get_github_user(access_token),
                                           os.environ.get("ENCRYPTION_PASSWORD"),
                                           os.environ.get("ENCRYPTION_SALT"))

        # Normally the session information would be persisted in a cookie. I could not get Azure functions to pass
        # through a cookie. So we pass it as a wrapper param.
        return func.HttpResponse(status_code=301,
                                 headers={
                                     "Location": f"{base_request_url(req)}/api/octopus?state=" + session_json})
    except Exception as e:
        handle_error(e)

        try:
            with open("html/login-failed.html", "r") as file:
                return func.HttpResponse(file.read(),
                                         headers={"Content-Type": "text/html"},
                                         status_code=500)

        except Exception as e:
            return func.HttpResponse("Failed to process GitHub login or read HTML form", status_code=500)


@app.route(route="form", auth_level=func.AuthLevel.ANONYMOUS)
def query_form(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that returns an HTML form for testing
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        with open("html/query.html", "r") as file:
            return func.HttpResponse(file.read(), headers={"Content-Type": "text/html"})
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read form HTML", status_code=500)


@app.route(route="login_submit", auth_level=func.AuthLevel.ANONYMOUS)
def login_submit(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that responds to the submission of the API key and URL
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        body = json.loads(req.get_body())

        octopus_version = get_version(body['url'])

        if not octopus_version_at_least(octopus_version, min_octopus_version):
            raise OctopusVersionInvalid(octopus_version)

        # Extract the GitHub user from the client side session
        user_id = extract_session_blob(req.params.get("state"),
                                       os.environ.get("ENCRYPTION_PASSWORD"),
                                       os.environ.get("ENCRYPTION_SALT"))

        # Using the supplied API key, create a time limited API key that we'll save and reuse until
        # the next cleanup cycle triggered by api_key_cleanup. Using temporary keys mens we never
        # persist a long-lived key.
        user = get_current_user(body['api'], body['url'])

        # The guest API key is a fixed string, and we do not create a new temporary key
        api_key = create_limited_api_key(user, body['api'], body['url']) \
            if body['api'].upper().strip() != GUEST_API_KEY else GUEST_API_KEY

        # Persist the Octopus details against the GitHub user
        save_users_octopus_url_from_login(user_id,
                                          body['url'],
                                          api_key,
                                          os.environ.get("ENCRYPTION_PASSWORD"),
                                          os.environ.get("ENCRYPTION_SALT"),
                                          get_functions_connection_string())
        return func.HttpResponse(status_code=201)
    except OctopusVersionInvalid as e:
        handle_error(e)
        return func.HttpResponse(
            json.dumps({"error": "octopus_too_old", "message": f"Octopus version is too old ({e.version})"}),
            status_code=400)
    except (OctopusRequestFailed, OctopusApiKeyInvalid, ValueError) as e:
        handle_error(e)
        return func.HttpResponse(
            json.dumps({"error": "octopus_key_invalid", "message": "Failed to generate temporary key"}),
            status_code=400)
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read form HTML", status_code=500)


@app.route(route="query_parse", auth_level=func.AuthLevel.ANONYMOUS)
def query_parse(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that parses a wrapper for Octopus entities
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        # Extract the wrapper from the question
        query = extract_query(req)

        if not query.strip():
            logger.info(req.get_body())
            return func.HttpResponse(
                convert_to_sse_response("Ask a question like \"What are the projects in the space called Default?\""),
                headers=get_sse_headers())

        # A function that ignores the wrapper and the messages and returns the body.
        # The body contains all the extracted entities that must be returned from the Octopus API.
        def return_body_callback(tool_query, body, messages):
            return body

        tools = FunctionDefinitions([
            FunctionDefinition(answer_general_query_wrapper(query, return_body_callback), schema=AnswerGeneralQuery),
        ])

        # Result here is the body returned by return_body_callback
        result = llm_tool_query(query, tools, log_query).call_function()

        return func.HttpResponse(json.dumps(result), mimetype="application/json")
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("An exception was raised. See the logs for more details.",
                                 status_code=500)


@app.route(route="submit_query", auth_level=func.AuthLevel.ANONYMOUS)
def submit_query(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that queries the LLM with the supplied context. This is mostly used by the Chrome
    extension which will build its own context calling the Octopus API directly.
    :param req: The HTTP request
    :return: The HTML form
    """

    # This function is called after the wrapper has already been processed for the relevant entities and the HCL, JSON,
    # or logs context has been generated. The wrapper is then sent back to this function where we determine which
    # function the LLM will call. The function may alter the wrapper to provide few-shot examples, or may just pass the
    # wrapper through as is.

    try:
        # Extract the wrapper from the question
        query = extract_query(req)

        if not query.strip():
            logger.info(req.get_body())
            return func.HttpResponse(
                convert_to_sse_response("Ask a question like \"What are the projects in the space called Default?\""),
                headers=get_sse_headers())

        def get_context():
            return minify_hcl(req.get_body().decode("utf-8"))

        # Define some tools that the LLM can call
        def general_query_callback(*args, **kwargs):
            """
            Answers a general query about an Octopus space
            """
            body = json.loads(get_context())
            return llm_message_query(build_hcl_prompt(),
                                     {"json": body["json"], "hcl": body["hcl"], "context": body["context"],
                                      "input": query},
                                     log_query)

        def logs_query_callback(original_query, messages, *args, **kwargs):
            """
            Answers a general query about a logs
            """
            body = json.loads(get_context())
            return llm_message_query(messages,
                                     {"json": body["json"], "hcl": body["hcl"], "context": body["context"],
                                      "input": original_query}, log_query)

        def project_variables_usage_callback(original_query, messages, *args, **kwargs):
            """
            A function that passes the updated wrapper through to the LLM
            """
            body = json.loads(get_context())
            return llm_message_query(messages,
                                     {"json": body["json"], "hcl": body["hcl"], "context": body["context"],
                                      "input": original_query}, log_query)

        def releases_and_deployments_callback(original_query, messages, *args, **kwargs):
            """
            A function that passes the updated wrapper through to the LLM
            """
            body = json.loads(get_context())
            return llm_message_query(messages,
                                     {"json": body["json"], "hcl": body["hcl"], "context": body["context"],
                                      "input": original_query}, log_query)

        def resource_specific_callback(original_query, messages, *args, **kwargs):
            """
            A function that passes the updated wrapper through to the LLM
            """
            body = json.loads(get_context())
            return llm_message_query(messages,
                                     {"json": body["json"], "hcl": body["hcl"], "context": body["context"],
                                      "input": original_query}, log_query)

        def how_to_callback(original_query, keywords, *args, **kwargs):
            """
            A function that queries the documentation via the LLM.

            Note that this function involves some inefficiency when called from the Chrome
            extension, as the extension will first attempt to find any resource names,
            build the context, and then pass the wrapper back to the agent with the context.
            However, this callback ignores the context.
            """
            results = search_repo("OctopusDeploy/docs", "markdown", keywords)
            text = get_docs_context(results)
            messages = docs_prompt(text)

            context = {"input": original_query}

            chat_response = llm_message_query(messages, context, log_query)

            return chat_response

        def get_tools(tool_query):
            return FunctionDefinitions([
                FunctionDefinition(general_query_callback),
                FunctionDefinition(
                    answer_project_variables_wrapper(tool_query, project_variables_usage_callback, log_query)),
                FunctionDefinition(
                    answer_project_variables_usage_wrapper(tool_query, project_variables_usage_callback, log_query)),
                FunctionDefinition(
                    answer_releases_and_deployments_wrapper(tool_query,
                                                            releases_and_deployments_callback,
                                                            None,
                                                            log_query)),
                FunctionDefinition(answer_project_deployment_logs_wrapper(tool_query, logs_query_callback, log_query)),
                FunctionDefinition(answer_machines_wrapper(tool_query, resource_specific_callback, log_query)),
                FunctionDefinition(answer_certificates_wrapper(tool_query, resource_specific_callback, log_query)),
                FunctionDefinition(how_to_wrapper(query, how_to_callback, log_query)),
            ])

        # Call the appropriate tool. This may be a straight pass through of the wrapper and context,
        # or may update the wrapper with additional examples.
        result = llm_tool_query(query, get_tools(query), log_query).call_function()

        # Streaming the result could remove some timeouts. Sadly, this is yet to be implemented with
        # Python: https://github.com/Azure/azure-functions-python-worker/discussions/1349
        # So we return a bunch of SSE events as a single result.

        return func.HttpResponse(result)
    except OpenAIContentFilter as e:
        handle_error(e)
        return func.HttpResponse(NO_FUNCTION_RESPONSE, status_code=400)
    except OpenAITokenLengthExceeded as e:
        handle_error(e)
        return func.HttpResponse(
            "The wrapper and context exceeded the context window size. This error has been logged.",
            status_code=500)
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("An exception was raised. See the logs for more details.",
                                 status_code=500)


@app.route(route="form_handler", auth_level=func.AuthLevel.ANONYMOUS)
def copilot_handler(req: func.HttpRequest) -> func.HttpResponse:
    # Splitting the logic out makes testing easier, as the decorator attached to this function
    # makes it difficult to test.
    return copilot_handler_internal(req)


def copilot_handler_internal(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that processes a wrapper from the test form. This function accommodates the limitations
    of browser based SSE requests, namely that the request is a GET (so no request body). The Copilot
    requests on the other hand initiate an SSE stream with a POST that has a body.
    :param req: The HTTP request
    :return: A conversational string with the projects found in the space
    """

    def get_apikey_and_server():
        """
        When testing we supply the octopus details directly. This removes the need to use a GitHub token, as GitHub
        tokens have radiatively small rate limits. Load tests will pass these headers in to simulate a chat without
        triggering GitHub API rate limits
        :return:
        """
        api_key = req.headers.get("X-Octopus-ApiKey")
        server = req.headers.get("X-Octopus-Server")
        return api_key, server

    def get_github_token():
        return req.headers.get("X-GitHub-Token")

    def get_github_user_from_form():
        return get_github_user(get_github_token())

    def get_api_key_and_url():
        try:
            # First try to get the details from the headers
            api_key, server = get_apikey_and_server()

            if api_key and server:
                return api_key, server

            # Then get the details saved for a user
            github_username = get_github_user_from_form()

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

    def build_form_tools(query):
        """
        Builds a set of tools configured for use with HTTP requests (i.e. API key
        and URL extracted from an HTTP request body).
        :param: wrapper The wrapper sent to the LLM
        :return: The OpenAI tools
        """

        api_key, url = get_api_key_and_url()

        # A bunch of functions that do the same thing
        help_functions = [FunctionDefinition(tool) for tool in provide_help_wrapper(
            get_github_user_from_form(),
            url,
            api_key,
            log_query)]

        # A bunch of functions that search the docs
        docs_functions = [FunctionDefinition(tool) for tool in
                          how_to_wrapper(query, how_to_callback(get_github_token(), log_query), log_query)]

        # Functions related to the default values
        set_default_value, remove_default_value, get_default_value = default_value_callbacks(get_github_token())

        return FunctionDefinitions([
            FunctionDefinition(
                answer_general_query_wrapper(
                    query,
                    general_query_callback(get_github_user_from_form(),
                                           api_key,
                                           url,
                                           log_query),
                    log_query),
                schema=AnswerGeneralQuery),
            FunctionDefinition(answer_step_features_wrapper(
                query, general_query_callback(get_github_user_from_form(),
                                              api_key,
                                              url,
                                              log_query),
                log_query)),
            FunctionDefinition(
                answer_project_variables_wrapper(query,
                                                 variable_query_callback(get_github_user_from_form(),
                                                                         api_key,
                                                                         url,
                                                                         log_query),
                                                 log_query)),
            FunctionDefinition(
                answer_project_variables_usage_wrapper(query,
                                                       variable_query_callback(get_github_user_from_form(),
                                                                               api_key,
                                                                               url,
                                                                               log_query),
                                                       log_query)),
            FunctionDefinition(answer_project_deployment_logs_wrapper(query,
                                                                      logs_callback(get_github_user_from_form(),
                                                                                    api_key,
                                                                                    url,
                                                                                    log_query),
                                                                      log_query)),
            FunctionDefinition(answer_runbook_run_logs_wrapper(
                query,
                get_runbook_logs_wrapper(
                    get_github_user_from_form(),
                    api_key,
                    url,
                    log_query),
                log_query)),
            FunctionDefinition(
                answer_releases_and_deployments_wrapper(
                    query,
                    releases_query_callback(get_github_user_from_form(),
                                            api_key,
                                            url,
                                            log_query),
                    releases_query_messages(get_github_user_from_form()),
                    log_query)),
            FunctionDefinition(answer_machines_wrapper(query, resource_specific_callback(get_github_user_from_form(),
                                                                                         api_key,
                                                                                         url,
                                                                                         log_query),
                                                       log_query)),
            FunctionDefinition(
                answer_certificates_wrapper(query, resource_specific_callback(get_github_user_from_form(),
                                                                              api_key,
                                                                              url,
                                                                              log_query),
                                            log_query)),
            FunctionDefinition(logout(get_github_user_from_form(), get_functions_connection_string())),
            FunctionDefinition(set_default_value),
            FunctionDefinition(get_default_value),
            FunctionDefinition(remove_default_value),
            FunctionDefinition(get_dashboard_wrapper(
                query,
                api_key,
                url,
                get_dashboard_callback(get_github_user_from_form()))),
            FunctionDefinition(get_runbook_dashboard_wrapper(
                query,
                api_key,
                url,
                get_runbook_dashboard_callback(get_github_user_from_form()))),
            *help_functions,
            FunctionDefinition(run_runbook_wrapper(
                url,
                api_key,
                get_github_user_from_form(),
                query,
                get_functions_connection_string(),
                log_query),
                callback=run_runbook_confirm_callback_wrapper(url, api_key, log_query),
                is_enabled=is_admin_user(get_github_user_from_form(), get_admin_users()))],
            fallback=FunctionDefinitions(docs_functions),
            invalid=FunctionDefinition(
                answer_general_query_wrapper(query,
                                             general_query_callback(get_github_user_from_form(),
                                                                    api_key,
                                                                    url,
                                                                    log_query),
                                             log_query),
                schema=AnswerGeneralQuery)
        )

    try:
        result = execute_callback(
            req,
            build_form_tools,
            get_github_user_from_form()) or execute_function(req, build_form_tools)

        return func.HttpResponse(
            convert_to_sse_response(result.response, result.prompt_title, result.prompt_message, result.prompt_id),
            headers=get_sse_headers())

    except UserNotLoggedIn as e:
        return func.HttpResponse(convert_to_sse_response("Your GitHub token is invalid."),
                                 headers=get_sse_headers())
    except OctopusRequestFailed as e:
        handle_error(e)
        return func.HttpResponse(convert_to_sse_response(
            "The request to the Octopus API failed. "
            + "Either your API key is invalid, does not have the required permissions, or there was an issue contacting the server."),
            headers=get_sse_headers())
    except GitHubRequestFailed as e:
        handle_error(e)
        return func.HttpResponse(
            convert_to_sse_response("The request to the GitHub API failed. "
                                    + "Your GitHub token is likely to be invalid."),
            headers=get_sse_headers())
    except NotAuthorized as e:
        return func.HttpResponse(convert_to_sse_response("You are not authorized."),
                                 headers=get_sse_headers())
    except SpaceNotFound as e:
        return func.HttpResponse(
            convert_to_sse_response(f"The space \"{e.space_name}\" was not found. "
                                    + "Either the space does not exist or the API key does not "
                                    + "have permissions to access it."),
            headers=get_sse_headers())
    except ResourceNotFound as e:
        return func.HttpResponse(
            convert_to_sse_response(f"The {e.resource_type} \"{e.resource_name}\" was not found. "
                                    + "Either the resource does not exist or the API key does not "
                                    + "have permissions to access it."),
            headers=get_sse_headers())
    except (UserNotConfigured, OctopusApiKeyInvalid) as e:
        # This exception means there is no Octopus instance configured for the GitHub user making the request.
        # The Octopus instance is supplied via a chat message.
        return request_config_details()
    except ValueError as e:
        # Assume this is the error "Azure has not provided the response due to a content filter being triggered"
        # from azure_openai.py in langchain.
        return func.HttpResponse(convert_to_sse_response(NO_FUNCTION_RESPONSE), headers=get_sse_headers())
    except Exception as e:
        handle_error(e)
        return func.HttpResponse(convert_to_sse_response(
            "An unexpected error was thrown. This error has been logged. I'm sorry for the inconvenience."),
            headers=get_sse_headers())


def get_sse_headers():
    return {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache'
    }


def request_config_details():
    try:
        logger.info("User has not configured Octopus instance")
        return func.HttpResponse(convert_to_sse_response(LOGIN_MESSAGE),
                                 status_code=200,
                                 headers=get_sse_headers())
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("data: An exception was raised. See the logs for more details.\n\n",
                                 status_code=500,
                                 headers=get_sse_headers())


def execute_callback(req, build_form_tools, github_user):
    """
    Extract a confirmation from the request and execute the function callback
    :param req: The HTTP request
    :param build_form_tools: The function that builds the tools
    :param github_user: The github user
    :return: The result of calling the callback if the confirmation is "accepted"
    """
    state, task_id = extract_confirmation_state_and_id(req)

    logger.info("State: " + (state or "None"))
    logger.info("Task ID: " + (task_id or "None"))

    # We have received a confirmation, so call the callback
    if state and task_id:
        if state.strip().casefold() == "accepted":
            function_name, arguments, query = load_callback(github_user, task_id.strip(),
                                                            get_functions_connection_string())
            parsed_args = {}
            if arguments:
                parsed_args = json.loads(arguments)

            if function_name:
                functions = build_form_tools(query)
                result = FunctionCall(functions.get_callback_function(function_name),
                                      function_name,
                                      parsed_args).call_function()
                delete_callback(task_id, get_functions_connection_string())
                return result

        return CopilotResponse("Confirmation was denied")

    return None


def execute_function(req, build_form_tools):
    query = extract_query(req)

    functions = build_form_tools(query)

    logger.info("Query: " + (query or "None"))

    if not query.strip():
        return CopilotResponse("Ask a question like \"What are the projects in the space called Default?\"")

    return llm_tool_query(
        query,
        functions,
        log_query).call_function()
