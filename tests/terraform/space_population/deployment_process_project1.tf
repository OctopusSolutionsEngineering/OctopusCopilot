resource "octopusdeploy_deployment_process" "deployment_process_project1" {
  project_id = "${octopusdeploy_project.project_project1.id}"
  depends_on = []
}
