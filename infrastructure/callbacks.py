from datetime import datetime, timedelta

from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient

from domain.errors.error_handling import handle_error
from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)


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
    sanitised_github_user = (
        github_user.casefold().strip() if github_user.strip() else "Unknown"
    )

    callback = {
        "PartitionKey": "github.com",
        "RowKey": callback_id,
        "FunctionName": function_name,
        "Arguments": arguments,
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
        sanitised_github_user = (
            github_user.casefold().strip() if github_user.strip() else "Unknown"
        )

        if not callback["GithubUser"] == sanitised_github_user:
            return None, None, None

        return callback["FunctionName"], callback["Arguments"], callback["Query"]

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
            table_client.delete_entity("github.com", row["RowKey"])

        logger.info(f"Cleaned up {counter} entries.")

        return counter

    except HttpResponseError as e:
        handle_error(e)
