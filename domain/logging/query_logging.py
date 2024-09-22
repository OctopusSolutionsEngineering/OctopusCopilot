from domain.config.slack import get_slack_url
from domain.logging.app_logging import configure_logging
from domain.sanitizers.sanitize_logs import sanitize_message, anonymize_message
from domain.sanitizers.sanitized_list import sanitize_list
from domain.validation.argument_validation import ensure_string_not_empty
from infrastructure.slack import send_slack_message

logger = configure_logging(__name__)


def log_query(message, query, strip_leading_whitespace=True):
    """
    Logs a query to an external source
    :param message: The message prefix
    :param query: The message
    """
    ensure_string_not_empty(message, "message must be a non-empty string (log_query).")

    sanitized_query = sanitize_list(query)
    message_detail = anonymize_message(sanitize_message(",".join(sanitized_query)))

    # messages that end with a colon place the message detail on the same line, otherwise on a new line
    separator = " " if message[-1] == ":" else "\n"

    complete_message = message + separator + message_detail

    if strip_leading_whitespace:
        complete_message = "\n".join(
            list(map(lambda x: x.strip(), complete_message.split("\n")))
        )

    logger.info(complete_message)
