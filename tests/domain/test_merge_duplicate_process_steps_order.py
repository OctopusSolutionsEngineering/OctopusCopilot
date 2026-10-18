import unittest

from domain.sanitizers.terraform import merge_duplicate_process_steps_order

PROCESS_ID = '"${length(local.p_matches) != 0 ? null : octopusdeploy_process.process_q77[0].id}"'


def order(label, steps, process_id=PROCESS_ID):
    items = ",\n".join(f'    "${{octopusdeploy_process_step.{step}[0].id}}"' for step in steps)
    return (
        f'resource "octopusdeploy_process_steps_order" "{label}" {{\n'
        f"  count      = 1\n"
        f"  process_id = {process_id}\n"
        f"  steps      = [\n{items}\n  ]\n"
        f"}}\n"
    )


class TestMergeDuplicateProcessStepsOrder(unittest.TestCase):
    def test_observed_updated_steps_order_is_merged(self):
        config = order("process_step_order_q77", ["step_approve", "step_rollout"]) + order(
            "process_step_order_q77_updated", ["create_aws_sqs_queue"]
        )
        result = merge_duplicate_process_steps_order(config)
        self.assertEqual(1, result.count('resource "octopusdeploy_process_steps_order"'))
        self.assertIn('"process_step_order_q77"', result)
        self.assertNotIn("process_step_order_q77_updated", result)
        self.assertLess(result.index("step_approve"), result.index("step_rollout"))
        self.assertLess(result.index("step_rollout"), result.index("create_aws_sqs_queue"))
        self.assertEqual(result.count("{"), result.count("}"))

    def test_duplicate_steps_are_not_repeated(self):
        config = order("a", ["one", "two"]) + order("b", ["two", "three"])
        result = merge_duplicate_process_steps_order(config)
        self.assertEqual(1, result.count("octopusdeploy_process_step.two[0].id"))
        self.assertIn("octopusdeploy_process_step.three[0].id", result)

    def test_references_point_at_the_kept_resource(self):
        config = (
            order("a", ["one"])
            + order("b", ["two"])
            + 'resource "octopusdeploy_channel" "c" {\n  depends_on = [octopusdeploy_process_steps_order.b]\n}\n'
        )
        result = merge_duplicate_process_steps_order(config)
        self.assertIn("depends_on = [octopusdeploy_process_steps_order.a]", result)

    def test_different_processes_are_unchanged(self):
        runbook_id = '"${octopusdeploy_process.process_q77_runbook[0].id}"'
        config = order("a", ["one"]) + order("b", ["two"], runbook_id)
        self.assertEqual(config, merge_duplicate_process_steps_order(config))

    def test_single_steps_order_is_unchanged(self):
        config = order("a", ["one", "two"])
        self.assertEqual(config, merge_duplicate_process_steps_order(config))

    def test_empty(self):
        self.assertEqual("", merge_duplicate_process_steps_order(""))
        self.assertIsNone(merge_duplicate_process_steps_order(None))


if __name__ == "__main__":
    unittest.main()
