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


def get_dashboard_response(dashboard):
    table = ""
    for project_group in dashboard["ProjectGroups"]:

        table += f"| {project_group['Name']} "
        for environment in project_group["EnvironmentIds"]:
            environment_name = list(filter(lambda e: e["Id"] == environment, dashboard["Environments"]))
            table += f"| {environment_name[0]['Name']} "

        table += "|\n"

        environments = len(project_group["EnvironmentIds"])
        columns = ["|"] * (environments + 2)
        table += "-".join(columns) + "\n"

        projects = list(filter(lambda p: p["ProjectGroupId"] == project_group["Id"], dashboard["Projects"]))

        for project in projects:
            table += f"| {project['Name']} "

            for environment in project_group["EnvironmentIds"]:
                deployment = list(
                    filter(lambda d: d["ProjectId"] == project["Id"] and d["EnvironmentId"] == environment,
                           dashboard["Items"]))

                if len(deployment) > 0:
                    last_deployment = deployment[0]
                    icon = "⚪"
                    if last_deployment['State'] == "Executing":
                        icon = "🔵"
                    elif last_deployment['State'] == "Success":
                        if last_deployment['HasWarningsOrErrors']:
                            icon = "🟡"
                        else:
                            icon = "🟢"
                    elif last_deployment['State'] == "Failed":
                        icon = "🔴"
                    elif last_deployment['State'] == "Canceled":
                        icon = "🔴"
                    elif last_deployment['State'] == "TimedOut":
                        icon = "🔴"
                    elif last_deployment['State'] == "Cancelling":
                        icon = "🔴"
                    elif last_deployment['State'] == "Queued":
                        icon = "⚪"

                    table += f"| {icon} {last_deployment['ReleaseVersion']}"
                else:
                    table += f"|  "

            table += "|\n"
        table += "|\n\n"
    return table
