def ensure_string_not_empty(value, error_message):
    if not value or not isinstance(value, str) or not value.strip():
        raise ValueError(error_message)
