import unittest

from domain.sanitizers.terraform import fix_bare_comparison_in_condition_expression

LINE = '    "Octopus.Step.ConditionVariableExpression" = "VALUE"\n'


class TestFixBareComparisonInConditionExpression(unittest.TestCase):
    def test_bare_comparison_is_wrapped_in_if(self):
        result = fix_bare_comparison_in_condition_expression(LINE.replace("VALUE", '#{Search.PreflightEnabled == \\"true\\"}'))
        self.assertIn('"#{if Search.PreflightEnabled == \\"true\\"}true#{/if}"', result)

    def test_not_equal_comparison(self):
        result = fix_bare_comparison_in_condition_expression(LINE.replace("VALUE", '#{Octopus.Environment.Name != \\"Development\\"}'))
        self.assertIn('#{if Octopus.Environment.Name != \\"Development\\"}true#{/if}', result)

    def test_if_expression_is_unchanged(self):
        config = LINE.replace("VALUE", '#{if Search.Enabled == \\"true\\"}true#{/if}')
        self.assertEqual(fix_bare_comparison_in_condition_expression(config), config)

    def test_unless_and_plain_variable_are_unchanged(self):
        config = LINE.replace("VALUE", "#{unless Octopus.Deployment.Error}True#{/unless}") + LINE.replace("VALUE", "#{Search.Enabled}")
        self.assertEqual(fix_bare_comparison_in_condition_expression(config), config)

    def test_other_properties_are_unchanged(self):
        config = '    "Octopus.Action.Script.ScriptBody" = "echo #{A == \\"b\\"}"\n'
        self.assertEqual(fix_bare_comparison_in_condition_expression(config), config)

    def test_empty_config(self):
        self.assertEqual(fix_bare_comparison_in_condition_expression(""), "")
        self.assertIsNone(fix_bare_comparison_in_condition_expression(None))


if __name__ == "__main__":
    unittest.main()
