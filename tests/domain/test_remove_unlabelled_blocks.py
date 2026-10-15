import unittest

from domain.sanitizers.terraform import remove_unlabelled_blocks

CONFIG = """data "octopusdeploy_projects" "project_microservice_2" {
  partial_name = "20. Microservice 2"
}
data "octopusdeploy_channel" {}
resource "octopusdeploy_project" "project_microservice_2" {
  name = "20. Microservice 2"
}
"""


class TestRemoveUnlabelledBlocks(unittest.TestCase):
    def test_unlabelled_empty_data_block_is_removed(self):
        result = remove_unlabelled_blocks(CONFIG)
        self.assertNotIn('data "octopusdeploy_channel"', result)
        self.assertIn('data "octopusdeploy_projects" "project_microservice_2"', result)
        self.assertIn('resource "octopusdeploy_project" "project_microservice_2"', result)

    def test_unlabelled_block_with_a_body_is_removed(self):
        config = 'resource "octopusdeploy_environment" {\n  name = "Test"\n}\nresource "octopusdeploy_project" "p" {\n}\n'
        self.assertEqual('resource "octopusdeploy_project" "p" {\n}\n', remove_unlabelled_blocks(config))

    def test_labelled_blocks_are_unchanged(self):
        config = CONFIG.replace('data "octopusdeploy_channel" {}\n', "")
        self.assertEqual(config, remove_unlabelled_blocks(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_unlabelled_blocks(None))
        self.assertEqual("", remove_unlabelled_blocks(""))


if __name__ == "__main__":
    unittest.main()
