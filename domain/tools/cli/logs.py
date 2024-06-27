from domain.context.octopus_context import max_chars
from domain.converters.string_to_int import string_to_int
from domain.sanitizers.sanitized_list import get_item_or_none, sanitize_list, sanitize_log_steps, sanitize_log_lines
from infrastructure.octopus import get_deployment_logs, activity_logs_to_string
from infrastructure.openai import llm_message_query


def logs_cli_callback(api_key, url, get_default_argument, logging):
    def logs_callback_implementation(original_query, messages, space, projects, environments, channel, tenants, release,
                                     steps, lines):
        space = get_default_argument(space, 'Space')

        activity_logs, actual_release_version = get_deployment_logs(space, get_item_or_none(sanitize_list(projects), 0),
                                                                    get_item_or_none(sanitize_list(environments), 0),
                                                                    get_item_or_none(sanitize_list(tenants), 0),
                                                                    release,
                                                                    api_key,
                                                                    url)

        sanitized_steps = sanitize_log_steps(steps, original_query, activity_logs)

        logs = activity_logs_to_string(activity_logs, sanitized_steps)

        # Get the end of the logs if we have exceeded our context limit
        logs = logs[-max_chars:]

        # return the last n lines of the logs
        log_lines = sanitize_log_lines(string_to_int(lines), original_query)
        if log_lines and log_lines > 0:
            logs = "\n".join(logs.split("\n")[-log_lines:])

        context = {"input": original_query, "context": logs}

        return llm_message_query(messages, context, logging)

    return logs_callback_implementation
