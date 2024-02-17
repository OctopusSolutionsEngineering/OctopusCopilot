variable "library_variable_set_variables_openai_azure_openai_key_1" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable Azure.OpenAI.Key"
}
resource "octopusdeploy_variable" "library_variable_set_variables_openai_azure_openai_key_1" {
  owner_id        = "${octopusdeploy_library_variable_set.library_variable_set_variables_openai.id}"
  name            = "Azure.OpenAI.Key"
  type            = "Sensitive"
  sensitive_value = "${var.library_variable_set_variables_openai_azure_openai_key_1}"
  is_sensitive    = true
  depends_on      = []
}
