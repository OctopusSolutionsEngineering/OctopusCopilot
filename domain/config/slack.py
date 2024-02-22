import os


def get_slack_url():
    """
    Returns the Slack web hook URL for the live application
    :return: The slack web hook URL
    """
    return os.environ.get("SLACK_WEBHOOK_URL")
