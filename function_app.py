import os
import traceback

from azure.core.exceptions import HttpResponseError

import azure.functions as func
from domain.exceptions.space_not_found import SpaceNotFound
from domain.exceptions.user_not_configured import UserNotConfigured
from domain.handlers.copilot_handler import handle_copilot_chat
from domain.logging.app_logging import configure_logging
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.transformers.sse_transformers import convert_to_sse_response
from domain.validation.octopus_validation import is_hosted_octopus
from infrastructure.github import get_github_user
from infrastructure.octopus_projects import get_octopus_project_names_base, get_octopus_project_names_response
from infrastructure.users import get_users_details, save_users_octopus_url, delete_old_user_details

app = func.FunctionApp()
logger = configure_logging(__name__)


@app.function_name(name="api_key_cleanup")
@app.timer_trigger(schedule="0 1 0 * *",
                   arg_name="mytimer",
                   run_on_startup=True)
def api_key_cleanup(mytimer: func.TimerRequest) -> None:
    """
    A function handler used to clean up old API keys
    :param mytimer: The Timer request
    """
    delete_old_user_details(lambda: os.environ.get("AzureWebJobsStorage"))


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
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
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

    def get_github_user_from_form():
        return get_github_user(lambda: req.headers.get("X-GitHub-Token"))

    def set_octopus_details_from_form(octopus_url, api_key):
        """Sets or saves the Octopus instance of a user

            Args:
                octopus_url: The URL of an octopus instance, for example https://myinstance.octopus.app,
                where "myinstance" can be any name

                api_key: The Octopus API key, e.g. API-xxxxxxxxxxxxxxxxxxxxxxx
        """

        logger.info("Calling set_octopus_details_from_form")

        if not octopus_url or not isinstance(octopus_url, str) or not octopus_url.strip():
            raise ValueError('octopus_url must be an Octopus Url.')

        if not api_key or not isinstance(api_key, str) or not api_key.strip():
            raise ValueError('service_account_id must be the ID of a service account.')

        if not is_hosted_octopus(octopus_url):
            raise ValueError('octopus_url must be a Octopus cloud instance.')

        username = get_github_user_from_form()

        if not username or not isinstance(username, str) or not username.strip():
            return "You are not logged into GitHub."

        save_users_octopus_url(username,
                               octopus_url,
                               api_key,
                               lambda: os.environ.get("AzureWebJobsStorage"))

        return "Successfully updated the Octopus instance and API key."

    def get_octopus_project_names_form(space_name):
        """Return a list of project names in an Octopus space

            Args:
                space_name: The name of the space containing the projects
        """

        logger.info("Calling get_octopus_project_names_form")

        github_username = get_github_user_from_form()

        if not github_username:
            return "You must be logged in to GitHub to chat"

        try:
            github_user = get_users_details(github_username, lambda: os.environ.get("AzureWebJobsStorage"))

            # We need to configure the Octopus details first because we need to know the service account id
            # before attempting to generate an ID token.
            if "OctopusUrl" not in github_user or "OctopusApiKey" not in github_user:
                logger.info("No OctopusUrl or OctopusApiKey")
                raise UserNotConfigured()

        except HttpResponseError as e:
            # assume any exception means the user must log in
            raise UserNotConfigured()

        actual_space_name, projects = get_octopus_project_names_base(space_name,
                                                                     lambda: github_user["OctopusApiKey"],
                                                                     lambda: github_user["OctopusUrl"])
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
        ])

    try:
        query = req.params.get("message")
        logger.info("Query: " + query)
        result = handle_copilot_chat(query, build_form_tools).call_function()

        return func.HttpResponse(convert_to_sse_response(result), headers=get_sse_headers())

    except SpaceNotFound as e:
        return func.HttpResponse(convert_to_sse_response("The requested space was not found. "
                                                         + "Either the space does not exist or the API key does not "
                                                         + "have permissions to access it."),
                                 headers=get_sse_headers())
    except UserNotConfigured as e:
        # This exception means there is no Octopus instance configured for the GitHub user making the request.
        # The Octopus instance is supplied via a chat message.
        return request_config_details()
    except Exception as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
        return func.HttpResponse("data: An exception was raised. See the logs for more details.\n\n",
                                 status_code=500,
                                 headers=get_sse_headers())


def get_sse_headers():
    return {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache'
    }


def request_config_details():
    try:
        logger.info("User has not configured Octopus instance")
        return func.HttpResponse(convert_to_sse_response(
            "You must first configure the Octopus cloud instance you wish to interact with.\n"
            + "\n"
            + "To configure your Octopus instance, say "
            + "`Set my Octopus instance to https://myinstance.octopus.app and API key to "
            + "API-ABCDEFGHIJKLMNOPQRSTUVWXYZ` (replacing `myinstance` with the hostname of your Octopus "
            + "instance, and `API-ABCDEFGHIJKLMNOPQRSTUVWXYZ` with your Octopus API key)."),
            status_code=200,
            headers=get_sse_headers())
    except Exception as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
        return func.HttpResponse("data: An exception was raised. See the logs for more details.\n\n",
                                 status_code=500,
                                 headers=get_sse_headers())
