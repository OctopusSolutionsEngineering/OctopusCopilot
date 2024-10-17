import asyncio

from html_sanitizer import Sanitizer

from domain.defaults.defaults import get_default_argument
from domain.lookup.octopus_lookups import lookup_projects, lookup_runbooks
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space
from domain.tools.debug import get_params_message
from domain.view.markdown.markdown_dashboards import get_runbook_dashboard_response
from infrastructure.octopus import (
    get_spaces_generator,
    get_space_id_and_name_from_name,
    get_runbooks_dashboard,
    get_project,
    get_tenant,
    get_runbook_fuzzy,
    get_task_details_async,
    activity_logs_to_string,
    get_artifacts,
)


def get_runbook_dashboard_callback(github_user):
    async def get_runbook_dashboard_implementation_async(
        original_query, api_key, url, space_name, project_name, runbook_name
    ):
        debug_text = get_params_message(
            github_user,
            True,
            get_runbook_dashboard_implementation_async.__name__,
            original_query=original_query,
            space_name=space_name,
            project_name=project_name,
            runbook_name=runbook_name,
        )

        sanitized_space = sanitize_name_fuzzy(
            lambda: get_spaces_generator(api_key, url),
            sanitize_space(original_query, space_name),
        )

        space_name = get_default_argument(
            github_user,
            sanitized_space["matched"] if sanitized_space else None,
            "Space",
        )

        warnings = []

        if not space_name:
            space_name = next(
                get_spaces_generator(api_key, url), {"Name": "Default"}
            ).get("Name")
            warnings.append(
                f"The query did not specify a space so the so the space named {space_name} was assumed."
            )

        space_id, actual_space_name = get_space_id_and_name_from_name(
            space_name, api_key, url
        )

        sanitized_project_names, sanitized_projects = lookup_projects(
            url, api_key, github_user, original_query, space_id, project_name
        )

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_runbook_names = lookup_runbooks(
            url,
            api_key,
            github_user,
            original_query,
            space_id,
            project["Id"],
            runbook_name,
        )

        if not sanitized_runbook_names:
            return CopilotResponse("Please specify a runbook name in the query.")

        runbook = get_runbook_fuzzy(
            space_id, project["Id"], sanitized_runbook_names[0], api_key, url
        )

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                get_runbook_dashboard_implementation_async.__name__,
                original_query=original_query,
                space_name=space_name,
                project_name=sanitized_project_names[0],
                runbook_name=sanitized_runbook_names[0],
            )
        )

        dashboard = get_runbooks_dashboard(space_id, runbook["Id"], api_key, url)
        highlights = await get_dashboard_execution_highlights(
            space_id, dashboard, api_key, url, 5
        )
        response = [
            get_runbook_dashboard_response(
                project,
                runbook,
                dashboard,
                highlights,
                lambda x: get_tenant(space_id, x, api_key, url)["Name"],
            )
        ]

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    def get_runbook_dashboard_implementation(
        original_query, api_key, url, space_name, project_name, runbook_name
    ):
        """
        The async entrypoint for a tool called by the extension
        """
        return asyncio.run(
            get_runbook_dashboard_implementation_async(
                original_query, api_key, url, space_name, project_name, runbook_name
            )
        )

    return get_runbook_dashboard_implementation


async def get_dashboard_execution_highlights(
    space_id, progression, api_key, url, limit=0
):
    """
    Returns the deployment log highlights associated with deployments
    """

    deployment_highlights = []
    for environmentId, runs in progression["RunbookRuns"].items():
        for run in runs:
            deployment_highlights.append(
                map_execution_to_highlights(
                    space_id,
                    api_key,
                    url,
                    limit,
                    run["TaskId"],
                )
            )

    return await asyncio.gather(*deployment_highlights)


async def map_execution_to_highlights(space_id, api_key, url, limit, task_id):
    task = await get_task_details_async(space_id, task_id, api_key, url)
    highlights = activity_logs_to_string(
        task["ActivityLogs"],
        categories=["Highlight"],
        join_string="<br/>",
        include_name=False,
    )

    artifacts = get_artifacts(space_id, task["Task"]["Id"], api_key, url)

    if limit != 0:
        highlights = "\n".join(highlights.split("\n")[:limit])

    sanitized_highlights = Sanitizer().sanitize(highlights)
    return {
        "TaskId": task_id,
        "Highlights": sanitized_highlights,
        "Artifacts": artifacts,
    }
