import os

from gql import Client, gql
from gql.transport.requests import RequestsHTTPTransport
from gql.transport.exceptions import TransportServerError

from domain.exceptions.request_failed import CodefreshRequestFailed
from domain.exceptions.user_not_loggedin import CodefreshTokenInvalid
from domain.logging.app_logging import configure_logging
from domain.url.build_url import build_url
from infrastructure.octopus import logging_wrapper

logger = configure_logging()


def handle_response(callback):
    """
    This function maps common HTTP response codes from the GraphQL client to exceptions
    :param callback: A function that returns a response object
    :return: The response object
    """
    try:

        response = callback()
        return response
    except TransportServerError as e:
        if e.code == 401:
            logger.info(e.args)
            raise CodefreshTokenInvalid()
        if e.code not in (200, 201):
            logger.info(e.args)
            raise CodefreshRequestFailed(f"Request failed with {e.args}")


def get_query(query_name, query_path="infrastructure/queries"):
    query_file = os.path.join(query_path, f'{query_name}.graphql')
    with open(query_file, 'r') as file:
        query_content = file.read()
    return gql(query_content)


@logging_wrapper
def get_codefresh_user(base_url, token):
    user_query = get_query('user')
    return execute_graph_query(base_url, token, user_query)


@logging_wrapper
def execute_graph_query(url, token, query, path='/2.0/api/graphql'):
    url = build_url(url, path)
    transport = RequestsHTTPTransport(
        url=url,
        headers={'authorization': token},
        verify=True,
        retries=3,
    )
    client = Client(transport=transport, fetch_schema_from_transport=False)
    response = handle_response(lambda: client.execute(query, variable_values={}))
    return response
