import json
import traceback

import aiohttp

from domain.logging.app_logging import configure_logging
from domain.validation.argument_validation import ensure_string_not_empty

logger = configure_logging(__name__)


async def send_slack_message(message, slack_url):
    """
    Sends a message to a slack channel
    :param message: The message to send
    :param slack_url: The slack URL
    """

    ensure_string_not_empty(slack_url, "slack_url must be the Slack webhook Url (send_slack_message).")

    try:
        data = json.dumps({"text": message})

        async with aiohttp.ClientSession(headers={'Content-Type': 'application/json'}) as session:
            async with session.post(slack_url, data=data) as response:
                if response.status != 200:
                    logger.error(response.text())

    except Exception as e:
        error_message = getattr(e, 'message', repr(e))
        logger.error(error_message)
        logger.error(traceback.format_exc())
