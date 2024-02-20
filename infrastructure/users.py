import uuid

from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient


def save_users_octopus_url(username, octopus_url, connection_string):
    if not username or not isinstance(username, str):
        raise ValueError("username must be the GitHub user's ID (save_users_octopus_url).")

    if not octopus_url or not isinstance(octopus_url, str):
        raise ValueError("octopus_url must be an Octopus URL (save_users_octopus_url).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (save_users_octopus_url).')

    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'OctopusUrl': octopus_url
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


def save_users_id_token(username, id_token, connection_string):
    if not username or not isinstance(username, str):
        raise ValueError("username must be the GitHub user's ID (save_users_id_token).")

    if not id_token or not isinstance(id_token, str):
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
    if not username or not isinstance(username, str):
        raise ValueError("username must be the GitHub user's ID (save_login_state_id).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (save_login_state_id).')

    mapping_uuid = uuid.uuid4()

    user = {
        'PartitionKey': "github.com",
        'RowKey': uuid,
        'Username': username
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("user_login")
    table_client.upsert_entity(user)
    return mapping_uuid


def get_users_details(username, connection_string):
    if not username or not isinstance(username, str):
        raise ValueError("username must be the GitHub user's ID (get_users_details).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (get_users_details).')

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    return table_client.get_entity("github.com", username)


def get_login_details(state, connection_string):
    if not state or not isinstance(state, str):
        raise ValueError("state must be the random string passed when performing an Oauth login (get_login_details).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (get_login_details).')

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("user_login")
    return table_client.get_entity("github.com", state)


def delete_login_details(state, connection_string):
    if not state or not isinstance(state, str):
        raise ValueError(
            "state must be the random string passed when performing an Oauth login (delete_login_details).")

    if connection_string is None:
        raise ValueError('connection_string must be function returning the connection string (delete_login_details).')

    try:
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
        table_client = table_service_client.get_table_client(table_name="user_login")
        return table_client.delete_entity("github.com", state)
    except HttpResponseError as e:
        # Cleaning up old pairs is a best effort operation
        pass
