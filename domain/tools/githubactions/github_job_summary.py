import asyncio

from domain.defaults.defaults import get_default_argument
from domain.performance.timing import timing_wrapper
from domain.response.copilot_response import CopilotResponse
from domain.sanitizers.sanitized_list import get_item_or_none
from domain.tools.debug import get_params_message
from domain.view.markdown.github_jobs_summary import github_jobs_to_summary
from infrastructure.github import get_run_jobs_async, get_latest_workflow_run_async


def get_job_summary_callback(github_user, github_token, log_query=None):
    def get_task_summary_callback_implementation(original_query, owner, repo, workflow, run_id):
        debug_text = get_params_message(github_user,
                                        True,
                                        get_task_summary_callback_implementation.__name__,
                                        original_query=original_query,
                                        owner=owner,
                                        repo=repo,
                                        workflow=workflow,
                                        run_id=run_id)

        owner = get_default_argument(github_user, owner, "Owner")
        if not owner:
            return CopilotResponse("You must specify a repository owner.")

        repo = get_default_argument(github_user, repo, "Repository")
        if not repo:
            return CopilotResponse("You must specify a repository.")

        workflow = get_default_argument(github_user, workflow, "Workflow")
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

        debug_text.extend(get_params_message(github_user,
                                             True,
                                             get_task_summary_callback_implementation.__name__,
                                             original_query=original_query,
                                             owner=owner,
                                             repo=repo,
                                             workflow=workflow,
                                             run_id=run_id))

        response = [github_jobs_to_summary(jobs)]
        response.extend(debug_text)

        return CopilotResponse("\n\n".join(response))

    return get_task_summary_callback_implementation
