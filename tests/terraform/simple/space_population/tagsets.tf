resource "octopusdeploy_tag_set" "tagset_tag1" {
  name        = "regions"
  description = "Tags the represent regions"
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_a" {
  name        = "us-east-1"
  color       = "#333333"
  description = "tag a"
  sort_order  = 2
  tag_set_id  = octopusdeploy_tag_set.tagset_tag1.id
}

resource "octopusdeploy_tag" "tag_b" {
  name        = "us-east-2"
  color       = "#333333"
  description = "tag b"
  sort_order  = 3
  tag_set_id  = octopusdeploy_tag_set.tagset_tag1.id
}