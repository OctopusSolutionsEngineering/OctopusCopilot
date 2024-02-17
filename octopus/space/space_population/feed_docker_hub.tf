# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Feeds | jq -r '.Items[] | select(.Name=="octopusdeploy_docker_container_registry") | .Id')
# terraform import Docker Hub.feed_docker_hub ${RESOURCE_ID}
resource "octopusdeploy_docker_container_registry" "feed_docker_hub" {
  name                                 = "Docker Hub"
  registry_path                        = ""
  api_version                          = ""
  feed_uri                             = "https://index.docker.io"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
}
