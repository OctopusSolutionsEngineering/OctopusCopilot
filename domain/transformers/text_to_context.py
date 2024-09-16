def get_context_from_text_array(items, type):
    if not items:
        return []

    return [
        get_context_from_string(context, type)
        for context in items
        if isinstance(context, str)
    ]


def get_context_from_string(item, type):
    if not item:
        return []

    return [
        (
            "system",
            type + ": ###\n" + item.replace("{", "{{").replace("}", "}}") + "\n###",
        )
    ]
