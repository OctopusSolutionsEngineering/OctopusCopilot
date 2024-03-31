import re


def remove_empty_lines(s):
    return "\n".join([line for line in s.splitlines() if line.strip()])


def remove_double_whitespace(s):
    return re.sub(r'[ ]+', ' ', s)
