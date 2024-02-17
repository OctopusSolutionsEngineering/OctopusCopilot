variable "project_group_octopus_copilot_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Octopus Copilot"
}
data "octopusdeploy_project_groups" "project_group_octopus_copilot" {
  ids          = null
  partial_name = "${var.project_group_octopus_copilot_name}"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a project group called $${var.project_group_octopus_copilot_name}. This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.project_groups) != 0
    }
  }
}
