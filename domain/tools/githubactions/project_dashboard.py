from domain.defaults.defaults import get_default_argument
from domain.lookup.octopus_lookups import lookup_space, lookup_projects
from domain.response.copilot_response import CopilotResponse
from domain.transformers.chat_responses import get_project_dashboard_response, get_project_tenant_progression_response
from infrastructure.octopus import get_project, get_project_progression, \
    get_project_tenant_dashboard


def get_project_dashboard_callback(github_user, log_query=None):
    def get_project_dashboard_callback_implementation(original_query, api_key, url, space_name, project_name):
        space_id, space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        if log_query:
            log_query("get_project_dashboard_callback_implementation", f"""
                Space: {space_name}
                Project Names: {sanitized_project_names[0]}""")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        response = []
        if project["TenantedDeploymentMode"] == "Untenanted":
            response.append(get_dashboard(space_id, space_name, project, api_key, url))
        else:
            response.append(get_tenanted_dashboard(space_id, space_name, project, api_key, url))

        # Debug mode shows the entities extracted from the query
        debug_text = []
        debug = get_default_argument(github_user, None, "Debug")
        if debug.casefold() == "true":
            debug_text.append(get_project_dashboard_callback_implementation.__name__
                              + " was called with the following parameters:"
                              + f"\n* Original Query: {original_query}"
                              + f"\n* Space: {space_name}"
                              + f"\n* Project: {project_name}")

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_project_dashboard_callback_implementation


def get_dashboard(space_id, space_name, project, api_key, url):
    progression = get_project_progression(space_id, project["Id"], api_key, url)
    return get_project_dashboard_response(space_name, project["Name"], progression)


def get_tenanted_dashboard(space_id, space_name, project, api_key, url):
    progression = get_project_tenant_dashboard(space_id, project["Id"], api_key, url)
    return get_project_tenant_progression_response(space_id, space_name, project["Name"], project["Id"],
                                                   progression["Dashboard"],
                                                   api_key, url)
