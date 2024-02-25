# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2348/Environments | jq -r '.Items[] | select(.Name=="octopusdeploy_environment") | .Id')
# terraform import Development.environment_development ${RESOURCE_ID}
resource "octopusdeploy_environment" "environment_development" {
  name                         = "Development"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = false
  sort_order                   = 0

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
}
