variable "project_project5_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Long running script"
  default     = "Long running script"
}
variable "project_project5_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Long running script"
  default     = ""
}
variable "project_project5_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Long running script"
  default     = ""
}
variable "project_project5_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Long running script"
  default     = ""
}
variable "project_project5_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
resource "octopusdeploy_project" "project_project5" {
  name                                 = "${var.project_project5_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "On"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${octopusdeploy_lifecycle.lifecycle_application.id}"
  project_group_id                     = "${octopusdeploy_project_group.project_group_test.id}"
  included_library_variable_sets = []
  tenanted_deployment_participation    = "TenantedOrUntenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
  }

  lifecycle {
    ignore_changes = []
  }
}