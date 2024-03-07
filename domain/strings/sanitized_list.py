import re


def sanitize_list(input_list, ignored_re=None):
    """
    OpenAI can provide some unexpected inputs. This function cleans them up.
    :param input_list:
    :return:
    """
    if isinstance(input_list, str):
        if input_list.strip() and not has_prefix(ignored_re, ignored_re):
            return [input_list.strip()]
        else:
            return []

    # Open AI will give you a list with a single asterisk if the list is empty
    return [entry.strip() for entry in input_list if
            entry.strip() and not has_prefix(entry, ignored_re)] if input_list else []


def has_prefix(entry, ignored_re):
    if not ignored_re:
        return False

    return re.match(ignored_re, entry)
