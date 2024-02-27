import json
import os

from azure.core.exceptions import HttpResponseError

import azure.functions as func
from domain.config.database import get_functions_connection_string
from domain.config.users import get_admin_users
from domain.encrption.encryption import decrypt_eax, generate_password
from domain.errors.error_handling import handle_error
from domain.exceptions.not_authorized import NotAuthorized
from domain.exceptions.request_failed import GitHubRequestFailed, OctopusRequestFailed
from domain.exceptions.space_not_found import SpaceNotFound
from domain.exceptions.user_not_configured import UserNotConfigured
from domain.exceptions.user_not_loggedin import OctopusApiKeyInvalid, UserNotLoggedIn
from domain.handlers.copilot_handler import handle_copilot_chat
from domain.logging.app_logging import configure_logging
from domain.security.security import is_admin_user
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.transformers.sse_transformers import convert_to_sse_response
from domain.validation.argument_validation import ensure_string_not_empty
from domain.validation.octopus_validation import is_hosted_octopus
from infrastructure.github import get_github_user
from infrastructure.octopus import get_octopus_project_names_base, get_octopus_project_names_response, get_current_user, \
    create_limited_api_key
from infrastructure.users import get_users_details, save_users_octopus_url, delete_old_user_details, save_login_uuid, \
    save_users_octopus_url_from_login, delete_all_user_details, delete_old_user_login_records

app = func.FunctionApp()
logger = configure_logging(__name__)


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


@app.function_name(name="login_record_cleanup")
@app.timer_trigger(schedule="0 */5 * * * *",
                   arg_name="mytimer",
                   run_on_startup=True)
def login_record_cleanup(mytimer: func.TimerRequest) -> None:
    """
    A function handler used to clean up old login joining records
    :param mytimer: The Timer request
    """
    try:
        delete_old_user_login_records(get_functions_connection_string())
    except Exception as e:
        handle_error(e)


@app.route(route="oauth_callback", auth_level=func.AuthLevel.ANONYMOUS)
def oauth_callback(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that returns an HTML form for testing
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        with open("html/oauth_callback.html", "r") as file:
            return func.HttpResponse(file.read(), headers={"Content-Type": "text/html"})
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read form HTML", status_code=500)


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


@app.route(route="login", auth_level=func.AuthLevel.ANONYMOUS)
def login_form(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that returns an HTML form logging in. The idea here is that we don't hold onto keys for long,
    and instead rely on the browser to save the credentials exposed by this form.
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        with open("html/login.html", "r") as file:
            return func.HttpResponse(file.read(), headers={"Content-Type": "text/html"})
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read form HTML", status_code=500)


@app.route(route="login_submit", auth_level=func.AuthLevel.ANONYMOUS)
def login_submit(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that responds to a login
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        uuid = req.params.get('state')
        body = json.loads(req.get_body())

        # Using the supplied API key, create a time limited API key that we'll save and reuse until
        # the next cleanup cycle triggered by api_key_cleanup. Using temporary keys mens we never
        # persist a long-lived key.
        user = get_current_user(body['api'], body['url'])
        api_key = create_limited_api_key(user, body['api'], body['url'])

        save_users_octopus_url_from_login(uuid, body['url'], api_key, get_functions_connection_string())
        return func.HttpResponse(status_code=201)
    except (OctopusRequestFailed, OctopusApiKeyInvalid) as e:
        handle_error(e)
        return func.HttpResponse("Failed to generate temporary key", status_code=400)
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read form HTML", status_code=500)


@app.route(route="form_handler", auth_level=func.AuthLevel.ANONYMOUS)
def copilot_handler(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that processes a query from the test form. This function accommodates the limitations
    of browser based SSE requests, namely that the request is a GET (so no request body). The Copilot
    requests on the other hand initiate an SSE stream with a POST that has a body.
    :param req: The HTTP request
    :return: A conversational string with the projects found in the space
    """

    def get_github_token():
        return req.headers.get("X-GitHub-Token")

    def get_github_user_from_form():
        return get_github_user(req.headers.get("X-GitHub-Token"))

    def clean_up_all_records():
        """Cleans up, or deletes, all user records
        """
        is_admin_user(get_github_user_from_form(),
                      get_admin_users(),
                      lambda: delete_all_user_details(get_functions_connection_string()))
        return f"Deleted all records"

    def set_octopus_details_from_form(octopus_url, api_key):
        """Sets or saves the Octopus instance of a user

            Args:
                octopus_url: The URL of an octopus instance, for example https://myinstance.octopus.app,
                where "myinstance" can be any name

                api_key: The Octopus API key, e.g. API-xxxxxxxxxxxxxxxxxxxxxxx
        """

        logger.info("Calling set_octopus_details_from_form")

        ensure_string_not_empty(octopus_url, 'octopus_url must be an Octopus Url (set_octopus_details_from_form).')
        ensure_string_not_empty(api_key, 'api_key must be the ID of a service account (set_octopus_details_from_form).')

        if not is_hosted_octopus(octopus_url):
            raise ValueError('octopus_url must be a Octopus cloud instance.')

        username = get_github_user_from_form()

        if not username or not isinstance(username, str) or not username.strip():
            raise UserNotLoggedIn()

        save_users_octopus_url(username,
                               octopus_url,
                               api_key,
                               get_functions_connection_string())

        return "Successfully updated the Octopus instance and API key."

    def get_api_key_and_url():
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

        decrypted_api_key = decrypt_eax(generate_password(get_github_token(), os.environ.get("SALT")),
                                        api_key,
                                        tag,
                                        nonce,
                                        os.environ.get("SALT"))

        return decrypted_api_key.decode(), github_user["OctopusUrl"]

    def get_octopus_project_names_form(space_name):
        """Return a list of project names in an Octopus space

            Args:
                space_name: The name of the space containing the projects
        """

        logger.info("Calling get_octopus_project_names_form")

        try:
            api_key, url = get_api_key_and_url()
        except ValueError as e:
            raise OctopusApiKeyInvalid()

        get_current_user(api_key, url)
        actual_space_name, projects = get_octopus_project_names_base(space_name, api_key, url)
        logger.info(f"Actual space name: {actual_space_name}")
        logger.info(f"Projects: " + str(projects))
        return get_octopus_project_names_response(actual_space_name, projects)

    def build_form_tools():
        """
        Builds a set of tools configured for use with HTTP requests (i.e. API key
        and URL extracted from an HTTP request body).
        :return: The OpenAI tools
        """
        return FunctionDefinitions([
            FunctionDefinition(get_octopus_project_names_form),
            FunctionDefinition(set_octopus_details_from_form),
            FunctionDefinition(clean_up_all_records),
        ])

    try:
        query = extract_query(req)
        logger.info("Query: " + query)

        if not query.strip():
            return func.HttpResponse(
                convert_to_sse_response("Ask a question like \"Show me the projects in the space called Default\""),
                headers=get_sse_headers())

        result = handle_copilot_chat(query, build_form_tools).call_function()

        return func.HttpResponse(convert_to_sse_response(result), headers=get_sse_headers())

    except UserNotLoggedIn as e:
        return func.HttpResponse(convert_to_sse_response("Your GitHub token is invalid."),
                                 headers=get_sse_headers())
    except OctopusRequestFailed as e:
        return func.HttpResponse(convert_to_sse_response(
            "The request to the Octopus API failed. "
            + "Either your API key is invalid, or there was an issue contacting the server."),
            headers=get_sse_headers())
    except GitHubRequestFailed as e:
        return func.HttpResponse(
            convert_to_sse_response("The request to the GitHub API failed. "
                                    + "Your GitHub token is likely to be invalid."),
            headers=get_sse_headers())
    except NotAuthorized as e:
        return func.HttpResponse(convert_to_sse_response("You are not authorized."),
                                 headers=get_sse_headers())
    except SpaceNotFound as e:
        return func.HttpResponse(convert_to_sse_response("The requested space was not found. "
                                                         + "Either the space does not exist or the API key does not "
                                                         + "have permissions to access it."),
                                 headers=get_sse_headers())
    except (UserNotConfigured, OctopusApiKeyInvalid,) as e:
        # This exception means there is no Octopus instance configured for the GitHub user making the request.
        # The Octopus instance is supplied via a chat message.
        return request_config_details(get_github_user_from_form(), get_github_token())
    except Exception as e:
        handle_error(e)
        return func.HttpResponse(convert_to_sse_response("An exception was raised. See the logs for more details."),
                                 status_code=500,
                                 headers=get_sse_headers())


def extract_query(req: func.HttpRequest):
    """
    Traditional web based SSE only supports GET requests, so testing the integration from a HTML form
    means making a GET request with the query as a parameter. Copilot makes POST requests with the
    query in the body. This functon extracts the query for both HTML forms and Copilot requests.
    :param req: The HTTP request
    :return: The query
    """

    # This is the query from a HTML form
    query = req.params.get("message")

    if query:
        return query.strip()

    body = json.loads(req.get_body())

    # This is the format supplied by copilot
    if 'messages' in body and len(body.get('messages')) != 0:
        # We don't care about the chat history, just the last message
        message = body.get('messages')[-1]
        if 'content' in message:
            return message.get('content').strip()

    return ""


def get_sse_headers():
    return {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache'
    }


def request_config_details(github_username, github_token):
    try:
        logger.info("User has not configured Octopus instance")
        password = generate_password(github_token, os.environ.get("SALT"))
        uuid = save_login_uuid(github_username, password, get_functions_connection_string())
        return func.HttpResponse(convert_to_sse_response(
            f"To continue chatting please [log in](https://octopuscopilotproduction.azurewebsites.net/api/login?state={uuid})."),
            status_code=200,
            headers=get_sse_headers())
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("data: An exception was raised. See the logs for more details.\n\n",
                                 status_code=500,
                                 headers=get_sse_headers())
