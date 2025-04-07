import asyncio
import json
import os
from urllib.parse import urlparse

import aiohttp
from retry import retry
from urllib3.exceptions import HTTPError

from domain.config.openai import max_context
from domain.exceptions.octoterra import OctoterraRequestFailed
from domain.logging.app_logging import configure_logging
from domain.performance.timing import timing_wrapper
from domain.query.query_inspector import (
    exclude_all_targets,
    exclude_all_runbooks,
    exclude_all_tenants,
    exclude_all_projects,
    exclude_all_library_variable_sets,
    exclude_all_environments,
    exclude_all_feeds,
    exclude_all_accounts,
    exclude_all_certificates,
    exclude_all_lifecycles,
    exclude_all_worker_pools,
    exclude_all_machine_policies,
    exclude_all_tagsets,
    exclude_all_project_groups,
    exclude_all_steps,
    exclude_all_variables,
)
from domain.sanitizers.sanitized_list import (
    sanitize_projects,
    sanitize_tenants,
    sanitize_targets,
    sanitize_runbooks,
    sanitize_library_variable_sets,
    sanitize_environments,
    sanitize_feeds,
    sanitize_accounts,
    sanitize_certificates,
    sanitize_lifecycles,
    sanitize_workerpools,
    sanitize_machinepolicies,
    sanitize_tenanttagsets,
    sanitize_projectgroups,
    none_if_falesy,
    sanitize_steps,
    none_if_falesy_or_all,
    sanitize_variables,
)
from domain.url.build_url import is_octopus_cloud_local_or_example
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http
from infrastructure.octopus import handle_response, logging_wrapper
from infrastructure.redirector import get_redirect_headers

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
                    raise OctoterraRequestFailed(f"Request failed with " + body)
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
