resource "octopusdeploy_tag" "tag_octopusinstance" {
  name        = "OctopusInstance"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_tenanttype.id}"
  color       = "#87BFEC"
  description = ""
  sort_order  = 2
}
