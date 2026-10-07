import re

# A line that opens or closes a markdown code fence, e.g. ``` or ```hcl
FENCE_LINE_REGEX = re.compile(r"^```[\w-]*[ \t]*$", re.MULTILINE)

# A fenced block, capturing the content between the opening and closing fences
FENCED_BLOCK_REGEX = re.compile(
    r"^```[\w-]*[ \t]*\n(.*?)^```[ \t]*$", re.MULTILINE | re.DOTALL
)

# Top level Terraform blocks. Text before a fence that contains these is configuration rather than prose.
HCL_BLOCK_REGEX = re.compile(
    r"^(resource|data|variable|provider|terraform|output|locals)\b", re.MULTILINE
)


# The start of a top level Terraform block. Stricter than HCL_BLOCK_REGEX so prose beginning with a word like
# "data" or "variable" is not mistaken for configuration.
HCL_BLOCK_START_REGEX = re.compile(
    r'^(?:(?:resource|data|variable|provider|output|module)[ \t]+"|(?:terraform|locals)[ \t]*\{)',
    re.MULTILINE,
)

COMMENT_OR_BLANK_LINE_REGEX = re.compile(r"^[ \t]*(?:#.*|//.*)?$")


def remove_markdown_code_block(text: str) -> str:
    stripped_text = text.strip()
    if stripped_text.startswith("```") and stripped_text.endswith("```"):
        return re.sub("```.*?$", "", text, flags=re.MULTILINE).removesuffix("```")

    # A response truncated at the token limit opens a fence that is never closed, which tofu rejects with
    # "Invalid character" on line 1. Drop the opening fence line.
    opening_fence = FENCE_LINE_REGEX.match(stripped_text)
    if opening_fence and not FENCE_LINE_REGEX.search(stripped_text, opening_fence.end()):
        return stripped_text[opening_fence.end() :].lstrip("\n")

    return remove_prose_around_code_block(text)


def remove_prose_around_code_block(text: str) -> str:
    """
    Models sometimes explain themselves before the code block, e.g. "Looking at the error, the issue is...
    ```hcl ...```", which is not valid Terraform. Where prose precedes the first fence, return only the
    content of the fenced blocks. Text that already starts with configuration, where a fence could only
    be part of a heredoc or description, is returned unchanged.
    """

    first_fence = FENCE_LINE_REGEX.search(text)
    if not first_fence:
        return remove_leading_prose(text)

    prose = text[: first_fence.start()]
    if not prose.strip() or HCL_BLOCK_REGEX.search(prose):
        return text

    blocks = [
        block for block in FENCED_BLOCK_REGEX.findall(text[first_fence.start() :])
    ]
    non_empty_blocks = [block for block in blocks if block.strip()]
    if not non_empty_blocks:
        return text

    return "\n".join(non_empty_blocks)


def remove_leading_prose(text: str) -> str:
    """
    When the model explains itself before unfenced configuration, e.g. "Looking at the error, the issue is...",
    tofu init fails with: Error: Unsupported block type ... Blocks of type "Looking" are not expected here.
    Everything before the first top level block is removed unless it is only blank lines and comments.
    """

    first_block = HCL_BLOCK_START_REGEX.search(text)
    if not first_block:
        return text

    prefix = text[: first_block.start()]
    if all(COMMENT_OR_BLANK_LINE_REGEX.match(line) for line in prefix.splitlines()):
        return text

    return text[first_block.start() :]
