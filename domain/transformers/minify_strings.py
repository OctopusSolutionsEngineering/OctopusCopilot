import re

from domain.validation.argument_validation import ensure_string


def minify_strings(input):
    """
    This function strips empty lines and double whitespace from a string. This is a potentially destructive operation when
    used with HCL, as it can alter the whitespace in properties, which are significant. This is mostly used to send a cut
    down HCL to OpenAI.
    :param input: The source string
    :return: The minified input
    """

    ensure_string(input, 'input must be a string (minify_strings).')

    no_empty_lines = '\n'.join([line for line in input.split('\n') if line.strip()])
    no_double_whitespace = re.sub(' +', ' ', no_empty_lines)
    return no_double_whitespace


def replace_space_codes(input):
    ensure_string(input, 'input must be a string (replace_space_codes).')
    return input.replace("&nbsp;", " ")
