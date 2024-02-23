import json
import traceback

from domain.logging.app_logging import configure_logging
from infrastructure.http_pool import http

logger = configure_logging(__name__)


def send_slack_message(message, get_slack_url):
    """
    Sends a message to a slack channel
    :param message: The message to send
    :param get_slack_url: A function to get the slack URL
    """
    try:
        data = json.dumps({"text": message})
        resp = http.request("POST", get_slack_url(), headers={'Content-Type': 'application/json'}, data=data)

        if resp.status != 200:
            logger.error(resp.data)
    except Exception as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
