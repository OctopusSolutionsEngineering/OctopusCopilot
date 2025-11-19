import re

from domain.validation.argument_validation import ensure_string

# https://github.com/odomojuli/regextokens
sensitive_vars = [
    "[Aa][Pp][Ii]-[A-Za-z0-9]+",
    "xoxe.xoxp-1-[0-9a-zA-Z]{166}",
    "xoxb-[0-9]{11}-[0-9]{11}-[0-9a-zA-Z]{24}",
    "xoxp-[0-9]{11}-[0-9]{11}-[0-9a-zA-Z]{24}",
    "xoxe-1-[0-9a-zA-Z]{147}",
    "T[a-zA-Z0-9_]{8}/B[a-zA-Z0-9_]{8}/[a-zA-Z0-9_]{24}",
    "ghp_[A-Za-z0-9-]+",
    "github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59}",
    "gho_[a-zA-Z0-9]{36}",
    "ghu_[a-zA-Z0-9]{36}",
    "ghs_[a-zA-Z0-9]{36}",
    "ghr_[a-zA-Z0-9]{36}",
]


def sanitize_message(message):
    """
    Strip sensitive and PII information from a message
    :param message: The message to be logged
    :return: The sanitized message
    """

    if not message:
        return message

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

    # To do - implement this

    return message
