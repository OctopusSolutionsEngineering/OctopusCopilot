# Import existing resources with the following commands:
# RESOURCE_ID=$(curl -H "X-Octopus-ApiKey: ${OCTOPUS_CLI_API_KEY}" https://mattc.octopus.app/api/Spaces-2328/Feeds | jq -r '.Items[] | select(.Name=="octopusdeploy_github_repository_feed") | .Id')
# terraform import GitHub Releases.feed_github_releases ${RESOURCE_ID}
resource "octopusdeploy_github_repository_feed" "feed_github_releases" {
  name                                 = "GitHub Releases"
  feed_uri                             = "https://api.github.com"
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
}
