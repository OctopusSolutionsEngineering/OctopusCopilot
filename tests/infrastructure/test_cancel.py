import requests

from tests.infrastructure.octopus_config import Octopus_Api_Key


def cancel_task(space_id, task_id, octopus_server_uri="http://localhost:8080", octopus_api_key=Octopus_Api_Key):
    """
    Cancels a task in Octopus Deploy.
    """

    headers = {'X-Octopus-ApiKey': octopus_api_key}

    uri = '{0}/api/{1}/tasks/{2}/cancel'.format(octopus_server_uri, space_id, task_id)
    response = requests.post(uri, headers=headers)
    task = response.json()
    response.raise_for_status()
    return task
