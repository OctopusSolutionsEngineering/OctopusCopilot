import asyncio

from domain.config.octopus import max_projects_for_github_links
from domain.date.parse_dates import parse_unknown_format_date
from domain.defaults.defaults import get_default_argument
from domain.exceptions.none_on_exception import none_on_exception
from domain.logging.app_logging import configure_logging
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space
from domain.tools.debug import get_params_message
from domain.view.markdown.markdown_dashboards import get_dashboard_response
from infrastructure.github import (
    get_latest_workflow_run_async,
    get_open_pull_requests_async,
    get_open_issues_async,
    get_workflow_artifacts_async,
    get_run_jobs_async,
)
from infrastructure.octopus import (
    get_spaces_generator,
    get_space_id_and_name_from_name,
    get_dashboard,
    get_project_github_workflow,
)

logger = configure_logging(__name__)


def get_dashboard_callback(github_token_func, github_user_func, log_query=None):
    def get_dashboard_callback_implementation(original_query, api_key, url, space_name):
        github_user = github_user_func()
        github_token = github_token_func()

        debug_text = get_params_message(
            github_user,
            True,
            get_dashboard_callback_implementation.__name__,
            original_query=original_query,
            space_name=space_name,
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

        if log_query:
            log_query(
                "get_dashboard_callback_implementation",
                f"""
                Space: {space_name}""",
            )

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                get_dashboard_callback_implementation.__name__,
                original_query=original_query,
                space_name=space_name,
            )
        )

        space_id, actual_space_name = get_space_id_and_name_from_name(
            space_name, api_key, url
        )
        dashboard = get_dashboard(space_id, api_key, url)

        # Get the dashboard GitHub data
        projects = dashboard["Projects"]
        github_actions = (
            none_on_exception(
                lambda: list(
                    filter(
                        lambda x: x,
                        map(
                            lambda x: get_project_github_workflow(
                                space_id, x["Id"], api_key, url
                            ),
                            projects,
                        ),
                    )
                )
            )
            if len(projects) <= max_projects_for_github_links
            else []
        )
        github_actions_status = none_on_exception(
            lambda: asyncio.run(get_all_workflow_status(github_actions, github_token))
        )
        pull_requests = none_on_exception(
            lambda: asyncio.run(get_all_prs(github_actions, github_token))
        )
        issues = none_on_exception(
            lambda: asyncio.run(get_all_issues(github_actions, github_token))
        )

        response = [
            get_dashboard_response(
                url,
                space_id,
                actual_space_name,
                dashboard,
                github_actions,
                github_actions_status,
                pull_requests,
                issues,
            )
        ]

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_dashboard_callback_implementation


async def get_workflow_status(project_id, owner, repo, workflow, github_token):
    try:
        workflow = await get_latest_workflow_run_async(
            owner, repo, workflow, github_token
        )
        if workflow.get("workflow_runs", []):
            first_workflow = workflow["workflow_runs"][0]
            artifacts, jobs = await asyncio.gather(
                get_workflow_artifacts_async(
                    owner, repo, str(first_workflow.get("id")), github_token
                ),
                get_run_jobs_async(
                    owner, repo, str(first_workflow.get("id")), github_token
                ),
            )
            return {
                "ProjectId": project_id,
                "Status": first_workflow.get("status"),
                "CreatedAt": parse_unknown_format_date(
                    first_workflow.get("created_at")
                ),
                "Conclusion": first_workflow.get("conclusion"),
                "Sha": first_workflow.get("head_sha"),
                "ShortSha": first_workflow.get("head_sha")[:7],
                "Name": first_workflow.get("name"),
                "Url": first_workflow.get("html_url"),
                "Artifacts": list(
                    map(
                        lambda x: {
                            "Name": x.get("name"),
                            "Url": f"https://github.com/{owner}/{repo}/actions/runs/{first_workflow.get('id')}/artifacts/{x.get('id')}",
                        },
                        artifacts["artifacts"],
                    )
                ),
                "Jobs": jobs,
            }
    except Exception as e:
        logger.error(e)
    return None


async def get_all_workflow_status(github_actions, github_token):
    if not github_actions:
        return []

    filtered_github_actions = filter(
        lambda x: x
        and x.get("Owner")
        and x.get("Repo")
        and x.get("Workflow")
        and x.get("ProjectId"),
        github_actions,
    )

    return await asyncio.gather(
        *[
            get_workflow_status(
                x["ProjectId"], x["Owner"], x["Repo"], x["Workflow"], github_token
            )
            for x in filtered_github_actions
        ]
    )


async def get_all_prs(github_actions, github_token):
    if not github_actions:
        return []

    async def map_project_to_pr_count(project_id, owner, repo):
        try:
            prs = await get_open_pull_requests_async(owner, repo, github_token)
        except Exception as e:
            return {"ProjectId": project_id, "Count": 0}
        return {"ProjectId": project_id, "Count": len(prs)}

    filtered_github_actions = filter(
        lambda x: x and x.get("Owner") and x.get("Repo") and x.get("ProjectId"),
        github_actions,
    )

    return await asyncio.gather(
        *[
            map_project_to_pr_count(x["ProjectId"], x["Owner"], x["Repo"])
            for x in filtered_github_actions
        ]
    )


async def get_all_issues(github_actions, github_token):
    if not github_actions:
        return []

    async def map_project_to_issue_count(project_id, owner, repo):
        try:
            prs = await get_open_issues_async(owner, repo, github_token)
        except Exception as e:
            return {"ProjectId": project_id, "Count": 0}
        return {"ProjectId": project_id, "Count": len(prs)}

    filtered_github_actions = filter(
        lambda x: x and x.get("Owner") and x.get("Repo") and x.get("ProjectId"),
        github_actions,
    )

    return await asyncio.gather(
        *[
            map_project_to_issue_count(x["ProjectId"], x["Owner"], x["Repo"])
            for x in filtered_github_actions
        ]
    )
