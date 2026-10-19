import unittest

from domain.sanitizers.terraform import remove_action_properties_from_template_parameters

COMMUNITY_STEP = """resource "octopusdeploy_process_templated_step" "process_step_script_calculate_deployment_mode" {
  count       = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  name        = "Calculate Deployment Mode"
  process_id  = "${octopusdeploy_process.process_script[0].id}"
  template_id = "${octopusdeploy_community_step_template.communitysteptemplate_calculate_deployment_mode[0].id}"
  worker_pool_variable = "Project.WorkerPool"

  execution_properties = {
    "Octopus.Action.RunOnServer" = "true"
  }
  parameters = {
    "Octopus.Action.Script.ScriptBody" = "Write-Host \\"Calculate deployment mode\\""
  }
}
"""

SCRIPT_STEP = """resource "octopusdeploy_process_step" "process_step_script_hello_world" {
  name = "Hello World"
  type = "Octopus.Script"
  execution_properties = {
    "Octopus.Action.Script.ScriptBody" = "echo hi"
  }
}
"""


class TestRemoveActionPropertiesFromTemplateParameters(unittest.TestCase):
    def test_script_body_is_removed_from_parameters(self):
        result = remove_action_properties_from_template_parameters(COMMUNITY_STEP)
        self.assertNotIn("ScriptBody", result)
        self.assertIn("  parameters = {\n  }\n", result)
        self.assertIn('"Octopus.Action.RunOnServer" = "true"', result)

    def test_template_parameters_are_kept(self):
        config = COMMUNITY_STEP.replace(
            "  parameters = {\n", '  parameters = {\n    "CalculateDeploymentMode.Value" = "Deploy"\n'
        )
        result = remove_action_properties_from_template_parameters(config)
        self.assertIn('"CalculateDeploymentMode.Value" = "Deploy"', result)
        self.assertNotIn("ScriptBody", result)

    def test_heredoc_value_is_removed(self):
        config = COMMUNITY_STEP.replace(
            '    "Octopus.Action.Script.ScriptBody" = "Write-Host \\"Calculate deployment mode\\""\n',
            '    "Octopus.Action.Script.ScriptBody" = <<-EOT\n      Write-Host "a"\n      Write-Host "b"\n    EOT\n'
            '    "Template.Param" = "x"\n',
        )
        result = remove_action_properties_from_template_parameters(config)
        self.assertNotIn("Write-Host", result)
        self.assertNotIn("EOT", result)
        self.assertIn('"Template.Param" = "x"', result)

    def test_regular_steps_are_unchanged(self):
        config = SCRIPT_STEP + "\n" + COMMUNITY_STEP
        result = remove_action_properties_from_template_parameters(config)
        self.assertTrue(result.startswith(SCRIPT_STEP))
        self.assertEqual(1, result.count("ScriptBody"))

    def test_empty(self):
        self.assertEqual("", remove_action_properties_from_template_parameters(""))
        self.assertIsNone(remove_action_properties_from_template_parameters(None))


if __name__ == "__main__":
    unittest.main()
