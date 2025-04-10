variable "project_project3_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Copilot manual approval"
  default     = "Copilot manual approval"
}
variable "project_project3_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Copilot manual approval"
  default     = ""
}
variable "project_project3_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Copilot manual approval"
  default     = ""
}
variable "project_project3_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Copilot manual approval"
  default     = ""
}
variable "project_project3_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
resource "octopusdeploy_project" "project_project3" {
  name                                 = "${var.project_project3_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "On"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${octopusdeploy_lifecycle.lifecycle_application.id}"
  project_group_id                     = "${octopusdeploy_project_group.project_group_test.id}"
  included_library_variable_sets       = []
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
resource "octopusdeploy_variable" "project3_variable_1" {
  owner_id     = "${octopusdeploy_project.project_project3.id}"
  value        = "ATestVariable"
  name         = "A.Test.Variable"
  type         = "String"
  is_sensitive = false
}
