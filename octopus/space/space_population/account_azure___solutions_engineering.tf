# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Accounts | jq -r '.Items[] | select(.Name=="Azure - Solutions Engineering") | .Id')
# terraform import octopusdeploy_azure_service_principal.account_azure___solutions_engineering ${RESOURCE_ID}
resource "octopusdeploy_azure_service_principal" "account_azure___solutions_engineering" {
  name                              = "Azure - Solutions Engineering"
  description                       = ""
  environments                      = ["${octopusdeploy_environment.environment_production.id}", "${octopusdeploy_environment.environment_sync.id}", "${octopusdeploy_environment.environment_security.id}", "${octopusdeploy_environment.environment_administration.id}"]
  tenant_tags                       = ["TenantType/OctopusInstance"]
  tenants                           = []
  tenanted_deployment_participation = "TenantedOrUntenanted"
  application_id                    = "08a4a027-6f2a-4793-a0e5-e59a3c79189f"
  password                          = "${var.account_azure___solutions_engineering}"
  subscription_id                   = "3b50dcf4-f74d-442e-93cb-301b13e1e2d5"
  tenant_id                         = "3d13e379-e666-469e-ac38-ec6fd61c1166"
  depends_on                        = [octopusdeploy_tag_set.tagset_tenanttype,octopusdeploy_tag.tag_octopusinstance]
}
variable "account_azure___solutions_engineering" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Azure secret associated with the account Azure - Solutions Engineering"
}
