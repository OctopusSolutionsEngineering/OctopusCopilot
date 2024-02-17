variable "library_variable_set_variables_openai_azure_openai_endpoint_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Azure.OpenAI.Endpoint"
  default     = "https://octopuscopilot.openai.azure.com/"
}
resource "octopusdeploy_variable" "library_variable_set_variables_openai_azure_openai_endpoint_1" {
  owner_id     = "${octopusdeploy_library_variable_set.library_variable_set_variables_openai.id}"
  value        = "${var.library_variable_set_variables_openai_azure_openai_endpoint_1}"
  name         = "Azure.OpenAI.Endpoint"
  type         = "String"
  is_sensitive = false
  depends_on   = []
}
