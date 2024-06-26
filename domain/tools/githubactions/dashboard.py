import asyncio

from domain.date.parse_dates import parse_unknown_format_date
from domain.defaults.defaults import get_default_argument
from domain.logging.app_logging import configure_logging
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space
from domain.tools.debug import get_params_message
from domain.transformers.chat_responses import get_dashboard_response
from infrastructure.github import get_latest_workflow_run_async
from infrastructure.octopus import get_spaces_generator, get_space_id_and_name_from_name, get_dashboard, \
    get_project_github_workflow

logger = configure_logging(__name__)


def get_dashboard_callback(github_token, github_user, log_query=None):
    def get_dashboard_callback_implementation(original_query, api_key, url, space_name):
        debug_text = get_params_message(github_user, True, get_dashboard_callback_implementation.__name__,
                                        original_query=original_query,
                                        space_name=space_name)

        sanitized_space = sanitize_name_fuzzy(lambda: get_spaces_generator(api_key, url),
                                              sanitize_space(original_query, space_name))

        space_name = get_default_argument(github_user,
                                          sanitized_space["matched"] if sanitized_space else None, "Space")

        warnings = []

        if not space_name:
            space_name = next(get_spaces_generator(api_key, url), {"Name": "Default"}).get("Name")
            warnings.append(f"The query did not specify a space so the so the space named {space_name} was assumed.")

        if log_query:
            log_query("get_dashboard_callback_implementation", f"""
                Space: {space_name}""")

        debug_text.extend(get_params_message(github_user, False, get_dashboard_callback_implementation.__name__,
                                             original_query=original_query,
                                             space_name=space_name))

        space_id, actual_space_name = get_space_id_and_name_from_name(space_name, api_key, url)
        dashboard = get_dashboard(space_id, api_key, url)

        # Attempt to get additional metadata about github action
        try:
            github_actions = map(
                lambda x: get_project_github_workflow(space_id, x["Id"], api_key, url),
                dashboard["Projects"])

            # Limit the results to projects that have the correct metadata
            filtered_github_actions = filter(lambda x: x["Owner"] and x["Repo"] and x["Workflow"], github_actions)

            # Call the GitHub API to get the workflow status
            github_actions_status = asyncio.run(get_all_workflow_status(filtered_github_actions, github_token))
        except Exception as e:
            # We make every attempt to allow the requests to the GitHub API to fail. But if there was an unexpected
            # exception, silently fail
            logger.error(e)
            github_actions = None
            github_actions_status = None

        response = [
            get_dashboard_response(url, space_id, actual_space_name, dashboard, github_actions, github_actions_status)]

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_dashboard_callback_implementation


async def get_workflow_status(project_id, owner, repo, workflow, github_token):
    try:
        workflow = await get_latest_workflow_run_async(owner, repo, workflow, github_token)
        if workflow.get("workflow_runs", []):
            first_workflow = workflow["workflow_runs"][0]
            return {"ProjectId": project_id,
                    "Status": first_workflow.get("status"),
                    "CreatedAt": parse_unknown_format_date(first_workflow.get("created_at")),
                    "Conclusion": first_workflow.get("conclusion"),
                    "Sha": first_workflow.get("head_sha"),
                    "ShortSha": first_workflow.get("head_sha")[:7],
                    "Name": first_workflow.get("name"),
                    "Url": first_workflow.get("html_url")}
    except Exception as e:
        # Silent fail, and fall back to returning blank result
        pass
    return {"ProjectId": project_id, "Status": "", "Sha": "", "Name": "", "Url": "", "ShortSha": "", "Conclusion": ""}


async def get_all_workflow_status(github_actions, github_token):
    if not github_actions:
        return []

    filtered_github_actions = filter(
        lambda x: x and x.get("Owner") and x.get("Repo") and x.get("Workflow") and x.get("ProjectId"), github_actions)

    return await asyncio.gather(
        *[get_workflow_status(x["ProjectId"], x["Owner"], x["Repo"], x["Workflow"], github_token) for x in
          filtered_github_actions])
