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

        # Then use a tree-of-thought prompt to get a consensus answer:
        # https://github.com/dave1010/tree-of-thought-prompting/blob/main/tree-of-thought-prompts.txt

        few_shot = f"""
Task: What is the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment for the "MyChannel" channel and the "My Tenant" tenant?

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
The HCL resource with the labels "octopusdeploy_environment" and "theenvironmentresource" has an attribute called "name" with the value "MyEnvironment" an an "id" attribute of "Environments-96789". This name matches the environment name in the query. Therefore, we must find deployments with the "EnvironmentId" of "Environments-96789".
The HCL resource with the labels "octopusdeploy_project" and "theprojectresource" has an attribute called "name" with the value "My Project" and "id" attribute of "Projects-91234". This name matches the project name in the query. Therefore, we must find deployments with the "ProjectId" of "Projects-91234".
The HCL resource with the labels "octopusdeploy_tenant" and "thetennatresource" has an attribute called "name" with the value "My Tenant" and an "id" attribute of "Tenants-9234". This name matches the tenant name in the query. Therefore, we must find deployments with the "TenantId" of "Tenants-9234".
The HCL resource with the labels "octopusdeploy_channel" and "thechannelresource" has an attribute called "name" with the value "MyChannel" and an "id" attribute of "Channels-97001". This name matches the channel name in the query. Therefore, we must find deployments with the "ChannelId" of "Channels-97001"
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
