import unittest

from domain.sanitizers.terraform import fix_underscore_ternary_operators


class FixUnderscoreTernaryOperatorsTests(unittest.TestCase):
    def test_fixes_both_operators_in_count(self):
        config = 'count = "${length([for env in data.octopusdeploy_environments.environment_development.environments : env if env.name == "Development"]) _= 0 _ 0 : 1}"'
        self.assertEqual(
            'count = "${length([for env in data.octopusdeploy_environments.environment_development.environments : env if env.name == "Development"]) != 0 ? 0 : 1}"',
            fix_underscore_ternary_operators(config),
        )

    def test_fixes_both_operators_with_expression_results(self):
        config = (
            "optional_deployment_targets           = [length([for env in data.octopusdeploy_environments.environment_ut.environments : env if env.name == \"UT\"]) "
            "_= 0 _ [for env in data.octopusdeploy_environments.environment_ut.environments : env if env.name == \"UT\"][0].id : octopusdeploy_environment.environment_ut[0].id]"
        )
        self.assertEqual(
            "optional_deployment_targets           = [length([for env in data.octopusdeploy_environments.environment_ut.environments : env if env.name == \"UT\"]) "
            "!= 0 ? [for env in data.octopusdeploy_environments.environment_ut.environments : env if env.name == \"UT\"][0].id : octopusdeploy_environment.environment_ut[0].id]",
            fix_underscore_ternary_operators(config),
        )

    def test_fixes_not_equal_only(self):
        config = "count = length(data.octopusdeploy_feeds.feed.feeds) _= 0 ? 0 : 1"
        self.assertEqual("count = length(data.octopusdeploy_feeds.feed.feeds) != 0 ? 0 : 1", fix_underscore_ternary_operators(config))

    def test_fixes_question_mark_only(self):
        config = "feed_id = length(data.octopusdeploy_feeds.feed.feeds) != 0 _ data.octopusdeploy_feeds.feed.feeds[0].id : null"
        self.assertEqual(
            "feed_id = length(data.octopusdeploy_feeds.feed.feeds) != 0 ? data.octopusdeploy_feeds.feed.feeds[0].id : null",
            fix_underscore_ternary_operators(config),
        )

    def test_leaves_valid_expression(self):
        config = 'count = "${length(data.octopusdeploy_feeds.feed.feeds) != 0 ? 0 : 1}"'
        self.assertEqual(config, fix_underscore_ternary_operators(config))


if __name__ == "__main__":
    unittest.main()
