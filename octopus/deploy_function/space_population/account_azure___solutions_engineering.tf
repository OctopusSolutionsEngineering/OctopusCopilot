data "octopusdeploy_accounts" "account_azure___solutions_engineering" {
  ids          = null
  partial_name = "Azure - Solutions Engineering"
  skip         = 0
  take         = 1
  account_type = "AzureServicePrincipal"
  lifecycle {
    postcondition {
      error_message = "Failed to resolve an account called \"Azure - Solutions Engineering\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.accounts) != 0
    }
  }
}
