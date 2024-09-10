from domain.config.openai import max_log_lines
from domain.context.octopus_context import max_chars
from domain.converters.string_to_int import string_to_int
from domain.lookup.octopus_lookups import (
    lookup_runbooks,
    lookup_projects,
    lookup_tenants,
    lookup_environments,
    lookup_space,
)
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import (
    sanitize_log_steps,
    sanitize_log_lines,
    update_query,
)
from domain.tools.debug import get_params_message
from infrastructure.octopus import (
    get_runbook_deployment_logs,
    activity_logs_to_string,
    get_project,
)
from infrastructure.openai import llm_message_query


def get_runbook_logs_wrapper(github_user, octopus_details, log_query):
    def runbook_logs_implementation(
        original_query,
        messages,
        space,
        project,
        runbook,
        environments,
        tenants,
        steps,
        lines,
    ):

        if log_query:
            log_query("Enter:", "runbook_logs_implementation")

        api_key, url = octopus_details()

        debug_text = get_params_message(
            github_user,
            True,
            runbook_logs_implementation.__name__,
            original_query=original_query,
            space=space,
            project=project,
            runbook=runbook,
            environments=environments,
            tenants=tenants,
            steps=steps,
            lines=lines,
        )

        space_id, actual_space_name, warnings = lookup_space(
            url, api_key, github_user, original_query, space
        )
        sanitized_project_names, sanitized_projects = lookup_projects(
            url, api_key, github_user, original_query, space_id, project
        )

        if not sanitized_project_names:
            return CopilotResponse("Please specify a project name in the query.")

        project = get_project(space_id, sanitized_project_names[0], api_key, url)

        sanitized_runbook_names = lookup_runbooks(
            url, api_key, github_user, original_query, space_id, project["Id"], runbook
        )

        if not sanitized_runbook_names:
            return CopilotResponse("Please specify a runbook name in the query.")

        sanitized_environment_names = lookup_environments(
            url, api_key, github_user, original_query, space_id, environments
        )

        if not sanitized_environment_names:
            return CopilotResponse("Please specify an environment name in the query.")

        sanitized_tenant_names = lookup_tenants(
            url, api_key, github_user, original_query, space_id, tenants
        )

        _, activity_logs = timing_wrapper(
            lambda: get_runbook_deployment_logs(
                actual_space_name,
                sanitized_project_names[0],
                sanitized_runbook_names[0],
                sanitized_environment_names[0],
                sanitized_tenant_names[0] if sanitized_tenant_names else None,
                api_key,
                url,
            ),
            "Runbook logs",
        )

        sanitized_steps = sanitize_log_steps(steps, original_query, activity_logs)

        debug_text.extend(
            get_params_message(
                github_user,
                False,
                runbook_logs_implementation.__name__,
                original_query=original_query,
                space=actual_space_name,
                project=sanitized_project_names[0],
                runbook=sanitized_runbook_names[0],
                environments=sanitized_environment_names[0],
                tenants=sanitized_tenant_names[0] if sanitized_tenant_names else None,
                steps=sanitized_steps,
                lines=lines,
            )
        )

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
                + f'e.g. `Show the last 100 lines from the deployment logs for the latest run of runbook "{sanitized_runbook_names[0]}" in project "{sanitized_project_names[0]}".` '
                + f'or `Show me the the deployment logs for step 2 for the latest run of runbook "{sanitized_runbook_names[0]}" in project "{sanitized_project_names[0]}".`'
            )

        log_query(
            "runbook_logs_implementation",
            f"""
            Space ID: {space_id}
            Space Name: {actual_space_name}
            Project Names: {sanitized_project_names[0]}
            Runbook Names: {sanitized_runbook_names[0]}
            Tenant Names: {sanitized_tenant_names[0] if sanitized_tenant_names else None}
            Environment Names: {sanitized_environment_names[0]}
            Steps: {sanitized_steps}
            Lines: {log_lines}""",
        )

        processed_query = update_query(original_query, sanitized_projects)

        context = {"input": processed_query, "context": logs}

        response = [llm_message_query(messages, context, log_query)]

        response.extend(warnings)
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return runbook_logs_implementation
