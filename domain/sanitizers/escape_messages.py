def escape_message(message):
    """
    Escape a string that is included in a LLM message
    :param message:
    :return:
    """

    if not message:
        return ""

    return message.replace("{", "{{").replace("}", "}}")
