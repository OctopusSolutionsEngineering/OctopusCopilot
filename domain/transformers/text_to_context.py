def get_context_from_text_array(items, type):
    if not items:
        return []

    return [
        (
            "system",
            type + ": ###\n" + context.replace("{", "{{").replace("}", "}}") + "\n###",
        )
        for context in items
        if isinstance(context, str)
    ]
