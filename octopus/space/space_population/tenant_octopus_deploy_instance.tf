# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Tenants | jq -r '.Items[] | select(.Name=="octopusdeploy_tenant") | .Id')
# terraform import Octopus Deploy Instance.tenant_octopus_deploy_instance ${RESOURCE_ID}
resource "octopusdeploy_tenant" "tenant_octopus_deploy_instance" {
  name        = "Octopus Deploy Instance"
  tenant_tags = ["TenantType/OctopusInstance"]
  depends_on  = [octopusdeploy_tag_set.tagset_tenanttype,octopusdeploy_tag.tag_octopusinstance]
}
