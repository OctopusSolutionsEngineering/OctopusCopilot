from datetime import datetime

from domain.validation.octopus_validation import is_api_key_or_jwt


def ensure_api_key(value, error_message):
    """
    Ensures the value is an API key
    :param value: The argument to test
    :param error_message: The error message to raise if the test fails
    """
    if not is_api_key_or_jwt(value):
        raise ValueError(error_message)


def ensure_string_not_empty(value, error_message):
    """
    Ensures the value is a non-empty string
    :param value: The argument to test
    :param error_message: The error message to raise if the test fails
    """
    if not value or not isinstance(value, str) or not value.strip():
        raise ValueError(error_message)


def ensure_one_string_not_empty(error_message, *values):
    """
    Ensures one of the values is a non-empty string
    :param value: The arguments to test
    :param error_message: The error message to raise if the test fails
    """
    for value in values:
        if value and isinstance(value, str) and value.strip():
            return True

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
