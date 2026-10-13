import unittest

from domain.sanitizers.terraform import fix_bare_data_lookup_reference

CONFIG = """resource "octopusdeploy_maven_feed" "feed_octopus_maven_feed" {
  count = "${length(local.feed_octopus_maven_feed_feeds_matches) != 0 ? 0 : 1}"
  name  = "Octopus Maven Feed"
}
resource "octopusdeploy_environment" "environment_test" {
  count = "${length(local.environment_test_matches) != 0 ? 0 : 1}"
  name  = "Test"
}
resource "octopusdeploy_process_step" "process_step_aws_lambda_upload_lambda" {
  feed_id      = "${local.feed_octopus_maven_feed_feeds_matches[0].id}"
  environments = ["${local.environment_test_matches[0].id}"]
  pool_id      = "${local.workerpool_default_worker_pool_worker_pools_matches[0].id}"
}
"""


class TestFixBareDataLookupReference(unittest.TestCase):
    def test_bare_exact_match_local_gets_create_fallback(self):
        result = fix_bare_data_lookup_reference(CONFIG)
        self.assertIn(
            'feed_id      = "${length(local.feed_octopus_maven_feed_feeds_matches) != 0 ? '
            'local.feed_octopus_maven_feed_feeds_matches[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"',
            result,
        )

    def test_environment_local_without_collection_gets_create_fallback(self):
        result = fix_bare_data_lookup_reference(CONFIG)
        self.assertIn(
            'environments = ["${length(local.environment_test_matches) != 0 ? '
            'local.environment_test_matches[0].id : octopusdeploy_environment.environment_test[0].id}"]',
            result,
        )

    def test_local_without_created_resource_is_unchanged(self):
        result = fix_bare_data_lookup_reference(CONFIG)
        self.assertIn('pool_id      = "${local.workerpool_default_worker_pool_worker_pools_matches[0].id}"', result)

    def test_existing_ternary_is_unchanged(self):
        config = CONFIG.replace(
            '"${local.feed_octopus_maven_feed_feeds_matches[0].id}"',
            '"${length(local.feed_octopus_maven_feed_feeds_matches) != 0 ? local.feed_octopus_maven_feed_feeds_matches[0].id : '
            'octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"',
        )
        result = fix_bare_data_lookup_reference(config)
        self.assertEqual(1, result.count("? local.feed_octopus_maven_feed_feeds_matches[0].id"))

    def test_bare_data_reference_still_fixed(self):
        config = CONFIG.replace(
            '"${local.feed_octopus_maven_feed_feeds_matches[0].id}"',
            '"${data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id}"',
        )
        result = fix_bare_data_lookup_reference(config)
        self.assertIn(": octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", result)


if __name__ == "__main__":
    unittest.main()
