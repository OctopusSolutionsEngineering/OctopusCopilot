from domain.validation.argument_validation import ensure_string


def strip_before_first_curly_bracket(text):
    """
    When asking the LLM for JSON responses, sometimes there is a short introduction, like "Answer:", before
    the JSON. This function strips everything before the first curly bracket, which is assumed to be the
    start of a JSON response.
    :param text:
    :return:
    """
    ensure_string(text, "text must be a string (strip_before_first_curly_bracket).")

    # Find the index of the first curly bracket
    index = text.find("{")

    # If a curly bracket was found, return the substring from that index onwards
    if index != -1:
        text = text[index:]

    last_index = text.rfind("}")

    if last_index != -1:
        text = text[: last_index + 1]

    return text
