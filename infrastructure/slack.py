import json
import traceback
from threading import Thread

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.http_pool import http

logger = configure_logging(__name__)


def send_slack_message_async(message, slack_url):
    """
    Send a message to a slack channel asynchronously
    :param message: The message to send
    :param slack_url: The slack URL
    """
    Thread(target=send_slack_message, args=(message, slack_url)).start()


def send_slack_message(message, slack_url):
    """
    Sends a message to a slack channel
    :param message: The message to send
    :param slack_url: The slack URL
    """

    ensure_string_not_empty(slack_url, "slack_url must be the Slack webhook Url (send_slack_message).")

    try:
        data = json.dumps({"text": message})
        resp = http.request("POST", slack_url, headers={'Content-Type': 'application/json'}, body=data)

        if resp.status != 200:
            logger.error(resp.data)
    except Exception as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
