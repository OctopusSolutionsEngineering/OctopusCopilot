data "octopusdeploy_feeds" "feed_docker_hub" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "Docker Hub"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"Docker Hub\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
  }
}
