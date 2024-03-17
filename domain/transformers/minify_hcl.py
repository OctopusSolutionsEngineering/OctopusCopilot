import re

from domain.validation.argument_validation import ensure_string


def minify_hcl(hcl):
    """
    This function strips empty lines and double whitespace from HCL. This is a potentially destructive operation, so it
    can alter the whitespace in properties, which are significant. This is mostly used to send a cut down HCL to OpenAI.
    :param hcl: The source HCL
    :return: The minified HCL
    """

    ensure_string(hcl, 'hcl must be a string (minify_hcl).')

    no_empty_lines = '\n'.join([line for line in hcl.split('\n') if line.strip()])
    no_double_whitespace = re.sub(' +', ' ', no_empty_lines)
    return no_double_whitespace
