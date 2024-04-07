import re


def strip_markdown_urls(text):
    """
    Strips markdown URLs from the text.
    :param text: The text to strip the URLs from.
    :return: The text with the URLs removed.
    """
    return re.sub(r'\[([^]]+)]\([^)]+\)', r'\1', text)
