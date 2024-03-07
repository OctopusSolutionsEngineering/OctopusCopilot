def sanitize_list(input_list):
    if isinstance(input_list, str):
        if input_list.strip():
            return [input_list.strip()]
        else:
            return []

    return [entry.strip() for entry in input_list if entry.strip()] if input_list else []
