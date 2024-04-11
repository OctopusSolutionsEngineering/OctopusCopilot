from domain.sanitizers.sanitized_list import get_key_or_none
from infrastructure.octopus import get_dashboard


def get_deployments_from_dashboard(space_id, api_key, octopus_url):
    dashboard = get_dashboard(space_id, api_key, octopus_url)

    deployments = [dashboard_item_to_deployment(space_id, dashboard["Environments"], dashboard["Projects"], item) for
                   item in dashboard["Items"]]

    return {
        "Deployments": deployments,
    }


def dashboard_item_to_deployment(space_id, environments, projects, item):
    return {
        "SpaceId": space_id,
        "ProjectId": item["ProjectId"],
        "ProjectName": get_key_or_none(next(filter(lambda project: project["Id"] == item["ProjectId"], projects)),
                                       "Name"),
        "ReleaseVersion": item["ReleaseVersion"],
        "DeploymentId": item["DeploymentId"],
        "TaskId": item["TaskId"],
        "TenantId": item["TenantId"],
        "ReleaseId": item["ReleaseId"],
        "EnvironmentId": item["EnvironmentId"],
        "EnvironmentName": get_key_or_none(next(filter(lambda env: env["Id"] == item["EnvironmentId"], environments)),
                                           "Name"),
        "ChannelId": item["ChannelId"],
        "Created": item["Created"],
        "TaskState": item["State"],
        "TaskDuration": item["Duration"],
        # These fields are created in get_deployments_for_project but is not available in the dashboard
        # They are noted here to document the differences between these two data sets
        "ReleaseNotes": None,
        "DeployedBy": None,
    }
