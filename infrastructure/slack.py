import json
import traceback

from domain.logging.app_logging import configure_logging
from infrastructure.http_pool import http

logger = configure_logging(__name__)


def send_slack_message(message, get_slack_url):
    try:
        data = json.dumps({"text": message})
        http.request("POST", get_slack_url(), headers={'Content-Type': 'application/json'}, data=data)
    except Exception as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
