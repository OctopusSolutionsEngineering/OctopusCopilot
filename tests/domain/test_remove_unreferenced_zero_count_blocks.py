import unittest

from domain.sanitizers.terraform import remove_unreferenced_zero_count_blocks

CONFIG = """data "octopusdeploy_libraries" "library_variable_set_placeholder" {
  count = 0
}
data "octopusdeploy_deployment_targets" "target_mock_k8s" {
  partial_name = "Mock K8s"
  take         = 1
}
resource "octopusdeploy_project" "project" {
  included_library_variable_sets = []
}
"""


class TestRemoveUnreferencedZeroCountBlocks(unittest.TestCase):
    def test_unreferenced_zero_count_data_source_is_removed(self):
        result = remove_unreferenced_zero_count_blocks(CONFIG)
        self.assertNotIn("octopusdeploy_libraries", result)
        self.assertTrue(result.startswith('data "octopusdeploy_deployment_targets" "target_mock_k8s"'))

    def test_quoted_zero_count_is_removed(self):
        result = remove_unreferenced_zero_count_blocks(CONFIG.replace("count = 0", 'count = "0"'))
        self.assertNotIn("octopusdeploy_libraries", result)

    def test_referenced_zero_count_data_source_is_kept(self):
        config = CONFIG + 'locals {\n  x = length(data.octopusdeploy_libraries.library_variable_set_placeholder)\n}\n'
        self.assertEqual(config, remove_unreferenced_zero_count_blocks(config))

    def test_data_source_without_zero_count_is_kept(self):
        config = 'data "octopusdeploy_feeds" "feed" {\n  count = 1\n  take  = 10\n}\n'
        self.assertEqual(config, remove_unreferenced_zero_count_blocks(config))

    def test_unreferenced_zero_count_resource_is_removed(self):
        config = 'resource "octopusdeploy_channels" "unused_channels" {\n  count = 0\n}\n' + CONFIG
        result = remove_unreferenced_zero_count_blocks(config)
        self.assertNotIn("unused_channels", result)

    def test_referenced_zero_count_resource_is_kept(self):
        config = (
            'resource "octopusdeploy_environment" "env" {\n  count = 0\n}\n'
            'x = "${length(octopusdeploy_environment.env) != 0 ? octopusdeploy_environment.env[0].id : ""}"\n'
        )
        self.assertEqual(config, remove_unreferenced_zero_count_blocks(config))

    def test_resource_address_inside_data_address_does_not_count_as_reference(self):
        config = (
            'resource "octopusdeploy_feeds" "feed" {\n  count = 0\n}\n'
            'x = data.octopusdeploy_feeds.feed.feeds\n'
        )
        self.assertNotIn('resource "octopusdeploy_feeds"', remove_unreferenced_zero_count_blocks(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_unreferenced_zero_count_blocks(None))
        self.assertEqual("", remove_unreferenced_zero_count_blocks(""))


if __name__ == "__main__":
    unittest.main()
