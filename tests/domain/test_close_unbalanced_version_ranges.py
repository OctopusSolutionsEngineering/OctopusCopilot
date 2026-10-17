import unittest

from domain.sanitizers.terraform import close_unbalanced_version_ranges


def channel(version_range):
    return (
        'resource "octopusdeploy_channel" "channel_stable" {\n'
        '  name = "Stable"\n'
        "  rule {\n"
        "    action_package {\n"
        '      deployment_action = "Update Argo CD Image Tags"\n'
        "    }\n"
        f'    version_range = "{version_range}"\n'
        "  }\n"
        "}\n"
    )


class TestCloseUnbalancedVersionRanges(unittest.TestCase):
    def test_observed_missing_closing_bracket_is_closed(self):
        self.assertIn('version_range = "[2.0,3.0)"', close_unbalanced_version_ranges(channel("[2.0,3.0")))

    def test_missing_opening_bracket_is_opened(self):
        self.assertIn('version_range = "[2.0,3.0]"', close_unbalanced_version_ranges(channel("2.0,3.0]")))

    def test_balanced_ranges_are_unchanged(self):
        for version_range in ("[2.0,3.0)", "(1.0,)", "[1.0]", "1.0"):
            config = channel(version_range)
            self.assertEqual(config, close_unbalanced_version_ranges(config))

    def test_open_parenthesis_is_closed(self):
        self.assertIn('version_range = "(1.0,)"', close_unbalanced_version_ranges(channel("(1.0,")))

    def test_empty(self):
        self.assertEqual("", close_unbalanced_version_ranges(""))
        self.assertIsNone(close_unbalanced_version_ranges(None))


if __name__ == "__main__":
    unittest.main()
