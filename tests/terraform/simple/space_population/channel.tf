resource "octopusdeploy_channel" "backend_mainline" {
  name        = "Mainline"
  project_id  = octopusdeploy_project.project_project2.id
  description = "Test channel"
  depends_on  = [octopusdeploy_project.project_project2, octopusdeploy_deployment_process.deployment_process_project2]
  is_default  = true
}