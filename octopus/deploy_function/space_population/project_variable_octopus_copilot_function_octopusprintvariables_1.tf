variable "octopus_copilot_function_octopusprintvariables_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable OctopusPrintVariables"
  default     = "False"
}
resource "octopusdeploy_variable" "octopus_copilot_function_octopusprintvariables_1" {
  owner_id     = "${octopusdeploy_project.project_octopus_copilot_function.id}"
  value        = "${var.octopus_copilot_function_octopusprintvariables_1}"
  name         = "OctopusPrintVariables"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes = all
  }
}
