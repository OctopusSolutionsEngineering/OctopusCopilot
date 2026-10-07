import unittest

from domain.sanitizers.terraform import fix_underscore_count_operators


class FixUnderscoreCountOperatorsTests(unittest.TestCase):
    def test_fixes_both_operators(self):
        config = 'count = "${length([for env in data.octopusdeploy_environments.environment_development.environments : env if env.name == "Development"]) _= 0 _ 0 : 1}"'
        self.assertEqual(
            'count = "${length([for env in data.octopusdeploy_environments.environment_development.environments : env if env.name == "Development"]) != 0 ? 0 : 1}"',
            fix_underscore_count_operators(config),
        )

    def test_fixes_not_equal_only(self):
        config = 'count = length(data.octopusdeploy_feeds.feed.feeds) _= 0 ? 0 : 1'
        self.assertEqual("count = length(data.octopusdeploy_feeds.feed.feeds) != 0 ? 0 : 1", fix_underscore_count_operators(config))

    def test_fixes_question_mark_only(self):
        config = 'count = length(data.octopusdeploy_feeds.feed.feeds) != 0 _ 1 : 0'
        self.assertEqual("count = length(data.octopusdeploy_feeds.feed.feeds) != 0 ? 1 : 0", fix_underscore_count_operators(config))

    def test_leaves_valid_expression(self):
        config = 'count = "${length(data.octopusdeploy_feeds.feed.feeds) != 0 ? 0 : 1}"'
        self.assertEqual(config, fix_underscore_count_operators(config))


if __name__ == "__main__":
    unittest.main()
