variable "runbook_octopus_copilot_function_find_outbound_ips_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Find Outbound IPs"
  default     = "Find Outbound IPs"
}
# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Runbooks | jq -r '.Items[] | select(.Name=="octopusdeploy_runbook") | .Id')
# terraform import Find Outbound IPs.runbook_octopus_copilot_function_find_outbound_ips ${RESOURCE_ID}
resource "octopusdeploy_runbook" "runbook_octopus_copilot_function_find_outbound_ips" {
  name                        = "${var.runbook_octopus_copilot_function_find_outbound_ips_name}"
  project_id                  = "${octopusdeploy_project.project_octopus_copilot_function.id}"
  environment_scope           = "Specified"
  environments                = ["${data.octopusdeploy_environments.environment_administration.environments[0].id}"]
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "Finds the outbound IP addresses associated with the Azure function."
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
