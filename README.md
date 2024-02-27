This project provides an agent for GitHub's Copilot that can query an Octopus
Server. It is deployed as an Azure functions app, and integrates with the
Azure OpenAI service.

# Creating a service account

This agent requires an account to interact with Octopus. This is best done with a
[service account](https://octopus.com/docs/security/users-and-teams/service-accounts).

To limit the agent's access, it is recommended that you create a team and role that has only read access to Octopus.

A sample Terraform configuration file has been provided to create a read-only service account, team, and role.

Save the
file [team.tf](https://github.com/OctopusSolutionsEngineering/OctopusCopilot/blob/main/octopus/serviceaccount/team.tf)
locally and apply it with the following commands (replacing the variables with your own values):

```shell
terraform init
terraform apply -var=octopus_server=https://yourinstance.octopus.app -var=octopus_api_key=API-XXXXXXXX -var=octopus_space_id=Spaces-x
```

This creates a service account, team, and user role called `Copilot`. The role includes permissions to view Octopus
resources, but not to modify them.

# Test Coverage

![coverage badge](./coverage.svg)
