def sanitize_keywords(keywords, max_keywords):
    # A key word like "Octopus" is not helpful
    invalid_keywords = ["octopus", "octopus deploy", "octopusdeploy"]
    filtered_keywords = [
        keyword
        for keyword in keywords
        if keyword.casefold().strip() not in invalid_keywords
    ]
    return filtered_keywords[:max_keywords]
