from datetime import datetime

import pytz

from domain.date.date_difference import get_date_difference_summary
from domain.date.parse_dates import parse_unknown_format_date
from domain.view.markdown.markdown_icons import get_activity_log_state_icon


def get_summary(log_item, depth, url=None, artifacts=None, step=None):
    if depth == 0 and len(log_item["Children"]) == 0:
        return f"No logs found (status: {log_item['Status']})."

    icon = get_activity_log_state_icon(log_item['Status'])

    # Show the duration on the top level task
    if depth == 1:
        now = datetime.now(pytz.utc)
        created = parse_unknown_format_date(log_item.get("Started"))
        completed = parse_unknown_format_date(log_item.get("Ended"))
        if completed and created:
            difference = f" (🕗 {get_date_difference_summary(completed - created)})"
        elif created:
            difference = f" (⟲ {get_date_difference_summary(now - created)} ago)"
        else:
            difference = ""
    else:
        difference = ""

    messages = [f"{'&ensp;' * depth}{icon} {log_item['Name']}{difference}"]

    # Show highlights
    filtered_logs = list(filter(lambda x: x["Category"] == "Highlight", log_item["LogElements"]))

    messages.extend(list(map(lambda e: f"{'&ensp;' * (depth + 1)}{e['MessageText']}", filtered_logs)))

    # Link artifacts
    if artifacts and url:
        messages.extend(map(lambda a: f"{'&ensp;' * (depth + 1)}💾 [{a['Filename']}]({url}{a['Links']['Content']})",
                            filter(lambda x: x["LogCorrelationId"] == log_item["Id"], artifacts["Items"])))

    logs = "\n\n".join(messages)

    if depth < 2 and log_item["Children"]:
        for child in log_item["Children"]:
            logs += "\n\n" + get_summary(child, depth + 1, url, artifacts)

    return logs


def activity_logs_to_summary(activity_logs, url=None, artifacts=None):
    """
    Builds a task summary response from the activity logs
    :param activity_logs: The deployment activity logs
    :param artifacts: The deployment artifacts
    :return: The text based summary of the logs
    """
    if not activity_logs:
        return ""

    logs = "\n".join(list(map(lambda i: get_summary(i, 0, url, artifacts), activity_logs)))

    return logs
