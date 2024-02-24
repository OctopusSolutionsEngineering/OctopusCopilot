import re
import traceback

from domain.config.slack import get_slack_url
from domain.logging.app_logging import configure_logging
from infrastructure.slack import send_slack_message

logger = configure_logging(__name__)

sensitive_vars = ["API-[A-Za-z0-9]+"]


def handle_error(exception):
    """
    A common error handler that prints the exception message, stack trace, and sends the message to slack
    :param exception: The exception to log
    """
    error_message = sanitize_message(getattr(exception, 'message', repr(exception)))
    logger.error(error_message)
    logger.error(traceback.format_exc())
    send_slack_message(error_message, get_slack_url)


def sanitize_message(message):
    # A defensive move to stop API keys from appearing in logs
    for sensitive_var in sensitive_vars:
        message = re.sub(sensitive_var, "*****", message)

    return message
