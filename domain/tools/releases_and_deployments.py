def answer_releases_and_deployments_callback(original_query, callback, logging=None):
    def answer_releases_and_deployments_usage(space=None, projects=None, environments=None, channels=None,
                                              releases=None, **kwargs):
        """Answers a question about deployments and releases.

        Args:
        space: Space name
        projects: project names
        environments: variable names
        channels: chanel names
        releases: release versions
        """

        if logging:
            logging("Enter:", "answer_releases_and_deployments_usage")

        # Build a few shot sample query with a chain-of-thought example to help the LLM understand the relationships
        # between projects, releases, deployments, and environments.

        few_shot = f"""
Task: Given the HCL representation of a project and environment; and a JSON representation of deployments and release, what is the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment for the "MyChannel" channel and the "My Tenant" tenant?

Example 1:
HCL: ###
resource "octopusdeploy_environment" "theenvironmentresource" {{
  id                           = "Environments-96789"
  name                         = "MyEnvironment"
}}
resource "octopusdeploy_project" "theprojectresource" {{
    id = "Projects-91234"
    name = "My Project"
}}
resource "octopusdeploy_tenant" "thetennatresource" {{
  id = "Tenants-9234"
  name = "My Tenant"
}}
resource "octopusdeploy_channel" "thechannelresource" {{
  id = "Channels-97001"
  name = "MyChannel"
}}
###
JSON: ###
[
    {{
        "Id": "Deployments-16435",
        "ProjectId": "Projects-91234",
        "EnvironmentId": "Environments-76534",
        "ReleaseId": "Releases-13568",
        "DeploymentId": "Deployments-16435",
        "TaskId": "ServerTasks-701983",
        "TenantId": "Tenants-9234",
        "ChannelId": "Channels-97001",
        "ReleaseVersion": "2.0.1",
        "Created": "2024-03-13T04:07:59.537+00:00",
        "QueueTime": "2024-03-13T04:07:59.537+00:00",
        "StartTime": "2024-03-13T04:08:00.196+00:00",
        "CompletedTime": "2024-03-13T04:08:47.885+00:00",
        "State": "Success"
    }},
    {{
        "Id": "Deployments-26435",
        "ProjectId": "Projects-91234",
        "EnvironmentId": "Environments-96789",
        "ReleaseId": "Releases-13568",
        "DeploymentId": "Deployments-26435",
        "TaskId": "ServerTasks-701983",
        "TenantId": "Tenants-9234",
        "ChannelId": "Channels-97001",
        "ReleaseVersion": "1.2.3-mybranch",
        "Created": "2024-03-13T04:07:59.537+00:00",
        "QueueTime": "2024-03-13T04:07:59.537+00:00",
        "StartTime": "2024-03-13T04:08:00.196+00:00",
        "CompletedTime": "2024-03-13T04:08:47.885+00:00",
        "State": "Success"
      }}
]
###
Output:
The HCL resource with the labels "octopusdeploy_environment" and "theenvironmentresource" has an attribute called "name" with the value "MyEnvironment". This name matches the environment name in the query. Therefore, this is the environment we base the answer on.
The HCL resource with the labels "octopusdeploy_project" and "theprojectresource" has an attribute called "name" with the value "My Project". This name matches the project name in the query. Therefore, this is the project we base the answer on.
The HCL resource with the labels "octopusdeploy_tenant" and "thetennatresource" has an attribute called "name" with the value "My Tenant". This name matches the tenant name in the query. Therefore, this is the tenant we base the answer on.
The HCL resource with the labels "octopusdeploy_channel" and "thechannelresource" has an attribute called "name" with the value "MyChannel". This name matches the channel name in the query. Therefore, this is the channel we base the answer on.
We filter the JSON array of deployments for a items with a "ProjectId" attribute with the value of "Projects-91234", an "EnvironmentId" attribute with the value of "Environments-96789", a "TenantId" attribute with the value of "Tenants-9234", and a "ChannelId" attribute with the value of "Channels-97001".
The deployment with the highest "StartTime" attribute is the latest deployment.
The release version is found in the deployment "ReleaseVersion" attribute.
Therefore, the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "1.2.3-mybranch".

The answer:
The release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "1.2.3-mybranch"

Question: {original_query}
"""

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, few_shot, space, projects, environments, channels, releases)

    return answer_releases_and_deployments_usage
