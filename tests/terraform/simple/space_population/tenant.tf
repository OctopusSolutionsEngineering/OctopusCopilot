resource "octopusdeploy_tenant" "tenant_team_a" {
  name        = "Marketing"
  description = "Marketing tenant"
  tenant_tags = ["regions/us-east-1", "regions/us-east-2"]
  depends_on  = [octopusdeploy_tag.tag_a, octopusdeploy_tag.tag_b]
}