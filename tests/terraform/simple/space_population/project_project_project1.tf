variable "project_project1_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Deploy Web App Container"
  default     = "Deploy Web App Container"
}
variable "project_project1_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Project1"
  default     = ""
}
variable "project_project1_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Project1"
  default     = ""
}
variable "project_project1_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Project1"
  default     = ""
}
# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2348/Projects | jq -r '.Items[] | select(.Name=="octopusdeploy_project") | .Id')
# terraform import Project1.project_project1 ${RESOURCE_ID}
resource "octopusdeploy_project" "project_project1" {
  name                                 = "${var.project_project1_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${octopusdeploy_lifecycle.lifecycle_application.id}"
  project_group_id                     = "${octopusdeploy_project_group.project_group_test.id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "Untenanted"

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
  description = "${var.project_project1_description_prefix}${var.project_project1_description}${var.project_project1_description_suffix}"
}

resource "octopusdeploy_variable" "variable_1" {
  owner_id     = "${octopusdeploy_project.project_project1.id}"
  value        = "TestVariable"
  name         = "Test.Variable"
  type         = "String"
  is_sensitive = false
}
