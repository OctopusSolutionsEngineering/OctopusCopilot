from domain.sanitizers.sanitized_list import get_item_or_none, sanitize_list
from domain.view.markdown.octopus_task_summary import activity_logs_to_summary
from infrastructure.octopus import get_deployment_logs


def get_task_summary_cli_callback(api_key, url, get_default_argument, log_query=None):
    def get_task_summary_callback_implementation(original_query, space_name, project_name,
                                                 environment_name, tenant_name, release_version):
        space_name = get_default_argument(space_name, 'Space')

        task, activity_logs, actual_release_version = get_deployment_logs(space_name,
                                                                          get_item_or_none(sanitize_list(project_name),
                                                                                           0),
                                                                          get_item_or_none(
                                                                              sanitize_list(environment_name),
                                                                              0),
                                                                          get_item_or_none(sanitize_list(tenant_name),
                                                                                           0),
                                                                          release_version,
                                                                          api_key,
                                                                          url)
        # TODO: Add pending interruptions calls
        return activity_logs_to_summary(activity_logs, url)

    return get_task_summary_callback_implementation
