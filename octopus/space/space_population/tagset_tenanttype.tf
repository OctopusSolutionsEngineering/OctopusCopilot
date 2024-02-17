# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/TagSets | jq -r '.Items[] | select(.Name=="octopusdeploy_tag_set") | .Id')
# terraform import TenantType.tagset_tenanttype ${RESOURCE_ID}
resource "octopusdeploy_tag_set" "tagset_tenanttype" {
  name       = "TenantType"
  sort_order = 0
}
