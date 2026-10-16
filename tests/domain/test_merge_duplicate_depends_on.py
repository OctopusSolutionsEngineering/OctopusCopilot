import unittest

from domain.sanitizers.terraform import merge_duplicate_depends_on

# Observed: a parallel step with tenant_tags got a second, multi-line depends_on adding the tag sets
OBSERVED = """resource "octopusdeploy_process_step" "process_step_aws_lambda_warm_cache" {
  count                 = "${length(local.project_aws_lambda_projects_matches) != 0 ? 0 : 1}"
  name                  = "Warm Cache"
  start_trigger         = "StartWithPrevious"
  tenant_tags           = ["Tier/Gold"]
  depends_on            = [octopusdeploy_process_step.process_step_aws_lambda_build_layer]
  execution_properties  = {
    "Octopus.Action.Script.ScriptBody"   = "echo \\"Warm cache\\""
  }
  depends_on = [
    octopusdeploy_process_step.process_step_aws_lambda_build_layer,
    octopusdeploy_tag_set.tagset_tier,
    octopusdeploy_tag.tagset_tier_tag_gold
  ]
}
resource "octopusdeploy_process_steps_order" "order" {
  steps = []
}
"""


class TestMergeDuplicateDependsOn(unittest.TestCase):
    def test_observed_duplicate_is_merged(self):
        expected = """resource "octopusdeploy_process_step" "process_step_aws_lambda_warm_cache" {
  count                 = "${length(local.project_aws_lambda_projects_matches) != 0 ? 0 : 1}"
  name                  = "Warm Cache"
  start_trigger         = "StartWithPrevious"
  tenant_tags           = ["Tier/Gold"]
  depends_on = [octopusdeploy_process_step.process_step_aws_lambda_build_layer, octopusdeploy_tag_set.tagset_tier, octopusdeploy_tag.tagset_tier_tag_gold]
  execution_properties  = {
    "Octopus.Action.Script.ScriptBody"   = "echo \\"Warm cache\\""
  }
}
resource "octopusdeploy_process_steps_order" "order" {
  steps = []
}
"""
        self.assertEqual(expected, merge_duplicate_depends_on(OBSERVED))

    def test_single_depends_on_is_unchanged(self):
        config = 'resource "octopusdeploy_variable" "v" {\n  name = "A"\n  depends_on = [octopusdeploy_project.p]\n}\n'
        self.assertEqual(config, merge_duplicate_depends_on(config))

    def test_depends_on_in_different_blocks_is_unchanged(self):
        config = (
            'resource "octopusdeploy_variable" "a" {\n  depends_on = [octopusdeploy_project.p]\n}\n'
            'resource "octopusdeploy_variable" "b" {\n  depends_on = [octopusdeploy_project.p]\n}\n'
        )
        self.assertEqual(config, merge_duplicate_depends_on(config))

    def test_data_references_are_kept(self):
        config = (
            'resource "octopusdeploy_variable" "a" {\n'
            "  depends_on = [data.octopusdeploy_projects.p]\n"
            '  name = "A"\n'
            "  depends_on = [octopusdeploy_tag_set.t]\n"
            "}\n"
        )
        result = merge_duplicate_depends_on(config)
        self.assertEqual(
            'resource "octopusdeploy_variable" "a" {\n'
            "  depends_on = [data.octopusdeploy_projects.p, octopusdeploy_tag_set.t]\n"
            '  name = "A"\n'
            "}\n",
            result,
        )

    def test_empty(self):
        self.assertEqual("", merge_duplicate_depends_on(""))
        self.assertIsNone(merge_duplicate_depends_on(None))


if __name__ == "__main__":
    unittest.main()
