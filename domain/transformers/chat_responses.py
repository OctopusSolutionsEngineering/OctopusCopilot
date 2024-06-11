from datetime import datetime

import pytz

from domain.date.date_difference import get_date_difference_summary
from domain.date.parse_dates import parse_unknown_format_date


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

    return f"I found {len(projects)} projects in the space \"{space_name.strip()}\":\n* " + "\n* ".join(projects)


def build_markdown_table_row(columns):
    """
    Builds a markdown table row
    :param columns: The columns
    :return: The markdown table row
    """
    return f"| {' | '.join(columns)} |\n"


def build_markdown_table_header_separator(count):
    """
    Builds a markdown table header separator
    :param count: The number of columns
    :return: The markdown table header separator
    """
    columns = ["|"] * (count + 1)
    return "-".join(columns) + "\n"


def get_env_name(dashboard, environment_id):
    environment = next(filter(lambda e: e["Id"] == environment_id, dashboard["Environments"]), None)
    if not environment:
        return None
    return environment["Name"]


def get_dashboard_response(space_name, dashboard):
    table = f"{space_name}\n\n"

    for project_group in dashboard["ProjectGroups"]:

        environment_names = list(map(lambda e: get_env_name(dashboard, e), project_group["EnvironmentIds"]))
        columns = [project_group['Name'], *environment_names]
        table += build_markdown_table_row(columns)
        table += build_markdown_table_header_separator(len(columns))

        projects = list(filter(lambda p: p["ProjectGroupId"] == project_group["Id"], dashboard["Projects"]))

        for project in projects:
            table += f"| {project['Name']} "

            for environment in project_group["EnvironmentIds"]:
                deployment = list(
                    filter(lambda d: d["ProjectId"] == project["Id"] and d["EnvironmentId"] == environment,
                           dashboard["Items"]))

                if len(deployment) > 0:
                    last_deployment = deployment[0]
                    icon = get_state_icon(last_deployment['State'], last_deployment['HasWarningsOrErrors'])
                    table += f"| {icon} {last_deployment['ReleaseVersion']}"
                else:
                    table += f"|  "

            table += "|\n"
        table += "|\n\n"
    return table


def build_runbook_run_columns(run, now, get_tenant):
    tenant_name = 'Untenanted' if not run['TenantId'] else get_tenant(run['TenantId'])
    created = parse_unknown_format_date(run["Created"])
    difference = get_date_difference_summary(now - created)
    icon = get_state_icon(run['State'], run['HasWarningsOrErrors'])
    return [tenant_name, icon + " " + difference + " ago"]


def get_tenants(dashboard):
    tenants = []
    for environment in dashboard["RunbookRuns"]:
        runs = dashboard["RunbookRuns"][environment]
        for run in runs:
            tenant = "Untenanted" if not run['TenantId'] else run['TenantId']
            if tenant not in tenants:
                tenants.append(tenant)
    return tenants


def get_runbook_dashboard_response(project, runbook, dashboard, get_tenant):
    dt = datetime.now(pytz.utc)

    table = f"{project['Name']} / {runbook['Name']}\n\n"

    tenants = get_tenants(dashboard)

    environment_ids = list(map(lambda x: x, dashboard["RunbookRuns"]))
    environment_names = list(map(lambda e: get_env_name(dashboard, e), environment_ids))
    columns = ["", *environment_names]
    table += build_markdown_table_row(columns)
    table += build_markdown_table_header_separator(len(columns))

    # Build the execution rows
    for tenant in tenants:
        for environment in environment_ids:
            runs = list(
                filter(lambda run: run['TenantId'] == tenant or (not run['TenantId'] and tenant == "Untenanted"),
                       dashboard["RunbookRuns"][environment]))
            for run in runs:
                table += build_markdown_table_row(build_runbook_run_columns(run, dt, get_tenant))

    return table


def get_state_icon(state, has_warnings):
    if state == "Executing":
        return "🔵"

    if state == "Success":
        if has_warnings:
            return "🟡"
        else:
            return "🟢"

    elif state == "Failed":
        return "🔴"

    if state == "Canceled":
        return "⚪"

    elif state == "TimedOut":
        return "🔴"

    elif state == "Cancelling":
        return "🔴"

    elif state == "Queued":
        return "🟣"

    return "⚪"
