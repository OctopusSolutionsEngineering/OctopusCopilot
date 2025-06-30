import asyncio
import json
import os
from urllib.parse import urlparse

import aiohttp

from domain.exceptions.none_on_exception import none_on_exception_async
from domain.exceptions.spacebuilder import SpaceBuilderRequestFailed
from domain.validation.argument_validation import (
    ensure_string_not_empty,
    ensure_one_string_not_empty,
)
from infrastructure.octolint import redirections_enabled
from infrastructure.octopus import logging_wrapper
from infrastructure.ratings import create_feedback_async

# Semaphore to limit the number of concurrent requests to the octopus space builder
sem = asyncio.Semaphore(10)


def get_space_builder_create_autoapply_api(use_redirections):
    if use_redirections:
        return f"https://{os.environ.get('REDIRECTION_HOST')}/api/terraformautoapply"
    else:
        return os.environ["APPLICATION_SPACEBUILDER_URL"] + "/api/terraformautoapply"


def get_space_builder_create_plan_api(use_redirections):
    if use_redirections:
        return f"https://{os.environ.get('REDIRECTION_HOST')}/api/terraformplan"
    else:
        return os.environ["APPLICATION_SPACEBUILDER_URL"] + "/api/terraformplan"


def get_space_builder_create_apply_api(use_redirections):
    if use_redirections:
        return f"https://{os.environ.get('REDIRECTION_HOST')}/api/terraformapply"
    else:
        return os.environ["APPLICATION_SPACEBUILDER_URL"] + "/api/terraformapply"


def get_space_builder_headers(
    use_redirections,
    api_key,
    octopus_url,
    access_token,
    redirections,
    redirections_apikey,
):
    headers = {
        "X-Octopus-ApiKey": api_key,
        "X-Octopus-Url": octopus_url,
    }

    if access_token.strip():
        headers["Authorization"] = "Bearer " + access_token.strip()

    if use_redirections:
        parsed_octolint_url = urlparse(os.environ["APPLICATION_SPACEBUILDER_URL"])
        headers["X_REDIRECTION_REDIRECTIONS"] = redirections
        headers["X_REDIRECTION_UPSTREAM_HOST"] = parsed_octolint_url.hostname
        headers["X_REDIRECTION_API_KEY"] = redirections_apikey
        headers["X_REDIRECTION_SERVICE_API_KEY"] = os.environ.get(
            "REDIRECTION_SERVICE_APIKEY", "Unknown"
        )

    return headers


def get_space_builder_create_plan_request_body(space_id, configuration):
    """
    Returns the body of the request to create a Terraform plan in the space builder
    """

    return {
        "data": {
            "type": "terraformplan",
            "attributes": {"configuration": configuration, "space_id": space_id},
        }
    }


def get_space_builder_create_apply_request_body(plan_id):
    """
    Returns the body of the request to create a Terraform apply in the space builder
    """

    return {
        "data": {
            "type": "terraformapply",
            "attributes": {"plan_id": plan_id},
        }
    }


@logging_wrapper
async def create_terraform_plan(
    api_key,
    access_token,
    octopus_url,
    space_id,
    project_name,
    prompt,
    configuration,
    redirections,
    redirections_apikey,
):
    ensure_string_not_empty(
        space_id, "space_id must be a non-empty string (create_terraform_plan)."
    )
    ensure_string_not_empty(
        octopus_url,
        "octopus_url must be a non-empty string (create_terraform_plan).",
    )
    ensure_one_string_not_empty(
        "api_key or access_token must be a non-empty string (create_terraform_plan).",
        api_key,
        access_token,
    )

    space_builder_request_body = get_space_builder_create_plan_request_body(
        space_id, configuration
    )

    redirections_are_enabled = redirections_enabled(redirections, redirections_apikey)

    api = get_space_builder_create_plan_api(redirections_are_enabled)

    headers = get_space_builder_headers(
        redirections_are_enabled,
        api_key,
        octopus_url,
        access_token,
        redirections,
        redirections_apikey,
    )

    async with sem:
        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.post(
                api, data=json.dumps(space_builder_request_body)
            ) as response:
                if response.status != 200 and response.status != 201:
                    # Send feedback to the feedback service if the request fails
                    # This allows us to capture prompts that fail to generate a plan
                    # This is a best-effort operation, and we don't fail on an exception
                    await none_on_exception_async(
                        lambda: create_feedback_async(
                            api_key,
                            access_token,
                            octopus_url,
                            prompt,
                            False,
                            "Failed to create terraform plan",
                        )
                    )
                    body = await response.text()
                    raise SpaceBuilderRequestFailed(
                        f"SpaceBuilder plan request to {api} failed with {body}"
                    )
                return await response.json()


@logging_wrapper
async def create_terraform_apply(
    api_key,
    access_token,
    octopus_url,
    plan_id,
    prompt,
    redirections,
    redirections_apikey,
):
    ensure_string_not_empty(
        plan_id,
        "plan_id must be a non-empty string (create_terraform_apply).",
    )
    ensure_one_string_not_empty(
        "api_key or access_token must be a non-empty string (create_terraform_plan).",
        api_key,
        access_token,
    )

    space_builder_request_body = get_space_builder_create_apply_request_body(plan_id)

    redirections_are_enabled = redirections_enabled(redirections, redirections_apikey)

    api = get_space_builder_create_apply_api(redirections_are_enabled)

    headers = get_space_builder_headers(
        redirections_are_enabled,
        api_key,
        octopus_url,
        access_token,
        redirections,
        redirections_apikey,
    )

    async with sem:
        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.post(
                api, data=json.dumps(space_builder_request_body)
            ) as response:
                if response.status != 200 and response.status != 201:
                    # Send feedback to the feedback service if the request fails
                    # This allows us to capture prompts that fail to generate a plan
                    # This is a best-effort operation, and we don't fail on an exception
                    await none_on_exception_async(
                        lambda: create_feedback_async(
                            api_key,
                            access_token,
                            octopus_url,
                            prompt,
                            False,
                            "Failed to apply terraform plan",
                        )
                    )
                    body = await response.text()
                    raise SpaceBuilderRequestFailed(
                        f"SpaceBuilder apply request to {api} failed with {body}"
                    )
                return await response.json()


@logging_wrapper
async def create_terraform_autoapply(
    api_key,
    access_token,
    octopus_url,
    space_id,
    project_name,
    prompt,
    configuration,
    redirections,
    redirections_apikey,
):
    ensure_string_not_empty(
        space_id, "space_id must be a non-empty string (create_terraform_plan)."
    )
    ensure_string_not_empty(
        octopus_url,
        "octopus_url must be a non-empty string (create_terraform_plan).",
    )
    ensure_one_string_not_empty(
        "api_key or access_token must be a non-empty string (create_terraform_plan).",
        api_key,
        access_token,
    )

    space_builder_request_body = get_space_builder_create_plan_request_body(
        space_id, configuration
    )

    redirections_are_enabled = redirections_enabled(redirections, redirections_apikey)

    api = get_space_builder_create_autoapply_api(redirections_are_enabled)

    headers = get_space_builder_headers(
        redirections_are_enabled,
        api_key,
        octopus_url,
        access_token,
        redirections,
        redirections_apikey,
    )

    async with sem:
        async with aiohttp.ClientSession(headers=headers) as session:
            async with session.post(
                api, data=json.dumps(space_builder_request_body)
            ) as response:
                if response.status != 200 and response.status != 201:
                    # Send feedback to the feedback service if the request fails
                    # This allows us to capture prompts that fail to generate a plan
                    # This is a best-effort operation, and we don't fail on an exception
                    await none_on_exception_async(
                        lambda: create_feedback_async(
                            api_key,
                            access_token,
                            octopus_url,
                            prompt,
                            False,
                            "Failed to create autoapply terraform configuration",
                        )
                    )
                    body = await response.text()
                    raise SpaceBuilderRequestFailed(
                        f"SpaceBuilder autoapply request to {api} failed with {body}"
                    )
                return await response.json()
