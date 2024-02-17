variable "project_octopus_copilot_function_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Octopus Copilot Function"
  default     = "Octopus Copilot Function"
}
variable "project_octopus_copilot_function_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Octopus Copilot Function"
  default     = ""
}
variable "project_octopus_copilot_function_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Octopus Copilot Function"
  default     = ""
}
variable "project_octopus_copilot_function_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Octopus Copilot Function"
  default     = ""
}
# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Projects | jq -r '.Items[] | select(.Name=="octopusdeploy_project") | .Id')
# terraform import Octopus Copilot Function.project_octopus_copilot_function ${RESOURCE_ID}
resource "octopusdeploy_project" "project_octopus_copilot_function" {
  name                                 = "${var.project_octopus_copilot_function_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_octopus_copilot.project_groups[0].id}"
  included_library_variable_sets       = ["", "", "${data.octopusdeploy_library_variable_sets.library_variable_set_openai.library_variable_sets[0].id}"]
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
    ignore_changes = ["project_group_id", "name"]
  }
  description = "${var.project_octopus_copilot_function_description_prefix}${var.project_octopus_copilot_function_description}${var.project_octopus_copilot_function_description_suffix}"
}
