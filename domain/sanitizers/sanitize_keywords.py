def sanitize_keywords(
    keywords,
    max_keywords,
    invalid_keywords=None,
):
    # A key word like "Octopus" is not helpful
    invalid_keywords = invalid_keywords or [
        "octopus",
        "deploy",
        "octopus deploy",
        "octopusdeploy",
    ]
    filtered_keywords = [
        keyword
        for keyword in keywords
        if keyword.casefold().strip() not in invalid_keywords
    ]
    return get_unique_values(filtered_keywords)[:max_keywords]


def get_unique_values(input_list):
    if not input_list:
        return []

    unique_list = []
    for item in input_list:
        if item not in unique_list:
            unique_list.append(item)
    return unique_list
