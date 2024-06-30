import asyncio

from domain.context.octopus_context import max_chars
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.tools.debug import get_params_message
from infrastructure.github import get_latest_workflow_run_async, get_workflow_run_logs_async
from infrastructure.openai import llm_message_query


def get_github_logs_callback(github_user, github_token, log_query=None):
    def get_github_logs_implementation(original_query, messages, owner, repo, workflow, steps, lines):
        debug_text = get_params_message(github_user,
                                        True,
                                        get_github_logs_implementation.__name__,
                                        messages=messages,
                                        owner=owner,
                                        repo=repo,
                                        workflow=workflow,
                                        steps=steps,
                                        lines=lines)

        if not owner:
            return CopilotResponse("You must specify a repository owner.")

        if not repo:
            return CopilotResponse("You must specify a repository.")

        if not workflow:
            return CopilotResponse("You must specify a workflow, for example build.yaml or test.yaml.")

        runs = asyncio.run(get_latest_workflow_run_async(owner, repo, workflow, github_token)).get("workflow_runs")
        run = get_item_or_none(runs, 0)
        run_id = str(run.get("id")) if run else None

        if not run_id:
            return CopilotResponse("No runs found for the specified workflow.")

        logs = timing_wrapper(
            lambda: asyncio.run(get_workflow_run_logs_async(owner, repo, run_id, github_token)),
            "GitHub Run logs")

        # Get the end of the logs if we have exceeded our context limit
        logs = logs[-max_chars:]

        debug_text.extend(get_params_message(github_user,
                                             False,
                                             get_github_logs_implementation.__name__,
                                             messages=messages,
                                             owner=owner,
                                             repo=repo,
                                             workflow=workflow,
                                             steps=steps,
                                             lines=lines))

        context = {"input": original_query, "context": logs}

        response = [llm_message_query(messages, context, log_query)]
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_github_logs_implementation
