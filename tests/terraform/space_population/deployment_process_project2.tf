resource "octopusdeploy_deployment_process" "deployment_process_project2" {
  project_id = "${octopusdeploy_project.project_project2.id}"
  depends_on = []
}
