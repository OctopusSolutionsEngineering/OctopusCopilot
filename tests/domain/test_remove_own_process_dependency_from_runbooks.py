import unittest

from domain.sanitizers.terraform import remove_own_process_dependency_from_runbooks

RUNBOOK = """resource "octopusdeploy_process" "process_k8s_web_app_deprovision_environment" {
  count      = "${length(local.project_k8s_web_app_projects_matches) != 0 ? 0 : 1}"
  project_id = "${local.project_k8s_web_app_projects_matches[0].id}"
  runbook_id = "${length(local.project_k8s_web_app_projects_matches) != 0 ? null : octopusdeploy_runbook.runbook_deprovision_environment[0].id}"
  depends_on = []
}
resource "octopusdeploy_process_step" "process_step_deprovision_environment_run_a_kubectl_script" {
  name       = "Run a kubectl script"
  process_id = "${octopusdeploy_process.process_k8s_web_app_deprovision_environment[0].id}"
}
resource "octopusdeploy_process_steps_order" "process_step_order_deprovision_environment" {
  process_id = "${octopusdeploy_process.process_k8s_web_app_deprovision_environment[0].id}"
  steps      = ["${octopusdeploy_process_step.process_step_deprovision_environment_run_a_kubectl_script[0].id}"]
}
resource "octopusdeploy_runbook" "runbook_deprovision_environment" {
  name       = "Deprovision Environment"
  depends_on = [
    DEPENDENCIES
  ]
}
"""


def runbook(dependencies):
    return RUNBOOK.replace("DEPENDENCIES", dependencies)


class TestRemoveOwnProcessDependencyFromRunbooks(unittest.TestCase):
    def test_steps_order_dependency_is_removed(self):
        result = remove_own_process_dependency_from_runbooks(
            runbook("octopusdeploy_process_steps_order.process_step_order_deprovision_environment")
        )
        runbook_block = result[result.index('resource "octopusdeploy_runbook"') :]
        self.assertNotIn("octopusdeploy_process_steps_order.", runbook_block)

    def test_process_and_step_dependencies_are_removed(self):
        result = remove_own_process_dependency_from_runbooks(
            runbook(
                "octopusdeploy_process.process_k8s_web_app_deprovision_environment, "
                "octopusdeploy_process_step.process_step_deprovision_environment_run_a_kubectl_script"
            )
        )
        runbook_block = result[result.index('resource "octopusdeploy_runbook"') :]
        self.assertNotIn("octopusdeploy_process", runbook_block.split("depends_on")[1])

    def test_other_dependencies_are_kept(self):
        result = remove_own_process_dependency_from_runbooks(
            runbook(
                "octopusdeploy_process_steps_order.process_step_order_deprovision_environment, "
                "octopusdeploy_parent_environment.parent_environment_features"
            )
        )
        runbook_block = result[result.index('resource "octopusdeploy_runbook"') :]
        self.assertIn("octopusdeploy_parent_environment.parent_environment_features", runbook_block)
        self.assertNotIn("octopusdeploy_process_steps_order.", runbook_block)

    def test_dependency_on_another_process_is_kept(self):
        config = runbook("octopusdeploy_process_steps_order.process_step_order_my_project") + (
            'resource "octopusdeploy_process_steps_order" "process_step_order_my_project" {\n'
            '  process_id = "${octopusdeploy_process.process_my_project[0].id}"\n'
            "}\n"
        )
        self.assertEqual(remove_own_process_dependency_from_runbooks(config), config)

    def test_runbook_without_process_is_untouched(self):
        config = (
            'resource "octopusdeploy_runbook" "runbook_a" {\n'
            "  depends_on = [octopusdeploy_process_steps_order.process_step_order_b]\n"
            "}\n"
        )
        self.assertEqual(remove_own_process_dependency_from_runbooks(config), config)

    def test_empty_config(self):
        self.assertEqual(remove_own_process_dependency_from_runbooks(""), "")
        self.assertIsNone(remove_own_process_dependency_from_runbooks(None))


if __name__ == "__main__":
    unittest.main()
