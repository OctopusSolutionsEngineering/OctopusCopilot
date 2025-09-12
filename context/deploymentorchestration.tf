provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.3.8" }
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

data "octopusdeploy_project_groups" "project_group_orchestrator" {
  ids          = null
  partial_name = "${var.project_group_orchestrator_name}"
  skip         = 0
  take         = 1
}
variable "project_group_orchestrator_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Orchestrator"
}
resource "octopusdeploy_project_group" "project_group_orchestrator" {
  count = "${length(data.octopusdeploy_project_groups.project_group_orchestrator.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_orchestrator_name}"
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
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_test" {
  ids          = null
  partial_name = "Test"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_test" {
  count                        = "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? 0 : 1}"
  name                         = "Test"
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
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_production" {
  ids          = null
  partial_name = "Production"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_production" {
  count                        = "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? 0 : 1}"
  name                         = "Production"
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
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_application" {
  ids          = null
  partial_name = "Application"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_application" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? 0 : 1}"
  name        = "Application"
  description = "This is an example lifecycle that automatically deploys to the first environment"

  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    name                                  = "Development"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
    name                                  = "Test"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
    name                                  = "Production"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }

  release_retention_policy {
    quantity_to_keep = 30
    unit             = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep = 30
    unit             = "Days"
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

data "octopusdeploy_channels" "channel_deployment_orchestration_default" {
  ids          = []
  partial_name = "Default"
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

data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_" {
  feed_type    = "OctopusProject"
  ids          = null
  partial_name = "Octopus Server Releases"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"Octopus Server Releases (built-in)\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
  }
}

data "octopusdeploy_worker_pools" "workerpool_hosted_windows" {
  ids          = null
  partial_name = "Hosted Windows"
  skip         = 0
  take         = 1
}

data "octopusdeploy_channels" "channel_child_project_default" {
  ids          = []
  partial_name = "Default"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_process" "process_child_project" {
  count      = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_child_project_run_a_script" {
  count                 = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process.process_child_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : null}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hello world\""
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_child_project" {
  count      = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process.process_child_project[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_child_project_run_a_script[0].id}"]
}

variable "project_child_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Child Project"
  default     = "Child Project"
}
variable "project_child_project_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Child Project"
  default     = ""
}
variable "project_child_project_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Child Project"
  default     = ""
}
variable "project_child_project_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Child Project"
  default     = ""
}
variable "project_child_project_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_child_project" {
  ids          = null
  partial_name = "${var.project_child_project_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_child_project" {
  count                                = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_child_project_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id : data.octopusdeploy_lifecycles.system_lifecycle_firstlifecycle.lifecycles[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_orchestrator.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_orchestrator.project_groups[0].id : octopusdeploy_project_group.project_group_orchestrator[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_child_project_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_child_project_description_prefix}${var.project_child_project_description}${var.project_child_project_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_child_project" {
  count      = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}

resource "octopusdeploy_process" "process_deployment_orchestration" {
  count      = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? data.octopusdeploy_projects.project_deployment_orchestration.projects[0].id : octopusdeploy_project.project_deployment_orchestration[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_deployment_orchestration_deploy_a_release" {
  count                 = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Release"
  type                  = "Octopus.DeployRelease"
  process_id            = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? null : octopusdeploy_process.process_deployment_orchestration[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a release of another project."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "NotAcquired", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}", id = null, package_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}", properties = null }
  slug                  = "deploy-a-release"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.DeployRelease.ProjectId" = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.DeployRelease.DeploymentCondition" = "IfNotCurrentVersion"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_deployment_orchestration" {
  count      = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? null : octopusdeploy_process.process_deployment_orchestration[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? null : octopusdeploy_process_step.process_step_deployment_orchestration_deploy_a_release[0].id}"]
}

variable "project_deployment_orchestration_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Deployment Orchestration"
  default     = "Deployment Orchestration"
}
variable "project_deployment_orchestration_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Deployment Orchestration"
  default     = ""
}
variable "project_deployment_orchestration_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Deployment Orchestration"
  default     = ""
}
variable "project_deployment_orchestration_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Deployment Orchestration"
  default     = "This project is used to host \"Deploy a Release\" steps to orchestrate the deployment of child projects. This is typically used to promote a set of microservice releases across environments as a group."
}
variable "project_deployment_orchestration_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_deployment_orchestration" {
  ids          = null
  partial_name = "${var.project_deployment_orchestration_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_deployment_orchestration" {
  count                                = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_deployment_orchestration_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_application[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_orchestrator.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_orchestrator.project_groups[0].id : octopusdeploy_project_group.project_group_orchestrator[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_deployment_orchestration_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_deployment_orchestration_description_prefix}${var.project_deployment_orchestration_description}${var.project_deployment_orchestration_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_deployment_orchestration" {
  count      = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_deployment_orchestration.projects) != 0 ? data.octopusdeploy_projects.project_deployment_orchestration.projects[0].id : octopusdeploy_project.project_deployment_orchestration[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


