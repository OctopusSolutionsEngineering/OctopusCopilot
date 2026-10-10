import unittest

from domain.sanitizers.terraform import convert_numeric_version_channel_tags

CHANNEL = """resource "octopusdeploy_channel" "channel_mesh_stable" {
  name       = "Stable"
  is_default = false
  rule {
    action_package {
      deployment_action = "Deploy a Kubernetes Web App via YAML"
    }
    tag = "TAG"
  }
}
"""


class TestConvertNumericVersionChannelTags(unittest.TestCase):
    def test_numeric_version_regex_becomes_range(self):
        result = convert_numeric_version_channel_tags(CHANNEL.replace("TAG", "^3\\\\.\\\\d+\\\\.\\\\d+$"))
        self.assertIn('version_range = "[3.0,4.0)"', result)
        self.assertIn('tag = "^$"', result)
        self.assertNotIn("\\\\d", result)
        self.assertIn('deployment_action = "Deploy a Kubernetes Web App via YAML"', result)

    def test_character_class_form(self):
        result = convert_numeric_version_channel_tags(CHANNEL.replace("TAG", "^15\\\\.[0-9]+\\\\.[0-9]+$"))
        self.assertIn('version_range = "[15.0,16.0)"', result)

    def test_prerelease_tag_is_unchanged(self):
        config = CHANNEL.replace("TAG", "^hotfix")
        self.assertEqual(convert_numeric_version_channel_tags(config), config)

    def test_rule_with_version_range_keeps_it_and_fixes_tag(self):
        config = CHANNEL.replace('    tag = "TAG"\n', '    tag = "^7\\\\.[0-9]+\\\\.[0-9]+$"\n    version_range = "[7.0,8.0)"\n')
        result = convert_numeric_version_channel_tags(config)
        self.assertIn('tag = "^$"', result)
        self.assertEqual(result.count("version_range"), 1)
        self.assertIn('version_range = "[7.0,8.0)"', result)

    def test_tag_without_fixed_major_is_unchanged(self):
        config = CHANNEL.replace("TAG", "^\\\\d+\\\\.\\\\d+\\\\.\\\\d+$")
        self.assertEqual(convert_numeric_version_channel_tags(config), config)

    def test_several_rules_and_channels(self):
        two_rules = CHANNEL.replace("TAG", "^1\\\\.\\\\d+").replace(
            "  }\n}\n", '  }\n  rule {\n    action_package {\n      deployment_action = "Other"\n    }\n    tag = "^2\\\\.\\\\d+\\\\.\\\\d+$"\n  }\n}\n'
        )
        result = convert_numeric_version_channel_tags(two_rules + two_rules.replace("channel_mesh_stable", "channel_b"))
        self.assertEqual(result.count('version_range = "[1.0,2.0)"'), 2)
        self.assertEqual(result.count('version_range = "[2.0,3.0)"'), 2)

    def test_empty_config(self):
        self.assertEqual(convert_numeric_version_channel_tags(""), "")
        self.assertIsNone(convert_numeric_version_channel_tags(None))


if __name__ == "__main__":
    unittest.main()
