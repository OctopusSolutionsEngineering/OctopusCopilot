resource "octopusdeploy_tag_set" "tagset_tag1" {
  name        = "regions"
  description = "Tags the represent regions"
}

resource "octopusdeploy_tag" "tag_a" {
  name        = "us-east-1"
  color       = "#333333"
  description = "tag a"
  tag_set_id  = octopusdeploy_tag_set.tagset_tag1.id
}

resource "octopusdeploy_tag" "tag_b" {
  name        = "us-east-2"
  color       = "#333333"
  description = "tag b"
  tag_set_id  = octopusdeploy_tag_set.tagset_tag1.id
}