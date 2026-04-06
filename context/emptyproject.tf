provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.10.2" }
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

data "octopusdeploy_channels" "channel_empty_project_default" {
  ids          = []
  partial_name = "Default"
  project_id   = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? data.octopusdeploy_projects.project_empty_project.projects[0].id : octopusdeploy_project.project_empty_project[0].id}"
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

resource "octopusdeploy_process" "process_empty_project" {
  count      = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? data.octopusdeploy_projects.project_empty_project.projects[0].id : octopusdeploy_project.project_empty_project[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_steps_order" "process_step_order_empty_project" {
  count      = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? null : octopusdeploy_process.process_empty_project[0].id}"
  steps      = []
}

variable "project_empty_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Empty Project"
  default     = "Empty Project"
}
variable "project_empty_project_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Empty Project"
  default     = ""
}
variable "project_empty_project_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Empty Project"
  default     = ""
}
variable "project_empty_project_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Empty Project"
  default     = ""
}
variable "project_empty_project_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_empty_project" {
  ids          = null
  partial_name = "${var.project_empty_project_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_empty_project" {
  count                                = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_empty_project_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id : data.octopusdeploy_lifecycles.system_lifecycle_firstlifecycle.lifecycles[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_empty_project_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_empty_project_description_prefix}${var.project_empty_project_description}${var.project_empty_project_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_empty_project" {
  count      = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_empty_project.projects) != 0 ? data.octopusdeploy_projects.project_empty_project.projects[0].id : octopusdeploy_project.project_empty_project[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}


