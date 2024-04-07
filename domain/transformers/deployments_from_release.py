from domain.config.openai import max_context
from domain.date.parse_dates import parse_unknown_format_date
from domain.sanitizers.url_remover import strip_markdown_urls
from infrastructure.octopus import get_project_releases, get_release_deployments, get_environments, \
    get_task, get_project


def get_deployments_for_project(space_id, project_name, environment_names, api_key, octopus_url, dates,
                                max_results=max_context):
    """
    Gets the list of deployments for a specific environment from the progression of a project
    :param space_id: The id of the space
    :param project_name: The name of the project
    :param environment_names: And environments to filter the deployments to
    :param api_key: The Octopus API key
    :param octopus_url: The Octopus URL
    :param max_results: The maximum number of results
    :return: The list of deployments
    """

    # Not every release will have a deployment for the selected environment. So return a large number of releases,
    # which will then be filtered down.
    project = get_project(space_id, project_name, api_key, octopus_url)
    releases = get_project_releases(space_id, project["Id"], api_key, octopus_url, 100)
    environments = get_environments(api_key, octopus_url, space_id)

    # Convert the environment names to environment ids
    environment_ids = [environment["Id"] for environment in environments if
                       environment["Name"] in environment_names] if environment_names else []

    # Get the deployments associated with the releases, filtered to the environments
    deployments = []
    for release in releases["Items"]:
        release_deployments = get_release_deployments(space_id, release["Id"], api_key,
                                                      octopus_url)
        for deployment in release_deployments["Items"]:
            # Keep the deployment if it matches the environment, or if there were no environments
            if len(environment_ids) != 0 and deployment["EnvironmentId"] not in environment_ids:
                continue

            # If there were two dates, treat them as a range, and exclude anything outside the range
            if dates and len(dates) == 2:
                created = parse_unknown_format_date(deployment["Created"])

                if created < min(dates[0], dates[1]) or created > max(dates[0], dates[1]):
                    continue

            task = get_task(space_id, deployment["TaskId"], api_key, octopus_url) if deployment.get(
                "TaskId") else None

            deployments.append({
                "SpaceId": space_id,
                "ProjectId": project["Id"],
                "ReleaseVersion": release["Version"],
                "DeploymentId": deployment["Id"],
                "TaskId": deployment["TaskId"],
                "TenantId": deployment["TenantId"],
                "ReleaseId": deployment["ReleaseId"],
                "EnvironmentId": deployment["EnvironmentId"],
                "ChannelId": deployment["ChannelId"],
                "Created": deployment["Created"],
                "TaskState": task["State"] if task else None,
                "TaskDuration": task["Duration"] if task else None,
                # Urls in markdown often resulted in the LLM not returning any results
                "ReleaseNotes": strip_markdown_urls(release["ReleaseNotes"]),
                "DeployedBy": deployment["DeployedBy"],
            })

            if len(deployments) >= max_results:
                break

        if len(deployments) >= max_results:
            break

    return {"Deployments": deployments[:max_results]}
