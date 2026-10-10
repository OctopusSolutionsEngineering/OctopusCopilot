import unittest

from domain.sanitizers.terraform import remove_empty_action_properties

STEP = """resource "octopusdeploy_process_step" "process_step_stack_manager_create_change_set" {
  name                  = "Create Change Set"
  type                  = "Octopus.AwsRunCloudFormation"
  properties            = {
    "Octopus.Action.TargetRoles" = ""
  }
  execution_properties  = {
    "Octopus.Action.RunOnServer" = "true"
    "Octopus.Action.Package.JsonConfigurationVariablesTargets" = ""
    "Octopus.Action.Aws.CloudFormationTemplate" = "app.yaml"
    "OctopusUseBundledTooling" = "False"
  }
}
"""


class TestRemoveEmptyActionProperties(unittest.TestCase):
    def test_empty_properties_are_removed(self):
        result = remove_empty_action_properties(STEP)
        self.assertNotIn("JsonConfigurationVariablesTargets", result)
        self.assertNotIn('"Octopus.Action.TargetRoles" = ""', result)
        self.assertIn('"Octopus.Action.RunOnServer" = "true"', result)
        self.assertIn('"Octopus.Action.Aws.CloudFormationTemplate" = "app.yaml"', result)
        self.assertIn('"OctopusUseBundledTooling" = "False"', result)

    def test_non_empty_values_are_untouched(self):
        config = STEP.replace('= ""', '= "x"')
        self.assertEqual(remove_empty_action_properties(config), config)

    def test_empty_values_outside_steps_are_untouched(self):
        config = 'resource "octopusdeploy_variable" "v" {\n  properties = {\n    "Octopus.Action.X" = ""\n  }\n}\n'
        self.assertEqual(remove_empty_action_properties(config), config)

    def test_templated_steps_are_handled(self):
        config = STEP.replace("octopusdeploy_process_step", "octopusdeploy_process_templated_step")
        self.assertNotIn("JsonConfigurationVariablesTargets", remove_empty_action_properties(config))

    def test_several_steps(self):
        config = STEP + STEP.replace("create_change_set", "execute_change_set")
        self.assertEqual(remove_empty_action_properties(config).count('= ""'), 0)

    def test_empty_config(self):
        self.assertEqual(remove_empty_action_properties(""), "")
        self.assertIsNone(remove_empty_action_properties(None))


if __name__ == "__main__":
    unittest.main()
