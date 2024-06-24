from domain.defaults.defaults import get_default_argument
from domain.logging.app_logging import configure_logging
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import sanitize_name_fuzzy, sanitize_space
from domain.tools.debug import get_params_message
from domain.transformers.chat_responses import get_dashboard_response
from infrastructure.github import try_get_workflow_run
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
            filtered_github_actions = filter(lambda x: x["Owner"] and x["Repo"] and x["Workflow"], github_actions)
            github_actions_status = list(map(
                lambda x: {"ProjectId": x["ProjectId"],
                           # Spread the status (or a black object if not workflow was found)
                           # from the list of workflow runs. This is where we map the incoming data to the expected
                           # fields that ware used by the dashboard generation script.

                           # There is a lot that can go wrong here: there may be no workflow runs, there may be
                           # an exception raised with the API request, etc. Most of this logic here is dealing with
                           # empty arrays and empty responses.
                           **next(({"Status": i.get("status"), "Sha": i.get("head_sha"), "Name": i.get("name")} for i in
                                   try_get_workflow_run(x["Owner"], x["Repo"], x["Workflow"], github_token).get(
                                       "workflow_runs", [])),
                                  # If nothing was returned, return an empty object
                                  {"Status": "", "Sha": "", "Name": ""})},
                filtered_github_actions))
        except Exception as e:
            # We make every attempt to allow the requests to the GitHub API to fail. But if there was an unexpected
            # exception, silently fail
            logger.error(e)
            github_actions_status = None

        response = [get_dashboard_response(actual_space_name, dashboard, github_actions_status)]

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_dashboard_callback_implementation
