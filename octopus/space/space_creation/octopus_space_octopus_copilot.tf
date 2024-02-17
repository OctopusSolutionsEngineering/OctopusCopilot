# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Spaces | jq -r '.Items[] | select(.Name=="octopusdeploy_space") | .Id')
# terraform import Octopus Copilot.${var.octopus_space_name} ${RESOURCE_ID}
resource "octopusdeploy_space" "octopus_space_octopus_copilot" {
  name                        = "${var.octopus_space_name}"
  is_default                  = false
  is_task_queue_stopped       = false
  space_managers_team_members = null
  space_managers_teams        = ["${var.octopus_space_managers}"]
}
output "octopus_space_id" {
  value = "${octopusdeploy_space.octopus_space_octopus_copilot.id}"
}
output "octopus_space_name" {
  value = "${var.octopus_space_name}"
}
variable "octopus_space_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the new space (the exported space was called Octopus Copilot)"
  default     = "Octopus Copilot"
}
variable "octopus_space_managers" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The space manager teams for the new space"
  default     = "teams-administrators"
}
