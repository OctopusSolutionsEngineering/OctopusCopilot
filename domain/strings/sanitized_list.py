def sanitize_list(input_list):
    if isinstance(input_list, str):
        if input_list.strip():
            return [input_list.strip()]
        else:
            return []

    # Open AI will give you a list with a single asterisk if the list is empty
    return [entry.strip() for entry in input_list if entry.strip() and not entry == "*"] if input_list else []
