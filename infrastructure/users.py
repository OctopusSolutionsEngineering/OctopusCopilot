from datetime import timedelta, datetime

from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient

from domain.encryption.encryption import encrypt_eax, generate_password
from domain.errors.error_handling import handle_error
from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty

logger = configure_logging(__name__)


def database_connection_test(connection_string):
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (test_database).')

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
    table_client = table_service_client.create_table_if_not_exists("healthcheck")

    test = {
        'PartitionKey': "github.com",
        'RowKey': "test"
    }

    table_client.upsert_entity(test)


def save_default_values(username, default_name, default_value, connection_string):
    logger.info("save_default_values - Enter")

    ensure_string_not_empty(username, "username must be the GitHub user's ID (save_default_values).")
    ensure_string_not_empty(default_name, "default_name must be a non-empty string (save_default_values).")
    ensure_string_not_empty(default_value, "default_value must be a non-empty string (save_default_values).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_default_values).')

    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        default_name.casefold().strip(): default_value
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
    table_client = table_service_client.create_table_if_not_exists("userdefaults")
    table_client.upsert_entity(user)


def get_default_values(username, default_name, connection_string):
    logger.info("get_default_values - Enter")

    ensure_string_not_empty(username, "username must be the GitHub user's ID (get_default_values).")
    ensure_string_not_empty(default_name, "default_name must be a non-empty string (get_default_values).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (get_default_values).')

    try:
        table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
        table_client = table_service_client.create_table_if_not_exists("userdefaults")
        defaults = table_client.get_entity("github.com", username)

        sanitised_default_name = default_name.casefold().strip()

        if sanitised_default_name in defaults:
            return defaults[default_name.casefold().strip()]

        return None
    except HttpResponseError as e:
        return None


def save_users_octopus_url(username, octopus_url, encrypted_api_key, tag, nonce, connection_string):
    logger.info("save_users_octopus_url - Enter")

    ensure_string_not_empty(username, "username must be the GitHub user's ID (save_users_octopus_url).")
    ensure_string_not_empty(octopus_url, "octopus_url must be an Octopus URL (save_users_octopus_url).")
    ensure_string_not_empty(encrypted_api_key,
                            "api_key must be a the ID of a service account (save_users_octopus_url).")
    ensure_string_not_empty(tag,
                            "tag must be a the tag associated with the encrypted api key (save_users_octopus_url).")
    ensure_string_not_empty(nonce,
                            "nonce must be a the nonce associated with the encrypted api key (save_users_octopus_url).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_users_octopus_url).')

    user = {
        'PartitionKey': "github.com",
        'RowKey': username,
        'OctopusUrl': octopus_url,
        'OctopusApiKey': encrypted_api_key,
        'EncryptionTag': tag,
        'EncryptionNonce': nonce,
    }

    table_service_client = TableServiceClient.from_connection_string(conn_str=connection_string)
    table_client = table_service_client.create_table_if_not_exists("users")
    table_client.upsert_entity(user)


def save_users_octopus_url_from_login(username, url, api, encryption_password, encryption_salt, connection_string):
    logger.info("save_users_octopus_url_from_login - Enter")

    ensure_string_not_empty(username,
                            "username must be the GitHub user ID (save_users_octopus_url_from_login).")
    ensure_string_not_empty(url, "url must be the Octopus URL (save_users_octopus_url_from_login).")
    ensure_string_not_empty(api, "api must be the Octopus API key (save_users_octopus_url_from_login).")
    ensure_string_not_empty(connection_string,
                            'connection_string must be the connection string (save_users_octopus_url_from_login).')

    encryption_password = generate_password(encryption_password, encryption_salt)
    encrypted_api_key, tag, nonce = encrypt_eax(api, encryption_password, encryption_salt)
    save_users_octopus_url(username, url, encrypted_api_key, tag, nonce, connection_string)


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
