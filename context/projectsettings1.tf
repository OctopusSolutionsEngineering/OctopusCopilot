provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.0.1" }
  }
  required_version = ">= 1.6.0"
}

variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
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
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a lifecycle called \"Default Lifecycle\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.lifecycles) != 0
    }
  }
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

resource "octopusdeploy_deployment_process" "deployment_process_project_settings_example" {
  count      = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? data.octopusdeploy_projects.project_project_settings_example.projects[0].id : octopusdeploy_project.project_project_settings_example[0].id}"
  depends_on = []
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
data "octopusdeploy_projects" "project_project_settings_example" {
  ids          = null
  partial_name = "${var.project_project_settings_example_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_project_settings_example" {
  count                                = "${length(data.octopusdeploy_projects.project_project_settings_example.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_project_settings_example_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "On"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_project_settings_example_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = true
    skip_machine_behavior           = "SkipUnavailableMachines"
  }

  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
  }
  description = "${var.project_project_settings_example_description_prefix}${var.project_project_settings_example_description}${var.project_project_settings_example_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


