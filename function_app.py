import logging

import azure.functions as func
from domain.handlers.copilot_handler import handle_copilot_chat
from domain.tools.function_definition import FunctionDefinitions, FunctionDefinition
from infrastructure.octopus_projects import get_octopus_project_names_base, get_octopus_project_names_response

app = func.FunctionApp()


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
def query_form_handler(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that processes a plain text query
    :param req: The HTTP request
    :return: A conversational string with the projects found in the space
    """
    logging.info('Python HTTP trigger function processed a request.')

    req_body = req.get_json()

    def get_octopus_project_names_form(space_name):
        """Return a list of project names in an Octopus space

            Args:
                space_name: The name of the space containing the projects
        """

        actual_space_name, projects = get_octopus_project_names_base(space_name, lambda: req_body["api"],
                                                                     lambda: req_body["url"])
        return get_octopus_project_names_response(actual_space_name, projects)

    def build_form_tools():
        """
        Builds a set of tools configured for use with HTTP requests (i.e. API key
        and URL extracted from an HTTP request body).
        :return: The OpenAI tools
        """
        return FunctionDefinitions([
            FunctionDefinition(get_octopus_project_names_form),
        ])

    try:
        result = handle_copilot_chat(req_body["query"], build_form_tools).call_function()
        return func.HttpResponse(result)
    except Exception as e:
        return func.HttpResponse(getattr(e, 'message', repr(e)))


@app.route(route="copilot_handler", auth_level=func.AuthLevel.ANONYMOUS)
def copilot_handler(req: func.HttpRequest) -> func.HttpResponse:
    """
    A function handler that processes a plain text query
    :param req: The HTTP request
    :return: A conversational string with the projects found in the space
    """
    logging.info('Python HTTP trigger function processed a request.')

    req_body = req.get_json()

    def get_octopus_project_names_form(space_name):
        """Return a list of project names in an Octopus space

            Args:
                space_name: The name of the space containing the projects
        """

        actual_space_name, projects = get_octopus_project_names_base(space_name,
                                                                     lambda: req.headers["OCTOPUS_API"],
                                                                     lambda: req.headers["OCTOPUS_URL"])
        return get_octopus_project_names_response(actual_space_name, projects)

    def build_form_tools():
        """
        Builds a set of tools configured for use with HTTP requests (i.e. API key
        and URL extracted from an HTTP request body).
        :return: The OpenAI tools
        """
        return FunctionDefinitions([
            FunctionDefinition(get_octopus_project_names_form),
        ])

    # We want to fake an SSE stream. Our "stream" has one result.

    # Set the content type to text/event-stream
    headers = {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache'
    }

    try:
        query = "\n".join(map(lambda m: m["content"], req_body["messages"]))
        result = handle_copilot_chat(query, build_form_tools).call_function()

        # Create data only SSE response
        # https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#data-only_messages
        return func.HttpResponse("data: " + result, headers=headers)
    except Exception as e:
        return func.HttpResponse(getattr(e, 'message', repr(e)))
