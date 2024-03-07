from domain.config.slack import get_slack_url
from domain.strings.sanitized_list import sanitize_list
from infrastructure.slack import send_slack_message_async


def log_query(message, query):
    """
    Logs a query to an external source
    :param message: The message prefix
    :param query: The message
    """
    sanitized_query = sanitize_list(query)
    send_slack_message_async(message + " " + ",".join(sanitized_query), get_slack_url())
