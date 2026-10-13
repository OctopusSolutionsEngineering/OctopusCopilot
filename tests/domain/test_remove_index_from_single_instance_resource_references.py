import unittest

from domain.sanitizers.terraform import remove_index_from_single_instance_resource_references

CONFIG = """resource "octopusdeploy_runbook" "runbook_deprovision_environment" {
  name = "Deprovision Environment"
  connectivity_policy {
    allow_deployments_to_no_targets = true
  }
}
resource "octopusdeploy_runbook" "runbook_provision_environment" {
  count = "1"
  name  = "Provision Environment"
}
resource "octopusdeploy_process" "process_deprovision_environment" {
  count      = "1"
  runbook_id = "${octopusdeploy_runbook.runbook_deprovision_environment[0].id}"
}
resource "octopusdeploy_process" "process_provision_environment" {
  count      = "1"
  runbook_id = "${octopusdeploy_runbook.runbook_provision_environment[0].id}"
}
resource "octopusdeploy_process_step" "process_step_deprovision_environment" {
  count      = "1"
  process_id = "${octopusdeploy_process.process_deprovision_environment[0].id}"
  feed_id    = "${data.octopusdeploy_feeds.octopusdeploy_feed.feeds[0].id}"
}
"""


class TestRemoveIndexFromSingleInstanceResourceReferences(unittest.TestCase):
    def test_index_is_removed_from_single_instance_resource(self):
        result = remove_index_from_single_instance_resource_references(CONFIG)
        self.assertIn('runbook_id = "${octopusdeploy_runbook.runbook_deprovision_environment.id}"', result)

    def test_index_is_kept_for_counted_resources(self):
        result = remove_index_from_single_instance_resource_references(CONFIG)
        self.assertIn("octopusdeploy_runbook.runbook_provision_environment[0].id", result)
        self.assertIn("octopusdeploy_process.process_deprovision_environment[0].id", result)

    def test_data_references_are_unchanged(self):
        result = remove_index_from_single_instance_resource_references(CONFIG)
        self.assertIn("data.octopusdeploy_feeds.octopusdeploy_feed.feeds[0].id", result)

    def test_for_each_resource_is_not_single_instance(self):
        config = 'resource "octopusdeploy_environment" "env" {\n  for_each = toset(["a"])\n}\nx = octopusdeploy_environment.env[0]\n'
        self.assertEqual(config, remove_index_from_single_instance_resource_references(config))

    def test_undeclared_resources_are_unchanged(self):
        config = 'x = "${octopusdeploy_environment.missing[0].id}"\n'
        self.assertEqual(config, remove_index_from_single_instance_resource_references(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_index_from_single_instance_resource_references(None))
        self.assertEqual("", remove_index_from_single_instance_resource_references(""))


if __name__ == "__main__":
    unittest.main()
