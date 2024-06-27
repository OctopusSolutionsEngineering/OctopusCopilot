from domain.view.markdown.markdown_icons import get_github_state_icon


def github_jobs_to_summary(jobs):
    """
    Convert the jobs from a run into a markdown summary
    :param jobs: The run jobs
    :return: The markdown summary of the run
    """
    if not jobs:
        return ""

    messages = []
    for job in jobs.get("jobs", []):
        icon = get_github_state_icon(job.get("status"), job.get("conclusion"))
        messages.append(f"{icon} {job.get('name')}")
        for step in job.get("steps", []):
            icon = get_github_state_icon(step.get("status"), step.get("conclusion"))
            messages.append(f"&ensp;{icon} {step.get('name')}")
    return "\n".join(messages)
