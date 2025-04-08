import asyncio
import json
import os
from urllib.parse import urlparse

import aiohttp

from domain.exceptions.octolint import OctolintRequestFailed
from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import logging_wrapper

logger = configure_logging(__name__)

# Semaphore to limit the number of concurrent requests to octoterra
sem = asyncio.Semaphore(10)


def redirections_enabled(redirections, redirections_apikey):
    return (
        redirections is not None
        and redirections.strip()
        and redirections_apikey is not None
        and redirections_apikey.strip()
    )


def get_api(use_redirections):
    if use_redirections:
        return f"https://{os.environ.get('REDIRECTION_HOST')}/api/octolint"
    else:
        return os.environ["APPLICATION_OCTOLINT_URL"] + "/api/octolint"


def get_headers(
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
        "X-Octopus-AccessToken": access_token,
    }

    if use_redirections:
        parsed_octolint_url = urlparse(os.environ["APPLICATION_OCTOLINT_URL"])
        headers["X_REDIRECTION_REDIRECTIONS"] = redirections
        headers["X_REDIRECTION_UPSTREAM_HOST"] = parsed_octolint_url.hostname
        headers["X_REDIRECTION_API_KEY"] = redirections_apikey
        headers["X_REDIRECTION_SERVICE_API_KEY"] = os.environ.get(
            "REDIRECTION_SERVICE_APIKEY", "Unknown"
        )

    return headers


@logging_wrapper
async def run_octolint_check_async(
    api_key,
    access_token,
    octopus_url,
    space_id,
    project_name,
    check_name,
    redirections,
    redirections_apikey,
):
    ensure_string_not_empty(
        space_id, "space_id must be a non-empty string (run_octolint_check_async)."
    )
    ensure_string_not_empty(
        check_name, "check_name must be a non-empty string (run_octolint_check_async)."
    )
    ensure_string_not_empty(
        octopus_url,
        "octopus_url must be a non-empty string (run_octolint_check_async).",
    )

    octolint_request_body = get_octolint_request_body(
        check_name, space_id, project_name
    )

    redirections_are_enabled = redirections_enabled(redirections, redirections_apikey)

    api = get_api(redirections_are_enabled)

    headers = get_headers(
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
                api, data=json.dumps(octolint_request_body)
            ) as response:
                if response.status != 200:
                    body = await response.text()
                    raise OctolintRequestFailed(f"Request to {api} failed with {body}")
                return await response.text()


def get_octolint_request_body(check_name, space_id, project_name):
    """
    Returns the body of the request to run octolint in a space
    """

    return {
        "space": space_id,
        "onlyTests": check_name,
        "excludeProjectsExcept": [project_name] if project_name else [],
        "maxUnusedProjects": 1000,
        "maxDefaultStepNameProjects": 1000,
        "maxUnusedVariablesProjects": 1000,
        "maxProjectStepsProjects": 1000,
        "maxEmptyProjectCheckProjects": 1000,
        "maxUnusedTargets": 1000,
        "maxUnhealthyTargets": 1000,
    }
