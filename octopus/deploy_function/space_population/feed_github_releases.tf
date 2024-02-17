data "octopusdeploy_feeds" "feed_github_releases" {
  feed_type    = "GitHub"
  ids          = null
  partial_name = "GitHub Releases"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"GitHub Releases\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
  }
}
