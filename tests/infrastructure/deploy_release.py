import json

import requests


def get_octopus_resource(uri, headers):
    response = requests.get(uri, headers=headers)
    response.raise_for_status()

    return json.loads(response.content.decode('utf-8'))


def get_by_name(uri, headers, name):
    resources = get_octopus_resource(uri)
    return next((x for x in resources if x['Name'] == name), None)


def deploy_release(octopus_server_uri, octopus_api_key, space_name, project_name, release_version, environment_name):
    headers = {'X-Octopus-ApiKey': octopus_api_key}

    space = get_by_name('{0}/spaces/all'.format(octopus_server_uri), headers, space_name)
    project = get_by_name('{0}/{1}/projects/all'.format(octopus_server_uri, space['Id']), headers, project_name)
    releases = get_octopus_resource(
        '{0}/{1}/projects/{2}/releases'.format(octopus_server_uri, space['Id'], project['Id']), headers)
    release = next((x for x in releases['Items'] if x['Version'] == release_version), None)
    environment = get_by_name('{0}/{1}/environments/all'.format(octopus_server_uri, space['Id']), headers,
                              environment_name)

    deployment = {
        'ReleaseId': release['Id'],
        'EnvironmentId': environment['Id']
    }

    uri = '{0}/{1}/deployments'.format(octopus_server_uri, space['Id'])
    response = requests.post(uri, headers=headers, json=deployment)
    response.raise_for_status()
