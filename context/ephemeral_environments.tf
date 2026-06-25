provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.14.0" }
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

variable "project_group_default_project_group_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Default Project Group"
}
data "octopusdeploy_project_groups" "project_group_default_project_group" {
  ids          = null
  partial_name = "${var.project_group_default_project_group_name}"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a project group called $${var.project_group_default_project_group_name}. This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.project_groups) != 0
    }
  }
}

data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle" {
  ids          = null
  partial_name = "Default Lifecycle"
  skip         = 0
  take         = 1
}

data "octopusdeploy_channels" "channel_ephemeral_environments_default" {
  ids          = []
  partial_name = "Default"
  project_id   = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? data.octopusdeploy_projects.project_ephemeral_environments.projects[0].id : octopusdeploy_project.project_ephemeral_environments[0].id}"
  skip         = 0
  take         = 1
}

data "octopusdeploy_environments" "parent_environment_features" {
  ids          = null
  partial_name = "Features"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_parent_environment" "parent_environment_features" {
  count                         = "${length(data.octopusdeploy_environments.parent_environment_features.environments) != 0 ? 0 : 1}"
  space_id                      = "${trimspace(var.octopus_space_id)}"
  name                          = "Features"
  use_guided_failure            = false
  automatic_deprovisioning_rule = { days = 7, hours = 0 }
  depends_on                    = []
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_projects" "channel_ephemeral_environments_features" {
  ids          = null
  partial_name = "Ephemeral Environments"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_channel" "channel_ephemeral_environments_features" {
  count                               = "${length(data.octopusdeploy_projects.channel_ephemeral_environments_features.projects) != 0 ? 0 : 1}"
  ephemeral_environment_name_template = "#{Octopus.Release.CustomFields[FeatureBranch]}"
  parent_environment_id               = "${length(data.octopusdeploy_environments.parent_environment_features.environments) != 0 ? data.octopusdeploy_environments.parent_environment_features.environments[0].id : octopusdeploy_parent_environment.parent_environment_features[0].id}"
  name                                = "Features"
  description                         = ""
  project_id                          = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? data.octopusdeploy_projects.project_ephemeral_environments.projects[0].id : octopusdeploy_project.project_ephemeral_environments[0].id}"
  is_default                          = false
  custom_field_definitions            = [{ description = "The name of the feature branch", field_name = "FeatureBranch" }]
  tenant_tags                         = []
  depends_on                          = [octopusdeploy_process_steps_order.process_step_order_ephemeral_environments]
  type                                = "EphemeralEnvironment"
  lifecycle {
    prevent_destroy = true
  }
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

resource "octopusdeploy_process" "process_ephemeral_environments" {
  count      = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? data.octopusdeploy_projects.project_ephemeral_environments.projects[0].id : octopusdeploy_project.project_ephemeral_environments[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_ephemeral_environments_run_a_script" {
  count                 = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? null : octopusdeploy_process.process_ephemeral_environments[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = "echo \"A sample script\""
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_ephemeral_environments" {
  count      = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? null : octopusdeploy_process.process_ephemeral_environments[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? null : octopusdeploy_process_step.process_step_ephemeral_environments_run_a_script[0].id}"]
}

variable "project_ephemeral_environments_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Ephemeral Environments"
  default     = "Ephemeral Environments"
}
variable "project_ephemeral_environments_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Ephemeral Environments"
  default     = ""
}
variable "project_ephemeral_environments_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Ephemeral Environments"
  default     = ""
}
variable "project_ephemeral_environments_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Ephemeral Environments"
  default     = ""
}
variable "project_ephemeral_environments_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_ephemeral_environments" {
  ids          = null
  partial_name = "${var.project_ephemeral_environments_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_ephemeral_environments" {
  count                                = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_ephemeral_environments_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id : data.octopusdeploy_lifecycles.system_lifecycle_firstlifecycle.lifecycles[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_ephemeral_environments_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_ephemeral_environments_description_prefix}${var.project_ephemeral_environments_description}${var.project_ephemeral_environments_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_ephemeral_environments" {
  count      = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_ephemeral_environments.projects) != 0 ? data.octopusdeploy_projects.project_ephemeral_environments.projects[0].id : octopusdeploy_project.project_ephemeral_environments[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}


