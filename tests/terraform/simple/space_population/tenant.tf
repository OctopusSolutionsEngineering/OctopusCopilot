resource "octopusdeploy_tenant" "tenant_team_a" {
  name        = "Marketing"
  description = "Marketing tenant"
  tenant_tags = ["regions/us-east-1", "regions/us-east-2"]
  depends_on = [octopusdeploy_tag.tag_a, octopusdeploy_tag.tag_b]
}

resource "octopusdeploy_tenant_project" "project2" {
    tenant_id  = octopusdeploy_tenant.tenant_team_a.id
    project_id = octopusdeploy_project.project_project2.id
    environment_ids = [octopusdeploy_environment.environment_test.id,
      octopusdeploy_environment.environment_development.id,
      octopusdeploy_environment.environment_production.id]
}

resource "octopusdeploy_tenant_project" "project5" {
    tenant_id  = octopusdeploy_tenant.tenant_team_a.id
    project_id = octopusdeploy_project.project_project5.id
    environment_ids = [octopusdeploy_environment.environment_test.id,
      octopusdeploy_environment.environment_development.id,
      octopusdeploy_environment.environment_production.id]
}