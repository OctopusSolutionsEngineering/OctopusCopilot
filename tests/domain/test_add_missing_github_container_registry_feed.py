import unittest

from domain.sanitizers.terraform import add_missing_github_container_registry_feed

# Observed: three wave steps used the bare lookup, and neither the lookup nor the feed was declared
OBSERVED = """resource "octopusdeploy_process_step" "process_step_r18_pos_rollout_deploy_wave_1" {
  name      = "Deploy Wave 1"
  container = {
    feed_id = "${data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id}"
    image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
  }
}
"""

TERNARY = (
    "length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? "
    "data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : "
    "octopusdeploy_docker_container_registry.feed_github_container_registry[0].id"
)


class TestAddMissingGithubContainerRegistryFeed(unittest.TestCase):
    def test_observed_bare_lookup_gets_lookup_feed_and_ternary(self):
        result = add_missing_github_container_registry_feed(OBSERVED)
        self.assertIn('feed_id = "${' + TERNARY + '}"', result)
        self.assertIn('data "octopusdeploy_feeds" "feed_github_container_registry" {', result)
        self.assertIn('resource "octopusdeploy_docker_container_registry" "feed_github_container_registry" {', result)
        self.assertIn('feed_uri    = "https://ghcr.io"', result)
        self.assertEqual(1, result.count('data "octopusdeploy_feeds" "feed_github_container_registry"'))

    def test_multiple_references_are_all_rewritten(self):
        result = add_missing_github_container_registry_feed(OBSERVED + OBSERVED.replace("wave_1", "wave_2"))
        self.assertEqual(2, result.count('feed_id = "${' + TERNARY + '}"'))
        self.assertEqual(1, result.count('resource "octopusdeploy_docker_container_registry"'))

    def test_declared_lookup_is_unchanged(self):
        config = OBSERVED + 'data "octopusdeploy_feeds" "feed_github_container_registry" {\n  take = 1\n}\n'
        self.assertEqual(config, add_missing_github_container_registry_feed(config))

    def test_declared_resource_is_unchanged(self):
        config = OBSERVED + (
            'resource "octopusdeploy_docker_container_registry" "feed_github_container_registry" {\n'
            '  name = "GitHub Container Registry"\n}\n'
        )
        self.assertEqual(config, add_missing_github_container_registry_feed(config))

    def test_existing_ternary_is_not_double_wrapped(self):
        config = 'x = "${' + TERNARY + '}"\n'
        result = add_missing_github_container_registry_feed(config)
        self.assertIn('x = "${' + TERNARY + '}"', result)
        self.assertEqual(1, result.count("length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data"))

    def test_no_reference_is_unchanged(self):
        config = 'resource "octopusdeploy_project" "p" {\n  name = "P"\n}\n'
        self.assertEqual(config, add_missing_github_container_registry_feed(config))

    def test_empty(self):
        self.assertEqual("", add_missing_github_container_registry_feed(""))
        self.assertIsNone(add_missing_github_container_registry_feed(None))


if __name__ == "__main__":
    unittest.main()
