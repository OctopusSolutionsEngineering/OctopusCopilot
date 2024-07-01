from datetime import datetime

import pytz

from domain.date.date_difference import get_date_difference_summary
from domain.date.parse_dates import parse_unknown_format_date
from domain.view.markdown.markdown_icons import get_github_state_icon


def github_jobs_to_summary(jobs):
    """
    Convert the jobs from a run into a markdown summary
    :param jobs: The run jobs
    :return: The markdown summary of the run
    """
    if not jobs:
        return ""

    now = datetime.now(pytz.utc)

    messages = []
    for job in jobs.get("jobs", []):
        icon = get_github_state_icon(job.get("status"), job.get("conclusion"))
        messages.append(f"{icon} {job.get('name')}")
        for step in job.get("steps", []):
            icon = get_github_state_icon(step.get("status"), step.get("conclusion"))
            created = parse_unknown_format_date(step.get("started_at"))
            completed = parse_unknown_format_date(step.get("completed_at"))
            if completed and created:
                difference = f" (🕗 {get_date_difference_summary(completed - created)})"
            elif created:
                difference = f" (⟲ {get_date_difference_summary(now - created)} ago)"
            else:
                difference = ""
            messages.append(f"&ensp;{icon} {step.get('name')}{difference}")
    return "\n\n".join(messages)
