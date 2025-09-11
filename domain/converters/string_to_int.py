def string_to_int(s, default=None):
    if not s:
        return None

    if isinstance(s, int):
        return s

    try:
        return int(s)
    except ValueError:
        return default
