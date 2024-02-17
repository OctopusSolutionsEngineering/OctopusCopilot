data "octopusdeploy_lifecycles" "lifecycle_application" {
  ids          = null
  partial_name = "Application"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a lifecycle called \"Application\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.lifecycles) != 0
    }
  }
}
