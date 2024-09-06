import os
import urllib


def generate_slack_login(session):
    return (
        f"[Log in to Slack to include Slack messages in the context](https://slack.com/oauth/v2/authorize?"
        + f"client_id={os.environ.get('SLACK_CLIENT_ID')}"
        + f"&redirect_url={urllib.parse.quote(os.environ.get('SLACK_CLIENT_REDIRECT', ''))}"
        + f"&user_scope={urllib.parse.quote('search:read,channels:history,groups:history,mpim:history,im:history')}"
        # + f"&user_scope={urllib.parse.quote('search:read')}"
        + f"&state={session})"
    )
