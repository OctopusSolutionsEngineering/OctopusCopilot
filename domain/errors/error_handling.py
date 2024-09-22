import traceback

from domain.config.slack import get_slack_url
from domain.logging.app_logging import configure_logging
from domain.sanitizers.sanitize_logs import sanitize_message, anonymize_message
from domain.validation.argument_validation import ensure_not_falsy
from infrastructure.slack import send_slack_message

logger = configure_logging(__name__)


def handle_error(exception):
    """
    A common error handler that prints the exception message, stack trace, and sends the message to slack
    :param exception: The exception to log
    """

    ensure_not_falsy(exception, "exception can not be None (handle_error).")

    try:
        error_message = anonymize_message(
            sanitize_message(getattr(exception, "message", repr(exception)))
        )
        stack_trace = anonymize_message(sanitize_message(traceback.format_exc()))

        # Get the wrapped exception, if any
        original_exception = anonymize_message(
            sanitize_message(getattr(exception, "original_exception", repr(exception)))
        )
        original_error_message = (
            anonymize_message(
                sanitize_message(
                    getattr(original_exception, "message", repr(original_exception))
                )
            )
            if original_exception
            else None
        )

        logger.error(error_message)
        if original_error_message:
            logger.error(original_error_message)
        logger.error(stack_trace)
    except Exception as e:
        logger.error(getattr(e, "message", repr(e)))
