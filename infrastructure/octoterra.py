import json

from retry import retry
from urllib3.exceptions import HTTPError

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http
from infrastructure.octopus import handle_response, get_space_id_and_name_from_name

logger = configure_logging(__name__)


@retry(HTTPError, tries=3, delay=2)
def get_octoterra_space(space_name, api_key, octopus_url):
    """
    Retunrs the terraform representation of a space
    :param space_name: The name of the space.
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :return: The space terraform module
    """
    logger.info("get_octoterra_space - Enter")

    ensure_string_not_empty(space_name, 'space_name must be a non-empty string (get_octoterra_space).')

    space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, octopus_url)

    body = {
        "space": space_id,
        "url": octopus_url,
        "apiKey": api_key,
        "ignoreCacManagedValues": False,
        "excludeCaCProjectSettings": True
    }

    resp = handle_response(lambda: http.request("POST",
                                                "https://octoterraproduction.azurewebsites.net/api/octoterra",
                                                body=json.dumps(body)))

    return resp.data.decode("utf-8")
