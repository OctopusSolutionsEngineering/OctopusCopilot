import json
import os

from domain.url.build_url import build_url
from infrastructure.http_pool import http
from infrastructure.octopus import handle_response
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url

# When OCTOPUS_TEST_REMOTE is "Y" or "TRUE", tests run against a remote Octopus instance
# identified by OCTOPUS_CLI_SERVER and OCTOPUS_CLI_API_KEY. A temporary space with a random
# name is created and deleted around the test run.
Remote_Test = os.environ.get("OCTOPUS_TEST_REMOTE", "").upper() in ("Y", "TRUE")
Remote_Octopus_Url = os.environ.get("OCTOPUS_CLI_SERVER", "")
Remote_Octopus_Api_Key = os.environ.get("OCTOPUS_CLI_API_KEY", "")
Space_Manager_Team = os.environ.get("OCTOPUS_SPACE_MANAGER_TEAM", "")


def get_active_octopus_url():
    """Return the Octopus URL for the current test mode."""
    return Remote_Octopus_Url if Remote_Test else Octopus_Url


def get_active_api_key():
    """Return the Octopus API key for the current test mode."""
    return Remote_Octopus_Api_Key if Remote_Test else Octopus_Api_Key


def create_remote_space(space_name):
    """
    Create a new space on the remote Octopus server and return its ID.
    :param space_name: the name for the new space
    :return: the ID of the created space e.g. "Spaces-123"
    """
    api, headers = build_url(Remote_Octopus_Url, Remote_Octopus_Api_Key, "/api/spaces")
    headers["Content-Type"] = "application/json"
    teams = ["teams-administrators"]
    if Space_Manager_Team:
        teams.append(Space_Manager_Team)
    body = json.dumps({
        "Name": space_name,
        "IsDefault": False,
        "TaskQueueStopped": False,
        "SpaceManagersTeamMembers": None,
        "SpaceManagersTeams": teams,
    }).encode("utf8")
    resp = handle_response(
        lambda: http.request("POST", api, headers=headers, body=body)
    )
    space = resp.json()
    print(f"Created remote space '{space_name}' with ID {space['Id']}")
    return space["Id"]


def delete_remote_space(space_id):
    """
    Mark a space on the remote Octopus server for deletion by stopping its task queue, then
    delete it.
    :param space_id: the ID of the space to delete
    """
    # First, stop the task queue so the space can be deleted
    get_api, get_headers = build_url(
        Remote_Octopus_Url, Remote_Octopus_Api_Key, f"/api/spaces/{space_id}"
    )
    resp = handle_response(
        lambda: http.request("GET", get_api, headers=get_headers)
    )
    space = resp.json()
    space["TaskQueueStopped"] = True

    put_api, put_headers = build_url(
        Remote_Octopus_Url, Remote_Octopus_Api_Key, f"/api/spaces/{space_id}"
    )
    put_headers["Content-Type"] = "application/json"
    handle_response(
        lambda: http.request(
            "PUT", put_api, headers=put_headers, body=json.dumps(space).encode("utf8")
        )
    )

    # Now delete the space
    del_api, del_headers = build_url(
        Remote_Octopus_Url, Remote_Octopus_Api_Key, f"/api/spaces/{space_id}"
    )
    handle_response(
        lambda: http.request("DELETE", del_api, headers=del_headers)
    )
    print(f"Deleted remote space {space_id}")
