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


def remove_markdown_code_block(text: str) -> str:
    stripped_text = text.strip()
    if stripped_text.startswith("```") and stripped_text.endswith("```"):
        return re.sub("```.*?$", "", text, flags=re.MULTILINE).removesuffix("```")

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
        return text

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
