import unittest

from domain.sanitizers.terraform import add_missing_default_machine_policy_lookup

TARGET = """resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_mock_k8s" {
  name              = "Mock K8s"
  machine_policy_id = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
}
"""


class TestAddMissingDefaultMachinePolicyLookup(unittest.TestCase):
    def test_missing_lookup_is_added(self):
        result = add_missing_default_machine_policy_lookup(TARGET)
        self.assertIn('data "octopusdeploy_machine_policies" "default_machine_policy" {', result)
        self.assertIn('partial_name = "Default Machine Policy"', result)

    def test_declared_lookup_is_not_duplicated(self):
        config = 'data "octopusdeploy_machine_policies" "default_machine_policy" {\n  partial_name = "Default Machine Policy"\n}\n' + TARGET
        self.assertEqual(config, add_missing_default_machine_policy_lookup(config))

    def test_unreferenced_lookup_is_not_added(self):
        config = 'resource "octopusdeploy_project" "p" {\n  name = "P"\n}\n'
        self.assertEqual(config, add_missing_default_machine_policy_lookup(config))

    def test_other_machine_policy_lookup_is_left_alone(self):
        config = 'x = "${data.octopusdeploy_machine_policies.machinepolicy_custom.machine_policies[0].id}"\n'
        self.assertEqual(config, add_missing_default_machine_policy_lookup(config))

    def test_none_and_empty(self):
        self.assertIsNone(add_missing_default_machine_policy_lookup(None))
        self.assertEqual("", add_missing_default_machine_policy_lookup(""))


if __name__ == "__main__":
    unittest.main()
