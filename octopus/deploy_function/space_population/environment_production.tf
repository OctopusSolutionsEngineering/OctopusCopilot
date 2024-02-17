data "octopusdeploy_environments" "environment_production" {
  ids          = null
  partial_name = "Production"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve an environment called \"Production\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.environments) != 0
    }
  }
}
