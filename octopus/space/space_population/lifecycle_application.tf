# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Lifecycles | jq -r '.Items[] | select(.Name=="octopusdeploy_lifecycle") | .Id')
# terraform import Application.lifecycle_application ${RESOURCE_ID}
resource "octopusdeploy_lifecycle" "lifecycle_application" {
  name        = "Application"
  description = ""

  phase {
    automatic_deployment_targets          = ["${octopusdeploy_environment.environment_production.id}"]
    optional_deployment_targets           = []
    name                                  = "Production"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = ["${octopusdeploy_environment.environment_security.id}"]
    optional_deployment_targets           = []
    name                                  = "Security"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }

  release_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = false
    unit                = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep    = 30
    should_keep_forever = false
    unit                = "Days"
  }
}
