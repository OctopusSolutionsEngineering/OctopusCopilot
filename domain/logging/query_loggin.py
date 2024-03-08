from domain.config.slack import get_slack_url
from domain.logging.app_logging import configure_logging
from domain.strings.sanitized_list import sanitize_list
from domain.validation.argument_validation import ensure_string_not_empty, ensure_not_falsy
from infrastructure.slack import send_slack_message_async

logger = configure_logging(__name__)


def log_query(message, query):
    """
    Logs a query to an external source
    :param message: The message prefix
    :param query: The message
    """
    ensure_string_not_empty(message, 'message must be a non-empty string (log_query).')
    ensure_not_falsy(query, 'query must not be falsy (log_query).')

    sanitized_query = sanitize_list(query)
    complete_message = message + " " + ",".join(sanitized_query)
    send_slack_message_async(complete_message, get_slack_url())
    logger.info(complete_message)
