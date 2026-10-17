import unittest

from domain.sanitizers.terraform import remove_empty_custom_field_definitions


def channel(value):
    return (
        'resource "octopusdeploy_channel" "channel_features" {\n'
        '  name                                = "Features"\n'
        '  ephemeral_environment_name_template = "#{Octopus.Release.Number}"\n'
        f"  custom_field_definitions = {value}\n"
        '  type                                = "EphemeralEnvironment"\n'
        "}\n"
    )


class TestRemoveEmptyCustomFieldDefinitions(unittest.TestCase):
    def test_empty_list_is_removed(self):
        result = remove_empty_custom_field_definitions(channel("[]"))
        self.assertNotIn("custom_field_definitions", result)
        self.assertIn('  ephemeral_environment_name_template = "#{Octopus.Release.Number}"\n  type', result)

    def test_empty_list_with_spaces_is_removed(self):
        result = remove_empty_custom_field_definitions(channel("[ ]"))
        self.assertNotIn("custom_field_definitions", result)

    def test_populated_list_is_unchanged(self):
        config = channel('[{ description = "The name of the feature branch", field_name = "FeatureBranch" }]')
        self.assertEqual(config, remove_empty_custom_field_definitions(config))

    def test_multiline_list_is_unchanged(self):
        config = channel('[\n    {\n      description = "x"\n      field_name  = "FeatureBranch"\n    }\n  ]')
        self.assertEqual(config, remove_empty_custom_field_definitions(config))

    def test_null_is_unchanged(self):
        config = channel("null")
        self.assertEqual(config, remove_empty_custom_field_definitions(config))

    def test_empty(self):
        self.assertEqual("", remove_empty_custom_field_definitions(""))
        self.assertIsNone(remove_empty_custom_field_definitions(None))


if __name__ == "__main__":
    unittest.main()
