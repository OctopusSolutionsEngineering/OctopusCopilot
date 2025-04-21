from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)


@logging_wrapper
def load_terraform_context(row_key, connection_string):
    ensure_string_not_empty(
        row_key, "row_key must be the connection string (load_terraform_context)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (load_terraform_context).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists(
            "terraformcontext"
        )
        terraform_context = table_client.get_entity("octopus", row_key)

        return terraform_context["Context"]

    except HttpResponseError as e:
        return None
