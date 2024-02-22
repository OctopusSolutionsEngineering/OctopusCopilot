import os


def get_slack_url():
    return os.environ.get("SLACK_WEBHOOK_URL")
