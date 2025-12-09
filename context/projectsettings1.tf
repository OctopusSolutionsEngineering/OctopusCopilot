provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.6.0" }
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

data "octopusdeploy_channels" "channel_project_settings_example_default" {
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

resource "octopusdeploy_process" "process_project_settings_example" {
  count      = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? data.octopusdeploy_projects.project_project_settings_example.projects[0].id : octopusdeploy_project.project_project_settings_example[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_steps_order" "process_step_order_project_settings_example" {
  count      = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? null : octopusdeploy_process.process_project_settings_example[0].id}"
  steps      = []
}

variable "project_project_settings_example_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Project Settings Example"
  default     = "Project Settings Example"
}
variable "project_project_settings_example_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Project Settings Example"
  default     = ""
}
variable "project_project_settings_example_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Project Settings Example"
  default     = ""
}
variable "project_project_settings_example_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Project Settings Example"
  default     = "This project includes examples of project level settings like:\n\n* Guided Failure Mode\n* Deployment Targets Required\n* Transient Deployment Targets\n* Force Package Download"
}
variable "project_project_settings_example_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
variable "project_project_settings_example_jsm_connection_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Jira Service Manager Connection ID for project Project Settings Example"
  default     = "8e5deac587294c26b432c9b389fd1772"
}
variable "project_project_settings_example_jsm_service_desk_project_name" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Jira Service Manager Service Desk Project Name for project Project Settings Example"
  default     = "myproject"
}
variable "project_project_settings_example_snow_connection_id" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Jira Service Manager Connection ID for project Project Settings Example"
  default     = "a9ba951dd84f49a3ab4b748a6ea94a55"
}
variable "project_project_settings_example_snow_standard_change_template_name" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The Jira Service Manager Service Desk Project Name for project Project Settings Example"
}
data "octopusdeploy_projects" "project_project_settings_example" {
  ids          = null
  partial_name = "${var.project_project_settings_example_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_project_settings_example" {
  count                                = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_project_settings_example_name}"
  default_guided_failure_mode          = "On"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id : data.octopusdeploy_lifecycles.system_lifecycle_firstlifecycle.lifecycles[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_project_settings_example_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = true
    skip_machine_behavior           = "SkipUnavailableMachines"
    target_roles                    = ["TestMe"]
  }

  jira_service_management_extension_settings {
    connection_id             = "${var.project_project_settings_example_jsm_connection_id}"
    is_enabled                = true
    service_desk_project_name = "${var.project_project_settings_example_jsm_service_desk_project_name}"
  }

  servicenow_extension_settings {
    connection_id                       = "${var.project_project_settings_example_snow_connection_id}"
    is_enabled                          = true
    is_state_automatically_transitioned = false
    standard_change_template_name       = "${var.project_project_settings_example_snow_standard_change_template_name}"
  }
  description = "${var.project_project_settings_example_description_prefix}${var.project_project_settings_example_description}${var.project_project_settings_example_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_project_settings_example" {
  count      = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? data.octopusdeploy_projects.project_project_settings_example.projects[0].id : octopusdeploy_project.project_project_settings_example[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}


