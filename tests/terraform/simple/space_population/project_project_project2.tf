variable "project_project2_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Deploy AWS Lambda"
  default     = "Deploy AWS Lambda"
}
variable "project_project2_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Deploy AWS Lambda"
  default     = ""
}
variable "project_project2_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Deploy AWS Lambda"
  default     = ""
}
variable "project_project2_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Deploy AWS Lambda"
  default     = ""
}
# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2348/Projects | jq -r '.Items[] | select(.Name=="octopusdeploy_project") | .Id')
# terraform import Deploy AWS Lambda.project_project2 ${RESOURCE_ID}
resource "octopusdeploy_project" "project_project2" {
  name                                 = "${var.project_project2_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${octopusdeploy_lifecycle.lifecycle_application.id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
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
  description = "${var.project_project2_description_prefix}${var.project_project2_description}${var.project_project2_description_suffix}"
}
