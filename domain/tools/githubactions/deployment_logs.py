from domain.config.openai import max_log_lines
from domain.context.octopus_context import max_chars
from domain.converters.string_to_int import string_to_int
from domain.defaults.defaults import get_default_argument
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import (
    sanitize_name_fuzzy,
    sanitize_space,
    sanitize_projects,
    sanitize_names_fuzzy,
    get_item_or_none,
    sanitize_environments,
    sanitize_tenants,
    sanitize_log_steps,
    sanitize_log_lines,
    update_query,
)
from domain.tools.debug import get_params_message
from infrastructure.octopus import (
    get_spaces_generator,
    get_space_id_and_name_from_name,
    get_projects_generator,
    get_deployment_logs,
    activity_logs_to_string,
)
from infrastructure.openai import llm_message_query


def logs_callback(github_user, octopus_details, log_query):
    def logs_callback_implementation(
        original_query,
        messages,
        space,
        projects,
        environments,
        channel,
        tenants,
        release,
        steps,
        lines,
    ):

        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            logs_callback_implementation.__name__,
            original_query=original_query,
            space=space,
            projects=projects,
            environments=environments,
            channel=channel,
            tenants=tenants,
            release=release,
            steps=steps,
            lines=lines,
        )

        sanitized_space = sanitize_name_fuzzy(
            lambda: get_spaces_generator(api_key, url),
            sanitize_space(original_query, space),
        )

        space = get_default_argument(
            github_user,
            sanitized_space["matched"] if sanitized_space else None,
            "Space",
        )

        warnings = []

        if not space:
            space = next(get_spaces_generator(api_key, url), {"Name": "Default"}).get(
                "Name"
            )
            warnings.append(
                f"The query did not specify a space so the so the space named {space} was assumed."
            )

        space_id, actual_space_name = get_space_id_and_name_from_name(
            space, api_key, url
        )

        # The project from the query
        original_sanitized_projects = sanitize_projects(projects)

        # The closest project match
        sanitized_projects = sanitize_names_fuzzy(
            lambda: get_projects_generator(space_id, api_key, url),
            original_sanitized_projects,
        )

        # If we had a project in the query but nothing matched, it means there were no projects in the space
        # (or no projects that the user had access to).
        if original_sanitized_projects and len(sanitized_projects) == 0:
            return CopilotResponse("The space has no projects.")

        project = get_default_argument(
            github_user,
            get_item_or_none([project["matched"] for project in sanitized_projects], 0),
            "Project",
        )

        if not project:
            return CopilotResponse("Please specify a project name in the query.")

        environment = get_default_argument(
            github_user,
            get_item_or_none(sanitize_environments(original_query, environments), 0),
            "Environment",
        )
        tenant = get_default_argument(
            github_user, get_item_or_none(sanitize_tenants(tenants), 0), "Tenant"
        )

        _, activity_logs, actual_release_version = timing_wrapper(
            lambda: get_deployment_logs(
                space, project, environment, tenant, release, api_key, url
            ),
            "Deployment logs",
        )

        sanitized_steps = sanitize_log_steps(steps, original_query, activity_logs)

        logs = activity_logs_to_string(activity_logs, sanitized_steps)

        # Get the end of the logs if we have exceeded our context limit
        logs = logs[-max_chars:]

        # return the last n lines of the logs
        log_lines = sanitize_log_lines(string_to_int(lines), original_query)
        if log_lines and log_lines > 0:
            logs = "\n".join(logs.split("\n")[-log_lines:])

        if len(logs.split("\n")) > max_log_lines:
            warnings.append(
                f"The logs exceed {max_log_lines} lines. "
                + "This may impact the extension's ability to process them. "
                + "Consider reducing the number of lines requested "
                + f'e.g. `Show the last 100 lines from the deployment logs for the latest deployment of project "{project}".` '
                + f'or `Show me the the deployment logs for step 2 for the latest deployment of project "{project}".`'
            )

        log_query(
            "logs_callback",
            f"""
            Space: {space}
            Project Names: {project}
            Tenant Names: {tenant}
            Environment Names: {environments}
            Release Version: {actual_release_version}
            Channel Names: {channel}
            Steps: {sanitized_steps}
            Lines: {log_lines}""",
        )

        # This will show the entities that were selected after fuzzy matching and loading defaults
        debug_text.extend(
            get_params_message(
                github_user,
                False,
                logs_callback_implementation.__name__,
                original_query=original_query,
                space=space,
                projects=project,
                environments=environment,
                channel=channel,
                tenants=tenant,
                release=release,
                steps=sanitized_steps,
                lines=log_lines,
            )
        )

        processed_query = update_query(original_query, sanitized_projects)

        context = {"input": processed_query, "context": logs}

        response = [llm_message_query(messages, context, log_query)]
        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return logs_callback_implementation
