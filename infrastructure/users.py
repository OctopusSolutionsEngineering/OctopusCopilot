import uuid

from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient, UpdateMode

from domain.logging.app_logging import configure_logging

logger = configure_logging()


def save_users_octopus_url(username, octopus_url, service_account_id, connection_string):
    logger.info("save_users_octopus_url - Enter")

    if not username or not isinstance(username, str) or not username.strip():
        raise ValueError("username must be the GitHub user's ID (save_users_octopus_url).")

    if not octopus_url or not isinstance(octopus_url, str) or not octopus_url.strip():
        raise ValueError("octopus_url must be an Octopus URL (save_users_octopus_url).")

    if not service_account_id or not isinstance(service_account_id, str) or not service_account_id.strip():
        raise ValueError("service_account_id must be a the ID of a service account (save_users_octopus_url).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (save_users_octopus_url).')

    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'OctopusUrl': octopus_url,
        'OctopusServiceAccountId': service_account_id
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


def save_login_state_id(username, connection_string):
    logger.info("save_login_state_id - Enter")

    if not username or not isinstance(username, str) or not username.strip():
        raise ValueError("username must be the GitHub user's ID (save_login_state_id).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (save_login_state_id).')

    mapping_uuid = str(uuid.uuid4())

    user = {
        'PartitionKey': "github.com",
        'RowKey': uuid,
        'Username': username
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("userlogin")

    logger.info("save_login_state_id - upsert")
    table_client.upsert_entity(user, mode=UpdateMode.REPLACE)
    logger.info("save_login_state_id - upsert done")
    return mapping_uuid


def get_users_details(username, connection_string):
    logger.info("get_users_details - Enter")

    if not username or not isinstance(username, str) or not username.strip():
        raise ValueError("username must be the GitHub user's ID (get_users_details).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (get_users_details).')

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    return table_client.get_entity("github.com", username)


def get_login_details(state, connection_string):
    logger.info("get_login_details - Enter")

    if not state or not isinstance(state, str) or not state.strip():
        raise ValueError("state must be the random string passed when performing an Oauth login (get_login_details).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (get_login_details).')

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("userlogin")
    return table_client.get_entity("github.com", state)


def delete_login_details(state, connection_string):
    logger.info("delete_login_details - Enter")

    if not state or not isinstance(state, str) or not state.strip():
        raise ValueError(
            "state must be the random string passed when performing an Oauth login (delete_login_details).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (delete_login_details).')

    try:
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
        table_client = table_service_client.get_table_client(table_name="userlogin")
        return table_client.delete_entity("github.com", state)
    except HttpResponseError as e:
        # Cleaning up old pairs is a best effort operation
        pass
