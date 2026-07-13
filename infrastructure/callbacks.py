from datetime import datetime, timedelta

from azure.core.exceptions import HttpResponseError, ResourceExistsError
from azure.data.tables import TableServiceClient
from azure.storage.blob import BlobServiceClient

from domain.errors.error_handling import handle_error
from domain.logging.app_logging import configure_logging
from domain.sanitizers.github_user import get_github_user_for_callback
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)

# Azure Table Storage has a 32KB limit per string property (64KB UTF-16).
# Arguments that exceed this limit are stored in Blob Storage instead.
CALLBACK_BLOB_CONTAINER = "callbackarguments"
BLOB_REFERENCE_PREFIX = "blob://"
# Use a conservative limit to stay well within the 32KB boundary
MAX_TABLE_PROPERTY_SIZE = 30000


@logging_wrapper
def save_callback(
    github_user, function_name, callback_id, arguments, query, connection_string
):
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_callback).",
    )
    ensure_string_not_empty(
        function_name,
        "function_name must be the name of the function that generated the callback (save_callback).",
    )
    ensure_string_not_empty(
        callback_id,
        "callback_id must be the id of the confirmation callback (save_callback).",
    )
    ensure_string_not_empty(query, "query must be the original query (save_callback).")

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("callback")

    # When called from OctoAI, we don't have a user, so we default to "Unknown"
    sanitised_github_user = get_github_user_for_callback(github_user)

    # If arguments exceed the table storage property size limit, store them in blob storage
    stored_arguments = arguments
    if arguments and len(arguments) > MAX_TABLE_PROPERTY_SIZE:
        blob_name = f"callback-{callback_id}.json"
        _save_arguments_to_blob(connection_string, blob_name, arguments)
        stored_arguments = BLOB_REFERENCE_PREFIX + blob_name

    callback = {
        "PartitionKey": "github.com",
        "RowKey": callback_id,
        "FunctionName": function_name,
        "Arguments": stored_arguments,
        "GithubUser": sanitised_github_user,
        "Query": query,
    }

    table_client.upsert_entity(callback)


@logging_wrapper
def load_callback(github_user, callback_id, connection_string):
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (save_callback).",
    )
    ensure_string_not_empty(
        callback_id,
        "callback_id must be the id of the confirmation callback (save_callback).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists("callback")
        callback = table_client.get_entity("github.com", callback_id)

        # When called from OctoAI, we don't have a user, so we default to "Unknown"
        sanitised_github_user = get_github_user_for_callback(github_user)

        if not callback["GithubUser"] == sanitised_github_user:
            return None, None, None

        arguments = callback["Arguments"]

        # If arguments were stored in blob storage, retrieve them
        if arguments and str(arguments).startswith(BLOB_REFERENCE_PREFIX):
            blob_name = str(arguments)[len(BLOB_REFERENCE_PREFIX):]
            arguments = _load_arguments_from_blob(connection_string, blob_name)

        return callback["FunctionName"], arguments, callback["Query"]

    except HttpResponseError as e:
        return None, None, None


@logging_wrapper
def delete_callback(callback_id, connection_string):
    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists(
            table_name="callback"
        )

        # Try to clean up any blob-stored arguments before deleting the entity
        try:
            entity = table_client.get_entity("github.com", callback_id)
            arguments = entity.get("Arguments", "")
            if arguments and str(arguments).startswith(BLOB_REFERENCE_PREFIX):
                blob_name = str(arguments)[len(BLOB_REFERENCE_PREFIX):]
                _delete_arguments_from_blob(connection_string, blob_name)
        except HttpResponseError:
            pass

        table_client.delete_entity("github.com", callback_id)

        logger.info(f"Deleted callback {callback_id}")

    except HttpResponseError as e:
        handle_error(e)


@logging_wrapper
def delete_old_callbacks(lifetime, connection_string):
    """
    We don't want to hold onto callback functions for very long. This function deletes any old callbacks.
    :param connection_string: The database connection string
    :return: The number of deleted records.
    """

    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (delete_old_user_details).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists(
            table_name="callback"
        )

        old_records = (datetime.now() - timedelta(minutes=lifetime)).strftime(
            "%Y-%m-%dT%H:%M:%S.%fZ"
        )

        rows = table_client.query_entities(f"Timestamp lt datetime'{old_records}'")
        counter = 0
        for row in rows:
            counter = counter + 1
            # Clean up any blob-stored arguments
            arguments = row.get("Arguments", "")
            if arguments and str(arguments).startswith(BLOB_REFERENCE_PREFIX):
                blob_name = str(arguments)[len(BLOB_REFERENCE_PREFIX):]
                _delete_arguments_from_blob(connection_string, blob_name)
            table_client.delete_entity("github.com", row["RowKey"])

        logger.info(f"Cleaned up {counter} entries.")

        return counter

    except HttpResponseError as e:
        handle_error(e)


def _save_arguments_to_blob(connection_string, blob_name, arguments):
    """Save large callback arguments to blob storage."""
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)

    try:
        blob_service_client.create_container(CALLBACK_BLOB_CONTAINER)
    except ResourceExistsError:
        pass

    container_client = blob_service_client.get_container_client(
        container=CALLBACK_BLOB_CONTAINER
    )
    container_client.upload_blob(name=blob_name, data=arguments, overwrite=True)


def _load_arguments_from_blob(connection_string, blob_name):
    """Load callback arguments from blob storage."""
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    container_client = blob_service_client.get_container_client(
        container=CALLBACK_BLOB_CONTAINER
    )
    return container_client.download_blob(blob_name).readall().decode("utf-8")


def _delete_arguments_from_blob(connection_string, blob_name):
    """Delete callback arguments from blob storage."""
    try:
        blob_service_client = BlobServiceClient.from_connection_string(
            connection_string
        )
        container_client = blob_service_client.get_container_client(
            container=CALLBACK_BLOB_CONTAINER
        )
        container_client.delete_blob(blob_name)
    except HttpResponseError:
        pass
