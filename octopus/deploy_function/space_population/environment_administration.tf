data "octopusdeploy_environments" "environment_administration" {
  ids          = null
  partial_name = "Administration"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve an environment called \"Administration\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.environments) != 0
    }
  }
}
