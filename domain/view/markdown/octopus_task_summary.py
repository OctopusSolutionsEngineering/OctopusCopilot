from domain.view.markdown.markdown_icons import get_activity_log_state_icon


def get_highlights(log_item):
    filtered_logs = list(filter(lambda x: x["Category"] == "Highlight", log_item["LogElements"]))
    for child in log_item["Children"]:
        filtered_logs.extend(get_highlights(child))
    return filtered_logs


def get_summary(log_item, depth):
    if depth == 0 and len(log_item["Children"]) == 0:
        return f"No logs found (status: {log_item['Status']})."

    icon = get_activity_log_state_icon(log_item['Status'])

    messages = [f"{'&ensp;' * depth}{icon} {log_item['Name']}"]

    filtered_logs = get_highlights(log_item)

    messages.extend(list(map(lambda e: f"{'&ensp;' * (depth + 1)}{e["MessageText"]}", filtered_logs)))

    logs = "\n".join(messages)

    if depth < 2 and log_item["Children"]:
        for child in log_item["Children"]:
            logs += "\n\n" + get_summary(child, depth + 1)

    return logs


def activity_logs_to_summary(activity_logs):
    """
    Builds a task summary response from the activity logs
    :param activity_logs: The deployment activity logs
    :return: The text based summary of the logs
    """
    if not activity_logs:
        return ""

    logs = "\n".join(list(map(lambda i: get_summary(i, 0), activity_logs)))

    return logs
