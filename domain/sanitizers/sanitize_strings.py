import re


def remove_empty_lines(s):
    return "\n".join([line for line in s.splitlines() if line.strip()])


def remove_double_whitespace(s):
    return re.sub(r"[ ]+", " ", s)


def add_spaces_before_capitals(s):
    return re.sub(r"((?<!^)[A-Z])", r" \1", s)


def replace_with_empty_string(input_string, pattern):
    return re.sub(pattern, "", input_string)


def strip_leading_whitespace(input_string):
    return "\n".join(
        [line.lstrip(" \t") for line in input_string.splitlines() if line.strip()]
    )


def to_lower_case_or_none(s):
    return s.lower() if s is not None else None
