variable "project_group_enterprise_patterns_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Enterprise Patterns"
}
# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/ProjectGroups | jq -r '.Items[] | select(.Name=="octopusdeploy_project_group") | .Id')
# terraform import Enterprise Patterns.project_group_enterprise_patterns ${RESOURCE_ID}
resource "octopusdeploy_project_group" "project_group_enterprise_patterns" {
  name = "${var.project_group_enterprise_patterns_name}"
}
