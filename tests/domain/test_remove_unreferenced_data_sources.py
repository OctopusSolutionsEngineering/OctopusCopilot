import unittest

from domain.sanitizers.terraform import remove_unreferenced_data_sources

CONFIG = """data "octopusdeploy_processes" "process_my_k8s_project" {
  project_id = "${local.project_my_k8s_project_projects_matches[0].id}"
}
data "octopusdeploy_projects" "project_my_k8s_project" {
  partial_name = "My K8s Project"
  skip         = 0
  take         = 100
}
data "octopusdeploy_feeds" "feed_docker_hub" {
  partial_name = "Docker Hub"
}
locals {
  project_my_k8s_project_projects_matches = [for project in data.octopusdeploy_projects.project_my_k8s_project.projects : project if project.name == "My K8s Project"]
}
resource "octopusdeploy_process" "process_my_k8s_project" {
  project_id = "${local.project_my_k8s_project_projects_matches[0].id}"
}
"""


class TestRemoveUnreferencedDataSources(unittest.TestCase):
    def test_unreferenced_data_source_is_removed(self):
        result = remove_unreferenced_data_sources(CONFIG)
        self.assertNotIn("octopusdeploy_processes", result)
        self.assertNotIn('data "octopusdeploy_feeds" "feed_docker_hub"', result)

    def test_referenced_data_source_is_kept(self):
        result = remove_unreferenced_data_sources(CONFIG)
        self.assertIn('data "octopusdeploy_projects" "project_my_k8s_project"', result)

    def test_data_source_with_a_postcondition_is_kept(self):
        config = (
            'data "octopusdeploy_projects" "project_existing" {\n'
            '  partial_name = "Existing"\n'
            "  lifecycle {\n"
            "    postcondition {\n"
            "      condition     = length(self.projects) != 0\n"
            '      error_message = "The project must exist."\n'
            "    }\n"
            "  }\n"
            "}\n"
        )
        self.assertEqual(config, remove_unreferenced_data_sources(config))

    def test_reference_from_depends_on_keeps_the_data_source(self):
        config = 'data "octopusdeploy_feeds" "feed" {\n}\nresource "x" "y" {\n  depends_on = [data.octopusdeploy_feeds.feed]\n}\n'
        self.assertEqual(config, remove_unreferenced_data_sources(config))

    def test_label_that_is_a_prefix_of_another_is_not_a_reference(self):
        config = (
            'data "octopusdeploy_feeds" "feed" {\n}\n'
            'data "octopusdeploy_feeds" "feed_two" {\n}\n'
            'x = data.octopusdeploy_feeds.feed_two.feeds\n'
        )
        result = remove_unreferenced_data_sources(config)
        self.assertNotIn('data "octopusdeploy_feeds" "feed" {', result)
        self.assertIn('data "octopusdeploy_feeds" "feed_two"', result)

    def test_none_and_empty(self):
        self.assertIsNone(remove_unreferenced_data_sources(None))
        self.assertEqual("", remove_unreferenced_data_sources(""))


if __name__ == "__main__":
    unittest.main()
