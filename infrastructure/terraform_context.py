from azure.core.exceptions import HttpResponseError, ResourceExistsError
from azure.data.tables import TableServiceClient

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import logging_wrapper
from azure.storage.blob import (
    BlobServiceClient,
)

logger = configure_logging(__name__)
terraform_context_container_name = "terraformcontext"


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
def save_terraform_context(name, template, connection_string):
    ensure_string_not_empty(
        name,
        "name must be the connection string (save_terraform_context).",
    )
    ensure_string_not_empty(
        template,
        "template must be the name of the function that generated the callback (save_terraform_context).",
    )

    table_service_client = TableServiceClient.from_connection_string(
        conn_str=connection_string
    )
    table_client = table_service_client.create_table_if_not_exists("terraformcontext")

    template = template.encode("utf-8")

    cached_templates = {
        "PartitionKey": "octopus",
        "RowKey": name,
        "Context": template,
    }

    table_client.upsert_entity(cached_templates)


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
        blob_service_client = BlobServiceClient.from_connection_string(
            connection_string
        )

        try:
            blob_service_client.create_container(terraform_context_container_name)
        except ResourceExistsError as e:
            pass

        container_client = blob_service_client.get_container_client(
            container=terraform_context_container_name
        )

        configuration_file = container_client.download_blob(
            "configuration." + sha + ".tf"
        ).readall()

        return str(configuration_file.decode("utf-8"))

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

    blob_service_client = BlobServiceClient.from_connection_string(connection_string)

    try:
        blob_service_client.create_container(terraform_context_container_name)
    except ResourceExistsError as e:
        pass

    try:
        container_client = blob_service_client.get_container_client(
            container=terraform_context_container_name
        )

        container_client.upload_blob(
            name="configuration." + sha + ".tf", data=template, overwrite=True
        )
    except HttpResponseError as e:
        # Saving a cached item is a best effort operation, so we don't raise an error if it fails.
        pass
