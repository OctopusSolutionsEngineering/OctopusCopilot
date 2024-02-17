variable "runbook_octopus_copilot_function_create_function_app_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Create Function App"
  default     = "Create Function App"
}
# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Runbooks | jq -r '.Items[] | select(.Name=="octopusdeploy_runbook") | .Id')
# terraform import Create Function App.runbook_octopus_copilot_function_create_function_app ${RESOURCE_ID}
resource "octopusdeploy_runbook" "runbook_octopus_copilot_function_create_function_app" {
  name                        = "${var.runbook_octopus_copilot_function_create_function_app_name}"
  project_id                  = "${octopusdeploy_project.project_octopus_copilot_function.id}"
  environment_scope           = "Specified"
  environments                = ["${data.octopusdeploy_environments.environment_production.environments[0].id}"]
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "Deploys the function app and supporting infrastructure"
  multi_tenancy_mode          = "Untenanted"

  retention_policy {
    quantity_to_keep    = 100
    should_keep_forever = false
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }
}
