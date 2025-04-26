from azure.core.exceptions import HttpResponseError
from azure.data.tables import TableServiceClient

from domain.b64.b64_encoder import decode_string_b64, encode_string_b64
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

        context = terraform_context["Context"]

        return context if isinstance(context, str) else context.decode("utf-8")

    except HttpResponseError as e:
        return None


@logging_wrapper
def load_terraform_cache(sha, connection_string):
    ensure_string_not_empty(
        sha, "sha must be the connection string (load_terraform_cache)."
    )
    ensure_string_not_empty(
        connection_string,
        "connection_string must be the connection string (load_terraform_context).",
    )

    try:
        table_service_client = TableServiceClient.from_connection_string(
            conn_str=connection_string
        )
        table_client = table_service_client.create_table_if_not_exists("terraformcache")
        terraform_context = table_client.get_entity("octopus", sha)

        template = terraform_context["Template"]

        return template if isinstance(template, str) else template.decode("utf-8")

    except HttpResponseError as e:
        return None


@logging_wrapper
def cache_terraform(sha, template, connection_string):
    ensure_string_not_empty(
        sha,
        "sha must be the connection string (cache_terraform).",
    )
    ensure_string_not_empty(
        template,
        "template must be the name of the function that generated the callback (cache_terraform).",
    )

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("terraformcache")

    template = template.encode("utf-8")

    cached_templates = {
        "PartitionKey": "octopus",
        "RowKey": sha,
        "Template": template,
    }

    table_client.upsert_entity(cached_templates)
