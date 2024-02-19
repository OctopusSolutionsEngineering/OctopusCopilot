import os

import azure.functions as func
from domain.exceptions.user_not_configured import UserNotConfigured
from domain.handlers.copilot_handler import handle_copilot_chat
from domain.logging.app_logging import configure_logging
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from domain.transformers.sse_transformers import convert_to_sse_response
from domain.validation.octopus_validation import is_hosted_octopus
from infrastructure.github import get_github_user
from infrastructure.octopus_projects import get_octopus_project_names_base, get_octopus_project_names_response
from infrastructure.users import get_users_details, save_users_details

app = func.FunctionApp()
logger = configure_logging()


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

    def set_octopus_details_from_form(octopus_url):
        """Sets or saves the Octopus instance of a user

            Args:
                octopus_url: The URL of an octopus instance, for example https://myinstance.octopus.app,
                where "myinstance" can be any name
        """

        if not octopus_url or not octopus_url.strip():
            raise ValueError('my_get_api_key must be function returning the Octopus Url.')

        if not is_hosted_octopus(octopus_url):
            raise ValueError('octopus_url must be a Octopus cloud instance.')

        save_users_details(get_github_user_from_form(), octopus_url, lambda: os.environ.get("AzureWebJobsStorage"))
        return "Successfully updated the Octopus instance"

    def get_octopus_project_names_form(space_name):
        """Return a list of project names in an Octopus space

            Args:
                space_name: The name of the space containing the projects
        """

        try:
            github_username = get_github_user_from_form()
            github_user = get_users_details(github_username, lambda: os.environ.get("AzureWebJobsStorage"))
        except Exception as e:
            raise UserNotConfigured()

        actual_space_name, projects = get_octopus_project_names_base(space_name,
                                                                     lambda: req.headers.get("OCTOPUS_API"),
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

    # We want to fake an SSE stream. Our "stream" has one result.

    # Set the content type to text/event-stream
    headers = {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache'
    }

    try:
        query = req.params.get("message")
        logger.info("Query: " + query)
        result = handle_copilot_chat(query, build_form_tools).call_function()

        return func.HttpResponse(convert_to_sse_response(result), headers=headers)
    except UserNotConfigured as e:
        return func.HttpResponse(
            "data: You must first configure the Octopus cloud instance you wish to interact with.\n"
            + "data: To configure your Octopus instance, say "
            + "\"Set my Octopus instance to https://myinstance.octopus.app\" "
            + "(replacing \"myinstance\" with the name of your Octopus instance).\n\n",
            status_code=200, headers=headers)
    except Exception as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        return func.HttpResponse("data: " + error_message + "\n\n", status_code=500, headers=headers)
