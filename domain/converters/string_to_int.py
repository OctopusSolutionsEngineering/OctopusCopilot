def string_to_int(s):
    if not s:
        return None

    if isinstance(s, int):
        return s

    try:
        return int(s)
    except ValueError:
        return None
