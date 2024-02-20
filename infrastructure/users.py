import uuid

from azure.data.tables import TableServiceClient


def save_users_octopus_url(username, octopus_url, connection_string):
    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'OctopusUrl': octopus_url
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


def save_users_id_token(username, id_token, connection_string):
    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'IdToken': id_token
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


def save_login_state_id(username, connection_string):
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
    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.get_table_client(table_name="users")
    return table_client.get_entity("github.com", username)


def get_login_details(state, connection_string):
    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string())
    table_client = table_service_client.get_table_client(table_name="user_login")
    return table_client.get_entity("github.com", state)
