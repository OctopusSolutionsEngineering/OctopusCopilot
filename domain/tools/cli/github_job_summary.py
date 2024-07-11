import asyncio

from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.tools.debug import get_params_message
from domain.view.markdown.github_jobs_summary import github_jobs_to_summary
from infrastructure.github import get_run_jobs_async, get_latest_workflow_run_async


def get_job_summary_cli_callback(github_user, github_token, log_query=None):
    def get_task_summary_cli_callback_implementation(original_query, owner, repo, workflow, run_id):

        if not owner:
            return CopilotResponse("You must specify a repository owner.")

        if not repo:
            return CopilotResponse("You must specify a repository.")

        if not workflow:
            return CopilotResponse("You must specify a workflow, for example build.yaml or test.yaml.")

        if not run_id:
            runs = asyncio.run(get_latest_workflow_run_async(owner, repo, workflow, github_token)).get("workflow_runs")
            run = get_item_or_none(runs, 0)
            run_id = run.get("id") if run else None

        if not run_id:
            return CopilotResponse("No runs found for the specified workflow.")

        jobs = timing_wrapper(
            lambda: asyncio.run(get_run_jobs_async(owner, repo, run_id, github_token)),
            "GitHub Run jobs")

        return github_jobs_to_summary(jobs)

    return get_task_summary_cli_callback_implementation
