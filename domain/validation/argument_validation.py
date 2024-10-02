from datetime import datetime


def ensure_string_not_empty(value, error_message):
    """
    Ensures the value is a non-empty string
    :param value: The argument to test
    :param error_message: The error message to raise if the test fails
    """
    if not value or not isinstance(value, str) or not value.strip():
        raise ValueError(error_message)


def ensure_string_starts_with(value, prefix, error_message):
    """
    Ensures the value is string with a given prefix
    :param value: The argument to test
    :param prefix: The prefix that must be at the start of the string
    :param error_message: The error message to raise if the test fails
    """
    if not value or not isinstance(value, str) or not value.strip():
        raise ValueError(error_message)
    if not value.startswith(prefix):
        raise ValueError(error_message)


def ensure_string(value, error_message):
    """
    Ensures the value is a string
    :param value: The argument to test
    :param error_message: The error message to raise if the test fails
    """
    if value is None or not isinstance(value, str):
        raise ValueError(error_message)


def ensure_string_or_none(value, error_message):
    """
    Ensures the value is a string or None
    :param value: The argument to test
    :param error_message: The error message to raise if the test fails
    """
    if value is None:
        return True

    if not isinstance(value, str):
        raise ValueError(error_message)


def ensure_not_falsy(value, error_message):
    """
    Ensures the value is a non-falsy value
    :param value: The argument to test
    :param error_message: The error message to raise if the test fails
    """
    if not value:
        raise ValueError(error_message)


def ensure_is_datetime(value, error_message):
    """
    Ensures the value is a datetime
    :param value: The argument to test
    :param error_message: The error message to raise if the test fails
    """
    if not value or not isinstance(value, datetime):
        raise ValueError(error_message)
