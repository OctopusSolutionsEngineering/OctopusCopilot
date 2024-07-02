from datetime import datetime

import pytz

from domain.date.date_difference import get_date_difference_summary
from domain.date.parse_dates import parse_unknown_format_date
from domain.view.markdown.markdown_icons import get_activity_log_state_icon


def activity_logs_to_running(log_item):
    """
    Find the top level tasks that are running
    :param log_item: The activity logs for the task
    :return: The list of running tasks
    """
    if len(log_item) != 1 or len(log_item[0]["Children"]) == 0:
        return []

    messages = []
    for step in log_item[0]["Children"]:
        if step['Status'] == 'Running':
            icon = get_activity_log_state_icon(step['Status'])

            now = datetime.now(pytz.utc)
            # Created will be 0001-01-01T00:00:00 if the task has not started yet
            created = parse_unknown_format_date(step.get("Started"))
            completed = parse_unknown_format_date(step.get("Ended"))
            if completed and created:
                difference = f" (🕗 {get_date_difference_summary(completed - created)})"
            elif created and created.year != 1:
                difference = f" (⟲ {get_date_difference_summary(now - created)} ago)"
            else:
                difference = ""

            messages.append(f"{icon} {step['Name']}{difference}")

    return messages
