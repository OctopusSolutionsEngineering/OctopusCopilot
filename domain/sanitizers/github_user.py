def get_github_user_for_callback(github_user):
    return (
        github_user.casefold().strip()
        if (github_user and github_user.strip())
        else "Unknown"
    )
