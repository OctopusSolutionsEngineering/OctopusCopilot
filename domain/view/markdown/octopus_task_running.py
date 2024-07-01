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
            messages.append(f"{icon} {step['Name']}")

    return messages
