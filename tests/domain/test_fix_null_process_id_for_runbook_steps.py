import unittest

from domain.sanitizers.terraform import fix_null_process_id_for_runbook_steps

CONFIG = """resource "octopusdeploy_process" "process_deprovision_environment" {
  count      = "${length(local.project_matches) != 0 ? 1 : 0}"
  project_id = "${local.project_matches[0].id}"
  runbook_id = "${octopusdeploy_runbook.runbook_deprovision_environment[0].id}"
}
resource "octopusdeploy_process" "process_web_app" {
  count      = "${length(local.project_matches) != 0 ? 0 : 1}"
  project_id = "${octopusdeploy_project.project_web_app[0].id}"
}
resource "octopusdeploy_process_step" "process_step_deprovision_environment_run_kubectl_script" {
  count      = "${length(local.project_matches) != 0 ? 1 : 0}"
  process_id = "${length(local.project_matches) != 0 ? null : octopusdeploy_process.process_deprovision_environment[0].id}"
}
resource "octopusdeploy_process_steps_order" "process_step_order_deprovision_environment" {
  count      = "1"
  process_id = "${octopusdeploy_process.process_deprovision_environment[0].id}"
  steps      = ["${length(local.project_matches) != 0 ? null : octopusdeploy_process_step.process_step_deprovision_environment_run_kubectl_script[0].id}"]
}
resource "octopusdeploy_process_steps_order" "process_step_order_web_app" {
  count      = "${length(local.project_matches) != 0 ? 0 : 1}"
  process_id = "${length(local.project_matches) != 0 ? null : octopusdeploy_process.process_web_app[0].id}"
  steps      = ["${length(local.project_matches) != 0 ? null : octopusdeploy_process_step.process_step_web_app_deploy[0].id}"]
}
resource "octopusdeploy_process_step" "process_step_web_app_deploy" {
  count      = "${length(local.project_matches) != 0 ? 0 : 1}"
  process_id = "${length(local.project_matches) != 0 ? null : octopusdeploy_process.process_web_app[0].id}"
}
"""


class TestFixNullProcessIdForRunbookSteps(unittest.TestCase):
    def test_runbook_step_process_id_is_fixed(self):
        result = fix_null_process_id_for_runbook_steps(CONFIG)
        self.assertIn('process_id = "${octopusdeploy_process.process_deprovision_environment[0].id}"', result)

    def test_runbook_steps_order_step_reference_is_fixed(self):
        result = fix_null_process_id_for_runbook_steps(CONFIG)
        self.assertIn(
            'steps      = ["${octopusdeploy_process_step.process_step_deprovision_environment_run_kubectl_script[0].id}"]',
            result,
        )

    def test_deployment_steps_order_is_unchanged(self):
        result = fix_null_process_id_for_runbook_steps(CONFIG)
        self.assertIn(
            'steps      = ["${length(local.project_matches) != 0 ? null : octopusdeploy_process_step.process_step_web_app_deploy[0].id}"]',
            result,
        )

    def test_deployment_process_step_is_unchanged(self):
        result = fix_null_process_id_for_runbook_steps(CONFIG)
        self.assertIn(
            'process_id = "${length(local.project_matches) != 0 ? null : octopusdeploy_process.process_web_app[0].id}"',
            result,
        )

    def test_no_runbook_processes_is_unchanged(self):
        config = CONFIG.replace(
            '  runbook_id = "${octopusdeploy_runbook.runbook_deprovision_environment[0].id}"\n', ""
        )
        self.assertEqual(config, fix_null_process_id_for_runbook_steps(config))

    def test_none_and_empty(self):
        self.assertIsNone(fix_null_process_id_for_runbook_steps(None))
        self.assertEqual("", fix_null_process_id_for_runbook_steps(""))


if __name__ == "__main__":
    unittest.main()
