import re
from urllib.parse import urlparse

from domain.view.markdown.octopus_task_interruption_details import format_interruption_details


def is_hosted_octopus(octopus_url):
    """
    Validates that a string is a cloud octopus URL
    :param octopus_url:
    :return: True if the URL is valid and False otherwise
    """
    if not octopus_url:
        return False

    parsed_url = urlparse(octopus_url.strip())
    return parsed_url.netloc.endswith(".octopus.app") or parsed_url.netloc.endswith(".testoctopus.app")


def is_api_key(api_key):
    """
    Tests if a string is an API key
    :param api_key: The value to test
    :return: True if the string is an API key, False otherwise
    """
    if not api_key or not isinstance(api_key, str):
        return False

    pattern = r"API-[A-Z0-9a-z]+"

    return re.match(pattern, api_key)


def is_manual_intervention_valid(space_name, space_id, project_name, release_version, environment_name, tenant_name, task_id,
                                 task_interruptions, teams, url, interruption_action):
    """
    Checks if a manual intervention is valid
    :param space_name: The Octopus space name
    :param space_id: The Octopus space id
    :param project_name: The Octopus project name
    :param release_version: The Octopus release version
    :param environment_name: The Octopus environment name
    :param tenant_name: The (optional) Octopus tenant name
    :param task_id: The Octopus task id
    :param task_interruptions: The Octopus task interruptions
    :param teams: The Octopus teams for the space
    :param url: The Octopus Server url
    :param interruption_action: Whether the interruption should be approved or rejected
    :return: Tuple of: bool value indicating if the octopus manual interruption is valid, and an error response if False.
    """

    interruption_details = format_interruption_details(project_name, release_version, environment_name, tenant_name,
                                                       space_name, interruption_action)

    if task_interruptions is None:
        response = ["⚠️ No interruptions found for:"]
        response.extend(interruption_details)
        return False, "".join(response)
    else:
        interruption = [interruption for interruption in task_interruptions if interruption['IsPending']][0]
        if interruption['Type'] == "ManualIntervention":
            if not interruption['CanTakeResponsibility']:
                team_names = [team['Name'] for team in teams if team['Id'] in interruption['ResponsibleTeamIds']]
                markdown_names = list(map(lambda t: f"* {t}", team_names))
                response = ["🚫 You don't have sufficient permissions to take responsibility for the "
                            "manual intervention.\n\nThe following teams can:\n", "\n".join(markdown_names),
                            f"\n\n[View task]({url}/app#/{space_id}/tasks/{task_id})\n\n"]
                return False, "".join(response)
            else:
                if interruption['ResponsibleUserId'] and not interruption['HasResponsibility']:
                    response = ["🚫 Another user has already taken responsibility of the manual "
                                "intervention for:"]
                    response.extend(interruption_details)
                    response.append(f"\n\n[View task]({url}/app#/{space_id}/tasks/{task_id})\n\n")
                    return False, "".join(response)
        else:
            response = ["🚫 An incompatible interruption (guided failure) was found for:"]
            response.extend(interruption_details)
            response.append(f"[View task]({url}/app#/{space_id}/tasks/{task_id})\n\n")
            return False, "".join(response)

    return True, None
