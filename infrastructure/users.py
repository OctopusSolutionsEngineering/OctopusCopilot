import traceback
from datetime import datetime

from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient

from domain.logging.app_logging import configure_logging

logger = configure_logging(__name__)


def save_users_octopus_url(username, octopus_url, api_key, connection_string):
    logger.info("save_users_octopus_url - Enter")

    if not username or not isinstance(username, str) or not username.strip():
        raise ValueError("username must be the GitHub user's ID (save_users_octopus_url).")

    if not octopus_url or not isinstance(octopus_url, str) or not octopus_url.strip():
        raise ValueError("octopus_url must be an Octopus URL (save_users_octopus_url).")

    if not api_key or not isinstance(api_key, str) or not api_key.strip():
        raise ValueError("service_account_id must be a the ID of a service account (save_users_octopus_url).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (save_users_octopus_url).')

    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'OctopusUrl': octopus_url,
        'OctopusApiKey': api_key
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


def save_users_id_token(username, id_token, connection_string):
    logger.info("save_users_id_token - Enter")

    if not username or not isinstance(username, str) or not username.strip():
        raise ValueError("username must be the GitHub user's ID (save_users_id_token).")

    if not id_token or not isinstance(id_token, str) or not id_token.strip():
        raise ValueError("id_token must be an OIDC token (save_users_id_token).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (save_users_id_token).')

    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'IdToken': id_token
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


def get_users_details(username, connection_string):
    logger.info("get_users_details - Enter")

    if not username or not isinstance(username, str) or not username.strip():
        raise ValueError("username must be the GitHub user's ID (get_users_details).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (get_users_details).')

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    return table_client.get_entity("github.com", username)


def delete_old_user_details(connection_string):
    logger.info("delete_user_details - Enter")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (delete_login_details).')

    try:
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
        table_client = table_service_client.get_table_client(table_name="users")

        thirty_days_ago = datetime.now(datetime.UTC).strftime("%Y-%m-%dT%H:%M:%S.%fZ")

        rows = table_client.query_entities(f"Timestamp lt datetime'{thirty_days_ago}'")
        for row in rows:
            table_client.delete_entity("github.com", row['RowKey'])

    except HttpResponseError as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
