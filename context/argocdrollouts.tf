provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.19.3" }
  }
  required_version = ">= 1.6.0"
}

variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
}

data "octopusdeploy_lifecycles" "system_lifecycle_firstlifecycle" {
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
}

data "octopusdeploy_project_groups" "project_group_argo_cd" {
  ids          = null
  partial_name = "${var.project_group_argo_cd_name}"
  skip         = 0
  take         = 1
}
variable "project_group_argo_cd_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Argo CD"
}
resource "octopusdeploy_project_group" "project_group_argo_cd" {
  count = "${length(data.octopusdeploy_project_groups.project_group_argo_cd.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_argo_cd_name}"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_development" {
  ids          = null
  partial_name = "Development"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_development" {
  count                        = "${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? 0 : 1}"
  name                         = "Development"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = true

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
  depends_on = []
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_prod_10" {
  ids          = null
  partial_name = "Prod 10"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_prod_10" {
  count                        = "${length(data.octopusdeploy_environments.environment_prod_10.environments) != 0 ? 0 : 1}"
  name                         = "Prod 10"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = false

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_security]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_prod_50" {
  ids          = null
  partial_name = "Prod 50"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_prod_50" {
  count                        = "${length(data.octopusdeploy_environments.environment_prod_50.environments) != 0 ? 0 : 1}"
  name                         = "Prod 50"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = false

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_prod_10,octopusdeploy_environment.environment_security]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_prod_100" {
  ids          = null
  partial_name = "Prod 100"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_prod_100" {
  count                        = "${length(data.octopusdeploy_environments.environment_prod_100.environments) != 0 ? 0 : 1}"
  name                         = "Prod 100"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = false

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_prod_10,octopusdeploy_environment.environment_prod_50,octopusdeploy_environment.environment_security]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_progressive" {
  ids          = null
  partial_name = "Progressive"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_progressive" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_progressive.lifecycles) != 0 ? 0 : 1}"
  name        = "Progressive"
  description = ""

  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    name                                  = "Development"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_prod_10.environments) != 0 ? data.octopusdeploy_environments.environment_prod_10.environments[0].id : octopusdeploy_environment.environment_prod_10[0].id}"]
    name                                  = "Prod 10"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_prod_50.environments) != 0 ? data.octopusdeploy_environments.environment_prod_50.environments[0].id : octopusdeploy_environment.environment_prod_50[0].id}"]
    name                                  = "Prod 50"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_prod_100.environments) != 0 ? data.octopusdeploy_environments.environment_prod_100.environments[0].id : octopusdeploy_environment.environment_prod_100[0].id}"]
    name                                  = "Prod 100"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }

  release_retention_with_strategy {
    strategy = "Default"
  }

  tentacle_retention_with_strategy {
    strategy = "Default"
  }
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle" {
  ids          = null
  partial_name = "Default Lifecycle"
  skip         = 0
  take         = 1
}

data "octopusdeploy_channels" "channel_argo_cd_rollouts_default" {
  ids          = []
  partial_name = "Default"
  project_id   = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id : octopusdeploy_project.project_argo_cd_rollouts[0].id}"
  skip         = 0
  take         = 1
}

data "octopusdeploy_feeds" "feed_octopus_server__built_in_" {
  feed_type    = "BuiltIn"
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"BuiltIn\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
  }
}

data "octopusdeploy_feeds" "feed_ghcr_anonymous" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "GHCR Anonymous"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_docker_container_registry" "feed_ghcr_anonymous" {
  count                                = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? 0 : 1}"
  name                                 = "GHCR Anonymous"
  registry_path                        = ""
  api_version                          = "v2"
  feed_uri                             = "https://ghcrfacade-a6awccayfpcpg4cg.eastus-01.azurewebsites.net"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_github_container_registry" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "GitHub Container Registry"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_docker_container_registry" "feed_github_container_registry" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Container Registry"
  registry_path                        = ""
  api_version                          = "v2"
  feed_uri                             = "https://ghcr.io"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_worker_pools" "workerpool_default_worker_pool" {
  ids          = null
  partial_name = "Default Worker Pool"
  skip         = 0
  take         = 1
}

data "octopusdeploy_worker_pools" "workerpool_hosted_windows" {
  ids          = null
  partial_name = "Hosted Windows"
  skip         = 0
  take         = 1
}

data "octopusdeploy_environments" "environment_security" {
  ids          = null
  partial_name = "Security"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_security" {
  count                        = "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? 0 : 1}"
  name                         = "Security"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = false

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
  depends_on = [octopusdeploy_environment.environment_development]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_git_credentials" "gitcredential_mock" {
  name = "Mock"
  skip = 0
  take = 1
}
resource "octopusdeploy_git_credential" "gitcredential_mock" {
  count                   = "${length(data.octopusdeploy_git_credentials.gitcredential_mock.git_credentials) != 0 ? 0 : 1}"
  name                    = "Mock"
  type                    = "UsernamePassword"
  username                = "changeme"
  password                = "${var.gitcredential_mock_sensitive_value}"
  repository_restrictions = { allowed_repositories = ["https://mockgit.octopusdemos.com/*"], enabled = true }
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "gitcredential_mock_sensitive_value" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"Mock\""
  default     = "Change Me!"
}

resource "octopusdeploy_process" "process_argo_cd_rollouts" {
  count      = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id : octopusdeploy_project.project_argo_cd_rollouts[0].id}"
  depends_on = []
}

variable "project_argo_cd_rollouts_step_deploy_rollout_package_rollouts_demo_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named rollouts-demo from step Deploy Rollout in project Argo CD Rollouts"
  default     = "octopussolutionsengineering/rollouts-demo"
}
resource "octopusdeploy_process_step" "process_step_argo_cd_rollouts_deploy_rollout" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  name                  = "Deploy Rollout"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_rollouts[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  excluded_environments = null
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "${length(data.octopusdeploy_git_credentials.gitcredential_mock.git_credentials) != 0 ? data.octopusdeploy_git_credentials.gitcredential_mock.git_credentials[0].id : octopusdeploy_git_credential.gitcredential_mock[0].id}", git_credential_type = "Library", github_connection_id = "", repository_uri = "https://mockgit.octopusdemos.com/repo/argorollout" } }
  package_requirement   = "LetOctopusDecide"
  packages              = { rollouts-demo = { acquisition_location = "NotAcquired", feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", id = null, package_id = "${var.project_argo_cd_rollouts_step_deploy_rollout_package_rollouts_demo_packageid}", properties = { Extract = "False", Purpose = "DockerImageReference", SelectionMode = "immediate" }, version = null } }
  slug                  = "deploy-rollout"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Mock"
      }
  execution_properties  = {
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "Octopus.Action.AutoRetry.MinimumBackoff" = "15"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "False"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.KubernetesContainers.DeploymentWait" = "NoWait"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.AutoRetry.MaximumCount" = "3"
        "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "template/rollout.yaml"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
      }
}

resource "octopusdeploy_process_step" "process_step_argo_cd_rollouts_get_rollout" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  name                  = "Get Rollout"
  type                  = "Octopus.KubernetesRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_rollouts[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "get-rollout"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  depends_on            = [octopusdeploy_process_step.process_step_argo_cd_rollouts_deploy_rollout]
  properties            = {
        "Octopus.Action.TargetRoles" = "Mock"
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = <<EOT
# The mock server can have many instances,
# and they do not sync state.
# Retry them all to get the instance that has the rollout created.
for ((count = 0; count < 30; count++)); do
  RESULT=$(kubectl get rollout rollouts-demo -o yaml 2>&1)
  if [ $? -eq 0 ]; then
    echo "$RESULT"
    exit 0
  fi
  sleep 1
done
echo "Didn't find the rollout resource"
exit 0
EOT
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_argo_cd_rollouts_link_to_repo" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  name                  = "Link to Repo"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_rollouts[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "link-to-repo"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Workerpool"
  depends_on            = [octopusdeploy_process_step.process_step_argo_cd_rollouts_get_rollout]
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = "Write-Highlight \"[Browse Git Repository](https://mockgit.octopusdemos.com/browse/$($OctopusParameters[\"Project.MockGit.Username\"])/argorollout)\""
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_argo_cd_rollouts_promote_rollout" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  name                  = "Promote Rollout"
  type                  = "Octopus.KubernetesRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_rollouts[0].id}"
  channels              = null
  condition             = "Success"
  container             = { dockerfile = null, feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", git_url = null, image = "octopusdeploylabs/argocd-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-kubectl-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Workerpool"
  depends_on            = [octopusdeploy_process_step.process_step_argo_cd_rollouts_link_to_repo]
  properties            = {
        "Octopus.Action.TargetRoles" = "Mock"
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.AutoRetry.MaximumCount" = "0"
        "Octopus.Action.Script.ScriptBody" = <<EOT
# The mock server can have many instances,
# and they do not sync state.
# Retry them all to get the instance that has the rollout created.
for ((count = 0; count < 30; count++)); do
  RESULT=$(kubectl argo rollouts promote rollouts-demo 2>&1)
  if [ $? -eq 0 ]; then
    echo "$RESULT"
    exit 0
  fi
  sleep 1
done
echo "Didn't find the rollout resource"
exit 0
EOT
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_argo_cd_rollouts" {
  count      = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_rollouts[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process_step.process_step_argo_cd_rollouts_deploy_rollout[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process_step.process_step_argo_cd_rollouts_get_rollout[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process_step.process_step_argo_cd_rollouts_link_to_repo[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? null : octopusdeploy_process_step.process_step_argo_cd_rollouts_promote_rollout[0].id}"]
}

resource "octopusdeploy_variable" "argo_cd_rollouts_project_image_1" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) == 0 ?octopusdeploy_project.project_argo_cd_rollouts[0].id : data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id}"
  value        = "#{Octopus.Action.Package[rollouts-demo].Image}"
  name         = "Project.Image"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_variable" "argo_cd_rollouts_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) == 0 ?octopusdeploy_project.project_argo_cd_rollouts[0].id : data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  name         = "Project.Workerpool"
  type         = "WorkerPool"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "argo_cd_rollouts_project_mockgit_username_1" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) == 0 ?octopusdeploy_project.project_argo_cd_rollouts[0].id : data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id}"
  value        = "ChangeMe"
  name         = "Project.MockGit.Username"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "argo_cd_rollouts_octopusprintvariables_1" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) == 0 ?octopusdeploy_project.project_argo_cd_rollouts[0].id : data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id}"
  value        = "False"
  name         = "OctopusPrintVariables"
  type         = "String"
  description  = "Set this variable to True to enable variable debugging"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "project_argo_cd_rollouts_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Argo CD Rollouts"
  default     = "Argo CD Rollouts"
}
variable "project_argo_cd_rollouts_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Argo CD Rollouts"
  default     = ""
}
variable "project_argo_cd_rollouts_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Argo CD Rollouts"
  default     = ""
}
variable "project_argo_cd_rollouts_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Argo CD Rollouts"
  default     = ""
}
variable "project_argo_cd_rollouts_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_argo_cd_rollouts" {
  ids          = null
  partial_name = "${var.project_argo_cd_rollouts_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_argo_cd_rollouts" {
  count                                = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_argo_cd_rollouts_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_progressive.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_progressive.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_progressive[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_argo_cd.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_argo_cd.project_groups[0].id : octopusdeploy_project_group.project_group_argo_cd[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_argo_cd_rollouts_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_argo_cd_rollouts_description_prefix}${var.project_argo_cd_rollouts_description}${var.project_argo_cd_rollouts_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_argo_cd_rollouts" {
  count      = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_argo_cd_rollouts.projects) != 0 ? data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id : octopusdeploy_project.project_argo_cd_rollouts[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}


