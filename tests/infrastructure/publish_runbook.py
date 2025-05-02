import json

import requests

from tests.infrastructure.octopus_config import Octopus_Url, Octopus_Api_Key


def get_octopus_resource(uri, headers, skip_count=0):
    items = []
    skip_querystring = ""

    if "?" in uri:
        skip_querystring = "&skip="
    else:
        skip_querystring = "?skip="

    response = requests.get((uri + skip_querystring + str(skip_count)), headers=headers)
    response.raise_for_status()

    # Get results of API call
    results = json.loads(response.content.decode("utf-8"))

    # Store results
    if "Items" in results.keys():
        items += results["Items"]

        # Check to see if there are more results
        if (len(results["Items"]) > 0) and (
            len(results["Items"]) == results["ItemsPerPage"]
        ):
            skip_count += results["ItemsPerPage"]
            items += get_octopus_resource(uri, headers, skip_count)

    else:
        return results

    # return results
    return items


def publish_runbook(
    space_name,
    project_name,
    runbook_name,
    octopus_server_uri=Octopus_Url,
    octopus_api_key=Octopus_Api_Key,
):
    # Define Octopus server variables
    headers = {"X-Octopus-ApiKey": octopus_api_key}

    # Get space
    uri = "{0}/api/spaces".format(octopus_server_uri)
    spaces = get_octopus_resource(uri, headers)
    space = next((x for x in spaces if x["Name"] == space_name), None)

    # Get project
    uri = "{0}/api/{1}/projects".format(octopus_server_uri, space["Id"])
    projects = get_octopus_resource(uri, headers)
    project = next((x for x in projects if x["Name"] == project_name), None)

    # Get project runbooks
    uri = "{0}/api/{1}/projects/{2}/runbooks".format(
        octopus_server_uri, space["Id"], project["Id"]
    )
    runbooks = get_octopus_resource(uri, headers)
    runbook = next((x for x in runbooks if x["Name"] == runbook_name), None)

    # Get runbook snapshot template
    uri = "{0}/api/{1}/runbookprocesses/{2}/runbooksnapshottemplate".format(
        octopus_server_uri, space["Id"], runbook["RunbookProcessId"]
    )
    runbook_snapshot_template = get_octopus_resource(uri, headers)

    # Create runbook snapshot
    runbookSnapshotJson = {
        "ProjectId": project["Id"],
        "RunbookId": runbook["Id"],
        "Name": runbook_snapshot_template["NextNameIncrement"],
        "SelectedPackages": [],
    }

    # Include any referenced packages
    for package in runbook_snapshot_template["Packages"]:
        uri = "{0}/api/{1}/feeds/{2}/packages/versions?packageId={3}".format(
            octopus_server_uri, space["Id"], package["FeedId"], package["PackageId"]
        )
        packages = get_octopus_resource(uri, headers)
        latestPackage = packages[0]  # get the latest one
        selectedPackage = {
            "ActionName": package["ActionName"],
            "Version": latestPackage["Version"],
            "PackageReferenceName": package["PackageReferenceName"],
        }

        runbookSnapshotJson["SelectedPackages"].append(selectedPackage)

    # Create snapshot
    uri = "{0}/api/{1}/runbooksnapshots".format(octopus_server_uri, space["Id"])
    response = requests.post(uri, headers=headers, json=runbookSnapshotJson)
    response.raise_for_status()

    # Get results of API call
    runbookSnapshot = json.loads(response.content.decode("utf-8"))

    # Update the runbook object
    runbook["PublishedRunbookSnapshotId"] = runbookSnapshot["Id"]
    uri = "{0}/api/{1}/runbooks/{2}".format(
        octopus_server_uri, space["Id"], runbook["Id"]
    )
    response = requests.put(uri, headers=headers, json=runbook)
    response.raise_for_status()
