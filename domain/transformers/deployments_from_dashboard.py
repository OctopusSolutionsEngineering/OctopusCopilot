from domain.sanitizers.sanitized_list import get_key_or_none
from infrastructure.octopus import get_dashboard, get_channel

# 40 projects results in th error:
# This model's maximum context length is 16384 tokens. However, your messages resulted in 29801 tokens. Please reduce the length of the messages.
# So we limit the dashboard results to 20 projects

max_projects = 20


def get_deployments_from_dashboard(space_id, api_key, octopus_url):
    dashboard = get_dashboard(space_id, api_key, octopus_url)

    deployments = [
        dashboard_item_to_deployment(
            space_id,
            dashboard["Environments"],
            dashboard["Projects"],
            item,
            api_key,
            octopus_url,
        )
        for item in dashboard["Items"]
    ]

    return {
        "Deployments": deployments[:max_projects],
    }


def dashboard_item_to_deployment(
    space_id, environments, projects, item, api_key, octopus_url
):
    channel = get_channel(space_id, item["ChannelId"], api_key, octopus_url)

    return {
        "SpaceId": space_id,
        "ProjectId": item["ProjectId"],
        "ProjectName": get_key_or_none(
            next(
                filter(lambda project: project["Id"] == item["ProjectId"], projects),
                None,
            ),
            "Name",
        ),
        "ReleaseVersion": item["ReleaseVersion"],
        "DeploymentId": item["DeploymentId"],
        "TaskId": item["TaskId"],
        "TenantId": item["TenantId"],
        "ReleaseId": item["ReleaseId"],
        "EnvironmentId": item["EnvironmentId"],
        "EnvironmentName": get_key_or_none(
            next(
                filter(lambda env: env["Id"] == item["EnvironmentId"], environments),
                None,
            ),
            "Name",
        ),
        "ChannelId": item["ChannelId"],
        "ChannelName": channel["Name"],
        "Created": item["Created"],
        "TaskState": item["State"],
        "TaskDuration": item["Duration"],
        # These fields are created in get_deployments_for_project but is not available in the dashboard
        # They are noted here to document the differences between these two data sets
        "ReleaseNotes": None,
        "DeployedBy": None,
    }
