data "octopusdeploy_library_variable_sets" "library_variable_set_openai" {
  ids          = null
  partial_name = "OpenAI"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a library variable set called \"OpenAI\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.library_variable_sets) != 0
    }
  }
}
