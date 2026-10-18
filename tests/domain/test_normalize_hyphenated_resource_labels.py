import unittest

from domain.sanitizers.terraform import normalize_hyphenated_resource_labels

FREEZE = """resource "octopusdeploy_deployment_freeze" "deploymentfreeze_q86-r3_ledger_freeze" {
  name = "Q86-R3 Ledger Freeze"
}
resource "octopusdeploy_deployment_freeze_project" "deploymentfreeze_q86-r3_ledger_freeze_q86c" {
  deploymentfreeze_id = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_q86-r3_ledger_freeze.deployment_freezes) != 0 ? data.octopusdeploy_deployment_freezes.deploymentfreeze_q86-r3_ledger_freeze.deployment_freezes[0].id : octopusdeploy_deployment_freeze.deploymentfreeze_q86-r3_ledger_freeze[0].id}"
  depends_on = [octopusdeploy_deployment_freeze.deploymentfreeze_q86-r3_ledger_freeze]
}
"""


class TestNormalizeHyphenatedResourceLabels(unittest.TestCase):
    def test_observed_freeze_labels(self):
        result = normalize_hyphenated_resource_labels(FREEZE)
        self.assertIn('"octopusdeploy_deployment_freeze" "deploymentfreeze_q86_r3_ledger_freeze"', result)
        self.assertIn('"octopusdeploy_deployment_freeze_project" "deploymentfreeze_q86_r3_ledger_freeze_q86c"', result)
        self.assertIn("octopusdeploy_deployment_freeze.deploymentfreeze_q86_r3_ledger_freeze[0].id", result)
        self.assertIn("depends_on = [octopusdeploy_deployment_freeze.deploymentfreeze_q86_r3_ledger_freeze]", result)
        # Undeclared data source references are left for fix_undeclared_deployment_freeze_lookup
        self.assertIn("data.octopusdeploy_deployment_freezes.deploymentfreeze_q86-r3_ledger_freeze", result)
        # Names and other text keep their dashes
        self.assertIn('name = "Q86-R3 Ledger Freeze"', result)

    def test_data_source_and_references(self):
        config = (
            'data "octopusdeploy_environments" "env_pre-prod" {\n}\n'
            'locals {\n  x = data.octopusdeploy_environments.env_pre-prod.environments\n}\n'
        )
        result = normalize_hyphenated_resource_labels(config)
        self.assertIn('data "octopusdeploy_environments" "env_pre_prod"', result)
        self.assertIn("data.octopusdeploy_environments.env_pre_prod.environments", result)

    def test_longer_label_is_not_partially_renamed(self):
        config = (
            'resource "octopusdeploy_tag" "a-b" {\n}\n'
            'resource "octopusdeploy_tag" "a-b-c" {\n}\n'
            "x = octopusdeploy_tag.a-b-c[0].id\ny = octopusdeploy_tag.a-b[0].id\n"
        )
        result = normalize_hyphenated_resource_labels(config)
        self.assertIn("x = octopusdeploy_tag.a_b_c[0].id", result)
        self.assertIn("y = octopusdeploy_tag.a_b[0].id", result)

    def test_taken_underscore_label_is_unchanged(self):
        config = 'resource "octopusdeploy_tag" "a-b" {\n}\nresource "octopusdeploy_tag" "a_b" {\n}\n'
        self.assertEqual(config, normalize_hyphenated_resource_labels(config))

    def test_labels_without_dashes_are_unchanged(self):
        config = 'resource "octopusdeploy_tag" "a_b" {\n  name = "x-y"\n}\n'
        self.assertEqual(config, normalize_hyphenated_resource_labels(config))

    def test_resource_and_data_with_same_label(self):
        config = (
            'data "octopusdeploy_deployment_targets" "target_mock_k8s_ledger-k8s" {\n}\n'
            'resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_mock_k8s_ledger-k8s" {\n'
            '  count = length(data.octopusdeploy_deployment_targets.target_mock_k8s_ledger-k8s.deployment_targets)\n}\n'
        )
        result = normalize_hyphenated_resource_labels(config)
        self.assertNotIn("ledger-k8s", result)

    def test_empty(self):
        self.assertEqual("", normalize_hyphenated_resource_labels(""))
        self.assertIsNone(normalize_hyphenated_resource_labels(None))


if __name__ == "__main__":
    unittest.main()
