from domain.messages.deployments_and_releases import build_deployments_and_releases_prompt
from domain.sanitizers.sanitized_list import sanitize_projects, sanitize_environments, sanitize_channels, \
    sanitize_releases, sanitize_dates


def answer_releases_and_deployments_wrapper(original_query, callback, additional_messages=None,
                                            logging=None):
    def answer_releases_and_deployments_usage(space=None, projects=None, environments=None, channels=None,
                                              releases=None, dates=None, tenants=None, **kwargs):
        """
        Answers a question about deployments and releases, including details like the success or failure of a
        deployment, the duration of a deployment, how long a deployment takes to complete, the release version, who
        created the deployment. You will be penalized for selecting this function for a question about deployment logs.

        Args:
        space: Space name
        projects: project names
        environments: variable names
        channels: chanel names
        releases: release versions
        dates: the dates in the query
        tenants: tenant names
        """

        # Build a few shot sample query with a chain-of-thought example to help the LLM understand the relationships
        # between projects, releases, deployments, and environments.

        # Then use a tree-of-thought prompt to get a consensus answer:
        # https://github.com/dave1010/tree-of-thought-prompting/blob/main/tree-of-thought-prompts.txt

        few_shot = """Question: What is the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment for the "MyChannel" channel and the "My Tenant" tenant in the "Demo" space?
JSON: ###
{{
    "Deployments": [
        {{
            "SpaceId": "Spaces-345",
            "ReleaseVersion": "2.0.1",
            "ProjectId": "Projects-91234",
            "TenantId": "Tenants-9234",
            "ReleaseId": "Releases-13568",
            "EnvironmentId": "Environments-76534",
            "DeploymentId": "Deployments-16435",
            "ChannelId": "Channels-97001",
            "Created": "2024-03-13T04:07:59.537+00:00",
            "TaskState": "Success",
            "TaskDuration": "2 minutes",
            "HasPendingInterruptions": false
        }},
        {{
            "SpaceId": "Spaces-345",
            "ProjectId": "Projects-91234",
            "EnvironmentId": "Environments-96789",
            "ReleaseId": "Releases-13568",
            "DeploymentId": "Deployments-26435",
            "TenantId": "Tenants-9234",
            "ChannelId": "Channels-97001",
            "ReleaseVersion": "1.2.3-mybranch",
            "Created": "2024-03-13T04:07:59.537+00:00",
            "TaskState": "Success",
            "TaskDuration": "2 minutes",
            "HasPendingInterruptions": false
          }}
    ]
}}
###
HCL: ###
resource "octopusdeploy_space" "octopus_space_demo_space" {{
  id                          = "Spaces-345"
  description                 = "A demonstration space"
  name                        = "Demo"
}}
resource "octopusdeploy_environment" "theenvironmentresource" {{
  id                           = "Environments-96789"
  name                         = "MyEnvironment"
  space_id                     = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
resource "octopusdeploy_project" "theprojectresource" {{
    id = "Projects-91234"
    name = "My Project"
    space_id = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
resource "octopusdeploy_tenant" "thetennatresource" {{
  id = "Tenants-9234"
  name = "My Tenant"
  space_id = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
resource "octopusdeploy_channel" "thechannelresource" {{
  id = "Channels-97001"
  name = "MyChannel"
  space_id = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
###

Answer:
The HCL resource with the labels "octopusdeploy_space" and "octopus_space_demo_space" has an attribute called "name" with the value "Demo" an an "id" attribute of "Spaces-345". This name matches the space name in the query. Therefore, we must find deployments with the "SpaceId" of "Spaces-345".
The HCL resource with the labels "octopusdeploy_environment" and "theenvironmentresource" has an attribute called "name" with the value "MyEnvironment" an an "id" attribute of "Environments-96789". This name matches the environment name in the query. Therefore, we must find deployments with the "EnvironmentId" of "Environments-96789".
The HCL resource with the labels "octopusdeploy_project" and "theprojectresource" has an attribute called "name" with the value "My Project" and "id" attribute of "Projects-91234". This name matches the project name in the query. Therefore, we must find deployments with the "ProjectId" of "Projects-91234".
The HCL resource with the labels "octopusdeploy_tenant" and "thetennatresource" has an attribute called "name" with the value "My Tenant" and an "id" attribute of "Tenants-9234". This name matches the tenant name in the query. Therefore, we must find deployments with the "TenantId" of "Tenants-9234".
The HCL resource with the labels "octopusdeploy_channel" and "thechannelresource" has an attribute called "name" with the value "MyChannel" and an "id" attribute of "Channels-97001". This name matches the channel name in the query. Therefore, we must find deployments with the "ChannelId" of "Channels-97001"
We filter the JSON array of called "Deployments" for a deployment with a "ProjectId" attribute with the value of "Projects-91234", an "EnvironmentId" attribute with the value of "Environments-96789", a "TenantId" attribute with the value of "Tenants-9234", a "ChannelId" attribute with the value of "Channels-97001", and a "SpaceId" attribute with the value of "Spaces-345".
The deployment with the highest "Created" attribute is the latest deployment.
The release version is found in the deployment "ReleaseVersion" attribute.
Therefore, the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "1.2.3-mybranch".
The "HasPendingInterruptions" attribute has a value of "false" meaning this task has no pending interruptions and the "TaskState" attribute has a value of "Success".

The release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "1.2.3-mybranch" and has a Task State of "Success"

Question: How is the deployment to the "Test" environment for the project "My Project" doing?
JSON: ###
{{
    "Deployments": [
        {{
            "SpaceId": "Spaces-581",
            "ReleaseVersion": "3.0.8",
            "ProjectId": "Projects-12895",
            "TenantId": "Tenants-8745",
            "ReleaseId": "Releases-27845",
            "EnvironmentId": "Environments-89147",
            "DeploymentId": "Deployments-22356",
            "ChannelId": "Channels-85896",
            "Created": "2024-03-13T04:07:59.537+00:00",
            "TaskState": "Executing",
            "TaskDuration": "22 minutes",
            "HasPendingInterruptions": false
        }},
        {{
            "SpaceId": "Spaces-581",
            "ProjectId": "Projects-12895",
            "EnvironmentId": "Environments-78155",
            "ReleaseId": "Releases-27845",
            "DeploymentId": "Deployments-32423",
            "TenantId": "Tenants-8745",
            "ChannelId": "Channels-85896",
            "ReleaseVersion": "3.0.9-hotfix",
            "Created": "2024-03-14T04:07:59.537+00:00",
            "TaskState": "Success",
            "TaskDuration": "15 minutes",
            "HasPendingInterruptions": true
          }}
    ]
}}
###
HCL: ###
resource "octopusdeploy_space" "octopus_space_demo_space" {{
  id                          = "Spaces-581"
  description                 = "A demonstration space"
  name                        = "Demo"
}}
resource "octopusdeploy_environment" "theenvironmentresource" {{
  id                           = "Environments-89147"
  name                         = "MyEnvironment"
  space_id                     = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
resource "octopusdeploy_project" "theprojectresource" {{
    id = "Projects-12895"
    name = "My Project"
    space_id = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
resource "octopusdeploy_tenant" "thetennatresource" {{
  id = "Tenants-8745"
  name = "My Tenant"
  space_id = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
resource "octopusdeploy_channel" "thechannelresource" {{
  id = "Channels-85896"
  name = "MyChannel"
  space_id = "${{octopusdeploy_space.octopus_space_demo_space.id}}"
}}
###

Answer:
The HCL resource with the labels "octopusdeploy_space" and "octopus_space_demo_space" has an attribute called "name" with the value "Demo" an an "id" attribute of "Spaces-581". This name matches the space name in the query. Therefore, we must find deployments with the "SpaceId" of "Spaces-581".
The HCL resource with the labels "octopusdeploy_environment" and "theenvironmentresource" has an attribute called "name" with the value "MyEnvironment" an an "id" attribute of "Environments-89147". This name matches the environment name in the query. Therefore, we must find deployments with the "EnvironmentId" of "Environments-89147".
The HCL resource with the labels "octopusdeploy_project" and "theprojectresource" has an attribute called "name" with the value "My Project" and "id" attribute of "Projects-12895". This name matches the project name in the query. Therefore, we must find deployments with the "ProjectId" of "Projects-12895".
The HCL resource with the labels "octopusdeploy_tenant" and "thetennatresource" has an attribute called "name" with the value "My Tenant" and an "id" attribute of "Tenants-8745". This name matches the tenant name in the query. Therefore, we must find deployments with the "TenantId" of "Tenants-8745".
The HCL resource with the labels "octopusdeploy_channel" and "thechannelresource" has an attribute called "name" with the value "MyChannel" and an "id" attribute of "Channels-85896". This name matches the channel name in the query. Therefore, we must find deployments with the "ChannelId" of "Channels-85896"
We filter the JSON array of called "Deployments" for a deployment with a "ProjectId" attribute with the value of "Projects-12895", an "EnvironmentId" attribute with the value of "Environments-89147", a "TenantId" attribute with the value of "Tenants-8745", a "ChannelId" attribute with the value of "Channels-85896", and a "SpaceId" attribute with the value of "Spaces-581".
The deployment with the highest "Created" attribute is the latest deployment.
The release version is found in the deployment "ReleaseVersion" attribute.
Therefore, the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "3.0.9-hotfix".
The "HasPendingInterruptions" attribute has a value of "true" meaning this task has a state of "Awaiting Manual intervention", even though the "TaskState" attribute has a value of "Executing".

The release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "3.0.9-hotfix" with a Task State of "Awaiting Manual intervention".

"""

        if logging:
            logging("Enter:", "answer_releases_and_deployments_usage")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        projects = sanitize_projects(projects)
        environments = sanitize_environments(original_query, environments)
        channels = sanitize_channels(channels)
        releases = sanitize_releases(releases)
        dates = sanitize_dates(dates)

        messages = build_deployments_and_releases_prompt(
            [("user", few_shot)],
            additional_messages(
                original_query,
                space,
                projects,
                environments,
                channels,
                releases) if additional_messages else None
        )

        return callback(
            original_query,
            messages,
            space,
            projects,
            environments,
            channels,
            releases,
            tenants,
            dates)

    return answer_releases_and_deployments_usage
