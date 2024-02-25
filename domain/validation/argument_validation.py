def ensure_string_not_empty(value, error_message):
    if not value or not isinstance(value, str) or not value.strip():
        raise ValueError(error_message)


def ensure_string(value, error_message):
    if value is None or not isinstance(value, str):
        raise ValueError(error_message)


def ensure_not_none(value, error_message):
    if not value:
        raise ValueError(error_message)
