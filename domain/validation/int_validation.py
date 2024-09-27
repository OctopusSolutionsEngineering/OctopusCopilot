def is_int(s):
    if s is None:
        return False

    try:
        int(s)
        return True
    except ValueError:
        return False
