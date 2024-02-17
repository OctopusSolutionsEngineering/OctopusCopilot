# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/LibraryVariableSets | jq -r '.Items[] | select(.Name=="octopusdeploy_library_variable_set") | .Id')
# terraform import OpenAI.library_variable_set_variables_openai ${RESOURCE_ID}
resource "octopusdeploy_library_variable_set" "library_variable_set_variables_openai" {
  name        = "OpenAI"
  description = ""
}
