def get_octopus_project_names_response(space_name, projects):
    """
    Provides a conversational response to the list of projects
    :param space_name: The name of the space containing the projects
    :param projects: The list of projects
    :return: A conversational response
    """

    if not projects and (space_name is None or not space_name.strip()):
        return "I found no projects."

    if not projects:
        return f"I found no projects in the space {space_name}."

    if space_name is None or not space_name.strip():
        return f"I found {len(projects)} projects:\n* " + "\n * ".join(projects)

    return f"I found {len(projects)} projects in the space \"{space_name.strip()}\":\n* " + "\n* ".join(projects)


def get_deployment_status_base_response(actual_space_name, actual_environment_name, actual_project_name, deployment):
    icon = "⚪"
    if deployment['State'] == "Executing":
        icon = "🔵"
    elif deployment['State'] == "Success":
        icon = "🟢"
    elif deployment['State'] == "Failed":
        icon = "🔴"
    elif deployment['State'] == "Canceled":
        icon = "🔴"
    elif deployment['State'] == "TimedOut":
        icon = "🔴"
    elif deployment['State'] == "Cancelling":
        icon = "🔴"
    elif deployment['State'] == "Queued":
        icon = "⚪"

    return f"{icon} The latest deployment in `{actual_space_name}` to `{actual_environment_name}` for `{actual_project_name}` is version `{deployment['ReleaseVersion']}` with state `{deployment['State']}`."
