import unittest

from domain.sanitizers.terraform import remove_duplicate_resources

CONFIG = """resource "octopusdeploy_lifecycle" "lifecycle_hotfix" {
  name = "Hotfix"
  phase {
    name = "Production"
  }
}
resource "octopusdeploy_project" "project_kubernetes_web_app" {
  name = "My K8s Project"
}
resource "octopusdeploy_lifecycle" "lifecycle_hotfix" {
  name        = "Hotfix"
  description = "A second copy"
}
"""


class TestRemoveDuplicateResources(unittest.TestCase):
    def test_second_copy_is_removed(self):
        result = remove_duplicate_resources(CONFIG)
        self.assertEqual(1, result.count('resource "octopusdeploy_lifecycle" "lifecycle_hotfix"'))
        self.assertIn('name = "Production"', result)
        self.assertNotIn("A second copy", result)
        self.assertIn('resource "octopusdeploy_project" "project_kubernetes_web_app"', result)

    def test_same_label_with_different_type_is_kept(self):
        config = 'resource "octopusdeploy_environment" "x" {\n}\nresource "octopusdeploy_lifecycle" "x" {\n}\n'
        self.assertEqual(config, remove_duplicate_resources(config))

    def test_data_source_with_same_label_is_kept(self):
        config = 'data "octopusdeploy_lifecycles" "lifecycle_hotfix" {\n}\nresource "octopusdeploy_lifecycle" "lifecycle_hotfix" {\n}\n'
        self.assertEqual(config, remove_duplicate_resources(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_duplicate_resources(None))
        self.assertEqual("", remove_duplicate_resources(""))


if __name__ == "__main__":
    unittest.main()
