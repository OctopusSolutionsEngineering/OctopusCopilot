def string_to_int(s):
    if not s:
        return None

    try:
        return int(s)
    except ValueError:
        return None
