import unittest

from domain.sanitizers.terraform import fix_step_process_ids_from_steps_order

PROCESSES = """resource "octopusdeploy_process" "process_progressive_deployment" {
  count      = "${length(local.project_matches) != 0 ? 0 : 1}"
  project_id = "${octopusdeploy_project.project_progressive_deployment[0].id}"
}
resource "octopusdeploy_process" "process_progressive_deployment_deploy_release" {
  count      = "${length(local.project_matches) != 0 ? 0 : 1}"
  project_id = "${octopusdeploy_project.project_progressive_deployment[0].id}"
  runbook_id = "${octopusdeploy_runbook.runbook_deploy_release[0].id}"
}
"""


def step(label, process):
    return f"""resource "octopusdeploy_process_step" "{label}" {{
  count      = "${{length(local.project_matches) != 0 ? 0 : 1}}"
  name       = "Sleep"
  type       = "Octopus.Script"
  process_id = "${{length(local.project_matches) != 0 ? null : octopusdeploy_process.{process}[0].id}}"
}}
"""


def order(label, process, steps):
    step_list = ", ".join(f'"${{octopusdeploy_process_step.{s}[0].id}}"' for s in steps)
    return f"""resource "octopusdeploy_process_steps_order" "{label}" {{
  count      = "${{length(local.project_matches) != 0 ? 0 : 1}}"
  process_id = "${{octopusdeploy_process.{process}[0].id}}"
  steps      = [{step_list}]
}}
"""


class TestFixStepProcessIdsFromStepsOrder(unittest.TestCase):
    def test_observed_runbook_step_in_deployment_process_is_fixed(self):
        config = (
            PROCESSES
            + step("process_step_deploy_release_sleep", "process_progressive_deployment")
            + order(
                "process_step_order_deploy_release",
                "process_progressive_deployment_deploy_release",
                ["process_step_deploy_release_sleep"],
            )
        )
        result = fix_step_process_ids_from_steps_order(config)
        self.assertIn(
            "process_id = \"${length(local.project_matches) != 0 ? null : "
            "octopusdeploy_process.process_progressive_deployment_deploy_release[0].id}\"",
            result,
        )

    def test_matching_process_is_unchanged(self):
        config = (
            PROCESSES
            + step("process_step_deploy", "process_progressive_deployment")
            + order("process_step_order", "process_progressive_deployment", ["process_step_deploy"])
        )
        self.assertEqual(config, fix_step_process_ids_from_steps_order(config))

    def test_step_listed_by_two_orders_is_unchanged(self):
        config = (
            PROCESSES
            + step("process_step_shared", "process_progressive_deployment")
            + order("order_a", "process_progressive_deployment", ["process_step_shared"])
            + order("order_b", "process_progressive_deployment_deploy_release", ["process_step_shared"])
        )
        self.assertEqual(config, fix_step_process_ids_from_steps_order(config))

    def test_unlisted_step_is_unchanged(self):
        config = PROCESSES + step("process_step_orphan", "process_progressive_deployment")
        self.assertEqual(config, fix_step_process_ids_from_steps_order(config))

    def test_templated_step_is_fixed(self):
        templated = step("process_step_templated", "process_progressive_deployment").replace(
            "octopusdeploy_process_step", "octopusdeploy_process_templated_step"
        )
        config = (
            PROCESSES
            + templated
            + """resource "octopusdeploy_process_steps_order" "order_runbook" {
  process_id = "${octopusdeploy_process.process_progressive_deployment_deploy_release[0].id}"
  steps      = ["${octopusdeploy_process_templated_step.process_step_templated[0].id}"]
}
"""
        )
        result = fix_step_process_ids_from_steps_order(config)
        self.assertIn("octopusdeploy_process.process_progressive_deployment_deploy_release[0].id}\"\n}", result)

    def test_observed_step_in_both_orders_moves_to_runbook(self):
        # Observed: the runbook Sleep step was listed by both the deployment and runbook steps orders
        config = (
            PROCESSES
            + step("process_step_progressive_deployment_deploy", "process_progressive_deployment")
            + step("process_step_progressive_deployment_deploy_release_sleep", "process_progressive_deployment")
            + order(
                "process_step_order_progressive_deployment",
                "process_progressive_deployment",
                ["process_step_progressive_deployment_deploy", "process_step_progressive_deployment_deploy_release_sleep"],
            )
            + order(
                "process_step_order_progressive_deployment_deploy_release",
                "process_progressive_deployment_deploy_release",
                ["process_step_progressive_deployment_deploy_release_sleep"],
            )
        )
        result = fix_step_process_ids_from_steps_order(config)
        self.assertIn(
            'steps      = ["${octopusdeploy_process_step.process_step_progressive_deployment_deploy[0].id}"]', result
        )
        sleep = result[result.index('"process_step_progressive_deployment_deploy_release_sleep" {'):]
        self.assertIn("octopusdeploy_process.process_progressive_deployment_deploy_release[0].id", sleep.split("}\n")[0] + "}")
        deploy = result[result.index('"process_step_progressive_deployment_deploy" {'):]
        self.assertIn("octopusdeploy_process.process_progressive_deployment[0].id", deploy[: deploy.index("\n}")])

    def test_empty(self):
        self.assertEqual("", fix_step_process_ids_from_steps_order(""))
        self.assertIsNone(fix_step_process_ids_from_steps_order(None))


if __name__ == "__main__":
    unittest.main()
