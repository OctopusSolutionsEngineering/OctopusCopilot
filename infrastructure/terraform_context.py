from azure.core.exceptions import HttpResponseError, ResourceExistsError

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import logging_wrapper
from azure.storage.blob import (
    BlobServiceClient,
)

logger = configure_logging(__name__)
terraform_context_container_name = "terraformcontext"
sample_terraform_context_container_name = "sampleterraformcontext"


@logging_wrapper
def load_terraform_context(filename, connection_string):
    ensure_string_not_empty(
        filename,
        "filename must be the name of the blob to load (load_terraform_cache).",
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
            blob_service_client.create_container(
                sample_terraform_context_container_name
            )
        except ResourceExistsError as e:
            pass

        container_client = blob_service_client.get_container_client(
            container=sample_terraform_context_container_name
        )

        configuration_file = container_client.download_blob(filename).readall()

        return str(configuration_file.decode("utf-8"))

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

    blob_service_client = BlobServiceClient.from_connection_string(connection_string)

    try:
        blob_service_client.create_container(sample_terraform_context_container_name)
    except ResourceExistsError as e:
        pass

    container_client = blob_service_client.get_container_client(
        container=sample_terraform_context_container_name
    )

    container_client.upload_blob(name=name, data=template, overwrite=True)


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
