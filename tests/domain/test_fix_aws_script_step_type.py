import unittest

from domain.sanitizers.terraform import fix_aws_script_step_type


AWS_SCRIPT_STEP = """resource "octopusdeploy_process_step" "process_step_q48_billing_api_deploy_to_ecs" {
  count                 = 1
  name                  = "Deploy to ECS"
  type                  = "Octopus.Script"
  execution_properties  = {
    "Octopus.Action.Script.ScriptBody"              = "aws ecs update-service --cluster billing-#{Octopus.Environment.Name | ToLower}"
    "Octopus.Action.AwsAccount.Variable"            = "Project.AWS.Account"
    "Octopus.Action.AwsAccount.UseInstanceRole"     = "False"
    "Octopus.Action.Aws.Region"                     = "eu-west-1"
  }
}
"""

PLAIN_SCRIPT_STEP = """resource "octopusdeploy_process_step" "process_step_hello" {
  name                  = "Hello"
  type                  = "Octopus.Script"
  execution_properties  = {
    "Octopus.Action.Script.ScriptBody" = "echo hello"
  }
}
"""


class TestFixAwsScriptStepType(unittest.TestCase):
    def test_observed_ecs_script_step(self):
        result = fix_aws_script_step_type(AWS_SCRIPT_STEP)
        self.assertIn('type                  = "Octopus.AwsRunScript"', result)
        self.assertNotIn('"Octopus.Script"', result)

    def test_plain_script_step_is_unchanged(self):
        config = PLAIN_SCRIPT_STEP + AWS_SCRIPT_STEP.replace("AwsAccount", "Other")
        self.assertEqual(config, fix_aws_script_step_type(config))

    def test_only_the_aws_step_changes(self):
        result = fix_aws_script_step_type(PLAIN_SCRIPT_STEP + AWS_SCRIPT_STEP)
        self.assertEqual(1, result.count('"Octopus.Script"'))
        self.assertEqual(1, result.count('"Octopus.AwsRunScript"'))
        self.assertTrue(result.startswith(PLAIN_SCRIPT_STEP))

    def test_aws_run_script_is_unchanged(self):
        config = AWS_SCRIPT_STEP.replace('"Octopus.Script"', '"Octopus.AwsRunScript"')
        self.assertEqual(config, fix_aws_script_step_type(config))

    def test_empty(self):
        self.assertEqual("", fix_aws_script_step_type(""))
        self.assertIsNone(fix_aws_script_step_type(None))


if __name__ == "__main__":
    unittest.main()
