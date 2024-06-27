import asyncio

from html_sanitizer import Sanitizer

from domain.config.octopus import max_highlight_links_on_dashboard, max_release_for_github_links
from domain.date.parse_dates import parse_unknown_format_date
from domain.exceptions.none_on_exception import none_on_exception
from domain.logging.app_logging import configure_logging
from domain.lookup.octopus_lookups import lookup_space, lookup_projects
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import flatten_list
from domain.tools.debug import get_params_message
from domain.tools.githubactions.dashboard import get_all_workflow_status
from domain.transformers.chat_responses import get_project_dashboard_response, get_project_tenant_progression_response
from infrastructure.github import get_workflow_run_async, get_open_pull_requests_async, get_open_issues_async, \
    get_workflow_artifacts_async
from infrastructure.octopus import get_project, get_project_progression, \
    get_project_tenant_dashboard, get_release_github_workflow_async, get_task_details_async, activity_logs_to_string, \
    get_project_github_workflow

logger = configure_logging(__name__)


def get_project_dashboard_callback(github_user, github_token, log_query=None):
    def get_project_dashboard_callback_implementation(original_query, api_key, url, space_name, project_name):
        debug_text = get_params_message(github_user, True,
                                        get_project_dashboard_callback_implementation.__name__,
                                        original_query=original_query,
                                        space_name=space_name,
                                        project_name=project_name)
        space_id, space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        if log_query:
            log_query("get_project_dashboard_callback_implementation", f"""
                Space: {space_name}
                Project Names: {sanitized_project_names[0]}""")

        debug_text.extend(get_params_message(github_user, False,
                                             get_project_dashboard_callback_implementation.__name__,
                                             original_query=original_query,
                                             space_name=space_name,
                                             project_name=sanitized_project_names[0]))

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        response = []
        if project["TenantedDeploymentMode"] == "Untenanted":
            response.append(get_dashboard(space_id, space_name, project, api_key, url, github_token))
        else:
            response.append(get_tenanted_dashboard(space_id, space_name, project, api_key, url, github_token))

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_project_dashboard_callback_implementation


def get_dashboard(space_id, space_name, project, api_key, url, github_token):
    progression = get_project_progression(space_id, project["Id"], api_key, url)

    github_action = none_on_exception(lambda: get_project_github_workflow(space_id, project["Id"], api_key, url))
    github_actions_status = none_on_exception(
        lambda: asyncio.run(get_all_workflow_status([github_action], github_token)))
    release_workflows = none_on_exception(
        lambda: asyncio.run(get_dashboard_release_workflows(space_id, progression, api_key, url)))
    release_workflow_runs = none_on_exception(
        lambda: asyncio.run(get_release_workflow_runs(release_workflows, github_token)))
    release_workflow_artifacts = none_on_exception(
        lambda: asyncio.run(get_release_workflow_artifacts(release_workflows, github_token)))

    # Get details about pull requests
    try:
        project_prs = asyncio.run(
            get_open_pull_requests_async(github_action["Owner"], github_action["Repo"], github_token))
        pull_requests = {"ProjectId": project["Id"], "Count": len(project_prs)}
    except Exception as e:
        logger.error(e)
        pull_requests = {"ProjectId": project["Id"], "Count": 0}

    # Get details about issues
    try:
        project_issues = asyncio.run(
            get_open_issues_async(github_action["Owner"], github_action["Repo"], github_token))
        issues = {"ProjectId": project["Id"], "Count": len(project_issues)}
    except Exception as e:
        logger.error(e)
        issues = {"ProjectId": project["Id"], "Count": 0}

    try:
        deployment_highlights = asyncio.run(
            get_dashboard_deployment_highlights(space_id, progression, api_key, url, max_highlight_links_on_dashboard))
    except Exception as e:
        logger.error(e)
        deployment_highlights = None

    return get_project_dashboard_response(url, space_id, space_name, project["Name"], project["Id"], progression,
                                          github_action, github_actions_status,
                                          pull_requests, issues, release_workflow_runs, release_workflow_artifacts,
                                          deployment_highlights)


async def get_tenanted_dashboard_release_workflows(space_id, progression, api_key, url):
    """
    Return the details of the associated GitHub workflow from the release notes of each release.
    """
    unique_list = list(
        next(item for item in progression["Releases"] if item["ReleaseId"] == release_id) for release_id in
        set(item["ReleaseId"] for item in progression["Items"]))

    return await asyncio.gather(
        *[get_release_github_workflow_async(space_id, x["ReleaseId"], api_key, url) for x in
          unique_list]) if len(unique_list) <= max_release_for_github_links else []


async def get_tenanted_dashboard_deployment_highlights(space_id, progression, api_key, url):
    """
    Returns the deployment log highlights associated with deployments
    """

    async def map_deployment_to_highlights(deployment_id, task_id):
        task = await get_task_details_async(space_id, task_id, api_key, url)
        highlights = activity_logs_to_string(task["ActivityLogs"], categories=["Highlight"], join_string="<br/>",
                                             include_name=False)
        return {"DeploymentId": deployment_id, "Highlights": highlights}

    return await asyncio.gather(
        *[map_deployment_to_highlights(x["DeploymentId"], x["TaskId"]) for x in
          progression["Items"]])


async def get_dashboard_release_workflows(space_id, progression, api_key, url):
    """
    Return the details of the associated GitHub workflow from the release notes of each release.
    """
    # Process each release only once
    unique_list = list(
        next(item for item in progression["Releases"] if item["Release"]["Id"] == release_id) for release_id in
        set(item["Release"]["Id"] for item in progression["Releases"]))

    return await asyncio.gather(
        *[get_release_github_workflow_async(space_id, x["Release"]["Id"], api_key, url) for x in
          unique_list]) if len(unique_list) <= max_release_for_github_links else []


async def get_dashboard_deployment_highlights(space_id, progression, api_key, url, limit=0):
    """
    Returns the deployment log highlights associated with deployments
    """

    async def map_deployment_to_highlights(deployment_id, task_id):
        task = await get_task_details_async(space_id, task_id, api_key, url)
        highlights = activity_logs_to_string(task["ActivityLogs"], categories=["Highlight"], join_string="<br/>",
                                             include_name=False)
        if limit != 0:
            highlights = "\n".join(highlights.split("\n")[:limit])

        sanitized_highlights = Sanitizer().sanitize(highlights)
        return {"DeploymentId": deployment_id, "Highlights": sanitized_highlights}

    deployment_highlights = []
    for environment in progression["Environments"]:
        for release in progression["Releases"]:
            if environment["Id"] in release["Deployments"]:
                deployments = release["Deployments"][environment["Id"]]
                for deployment in deployments:
                    deployment_highlights.append(
                        map_deployment_to_highlights(deployment["DeploymentId"], deployment["TaskId"]))

    return await asyncio.gather(*deployment_highlights)


async def get_release_workflow_runs(release_workflows, github_token):
    """
    Return the status of the workflow runs for each release.
    """
    return await asyncio.gather(
        *[get_workflow_status(x["ReleaseId"], x["Owner"], x["Repo"], x["RunId"], github_token) for x in
          release_workflows]) if release_workflows else []


async def get_workflow_status(release_id, owner, repo, run_id, github_token):
    try:
        workflow = await get_workflow_run_async(owner, repo, run_id, github_token)
        return {"ReleaseId": release_id,
                "Status": workflow.get("status"),
                "CreatedAt": parse_unknown_format_date(workflow.get("created_at")),
                "Conclusion": workflow.get("conclusion"),
                "Sha": workflow.get("head_sha"),
                "ShortSha": workflow.get("head_sha")[:7],
                "Name": workflow.get("name"),
                "Url": workflow.get("html_url")}
    except Exception as e:
        # Silent fail, and fall back to returning blank result
        logger.error(e)
    return None


async def get_release_workflow_artifacts(release_workflows, github_token):
    """
    Return the status of the workflow runs for each release.
    """
    return flatten_list(await asyncio.gather(
        *[get_workflow_artifacts(x["ReleaseId"], x["Owner"], x["Repo"], x["RunId"], github_token) for x in
          release_workflows]) if release_workflows else [])


async def get_workflow_artifacts(release_id, owner, repo, run_id, github_token):
    try:
        artifacts = await get_workflow_artifacts_async(owner, repo, run_id, github_token)
        return list(
            map(lambda x: {"ReleaseId": release_id, "Name": x.get("name"), "Url": x.get("archive_download_url")},
                artifacts["artifacts"]))
    except Exception as e:
        # Silent fail, and fall back to returning blank result
        logger.error(e)
    return []


def get_tenanted_dashboard(space_id, space_name, project, api_key, url, github_token):
    progression = get_project_tenant_dashboard(space_id, project["Id"], api_key, url)

    # We tolerate API requests failing, so we can still return a response with as much information
    # as we could successfully retrieve
    github_action = none_on_exception(lambda: get_project_github_workflow(space_id, project["Id"], api_key, url))
    github_actions_status = none_on_exception(
        lambda: asyncio.run(get_all_workflow_status([github_action], github_token)))
    release_workflows = none_on_exception(lambda: asyncio.run(
        get_tenanted_dashboard_release_workflows(space_id, progression["Dashboard"], api_key, url)))
    release_workflow_runs = none_on_exception(
        lambda: asyncio.run(get_release_workflow_runs(release_workflows, github_token)))
    release_workflow_artifacts = none_on_exception(
        lambda: asyncio.run(get_release_workflow_artifacts(release_workflows, github_token)))

    # Get details about pull requests
    try:
        project_prs = asyncio.run(
            get_open_pull_requests_async(github_action["Owner"], github_action["Repo"], github_token))
        pull_requests = {"ProjectId": project["Id"], "Count": len(project_prs)}
    except Exception as e:
        logger.error(e)
        pull_requests = {"ProjectId": project["Id"], "Count": 0}

    # Get details about issues
    try:
        project_issues = asyncio.run(
            get_open_issues_async(github_action["Owner"], github_action["Repo"], github_token))
        issues = {"ProjectId": project["Id"], "Count": len(project_issues)}
    except Exception as e:
        logger.error(e)
        issues = {"ProjectId": project["Id"], "Count": 0}

    try:
        deployment_highlights = asyncio.run(
            get_tenanted_dashboard_deployment_highlights(space_id, progression["Dashboard"], api_key, url))
    except Exception as e:
        logger.error(e)
        deployment_highlights = None

    return get_project_tenant_progression_response(space_id,
                                                   space_name,
                                                   project["Name"],
                                                   project["Id"],
                                                   progression["Dashboard"],
                                                   github_action,
                                                   github_actions_status,
                                                   release_workflow_runs,
                                                   release_workflow_artifacts,
                                                   pull_requests,
                                                   issues,
                                                   deployment_highlights,
                                                   api_key,
                                                   url)
