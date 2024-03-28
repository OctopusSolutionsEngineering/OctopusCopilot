variable "project_octofx_git_base_path" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The git base path for \"OctoFX\""
  default     = ".octopus/octofx"
}
variable "project_octofx_git_url" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The git url for \"OctoFX\""
  default     = "https://github.com/mcasperson/demo.octopus.app"
}
variable "project_octofx_git_protected_branches" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The protected branches for \"OctoFX\""
  default     = "[]"
}
resource "octopusdeploy_project" "project_octofx" {
  id                                   = "Projects-2398"
  name                                 = "OctoFX"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = true
  lifecycle_id                         = ""
  project_group_id                     = ""
  included_library_variable_sets       = [""]
  tenanted_deployment_participation    = "Untenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  git_library_persistence_settings {
    git_credential_id  = "${octopusdeploy_git_credential.gitcredential_cac.id}"
    url                = "${var.project_octofx_git_url}"
    base_path          = "${var.project_octofx_git_base_path}"
    default_branch     = "main"
    protected_branches = "${jsondecode(var.project_octofx_git_protected_branches)}"
  }

  lifecycle {
    ignore_changes = ["connectivity_policy"]
  }
  description = "Repository: [Azure DevOps](https://dev.azure.com/octopussamples/OctoFX/_git/Demo)"
}

resource "octopusdeploy_space" "octopus_space_matthew_casperson" {
  id                          = "Spaces-792"
  description                 = "Matthew Casperson's demo space"
  name                        = "${var.octopus_space_name}"
  is_default                  = false
  is_task_queue_stopped       = false
  space_managers_team_members = null
  space_managers_teams        = ["${var.octopus_space_managers}"]
}

resource "octopusdeploy_channel" "channel__hotfix" {
  id           = "Channels-3063"
  lifecycle_id = ""
  name         = "Hotfix"
  description  = ""
  project_id   = "${octopusdeploy_project.project_octofx.id}"
  is_default   = false

  rule {

    action_package {
      deployment_action = "deploy-database-changes"
    }
    action_package {
      deployment_action = "deploy-rate-service"
    }
    action_package {
      deployment_action = "deploy-trading-site"
    }

    tag           = "^hotfix$"
    version_range = ""
  }

  tenant_tags = []
  depends_on  = [octopusdeploy_deployment_process.deployment_process_octofx]
}

resource "octopusdeploy_channel" "channel__stable" {
  id           = "Channels-3062"
  lifecycle_id = ""
  name         = "Stable"
  project_id   = "${octopusdeploy_project.project_octofx.id}"
  is_default   = true

  rule {

    action_package {
      deployment_action = "deploy-database-changes"
    }
    action_package {
      deployment_action = "deploy-rate-service"
    }
    action_package {
      deployment_action = "deploy-trading-site"
    }

    tag           = "^$"
    version_range = ""
  }

  tenant_tags = []
  depends_on  = [octopusdeploy_deployment_process.deployment_process_octofx]
}

resource "octopusdeploy_deployment_process" "deployment_process_octofx" {
  project_id = "${octopusdeploy_project.project_octofx.id}"
  depends_on = []
  lifecycle {
    ignore_changes = all
  }
}

resource "octopusdeploy_environment" "environment_development" {
  id                           = "Environments-1022"
  name                         = "Development"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = true
  sort_order                   = 0

  jira_extension_settings {
    environment_type = "development"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = true
  }
}

resource "octopusdeploy_git_credential" "gitcredential_cac" {
  id       = "GitCredentials-221"
  name     = "CaC"
  type     = "UsernamePassword"
  username = "mcasperson"
  password = "${var.gitcredential_cac}"
}
variable "gitcredential_cac" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"CaC\""
}

resource "octopusdeploy_git_credential" "gitcredential_demo_space_creator_app" {
  id       = "GitCredentials-923"
  name     = "Demo Space Creator App"
  type     = "UsernamePassword"
  username = "x-access-token"
  password = "${var.gitcredential_demo_space_creator_app}"
}
variable "gitcredential_demo_space_creator_app" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"Demo Space Creator App\""
}

