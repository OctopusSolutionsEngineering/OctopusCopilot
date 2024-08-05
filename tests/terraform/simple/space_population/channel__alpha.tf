resource "octopusdeploy_channel" "channel_hotfix" {
  name        = "Alpha"
  project_id  = octopusdeploy_project.project_project1.id
  description = "Alpha channel"
  depends_on  = [octopusdeploy_project.project_project1, octopusdeploy_deployment_process.deployment_process_project1]
  is_default  = true
}