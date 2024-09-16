from domain.config.openai import max_context
from domain.date.parse_dates import parse_unknown_format_date
from domain.filter.list_filter import list_empty_or_match
from domain.sanitizers.sanitized_list import get_key_or_none, sanitize_list
from domain.sanitizers.url_remover import strip_markdown_urls
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.octopus import (
    get_project_releases,
    get_release_deployments,
    get_task,
    get_project,
    get_channel_cached,
    get_tenants_fuzzy_cached,
    get_environments_fuzzy_cached,
    get_channel_by_name_fuzzy,
)


def deployment_created_between(deployment, dates):
    if dates and isinstance(dates, list) and len(dates) == 2:
        created = parse_unknown_format_date(deployment["Created"])
        date1 = parse_unknown_format_date(dates[0])
        date2 = parse_unknown_format_date(dates[1])

        if created < min(date1, date2) or created > max(date1, date2):
            return False

    return True


def get_deployments_for_project(
    space_id,
    project_name,
    environment_names,
    tenant_names,
    api_key,
    octopus_url,
    dates,
    max_results=max_context,
    release_version=None,
    channel_names=None,
):
    """
    Gets the list of deployments for a specific environment from the progression of a project
    :param space_id: The id of the space
    :param project_name: The name of the project
    :param environment_names: Any environments to filter the deployments to
    :param tenant_names: Any tenants to filter the deployments to
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :param max_results: The maximum number of results
    :param release_version: The release version
    :param channel_names: The deployment channel
    :return: The list of deployments
    """

    ensure_string_not_empty(
        space_id, "space_id must be a non-empty string (get_deployments_for_project)."
    )
    ensure_string_not_empty(
        project_name,
        "project_name must be a non-empty string (get_deployments_for_project).",
    )
    ensure_string_not_empty(
        api_key, "api_key must be a non-empty string (get_deployments_for_project)."
    )
    ensure_string_not_empty(
        octopus_url,
        "octopus_url must be a non-empty string (get_deployments_for_project).",
    )

    # Not every release will have a deployment for the selected environment. So return a large number of releases,
    # which will then be filtered down.
    project = get_project(space_id, project_name, api_key, octopus_url)
    releases = get_project_releases(space_id, project["Id"], api_key, octopus_url, 100)

    # We expect lists here
    environment_names = sanitize_list(environment_names)
    tenant_names = sanitize_list(tenant_names)

    # Convert the environment and tenant names to IDs
    environments = get_environments_fuzzy_cached(
        space_id, environment_names, api_key, octopus_url
    )

    # Look up the closest matching channel
    channel = (
        get_channel_by_name_fuzzy(
            space_id, project["Id"], channel_names[0], api_key, octopus_url
        )
        if channel_names
        else None
    )

    tenants = get_tenants_fuzzy_cached(space_id, tenant_names, api_key, octopus_url)

    # Get the deployments associated with the releases, filtered to the environments
    deployments = []
    for release in releases["Items"]:
        # Keep the release if it matches the release version, or if there was no release version
        if release_version and not release_version == release["Version"]:
            continue

        release_deployments = get_release_deployments(
            space_id, release["Id"], api_key, octopus_url
        )["Items"]

        for deployment in release_deployments:
            # Keep the deployment if it matches the environment, or if there were no environments
            if not list_empty_or_match(
                environments, lambda x: x["Id"], deployment["EnvironmentId"]
            ):
                continue

            # Keep the deployment if it matches the tenant, or if there were no tenants
            if not list_empty_or_match(
                tenants, lambda x: x["Id"], deployment["TenantId"]
            ):
                continue

            # If there were two dates, treat them as a range, and exclude anything outside the range
            if not deployment_created_between(deployment, dates):
                continue

            task = get_task(space_id, deployment.get("TaskId"), api_key, octopus_url)

            deployment_channel = get_channel_cached(
                space_id, deployment["ChannelId"], api_key, octopus_url
            )

            # Keep the deployment if it matches the channel, or if there were no channels
            if channel and not channel["Name"] == deployment_channel["Name"]:
                continue

            deployments.append(
                {
                    "SpaceId": space_id,
                    "ProjectId": project["Id"],
                    "ProjectName": project["Name"],
                    "ReleaseVersion": release["Version"],
                    "DeploymentId": deployment["Id"],
                    "TaskId": deployment["TaskId"],
                    "TenantId": deployment["TenantId"],
                    "TenantName": get_key_or_none(
                        next(
                            filter(
                                lambda tenant: tenant["Id"] == deployment["TenantId"],
                                tenants,
                            ),
                            None,
                        ),
                        "Name",
                    ),
                    "ReleaseId": deployment["ReleaseId"],
                    "EnvironmentId": deployment["EnvironmentId"],
                    "EnvironmentName": get_key_or_none(
                        next(
                            filter(
                                lambda env: env["Id"] == deployment["EnvironmentId"],
                                environments,
                            ),
                            None,
                        ),
                        "Name",
                    ),
                    "ChannelId": deployment["ChannelId"],
                    "ChannelName": deployment_channel["Name"],
                    "Created": deployment["Created"],
                    "TaskState": task["State"] if task else None,
                    "TaskDuration": task["Duration"] if task else None,
                    # Urls in markdown often resulted in the LLM not returning any results
                    "ReleaseNotes": strip_markdown_urls(release["ReleaseNotes"]),
                    "DeployedBy": deployment["DeployedBy"],
                    "HasPendingInterruptions": (
                        task["HasPendingInterruptions"] if task else None
                    ),
                    "BuildInformation": release["BuildInformation"],
                }
            )

            if len(deployments) >= max_results:
                return {"Deployments": deployments}

    return {"Deployments": deployments}
