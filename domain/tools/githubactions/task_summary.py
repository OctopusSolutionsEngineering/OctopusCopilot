from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_tenants, lookup_environments
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.tools.debug import get_params_message
from infrastructure.octopus import get_deployment_logs, activity_logs_to_summary


def get_task_summary_callback(github_user, api_key, url, log_query=None):
    def get_task_summary_callback_implementation(original_query, space_name, project_name,
                                                 environment_name, tenant_name, release_version):
        debug_text = get_params_message(github_user,
                                        True,
                                        get_task_summary_callback_implementation.__name__,
                                        original_query=original_query,
                                        space_name=space_name,
                                        project_name=project_name,
                                        environment_name=environment_name,
                                        tenant_name=tenant_name,
                                        release_version=release_version)

        space_id, space_name, warnings = lookup_space(url, api_key, github_user, original_query, space_name)
        sanitized_project_names, sanitized_projects = lookup_projects(url, api_key, github_user, original_query,
                                                                      space_id, project_name)
        sanitized_tenant_names = lookup_tenants(url, api_key, github_user, original_query, space_id, tenant_name)
        sanitized_environment_names = lookup_environments(url, api_key, github_user, original_query, space_id,
                                                          environment_name)

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        if log_query:
            log_query("get_task_summary_callback_implementation", f"""
                Space: {space_name}
                Project Name: {sanitized_project_names}
                Environment Name: {sanitized_environment_names}
                Tenant Name: {sanitized_tenant_names}""")

        debug_text.extend(get_params_message(github_user,
                                             False,
                                             get_task_summary_callback_implementation.__name__,
                                             original_query=original_query,
                                             space_name=space_name,
                                             project_name=sanitized_project_names,
                                             environment_name=sanitized_environment_names,
                                             tenant_name=sanitized_tenant_names,
                                             release_version=release_version))

        activity_logs = timing_wrapper(
            lambda: get_deployment_logs(
                space_name,
                sanitized_project_names[0],
                sanitized_environment_names[0],
                get_item_or_none(sanitized_tenant_names, 0),
                release_version,
                api_key,
                url),
            "Deployment logs")

        response = [activity_logs_to_summary(activity_logs)]
        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_task_summary_callback_implementation
