import unittest

from domain.sanitizers.terraform import fix_helm_feed_acquisition_options

# Observed: a Helm feed with the Maven/NuGet acquisition options
HELM_FEED = """resource "octopusdeploy_helm_feed" "feed_llm_charts" {
  count                                = "${length(local.feed_llm_charts_matches) != 0 ? 0 : 1}"
  name                                 = "LLM Charts"
  feed_uri                             = "https://charts.example.com/llm"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
}
"""

MAVEN_FEED = """resource "octopusdeploy_maven_feed" "feed_maven" {
  name                                 = "Maven"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
}
"""


class TestFixHelmFeedAcquisitionOptions(unittest.TestCase):
    def test_observed_helm_feed_is_fixed(self):
        result = fix_helm_feed_acquisition_options(HELM_FEED)
        self.assertIn('package_acquisition_location_options = ["ExecutionTarget", "Server", "NotAcquired"]', result)
        self.assertIn('feed_uri                             = "https://charts.example.com/llm"', result)

    def test_other_feeds_are_unchanged(self):
        self.assertEqual(MAVEN_FEED, fix_helm_feed_acquisition_options(MAVEN_FEED))

    def test_only_the_helm_feed_changes(self):
        result = fix_helm_feed_acquisition_options(MAVEN_FEED + HELM_FEED)
        self.assertIn(MAVEN_FEED, result)
        self.assertIn('["ExecutionTarget", "Server", "NotAcquired"]', result)

    def test_empty(self):
        self.assertEqual("", fix_helm_feed_acquisition_options(""))
        self.assertIsNone(fix_helm_feed_acquisition_options(None))


if __name__ == "__main__":
    unittest.main()
