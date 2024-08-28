import os
import urllib


def generate_slack_login(github_user):
    return (
            f"To continue chatting please click the link below:\n\n[log in](https://slack.com/oauth/v2/authorize?"
            + f"client_id={os.environ.get('SLACK_CLIENT_ID')}"
            + f"&redirect_url={urllib.parse.quote(os.environ.get('SLACK_CLIENT_REDIRECT'))}"
            + f"&user_scope=search:read"
            + f"&state={github_user}")
