import unittest

from domain.sanitizers.terraform import (
    fix_container_registry_acquisition_options,
    fix_maven_feed_acquisition_options,
)

DOCKER_FEED = """resource "octopusdeploy_docker_container_registry" "feed_model_registry" {
  count       = "${length(local.feed_model_registry_feeds_matches) != 0 ? 0 : 1}"
  name        = "Model Registry"
  feed_uri    = "https://index.docker.io"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
"""

MAVEN_FEED = """resource "octopusdeploy_maven_feed" "feed_maven" {
  name     = "Maven"
  feed_uri = "https://repo.maven.apache.org/maven2/"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
}
"""


class TestFixContainerRegistryAcquisitionOptions(unittest.TestCase):
    def test_docker_feed_options_are_replaced(self):
        result = fix_container_registry_acquisition_options(DOCKER_FEED)
        self.assertIn(
            'package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]',
            result,
        )

    def test_ecr_feed_options_are_replaced(self):
        config = DOCKER_FEED.replace(
            "octopusdeploy_docker_container_registry",
            "octopusdeploy_aws_elastic_container_registry",
        )
        result = fix_container_registry_acquisition_options(config)
        self.assertIn('["ExecutionTarget", "NotAcquired"]', result)

    def test_maven_feed_is_untouched(self):
        self.assertEqual(
            fix_container_registry_acquisition_options(MAVEN_FEED), MAVEN_FEED
        )

    def test_only_the_container_feed_changes_in_a_mixed_config(self):
        result = fix_container_registry_acquisition_options(MAVEN_FEED + DOCKER_FEED)
        maven, docker = result.split('resource "octopusdeploy_docker_container_registry"')
        self.assertIn('["Server", "ExecutionTarget"]', maven)
        self.assertIn('["ExecutionTarget", "NotAcquired"]', docker)

    def test_correct_options_are_unchanged(self):
        config = DOCKER_FEED.replace(
            '["Server", "ExecutionTarget"]', '["ExecutionTarget", "NotAcquired"]'
        )
        self.assertEqual(fix_container_registry_acquisition_options(config), config)

    def test_maven_fix_still_works_after_refactor(self):
        config = MAVEN_FEED.replace(
            '["Server", "ExecutionTarget"]', '["ExecutionTarget", "NotAcquired"]'
        )
        self.assertIn(
            '["Server", "ExecutionTarget"]', fix_maven_feed_acquisition_options(config)
        )

    def test_empty_config(self):
        self.assertEqual(fix_container_registry_acquisition_options(""), "")
        self.assertIsNone(fix_container_registry_acquisition_options(None))


if __name__ == "__main__":
    unittest.main()
