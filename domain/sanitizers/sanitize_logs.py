import re

from scrubadubdub import Scrub

from domain.validation.argument_validation import ensure_string

sensitive_vars = ["[Aa][Pp][Ii]-[A-Za-z0-9]+"]
scrubber = Scrub()


def sanitize_message(message):
    """
    Strip sensitive and PII information from a message
    :param message: The message to be logged
    :return: The sanitized message
    """
    ensure_string(message, "message must be a string (sanitize_message)")

    # A defensive move to stop API keys from appearing in logs
    for sensitive_var in sensitive_vars:
        message = re.sub(sensitive_var, "*****", message)

    return message


def anonymize_message(message):
    """
    Anonymize the message
    :param message: The message to be anonymized
    :return: The anonymized message
    """
    ensure_string(message, "message must be a string (anonymize_message)")

    removed_pii = scrubber.scrub(message)

    return removed_pii
