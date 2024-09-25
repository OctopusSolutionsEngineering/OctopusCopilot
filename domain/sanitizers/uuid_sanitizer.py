import re

uuid_pattern = re.compile(
    r"\b[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}\b"
)


def is_uuid(text):
    if not text:
        return False

    # Search for the UUID in the text
    match = uuid_pattern.search(text)

    if match:
        return True
    else:
        return None
