resource "octopusdeploy_tenant" "tenant_team_a" {
  name        = "Marketing"
  description = "Marketing tenant"
  tenant_tags = ["regions/us-east-1", "regions/us-east-2"]
  depends_on = [octopusdeploy_tag.tag_a, octopusdeploy_tag.tag_b]

  project_environment {
    environments = [
      octopusdeploy_environment.environment_test.id,
      octopusdeploy_environment.environment_development.id,
      octopusdeploy_environment.environment_production.id
    ]
    project_id = octopusdeploy_project.project_project2.id
  }

  project_environment {
    environments = [
      octopusdeploy_environment.environment_test.id,
      octopusdeploy_environment.environment_development.id,
      octopusdeploy_environment.environment_production.id
    ]
    project_id = octopusdeploy_project.project_project5.id
  }
}