import unittest

from domain.sanitizers.terraform import add_child_steps_order_dependency_to_channels_with_rules

CHILD_ORDER = """resource "octopusdeploy_process_child_steps_order" "process_child_step_order_catalog_service_drain_node" {
  process_id = "${octopusdeploy_process.process_catalog_service[0].id}"
  parent_id  = "${octopusdeploy_process_step.process_step_catalog_service_drain_node[0].id}"
  children   = []
}
"""

CHANNEL = """resource "octopusdeploy_channel" "channel_catalog_service_stable" {
  name       = "Stable"
  project_id = "${octopusdeploy_project.project_catalog_service[0].id}"
  rule {
    action_package {
      deployment_action = "deploy-to-tomcat-via-manager"
    }
    tag = "^$"
  }
  depends_on = [octopusdeploy_process_steps_order.process_step_order_catalog_service]
}
"""


class TestAddChildStepsOrderDependencyToChannelsWithRules(unittest.TestCase):
    def test_child_steps_order_is_added_to_existing_depends_on(self):
        result = add_child_steps_order_dependency_to_channels_with_rules(CHILD_ORDER + CHANNEL)
        self.assertIn(
            "depends_on = [octopusdeploy_process_steps_order.process_step_order_catalog_service, "
            "octopusdeploy_process_child_steps_order.process_child_step_order_catalog_service_drain_node]",
            result,
        )

    def test_depends_on_is_created_when_missing(self):
        channel = CHANNEL.replace(
            "  depends_on = [octopusdeploy_process_steps_order.process_step_order_catalog_service]\n", ""
        )
        result = add_child_steps_order_dependency_to_channels_with_rules(CHILD_ORDER + channel)
        self.assertIn(
            "depends_on = [octopusdeploy_process_child_steps_order.process_child_step_order_catalog_service_drain_node]",
            result,
        )

    def test_channel_without_rules_is_unchanged(self):
        channel = 'resource "octopusdeploy_channel" "channel_x" {\n  name = "X"\n  project_id = "${octopusdeploy_project.project_catalog_service[0].id}"\n}\n'
        config = CHILD_ORDER + channel
        self.assertEqual(add_child_steps_order_dependency_to_channels_with_rules(config), config)

    def test_child_order_of_another_project_is_not_added(self):
        config = CHILD_ORDER.replace("catalog_service_drain_node", "billing_drain_node") + CHANNEL
        self.assertEqual(add_child_steps_order_dependency_to_channels_with_rules(config), config)

    def test_channel_referenced_by_a_step_is_skipped(self):
        step = 'resource "octopusdeploy_process_child_step" "c" {\n  channels = ["${octopusdeploy_channel.channel_catalog_service_stable[0].id}"]\n}\n'
        config = CHILD_ORDER + step + CHANNEL
        self.assertEqual(add_child_steps_order_dependency_to_channels_with_rules(config), config)

    def test_dependency_is_not_duplicated(self):
        once = add_child_steps_order_dependency_to_channels_with_rules(CHILD_ORDER + CHANNEL)
        self.assertEqual(add_child_steps_order_dependency_to_channels_with_rules(once), once)

    def test_no_child_steps_order_means_no_change(self):
        self.assertEqual(add_child_steps_order_dependency_to_channels_with_rules(CHANNEL), CHANNEL)

    def test_empty_config(self):
        self.assertEqual(add_child_steps_order_dependency_to_channels_with_rules(""), "")
        self.assertIsNone(add_child_steps_order_dependency_to_channels_with_rules(None))


if __name__ == "__main__":
    unittest.main()
