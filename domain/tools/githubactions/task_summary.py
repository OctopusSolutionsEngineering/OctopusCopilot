from domain.lookup.octopus_lookups import lookup_space, lookup_projects, lookup_tenants, lookup_environments
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.tools.debug import get_params_message
from domain.view.markdown.octopus_task_summary import activity_logs_to_summary
from infrastructure.octopus import get_deployment_logs, get_artifacts, get_task_interruptions


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

        task, activity_logs, actual_release_version = timing_wrapper(
            lambda: get_deployment_logs(
                space_name,
                sanitized_project_names[0],
                sanitized_environment_names[0],
                get_item_or_none(sanitized_tenant_names, 0),
                release_version,
                api_key,
                url),
            "Deployment logs")

        artifacts = timing_wrapper(lambda: get_artifacts(space_id, task["Id"], api_key, url), "Artifacts")

        debug_text.extend(get_params_message(github_user,
                                             False,
                                             get_task_summary_callback_implementation.__name__,
                                             original_query=original_query,
                                             space_name=space_name,
                                             project_name=sanitized_project_names,
                                             environment_name=sanitized_environment_names,
                                             tenant_name=sanitized_tenant_names,
                                             release_version=actual_release_version))

        response = []
        interruptions = None

        # Check for interruptions
        if task['HasPendingInterruptions']:
            interruptions = get_task_interruptions(space_id, task['Id'], api_key, url)

        if interruptions is not None:
            first_interruption = interruptions[0]
            responsible_user = first_interruption["ResponsibleUserId"]
            response.extend(f"⚠️ **{first_interruption['Title']}**")
            response.extend(f'This task is waiting for **manual intervention**{"." if responsible_user is None else " and must be assigned before proceeding."}')
            response.extend(f'\n\n* [View task]({url}/app#/{space_id}/tasks/{task["Id"]}')

        response.extend(activity_logs_to_summary(activity_logs, url, artifacts))
        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_task_summary_callback_implementation
