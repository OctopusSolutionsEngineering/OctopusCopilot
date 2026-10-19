import unittest

from domain.sanitizers.terraform import add_ephemeral_environment_channel_type

FEATURES_CHANNEL = """resource "octopusdeploy_channel" "channel_kubernetes_web_app_features" {
  count                  = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  name                   = "Features"
  project_id             = "${octopusdeploy_project.project_kubernetes_web_app[0].id}"
  parent_environment_id  = "${octopusdeploy_parent_environment.parent_environment_features[0].id}"
  ephemeral_environment_name_template = "#{Octopus.Release.CustomFields[FeatureBranch]}"
  custom_field_definitions = [{ description = "The name of the feature branch", field_name = "FeatureBranch" }]
  is_default              = false
  tenant_tags             = []
  lifecycle {
    prevent_destroy = true
  }
}
"""

HOTFIX_CHANNEL = """resource "octopusdeploy_channel" "channel_kubernetes_web_app_hotfix" {
  count       = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  lifecycle_id = "${octopusdeploy_lifecycle.lifecycle_hotfix[0].id}"
  name        = "Hotfix"
  project_id  = "${octopusdeploy_project.project_kubernetes_web_app[0].id}"
  is_default  = false
  type        = "Lifecycle"
  tenant_tags = []
}
"""


class TestAddEphemeralEnvironmentChannelType(unittest.TestCase):
    def test_missing_type_is_added_after_name(self):
        result = add_ephemeral_environment_channel_type(FEATURES_CHANNEL)
        self.assertIn('  name                   = "Features"\n  type = "EphemeralEnvironment"\n', result)
        self.assertEqual(1, result.count("type = "))

    def test_lifecycle_type_is_replaced(self):
        config = FEATURES_CHANNEL.replace("  is_default ", '  type = "Lifecycle"\n  is_default ')
        result = add_ephemeral_environment_channel_type(config)
        self.assertIn('  type = "EphemeralEnvironment"\n', result)
        self.assertNotIn('"Lifecycle"', result)

    def test_ephemeral_type_is_unchanged(self):
        config = FEATURES_CHANNEL.replace("  is_default ", '  type = "EphemeralEnvironment"\n  is_default ')
        self.assertEqual(config, add_ephemeral_environment_channel_type(config))

    def test_lifecycle_channel_is_unchanged(self):
        self.assertEqual(HOTFIX_CHANNEL, add_ephemeral_environment_channel_type(HOTFIX_CHANNEL))

    def test_channel_with_lifecycle_id_and_parent_environment_is_unchanged(self):
        config = FEATURES_CHANNEL.replace(
            "  is_default ", '  lifecycle_id = "Lifecycles-1"\n  is_default '
        )
        self.assertEqual(config, add_ephemeral_environment_channel_type(config))

    def test_only_ephemeral_channel_changes_in_mixed_config(self):
        config = HOTFIX_CHANNEL + "\n" + FEATURES_CHANNEL + "\n" + HOTFIX_CHANNEL
        result = add_ephemeral_environment_channel_type(config)
        self.assertEqual(1, result.count('type = "EphemeralEnvironment"'))
        self.assertEqual(2, result.count('type        = "Lifecycle"'))
        self.assertTrue(result.startswith(HOTFIX_CHANNEL))
        self.assertTrue(result.endswith(HOTFIX_CHANNEL))

    def test_channel_without_name_gets_type_after_header(self):
        config = (
            'resource "octopusdeploy_channel" "channel_features" {\n'
            '  parent_environment_id = "Environments-5"\n'
            "}\n"
        )
        result = add_ephemeral_environment_channel_type(config)
        self.assertIn('{\n  type = "EphemeralEnvironment"\n  parent_environment_id', result)

    def test_empty(self):
        self.assertEqual("", add_ephemeral_environment_channel_type(""))
        self.assertIsNone(add_ephemeral_environment_channel_type(None))


if __name__ == "__main__":
    unittest.main()
