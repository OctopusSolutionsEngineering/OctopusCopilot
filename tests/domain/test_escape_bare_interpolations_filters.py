import unittest

from domain.sanitizers.terraform import escape_bare_interpolations


class TestEscapeBareInterpolationsFilters(unittest.TestCase):
    def test_filtered_octopus_variable_becomes_octostache(self):
        config = '"Octopus.Action.Aws.CloudFormationStackName" = "order-queue-${Octopus.Environment.Name | ToLower}"'
        self.assertEqual(
            escape_bare_interpolations(config),
            '"Octopus.Action.Aws.CloudFormationStackName" = "order-queue-#{Octopus.Environment.Name | ToLower}"',
        )

    def test_escaped_filtered_octopus_variable_becomes_octostache(self):
        config = 'QueueName: order-events-$${Octopus.Environment.Name | ToLower}'
        self.assertEqual(escape_bare_interpolations(config), "QueueName: order-events-#{Octopus.Environment.Name | ToLower}")

    def test_chained_filters_are_kept(self):
        self.assertEqual(
            escape_bare_interpolations("a ${Octopus.Space.Name | ToLower | Trim} b"),
            "a #{Octopus.Space.Name | ToLower | Trim} b",
        )

    def test_unfiltered_octopus_variable_still_becomes_octostache(self):
        self.assertEqual(escape_bare_interpolations("${DNS.Zone}"), "#{DNS.Zone}")

    def test_escaped_cloudformation_getatt_without_filter_is_untouched(self):
        config = "!Sub 'arn:$${Bucket.Arn}/*'"
        self.assertEqual(escape_bare_interpolations(config), config)

    def test_cloudformation_pseudo_parameter_is_still_escaped(self):
        self.assertEqual(escape_bare_interpolations("!Sub '${AWS::Region}'"), "!Sub '$${AWS::Region}'")

    def test_logical_or_is_not_treated_as_a_filter(self):
        config = '"x" = "${Foo.bar || true}"'
        self.assertNotIn("#{", escape_bare_interpolations(config))

    def test_terraform_references_are_untouched(self):
        config = 'project_id = "${octopusdeploy_project.project_x[0].id}"'
        self.assertEqual(escape_bare_interpolations(config), config)

    def test_empty_config(self):
        self.assertEqual(escape_bare_interpolations(""), "")
        self.assertIsNone(escape_bare_interpolations(None))


if __name__ == "__main__":
    unittest.main()
