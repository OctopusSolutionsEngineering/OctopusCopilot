from datetime import datetime

import pytz

from domain.config.octopus import max_github_artifacts
from domain.date.date_difference import get_date_difference_summary
from domain.date.parse_dates import parse_unknown_format_date
from domain.sanitizers.sanitized_list import yield_first, flatten_list
from domain.view.markdown.markdown_icons import get_github_state_icon, get_state_icon
from infrastructure.octopus import get_channel_cached


def get_octopus_project_names_response(space_name, projects):
    """
    Provides a conversational response to the list of projects
    :param space_name: The name of the space containing the projects
    :param projects: The list of projects
    :return: A conversational response
    """

    if not projects and (space_name is None or not space_name.strip()):
        return "I found no projects."

    if not projects:
        return f"I found no projects in the space {space_name}."

    if space_name is None or not space_name.strip():
        return f"I found {len(projects)} projects:\n* " + "\n * ".join(projects)

    return (
        f'I found {len(projects)} projects in the space "{space_name.strip()}":\n* '
        + "\n* ".join(projects)
    )


def build_markdown_table_row(columns):
    """
    Builds a markdown table row
    :param columns: The columns
    :return: The markdown table row
    """
    if not columns:
        return ""
    return f"| {' | '.join(columns)} |\n"


def build_markdown_table_header_separator(count):
    """
    Builds a markdown table header separator
    :param count: The number of columns
    :return: The markdown table header separator
    """
    if count == 0:
        return ""

    columns = ["|"] * (count + 1)
    return "-".join(columns) + "\n"


def get_env_name(dashboard, environment_id):
    environment = next(
        filter(lambda e: e["Id"] == environment_id, dashboard["Environments"]), None
    )
    if not environment:
        return None
    return environment["Name"]


def get_dashboard_response(
    octopus_url,
    space_id,
    space_name,
    dashboard,
    github_actions=None,
    github_actions_status=None,
    pull_requests=None,
    issues=None,
):
    now = datetime.now(pytz.utc)
    table = f"# {space_name}\n\n"

    for project_group in dashboard["ProjectGroups"]:

        environment_names = []

        # If any projects have associated GitHub workflows, add the column to the start of the table
        if github_actions_status:
            environment_names.append("GitHub")

        environment_names.extend(
            list(
                filter(
                    # Filter out any None responses from get_env_name, which might be
                    # due to RBAC controls
                    lambda e: e,
                    map(
                        # Get the environment name for each environment ID
                        lambda e: get_env_name(dashboard, e),
                        project_group["EnvironmentIds"],
                    ),
                )
            )
        )

        columns = [project_group["Name"], *environment_names]
        table += build_markdown_table_row(columns)
        table += build_markdown_table_header_separator(len(columns))

        projects = list(
            filter(
                lambda p: p["ProjectGroupId"] == project_group["Id"],
                dashboard["Projects"],
            )
        )

        for project in projects:
            table += f"| {project['Name']} "

            # Find the github repo details
            github_repo = (
                next(
                    filter(
                        lambda x: x
                        and x["ProjectId"] == project["Id"]
                        and x["Repo"]
                        and x["Owner"],
                        github_actions,
                    ),
                    None,
                )
                if github_actions
                else None
            )

            # Get the GitHub Actions workflow status
            if github_actions_status:
                github_messages = []
                github_messages.extend(build_repo_link(github_repo))
                github_messages.extend(
                    get_project_workflow_status(github_actions_status, project["Id"])
                )
                github_messages.extend(
                    build_pr_response_for_project(
                        pull_requests, project["Id"], github_repo
                    )
                )
                github_messages.extend(
                    build_issue_response_for_project(issues, project["Id"], github_repo)
                )

                if github_messages:
                    table += f"| {'<br/>'.join(github_messages)}"
                else:
                    table += f"| ⨂ "

            # Get the deployment status
            for environment in project_group["EnvironmentIds"]:
                deployment = list(
                    filter(
                        lambda d: d["ProjectId"] == project["Id"]
                        and d["EnvironmentId"] == environment,
                        dashboard["Items"],
                    )
                )

                if len(deployment) > 0:
                    last_deployment = deployment[0]

                    created = parse_unknown_format_date(last_deployment["Created"])
                    difference = get_date_difference_summary(now - created)

                    icon = get_state_icon(
                        last_deployment["State"],
                        last_deployment["HasWarningsOrErrors"],
                        last_deployment["HasPendingInterruptions"],
                    )
                    url = build_deployment_url(
                        octopus_url,
                        space_id,
                        last_deployment["ProjectId"],
                        last_deployment["ReleaseVersion"],
                        last_deployment["DeploymentId"],
                    )

                    messages = [
                        f"{icon} [{last_deployment['ReleaseVersion']}]({url})",
                        f"⟲ {difference} ago",
                    ]

                    table += f"| {'<br/>'.join(messages)}"
                else:
                    table += f"| ⨂ "

            table += "|\n"
        table += "\n"

    return table


def get_project_dashboard_response(
    octopus_url,
    space_id,
    space_name,
    project_name,
    project_id,
    dashboard,
    channels,
    github_repo=None,
    github_actions_statuses=None,
    pull_requests=None,
    issues=None,
    release_workflow_runs=None,
    deployment_highlights=None,
):
    now = datetime.now(pytz.utc)

    table = f"# {space_name} / {project_name}\n\n"

    github_details = []
    github_details.extend(build_repo_link(github_repo))
    github_details.extend(
        get_project_workflow_status(github_actions_statuses, project_id)
    )
    github_details.extend(build_pr_response(pull_requests, github_repo))
    github_details.extend(build_issue_response(issues, github_repo))

    if github_details:
        table += "<br/>".join(github_details)

    for channel_id, environments in dashboard["ChannelEnvironments"].items():
        table += "\n\n"
        matching_channels = [
            channel for channel in channels if channel["Id"] == channel_id
        ]
        channel = matching_channels[0]

        if len(dashboard["ChannelEnvironments"]) > 1:
            table += f"### Channel: {channel['Name']}\n\n"

        environment_names = list(map(lambda e: e["Name"], environments))
        table += build_markdown_table_row(environment_names)
        table += build_markdown_table_header_separator(len(environment_names))

        for release in dashboard["Releases"]:
            if release["Channel"]["Id"] == channel_id:
                for environment in environments:
                    if environment["Id"] in release["Deployments"]:
                        # Get the latest deployment for the release. Redeploying a release can result in many
                        # deployments for an environment and a release.
                        for deployment in yield_first(
                            release["Deployments"][environment["Id"]]
                        ):
                            created = parse_unknown_format_date(deployment["Created"])
                            difference = get_date_difference_summary(now - created)
                            icon = get_state_icon(
                                deployment["State"],
                                deployment["HasWarningsOrErrors"],
                                deployment["HasPendingInterruptions"],
                            )

                            release_url = build_deployment_url(
                                octopus_url,
                                space_id,
                                deployment["ProjectId"],
                                deployment["ReleaseVersion"],
                                deployment["DeploymentId"],
                            )

                            release_details = [
                                f"{icon} [{deployment['ReleaseVersion']}]({release_url})"
                            ]

                            # Find any running steps
                            release_details.extend(
                                map(
                                    lambda x: "&ensp;" + x,
                                    get_running(
                                        deployment_highlights,
                                        deployment["DeploymentId"],
                                    ),
                                )
                            )

                            release_details.append(f"⟲ {difference} ago")

                            # Find any highlights in the logs
                            release_details.extend(
                                get_highlights(
                                    deployment_highlights, deployment["DeploymentId"]
                                )
                            )

                            # Find any artifacts in
                            release_details.extend(
                                get_artifacts(
                                    deployment_highlights,
                                    octopus_url,
                                    deployment["DeploymentId"],
                                )
                            )

                            # Find the associated GitHub workflow and build a link
                            release_details.extend(
                                get_workflow_link(
                                    release_workflow_runs, release["Release"]["Id"]
                                )
                            )

                            table += f"| {'<br/>'.join(release_details)}"

                    else:
                        table += "| ⨂ "
                table += "| \n"
    return table


def get_tenant_environments(tenant, dashboard, project_id):
    environments_ids = []

    for project_environment in dashboard["Environments"]:
        if tenant.get("Id"):
            # Tenants have a subset of environments they are associated with.
            # We retain the environment order of the project, and then check to see if
            # the project environment is associated with the tenant
            if project_environment["Id"] in tenant.get("ProjectEnvironments", {}).get(
                project_id, []
            ):
                # Add the project environment to the list
                environments_ids.append(project_environment["Id"])
        else:
            # Untenanted deployments just use project environments
            environments_ids.append(project_environment["Id"])

    return environments_ids


def get_tenant_environment_details(environments_ids, dashboard):
    environments = []
    for environment in environments_ids:
        environment_name = get_env_name(dashboard, environment)
        # Sometimes tenants will list environments that have no reference
        if environment_name:
            environments.append({"Name": environment_name, "Id": environment})

    return environments


def get_project_tenant_progression_response(
    space_id,
    space_name,
    project_name,
    project_id,
    dashboard,
    github_repo,
    github_actions_statuses,
    release_workflow_runs,
    pull_requests,
    issues,
    deployment_highlights,
    api_key,
    url,
):
    now = datetime.now(pytz.utc)

    table = f"# {space_name} / {project_name}\n\n"

    message = []
    message.extend(build_repo_link(github_repo))
    message.extend(get_project_workflow_status(github_actions_statuses, project_id))
    message.extend(build_pr_response(pull_requests, github_repo))
    message.extend(build_issue_response(issues, github_repo))

    if message:
        table += "<br/>".join(message) + "\n\n"

    for tenant in dashboard["Tenants"]:
        table += f"## {tenant['Name']}\n"
        environments_ids = get_tenant_environments(tenant, dashboard, project_id)
        environments = get_tenant_environment_details(environments_ids, dashboard)
        environment_names = list(map(lambda e: e["Name"], environments))
        table += build_markdown_table_row(environment_names)
        table += build_markdown_table_header_separator(len(environments))

        columns = []
        for environment in environments:
            found = False
            for deployment in dashboard["Items"]:
                # Note None == None, so the untenanted deployment will satisfy this condition because
                # the tenant has no ID and neither does the deployment
                tenanted = deployment.get("TenantId") == tenant.get("Id")
                environment_match = deployment.get("EnvironmentId") == environment.get(
                    "Id"
                )
                if environment_match and tenanted:
                    icon = get_state_icon(
                        deployment["State"],
                        deployment["HasWarningsOrErrors"],
                        deployment["HasPendingInterruptions"],
                    )
                    created = parse_unknown_format_date(deployment["Created"])
                    difference = get_date_difference_summary(now - created)
                    channel = get_channel_cached(
                        space_id, deployment["ChannelId"], api_key, url
                    )

                    release_url = build_deployment_url(
                        url,
                        space_id,
                        deployment["ProjectId"],
                        deployment["ReleaseVersion"],
                        deployment["DeploymentId"],
                    )

                    release_details = [
                        f"{icon} [{deployment['ReleaseVersion']}]({release_url})"
                    ]

                    # Find any running steps
                    release_details.extend(
                        map(
                            lambda x: "&ensp;" + x,
                            get_running(
                                deployment_highlights, deployment["DeploymentId"]
                            ),
                        )
                    )

                    release_details.extend(
                        [f"🔀 {channel['Name']}", f"⟲ {difference} ago"]
                    )

                    # Find any highlights in the logs
                    release_details.extend(
                        get_highlights(
                            deployment_highlights, deployment["DeploymentId"]
                        )
                    )

                    # Find any artifacts in
                    release_details.extend(
                        get_artifacts(
                            deployment_highlights, url, deployment["DeploymentId"]
                        )
                    )

                    # Find the associated github workflow and build a link
                    release_details.extend(
                        get_workflow_link(
                            release_workflow_runs, deployment["ReleaseId"]
                        )
                    )

                    columns.append("<br/>".join(release_details))
                    found = True
                    break

            if not found:
                columns.append("⨂")

        if columns:
            table += build_markdown_table_row(columns)
        else:
            table += "\nNo deployments"

        table += "\n\n"
    return table


def build_runbook_run_columns(dashboard, tenant, now, highlights, environments):
    # The first column is the tenant
    columns = [tenant]

    # Every environment is a column
    for environment in environments:
        # Get the runs for the tenant and environment
        runs = list(
            filter(
                lambda run: run["TenantId"] == tenant
                or (not run["TenantId"] and tenant == "Untenanted"),
                dashboard["RunbookRuns"][environment],
            )
        )

        if not runs:
            # A placeholder when no runs are found in that environment
            columns.append("⨂")
        else:
            run = runs[0]
            created = parse_unknown_format_date(run["Created"])
            difference = get_date_difference_summary(now - created)
            icon = get_state_icon(
                run["State"], run["HasWarningsOrErrors"], run["HasPendingInterruptions"]
            )

            task_highlights = [
                details["Highlights"]
                for details in highlights or []
                if details["TaskId"] == run["TaskId"]
            ]

            columns.append(
                "<br/>".join([icon + " " + difference + " ago", *task_highlights]),
            )

    return columns


def get_tenants(dashboard):
    tenants = []
    for environment in dashboard["RunbookRuns"]:
        runs = dashboard["RunbookRuns"][environment]
        for run in runs:
            tenant = "Untenanted" if not run["TenantId"] else run["TenantId"]
            if tenant not in tenants:
                tenants.append(tenant)
    return tenants


def get_runbook_dashboard_response(project, runbook, dashboard, highlights, get_tenant):
    dt = datetime.now(pytz.utc)

    table = f"{project['Name']} / {runbook['Name']}\n\n"

    tenants = get_tenants(dashboard)

    environment_ids = list(map(lambda x: x, dashboard["RunbookRuns"]))
    environment_names = list(
        filter(lambda e: e, map(lambda e: get_env_name(dashboard, e), environment_ids))
    )
    columns = ["", *environment_names]
    table += build_markdown_table_row(columns)
    table += build_markdown_table_header_separator(len(columns))

    # Build the execution rows
    for tenant in tenants:
        table += build_markdown_table_row(
            build_runbook_run_columns(
                dashboard, tenant, dt, highlights, environment_ids
            )
        )

    return table


def build_deployment_url(
    octopus_url, space_id, project_id, release_version, deployment_id
):
    return f"{octopus_url}/app#/{space_id}/projects/{project_id}/deployments/releases/{release_version}/deployments/{deployment_id}"


def get_project_workflow_status(github_actions_statuses, project_id):
    now = datetime.now(pytz.utc)
    message = []
    if github_actions_statuses:
        github_actions_status = next(
            filter(
                lambda x: x and x["ProjectId"] == project_id and x["Status"],
                github_actions_statuses,
            ),
            None,
        )

        if github_actions_status:
            message.append(
                f"{get_github_state_icon(github_actions_status.get('Status'), github_actions_status.get('Conclusion'))} "
                + f"[{github_actions_status.get('Name')} {github_actions_status.get('ShortSha')}]({github_actions_status.get('Url')}) "
                + f"(⟲ {get_date_difference_summary(now - github_actions_status.get('CreatedAt'))} ago)"
            )

            # Print any jobs currently running
            if github_actions_status.get("Jobs"):
                for job in github_actions_status.get("Jobs").get("jobs"):
                    if job.get("status") == "in_progress":
                        message.append("&ensp;" + build_job_status(job))
    return message


def build_job_status(job):
    now = datetime.now(pytz.utc)
    created = parse_unknown_format_date(job.get("started_at"))
    completed = parse_unknown_format_date(job.get("completed_at"))
    if completed and created:
        difference = f" (🕗 {get_date_difference_summary(completed - created)})"
    elif created:
        difference = f" (⟲ {get_date_difference_summary(now - created)} ago)"
    else:
        difference = ""
    return f"{get_github_state_icon(job.get('status'), job.get('conclusion'))} {job.get('name')}{difference}"


def build_pr_response_for_project(pull_requests, project_id, github_repo):
    if not pull_requests:
        return []

    status = next(filter(lambda x: x["ProjectId"] == project_id, pull_requests), None)
    return build_pr_response(status, github_repo)


def build_pr_response(pull_requests, github_repo):
    message = []
    if pull_requests and github_repo:
        message.append(
            f"🔁 [{pull_requests.get('Count')} PR{'s' if pull_requests.get('Count') != 1 else ''}](https://github.com/{github_repo['Owner']}/{github_repo['Repo']}/pulls)"
        )
    return message


def build_issue_response_for_project(issues, project_id, github_repo):
    if not issues:
        return []

    status = next(filter(lambda x: x["ProjectId"] == project_id, issues), None)
    return build_issue_response(status, github_repo)


def build_issue_response(issues, github_repo):
    message = []
    if issues and github_repo:
        message.append(
            f"🐛 [{issues.get('Count')} issue{'s' if issues.get('Count') != 1 else ''}](https://github.com/{github_repo['Owner']}/{github_repo['Repo']}/issues)"
        )
    return message


def build_repo_link(github_repo):
    message = []
    if github_repo and github_repo.get("Owner") and github_repo.get("Repo"):
        message.append(
            f'📑 [GitHub Repo](https://github.com/{github_repo["Owner"]}/{github_repo["Repo"]})'
        )
    return message


def get_workflow_link(release_workflow_runs, release_id):
    matching_releases = yield_first(
        filter(
            lambda x: x and x.get("ReleaseId") == release_id,
            release_workflow_runs or [],
        )
    )

    messages = []
    for release in matching_releases:
        messages.append(
            f"{get_github_state_icon(release.get('Status'), release.get('Conclusion'))} "
            + f"[{release.get('Name')} {release.get('ShortSha')}]({release.get('Url')})"
        )

        for artifact in release.get("Artifacts", [])[:max_github_artifacts]:
            messages.append(f"💾 [{artifact.get('Name')}]({artifact.get('Url')})")

    return messages


def get_artifact_links(release_workflow_artifacts, release_id):
    matching_artifacts = list(
        filter(
            lambda x: x and x.get("ReleaseId") == release_id,
            release_workflow_artifacts or [],
        )
    )

    return list(
        map(lambda x: f"💾 [{x.get('Name')}]({x.get('Url')})", matching_artifacts)
    )


def get_highlights(deployment_highlights, deployment_id):
    return list(
        map(
            lambda x: x["Highlights"],
            filter(
                lambda x: x and x["DeploymentId"] == deployment_id and x["Highlights"],
                deployment_highlights or [],
            ),
        )
    )


def get_running(deployment_highlights, deployment_id):
    return flatten_list(
        list(
            map(
                lambda x: x["Running"],
                filter(
                    lambda x: x and x["DeploymentId"] == deployment_id,
                    deployment_highlights or [],
                ),
            )
        )
    )


def get_artifacts(deployment_highlights, url, deployment_id):
    artifacts = flatten_list(
        list(
            map(
                lambda x: x["Artifacts"]["Items"],
                filter(
                    lambda x: x and x["DeploymentId"] == deployment_id,
                    deployment_highlights or [],
                ),
            )
        )
    )
    return list(
        map(lambda a: f"💾 [{a['Filename']}]({url}{a['Links']['Content']})", artifacts)
    )
