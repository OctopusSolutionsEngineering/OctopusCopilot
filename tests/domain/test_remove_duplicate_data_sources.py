import unittest

from domain.sanitizers.terraform import enforce_exact_name_matches, remove_duplicate_data_sources

CONFIG = """data "octopusdeploy_projects" "channel_kubernetes_web_app_hotfix" {
  ids          = null
  partial_name = "K8s Web App"
  skip         = 0
  take         = 100
}
resource "octopusdeploy_project" "project_kubernetes_web_app" {
  name = "K8s Web App"
}
data "octopusdeploy_projects" "channel_kubernetes_web_app_hotfix" {
  ids          = null
  partial_name = "K8s Web App"
  skip         = 0
  take         = 1
}
data "octopusdeploy_channels" "channel_kubernetes_web_app_hotfix" {
  partial_name = "Hotfix"
  skip         = 0
  take         = 1
}
"""


class TestRemoveDuplicateDataSources(unittest.TestCase):
    def test_second_copy_is_removed(self):
        result = remove_duplicate_data_sources(CONFIG)
        self.assertEqual(1, result.count('data "octopusdeploy_projects" "channel_kubernetes_web_app_hotfix"'))
        self.assertIn("take         = 100", result)
        self.assertNotIn("take         = 1\n}\ndata \"octopusdeploy_channels\"", result)

    def test_same_label_with_different_type_is_kept(self):
        result = remove_duplicate_data_sources(CONFIG)
        self.assertIn('data "octopusdeploy_channels" "channel_kubernetes_web_app_hotfix"', result)
        self.assertIn('resource "octopusdeploy_project" "project_kubernetes_web_app"', result)

    def test_single_exact_match_local(self):
        result = enforce_exact_name_matches(remove_duplicate_data_sources(CONFIG))
        self.assertEqual(1, result.count("channel_kubernetes_web_app_hotfix_projects_matches ="))

    def test_unique_data_sources_are_unchanged(self):
        config = CONFIG[: CONFIG.index('data "octopusdeploy_projects"', 10)]
        self.assertEqual(config, remove_duplicate_data_sources(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_duplicate_data_sources(None))
        self.assertEqual("", remove_duplicate_data_sources(""))


if __name__ == "__main__":
    unittest.main()
