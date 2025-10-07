import re


def remove_markdown_code_block(text: str) -> str:
    stripped_text = text.strip()
    if stripped_text.startswith("```") and stripped_text.endswith("```"):
        return re.sub("```.*?$", "", text, flags=re.MULTILINE).removesuffix("```")

    return text
