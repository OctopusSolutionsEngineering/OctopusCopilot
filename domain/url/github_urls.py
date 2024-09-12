import re


def extract_owner_repo_and_commit(url):
    pattern = re.compile(r"https://github.com/(\w+)/(\w+)/commit/(\w+)")
    match = pattern.search(url)

    if match is None:
        return None, None, None

    return match.group(1), match.group(2), match.group(3)


def extract_owner_repo_and_issue(url):
    pattern = re.compile(r"https://github.com/(\w+)/(\w+)/issues/(\w+)")
    match = pattern.search(url)

    if match is None:
        return None, None, None

    return match.group(1), match.group(2), match.group(3)
