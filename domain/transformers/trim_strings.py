def trim_string_with_ellipsis(string, max_length):
    if len(string) > max_length:
        return string[:max_length] + "..."
    return string
