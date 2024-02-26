import uuid
from datetime import timedelta, datetime

from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient

from domain.errors.error_handling import handle_error
from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty

logger = configure_logging(__name__)


def save_users_octopus_url(username, octopus_url, api_key, connection_string):
    logger.info("save_users_octopus_url - Enter")

    ensure_string_not_empty(username, "username must be the GitHub user's ID (save_users_octopus_url).")
    ensure_string_not_empty(octopus_url, "octopus_url must be an Octopus URL (save_users_octopus_url).")
    ensure_string_not_empty(api_key, "api_key must be a the ID of a service account (save_users_octopus_url).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_users_octopus_url).')

    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'OctopusUrl': octopus_url,
        'OctopusApiKey': api_key
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


def save_login_uuid(username, connection_string):
    logger.info("save_login_uuid - Enter")

    ensure_string_not_empty(username, "username must be the GitHub user's ID (save_login_uuid).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_login_uuid).')

    login_uuid = str(uuid.uuid4())

    user = {
        'PartitionKey': "github.com",
        'RowKey': login_uuid,
        'Username': username
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
    table_client = table_service_client.create_table_if_not_exists("userlogin")
    table_client.upsert_entity(user)

    return login_uuid


def save_users_octopus_url_from_login(state, url, api, connection_string):
    logger.info("save_users_octopus_url_from_login - Enter")

    ensure_string_not_empty(state,
                            "uuid must be the UUID used to link a login to a user (save_users_octopus_url_from_login).")
    ensure_string_not_empty(url, "url must be the Octopus URL (save_users_octopus_url_from_login).")
    ensure_string_not_empty(api, "api must be the Octopus API key (save_users_octopus_url_from_login).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_users_octopus_url_from_login).')

    try:
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
        table_client = table_service_client.create_table_if_not_exists("userlogin")
        login = table_client.get_entity("github.com", state)

        username = login["Username"]

        save_users_octopus_url(username, url, api, connection_string)
    finally:
        delete_login_uuid(state, connection_string)


def delete_login_uuid(state, connection_string):
    ensure_string_not_empty(state,
                            "state must be the UUID used to link a login to a user (save_users_octopus_url_from_login).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_users_octopus_url_from_login).')

    try:
        # Clean up the linking record
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
        table_client = table_service_client.get_table_client("userlogin")
        table_client.delete_entity("github.com", state)
    except Exception as e:
        # This cleanup is a best effort operation, but it should not fail a login
        handle_error(e)


def get_users_details(username, connection_string):
    logger.info("get_users_details - Enter")

    ensure_string_not_empty(username, "username must be the GitHub user's ID (get_users_details).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_users_octopus_url).')

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
    table_client = table_service_client.create_table_if_not_exists("users")
    return table_client.get_entity("github.com", username)


def delete_old_user_details(connection_string):
    """
    We don't want to hold onto keys for very long. Every hour or so keys older than 8 hours are purged from the database
    and users need to log in again.
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """
    logger.info("delete_old_user_details - Enter")

    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (delete_old_user_details).')

    try:
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
        table_client = table_service_client.get_table_client(table_name="users")

        old_records = (datetime.now() - timedelta(hours=8)).strftime("%Y-%m-%dT%H:%M:%S.%fZ")

        rows = table_client.query_entities(f"Timestamp lt datetime'{old_records}'")
        counter = 0
        for row in rows:
            counter = counter + 1
            table_client.delete_entity("github.com", row['RowKey'])

        logger.info(f"Cleaned up {counter} entries.")

        return counter

    except HttpResponseError as e:
        handle_error(e)


def delete_all_user_details(connection_string):
    """
    Delete all user details.
    :param connection_string: The database connection string
    """
    logger.info("delete_all_user_details - Enter")

    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (delete_all_user_details).')

    try:
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
        table_service_client.delete_table("users")

    except HttpResponseError as e:
        handle_error(e)
