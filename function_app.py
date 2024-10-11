import datetime
import json
import os
import urllib.parse
from http.cookies import SimpleCookie

import azure.functions as func
from domain.config.codefresh import get_codefresh_url
from domain.config.database import get_functions_connection_string
from domain.config.octopus import min_octopus_version, GUEST_API_KEY
from domain.context.octopus_context import llm_message_query
from domain.encryption.encryption import generate_password
from domain.errors.error_handling import handle_error
from domain.exceptions.not_authorized import NotAuthorized
from domain.exceptions.oauth_failure import ExpectedParamMissing
from domain.exceptions.request_failed import (
    GitHubRequestFailed,
    OctopusRequestFailed,
    SlackRequestFailed,
    CodefreshRequestFailed,
)
from domain.exceptions.resource_not_found import ResourceNotFound
from domain.exceptions.space_not_found import SpaceNotFound
from domain.exceptions.user_not_configured import UserNotConfigured
from domain.exceptions.user_not_loggedin import (
    OctopusApiKeyInvalid,
    UserNotLoggedIn,
    OctopusVersionInvalid,
    CodefreshTokenInvalid,
)
from domain.logging.app_logging import configure_logging
from domain.logging.query_logging import log_query
from domain.messages.test_message import build_test_prompt
from domain.requestparsing.extract_query import (
    extract_query,
    extract_confirmation_state_and_id,
)
from domain.requests.github.copilot_request_context import (
    get_github_user_from_form,
    build_form_tools,
)
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitize_prompt import sanitize_prompt
from domain.sanitizers.url_sanitizer import quote_safe
from domain.tools.wrapper.function_call import FunctionCall
from domain.transformers.sse_transformers import convert_to_sse_response
from domain.url.build_cookie import get_cookie_expiration
from domain.url.build_url import build_url
from domain.url.session import create_session_blob, extract_session_blob
from domain.url.url_builder import base_request_url
from domain.versions.octopus_version import octopus_version_at_least
from domain.view.html.html_pages import get_redirect_page, get_login_page
from infrastructure.callbacks import (
    load_callback,
    delete_callback,
    delete_old_callbacks,
)
from infrastructure.codefresh import get_codefresh_user
from infrastructure.github import get_github_user, exchange_github_code
from infrastructure.http_pool import http
from infrastructure.octopus import get_current_user, create_limited_api_key, get_version
from infrastructure.openai import llm_tool_query, NO_FUNCTION_RESPONSE
from infrastructure.users import (
    delete_old_user_details,
    save_users_octopus_url_from_login,
    database_connection_test,
    save_users_slack_login,
    delete_old_slack_user_details,
    save_users_codefresh_details_from_login,
    delete_old_codefresh_user_details,
)

app = func.FunctionApp()
logger = configure_logging(__name__)

GITHUB_LOGIN_MESSAGE = (
    f"To continue chatting please click the link below:\n\n[log in](https://github.com/login/oauth/authorize?"
    + f"client_id={os.environ.get('GITHUB_CLIENT_ID')}"
    + f"&redirect_url={quote_safe(os.environ.get('GITHUB_CLIENT_REDIRECT'))}"
    + "&scope=user&allow_signup=false)"
)

# When running as a service, files are available from the html dir.
# When run as a test, files are located back up in the tree
HTML_FILE_LOCATIONS = ["html/", "../../html/"]


@app.function_name(name="api_key_cleanup")
@app.timer_trigger(schedule="0 0 * * * *", arg_name="mytimer", run_on_startup=True)
def api_key_cleanup(mytimer: func.TimerRequest) -> None:
    """
    A function handler used to clean up old API keys
    :param mytimer: The Timer request
    """
    try:
        delete_old_user_details(get_functions_connection_string())
    except Exception as e:
        handle_error(e)


@app.function_name(name="slack_token_cleanup")
@app.timer_trigger(schedule="0 0 * * * *", arg_name="mytimer", run_on_startup=True)
def api_key_cleanup(mytimer: func.TimerRequest) -> None:
    """
    A function handler used to clean up old slack tokens
    :param mytimer: The Timer request
    """
    try:
        delete_old_slack_user_details(get_functions_connection_string())
    except Exception as e:
        handle_error(e)


@app.function_name(name="codefresh_token_cleanup")
@app.timer_trigger(schedule="0 0 * * * *", arg_name="mytimer", run_on_startup=True)
def api_key_cleanup(mytimer: func.TimerRequest) -> None:
    """
    A function handler used to clean up old codefresh tokens
    :param mytimer: The Timer request
    """
    try:
        delete_old_codefresh_user_details(get_functions_connection_string())
    except Exception as e:
        handle_error(e)


@app.function_name(name="callback_cleanup")
@app.timer_trigger(schedule="0 0 * * * *", arg_name="mytimer", run_on_startup=True)
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
        return func.HttpResponse(
            get_login_page(req), headers={"Content-Type": "text/html"}
        )
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read HTML form", status_code=500)


@app.route(route="oauth_callback", auth_level=func.AuthLevel.ANONYMOUS)
def oauth_callback(req: func.HttpRequest) -> func.HttpResponse:
    return oauth_callback_internal(req)


def oauth_callback_internal(req: func.HttpRequest):
    """
    Responds to the Oauth login callback and redirects to a form to submit the Octopus details.

    We have a challenge with a chat agent in that it is essentially two halves that are not aware of each other and
    share different authentication workflows. The chat agent receives a GitHub token from Copilot directly. The web
    half of the app, where uses enter their Octopus details, uses standard Oauth based login workflows.

    We use the GitHub user ID as the common context for these two halves. The web interface uses Oauth login to
    identify the GitHub user and persist their details, while the chat half uses the supplied GitHub tokens to
    identify the user. We trust that the user IDs are the same and so can exchange information between the two halves.

    Note that we never ask the user for their ID - we always get the ID from a query to the GitHub API.
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        access_token = exchange_github_code(req.params.get("code"))

        # State is used to track the page to redirect to. It defaults to the page that collects
        # octopus details.
        redirect = req.params.get("state", "")

        session_json = create_session_blob(
            access_token,
            os.environ.get("ENCRYPTION_PASSWORD"),
            os.environ.get("ENCRYPTION_SALT"),
        )

        return func.HttpResponse(
            get_redirect_page(
                f"{base_request_url(req)}/api/octopus?redirect=" + quote_safe(redirect),
                "Redirecting to Octopus login...",
            ),
            headers={
                "Content-Type": "text/html",
                "Set-Cookie": f"session={session_json}; Secure; SameSite=Strict; Path=/; Expires={get_cookie_expiration(datetime.datetime.now(), 7)}",
            },
        )
    except Exception as e:
        handle_error(e)

        try:
            with open(get_html_file("login-failed.html"), "r") as file:
                return func.HttpResponse(
                    file.read(), headers={"Content-Type": "text/html"}, status_code=500
                )

        except Exception as e:
            return func.HttpResponse(
                "Failed to process GitHub login or read HTML form", status_code=500
            )


@app.route(route="slack_oauth_callback", auth_level=func.AuthLevel.ANONYMOUS)
def slack_oauth_callback(req: func.HttpRequest) -> func.HttpResponse:
    return slack_oauth_callback_internal(req)


def slack_oauth_callback_internal(req: func.HttpRequest) -> func.HttpResponse:
    """
    Responds to the Slack Oauth login callback by persisting the access token in the database against
    the GitHub user.
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        # Exchange the code. Do this before extracting (or checking for) the state. This allows us
        # to complete a login without a state parameter, which is useful for debugging and changing
        # oauth permissions for a Slack app requires an OAuth login to succeed.
        resp = http.request(
            "POST",
            build_url(
                "https://slack.com",
                "/api/oauth.v2.access",
                dict(
                    client_id=os.environ.get("SLACK_CLIENT_ID"),
                    client_secret=os.environ.get("SLACK_CLIENT_SECRET"),
                    code=req.params.get("code"),
                ),
            ),
            headers={"Accept": "application/json"},
        )

        if resp.status != 200:
            raise SlackRequestFailed(
                f"Request failed with " + resp.data.decode("utf-8")
            )

        response_json = resp.json()

        # You can get 200 ok response with a bad request:
        # https://github.com/orgs/community/discussions/57068
        if "access_token" not in response_json.get("authed_user", {}):
            raise SlackRequestFailed(
                f"Request failed with " + json.dumps(response_json)
            )

        access_token = response_json["authed_user"]["access_token"]

        # Get the state, which is the details of the GitHub user to associated with this slack login
        state = req.params.get("state")

        if not state:
            raise ExpectedParamMissing(f"Request did not include a state parameter")

        # Extract the GitHub user from the client side session
        token = extract_session_blob(
            state,
            generate_password(
                os.environ.get("ENCRYPTION_PASSWORD"), os.environ.get("ENCRYPTION_SALT")
            ),
            os.environ.get("ENCRYPTION_SALT"),
        )
        user_id = get_github_user(token)

        # Persist the slack access token against the GitHub user
        save_users_slack_login(
            user_id,
            access_token,
            os.environ.get("ENCRYPTION_PASSWORD"),
            os.environ.get("ENCRYPTION_SALT"),
            get_functions_connection_string(),
        )

        with open(get_html_file("slack-login-success.html"), "r") as file:
            return func.HttpResponse(file.read(), headers={"Content-Type": "text/html"})
    except ExpectedParamMissing as e:
        handle_error(e)
        with open(get_html_file("slack-login-incomplete.html"), "r") as file:
            return func.HttpResponse(
                file.read(), headers={"Content-Type": "text/html"}, status_code=500
            )
    except Exception as e:
        handle_error(e)

        try:
            with open(get_html_file("slack-login-failed.html"), "r") as file:
                return func.HttpResponse(
                    file.read(), headers={"Content-Type": "text/html"}, status_code=500
                )

        except Exception as e:
            return func.HttpResponse(
                "Failed to process GitHub login or read HTML form", status_code=500
            )


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


@app.route(route="octopus_login_submit", auth_level=func.AuthLevel.ANONYMOUS)
def octopus_login_submit(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that responds to the submission of an Octopus API key and URL
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        body = json.loads(req.get_body())

        octopus_version = get_version(body["url"])

        if not octopus_version_at_least(octopus_version, min_octopus_version):
            raise OctopusVersionInvalid(octopus_version, min_octopus_version)

        # Extract the GitHub user from the client side session
        cookie = SimpleCookie()
        cookie.load(req.headers["Cookie"])
        session = cookie["session"].value

        access_token = extract_session_blob(
            session,
            generate_password(
                os.environ.get("ENCRYPTION_PASSWORD"), os.environ.get("ENCRYPTION_SALT")
            ),
            os.environ.get("ENCRYPTION_SALT"),
        )

        user_id = get_github_user(access_token)

        # Using the supplied API key, create a time limited API key that we'll save and reuse until
        # the next cleanup cycle triggered by api_key_cleanup. Using temporary keys mens we never
        # persist a long-lived key.
        user = get_current_user(body["api"], body["url"])

        # The guest API key is a fixed string, and we do not create a new temporary key
        api_key = (
            create_limited_api_key(user, body["api"], body["url"])
            if body["api"].upper().strip() != GUEST_API_KEY
            else GUEST_API_KEY
        )

        # Persist the Octopus details against the GitHub user
        save_users_octopus_url_from_login(
            user_id,
            body["url"],
            api_key,
            os.environ.get("ENCRYPTION_PASSWORD"),
            os.environ.get("ENCRYPTION_SALT"),
            get_functions_connection_string(),
        )
        return func.HttpResponse(status_code=201)
    except OctopusVersionInvalid as e:
        handle_error(e)
        return func.HttpResponse(
            json.dumps(
                {
                    "error": "octopus_too_old",
                    "octopus_version": e.version,
                    "required_version": e.required_version,
                    "message": f"Octopus version is too old ({e.version}). Requires at least {e.required_version}",
                }
            ),
            status_code=400,
        )
    except (OctopusRequestFailed, OctopusApiKeyInvalid, ValueError) as e:
        handle_error(e)
        return func.HttpResponse(
            json.dumps(
                {
                    "error": "octopus_key_invalid",
                    "message": "Failed to generate temporary key",
                }
            ),
            status_code=400,
        )
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read form HTML", status_code=500)


@app.route(route="codefresh_login_submit", auth_level=func.AuthLevel.ANONYMOUS)
def codefresh_login_submit(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that responds to the submission of a codefresh token
    :param req: The HTTP request
    :return: The HTML form
    """
    try:
        body = json.loads(req.get_body())
        codefresh_token = body["cf_token"]

        # Simple validation we can get the basic user details from the token
        _ = get_codefresh_user(get_codefresh_url(), codefresh_token)

        # Extract the GitHub user from the client side session
        cookie = SimpleCookie()
        cookie.load(req.headers["Cookie"])
        session = cookie["session"].value

        access_token = extract_session_blob(
            session,
            generate_password(
                os.environ.get("ENCRYPTION_PASSWORD"), os.environ.get("ENCRYPTION_SALT")
            ),
            os.environ.get("ENCRYPTION_SALT"),
        )

        user_id = get_github_user(access_token)

        # Persist the Codefresh details against the GitHub user
        save_users_codefresh_details_from_login(
            user_id,
            codefresh_token,
            os.environ.get("ENCRYPTION_PASSWORD"),
            os.environ.get("ENCRYPTION_SALT"),
            get_functions_connection_string(),
        )
        return func.HttpResponse(status_code=201)
    except (CodefreshRequestFailed, CodefreshTokenInvalid, ValueError) as e:
        handle_error(e)
        return func.HttpResponse(
            json.dumps(
                {
                    "error": "codefresh_key_invalid",
                    "message": "Failed to validate codefresh credentials",
                }
            ),
            status_code=400,
        )
    except Exception as e:
        handle_error(e)
        return func.HttpResponse("Failed to read form HTML", status_code=500)


@app.route(route="form_handler", auth_level=func.AuthLevel.ANONYMOUS)
def copilot_handler(req: func.HttpRequest) -> func.HttpResponse:
    # Splitting the logic out makes testing easier, as the decorator attached to this function
    # makes it difficult to test.
    return copilot_handler_internal(req)


def copilot_handler_internal(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that processes a query from the test form. This function accommodates the limitations
    of browser based SSE requests, namely that the request is a GET (so no request body). The Copilot
    requests on the other hand initiate an SSE stream with a POST that has a body.
    :param req: The HTTP request
    :return: A conversational string with the projects found in the space
    """

    try:
        result = execute_callback(
            req, build_form_tools, get_github_user_from_form(req)
        ) or execute_function(req, build_form_tools)

        return func.HttpResponse(
            convert_to_sse_response(
                result.response,
                result.prompt_title,
                result.prompt_message,
                result.prompt_id,
            ),
            headers=get_sse_headers(),
        )

    except UserNotLoggedIn as e:
        return handle_user_not_logged_in(e)
    except OctopusRequestFailed as e:
        return handle_octopus_request_failed(e)
    except GitHubRequestFailed as e:
        return handle_github_request_failed(e)
    except NotAuthorized as e:
        return handle_not_authorized(e)
    except SpaceNotFound as e:
        return handle_space_not_found(e)
    except ResourceNotFound as e:
        return handle_resource_not_found(e)
    except (UserNotConfigured, OctopusApiKeyInvalid) as e:
        # This exception means there is no Octopus instance configured for the GitHub user making the request.
        # The Octopus instance is supplied via a chat message.
        return request_config_details()
    except ValueError as e:
        # Assume this is the error "Azure has not provided the response due to a content filter being triggered"
        # from azure_openai.py in langchain.
        return handle_value_error(e)
    except Exception as e:
        return handle_exception(e)


def handle_value_error(e):
    handle_error(e)
    return func.HttpResponse(
        convert_to_sse_response(NO_FUNCTION_RESPONSE), headers=get_sse_headers()
    )


def handle_exception(e):
    handle_error(e)
    return func.HttpResponse(
        convert_to_sse_response(
            "An unexpected error was thrown. This error has been logged. I'm sorry for the inconvenience."
        ),
        headers=get_sse_headers(),
    )


def handle_resource_not_found(e):
    return func.HttpResponse(
        convert_to_sse_response(
            f'The {e.resource_type} "{e.resource_name}" was not found. '
            + "Either the resource does not exist or the API key does not "
            + "have permissions to access it."
        ),
        headers=get_sse_headers(),
    )


def handle_space_not_found(e):
    return func.HttpResponse(
        convert_to_sse_response(
            f'The space "{e.space_name}" was not found. '
            + "Either the space does not exist or the API key does not "
            + "have permissions to access it."
        ),
        headers=get_sse_headers(),
    )


def handle_not_authorized(e):
    return func.HttpResponse(
        convert_to_sse_response("You are not authorized."), headers=get_sse_headers()
    )


def handle_github_request_failed(e):
    handle_error(e)
    return func.HttpResponse(
        convert_to_sse_response(
            "The request to the GitHub API failed. "
            + "Your GitHub token is likely to be invalid."
        ),
        headers=get_sse_headers(),
    )


def handle_user_not_logged_in(e):
    return func.HttpResponse(
        convert_to_sse_response("Your GitHub token is invalid."),
        headers=get_sse_headers(),
    )


def handle_octopus_request_failed(e):
    handle_error(e)
    return func.HttpResponse(
        convert_to_sse_response(
            "The request to the Octopus API failed. "
            + "Either your API key is invalid, does not have the required permissions, or there was an issue contacting the server."
        ),
        headers=get_sse_headers(),
    )


def get_html_file(file):
    paths = map(lambda x: x + file, HTML_FILE_LOCATIONS)

    return next(
        filter(
            lambda x: os.path.exists(x),
            paths,
        )
    )


def get_sse_headers():
    return {"Content-Type": "text/event-stream", "Cache-Control": "no-cache"}


def request_config_details():
    try:
        logger.info("User has not configured Octopus instance")
        return func.HttpResponse(
            convert_to_sse_response(GITHUB_LOGIN_MESSAGE),
            status_code=200,
            headers=get_sse_headers(),
        )
    except Exception as e:
        handle_error(e)
        return func.HttpResponse(
            "data: An exception was raised. See the logs for more details.\n\n",
            status_code=500,
            headers=get_sse_headers(),
        )


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
            function_name, arguments, query = load_callback(
                github_user, task_id.strip(), get_functions_connection_string()
            )
            parsed_args = {}
            if arguments:
                parsed_args = json.loads(arguments)

            if function_name:
                functions = build_form_tools(query, req)
                result = FunctionCall(
                    functions.get_callback_function(function_name),
                    function_name,
                    parsed_args,
                ).call_function()
                delete_callback(task_id, get_functions_connection_string())
                return result

        return CopilotResponse("Confirmation was denied")

    return None


def execute_function(req, build_form_tools):
    query = sanitize_prompt(extract_query(req))

    functions = build_form_tools(query, req)

    logger.info("Query: " + (query or "None"))

    if not query.strip():
        return CopilotResponse(
            'Ask a question like "What are the projects in the space called Default?"'
        )

    # https://community.openai.com/t/is-there-a-way-to-force-the-model-to-use-function-calls/275672/9
    extra_messages = [
        ("system", "You will be penalized for answering the question directly."),
        ("system", "You must select from one of the supplied tools."),
    ]

    return llm_tool_query(query, functions, log_query, extra_messages).call_function()
