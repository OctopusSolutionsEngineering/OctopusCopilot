import unittest

from domain.sanitizers.terraform import enforce_exact_name_matches

LVS = """data "octopusdeploy_library_variable_sets" "library_variable_set_prompts" {
  ids          = null
  partial_name = "Prompts"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_library_variable_set" "library_variable_set_prompts" {
  count = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_prompts.library_variable_sets) != 0 ? 0 : 1}"
  name  = "Prompts"
}
resource "octopusdeploy_variable" "library_variable_set_prompts_prompt_system_1" {
  count    = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_prompts.library_variable_sets) != 0 ? 0 : 1}"
  owner_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_prompts.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_prompts.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_prompts[0].id}"
}
"""

GROUP_VIA_VARIABLE = """variable "project_group_default_name" {
  type    = string
  default = "Default"
}
data "octopusdeploy_project_groups" "project_group_default" {
  ids          = null
  partial_name = "${var.project_group_default_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project_group" "project_group_default" {
  count = "${length(data.octopusdeploy_project_groups.project_group_default.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_default_name}"
}
"""

BUILT_IN_FEED = """data "octopusdeploy_feeds" "feed_octopus_server__built_in_" {
  feed_type    = "BuiltIn"
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
}
"""


class TestEnforceExactNameMatches(unittest.TestCase):
    def test_library_variable_set_lookup_is_exact(self):
        result = enforce_exact_name_matches(LVS)
        self.assertIn(
            'library_variable_set_prompts_library_variable_sets_matches = [for set in data.octopusdeploy_library_variable_sets.library_variable_set_prompts.library_variable_sets : set if set.name == "Prompts"]',
            result,
        )
        self.assertNotIn("length(data.octopusdeploy_library_variable_sets", result)
        self.assertNotIn("library_variable_sets[0]", result.replace("_matches[0]", ""))
        self.assertIn("take         = 100", result)

    def test_name_from_variable_default_is_resolved(self):
        result = enforce_exact_name_matches(GROUP_VIA_VARIABLE)
        self.assertIn('group if group.name == "Default"]', result)
        self.assertIn("length(local.project_group_default_project_groups_matches)", result)

    def test_unnamed_lookup_is_unchanged(self):
        self.assertEqual(enforce_exact_name_matches(BUILT_IN_FEED), BUILT_IN_FEED)

    def test_variable_without_default_is_unchanged(self):
        config = GROUP_VIA_VARIABLE.replace('  default = "Default"\n', "")
        self.assertEqual(enforce_exact_name_matches(config), config)

    def test_several_types_share_one_locals_block(self):
        result = enforce_exact_name_matches(LVS + GROUP_VIA_VARIABLE)
        self.assertEqual(result.count("locals {"), 1)

    def test_existing_local_is_not_duplicated(self):
        once = enforce_exact_name_matches(LVS)
        self.assertEqual(enforce_exact_name_matches(once).count("library_variable_set_prompts_library_variable_sets_matches ="), 1)

    def test_built_in_project_feed_keeps_partial_match(self):
        config = """data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_" {
  feed_type    = "OctopusProject"
  ids          = null
  partial_name = "Octopus Server Releases"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_process_step" "deploy" {
  primary_package = { feed_id = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}" }
}
"""
        self.assertEqual(enforce_exact_name_matches(config), config)

    def test_git_credential_lookup_by_name_is_exact(self):
        config = """data "octopusdeploy_git_credentials" "gitcredential_edge_git" {
name = "Edge Git"
skip = 0
take = 1
}
resource "octopusdeploy_git_credential" "gitcredential_edge_git" {
count = "${length(data.octopusdeploy_git_credentials.gitcredential_edge_git.git_credentials) != 0 ? 0 : 1}"
}
"""
        result = enforce_exact_name_matches(config)
        self.assertIn('credential if credential.name == "Edge Git"]', result)
        self.assertIn("length(local.gitcredential_edge_git_git_credentials_matches)", result)
        self.assertIn("take = 100", result)

    def test_empty_config(self):
        self.assertEqual(enforce_exact_name_matches(""), "")
        self.assertIsNone(enforce_exact_name_matches(None))


if __name__ == "__main__":
    unittest.main()
