import traceback

from domain.config.slack import get_slack_url
from domain.logging.app_logging import configure_logging
from domain.sanitizers.sanitize_logs import sanitize_message
from domain.validation.argument_validation import ensure_not_falsy
from infrastructure.slack import send_slack_message

logger = configure_logging(__name__)


def handle_error(exception):
    """
    A common error handler that prints the exception message, stack trace, and sends the message to slack
    :param exception: The exception to log
    """

    ensure_not_falsy(exception, "exception can not be None (handle_error).")

    error_message = sanitize_message(getattr(exception, 'message', repr(exception)))
    stack_trace = sanitize_message(traceback.format_exc())

    logger.error(error_message)
    logger.error(stack_trace)

    send_slack_message(error_message, get_slack_url())
    send_slack_message(stack_trace, get_slack_url())
