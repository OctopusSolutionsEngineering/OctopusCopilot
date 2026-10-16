import unittest

from domain.sanitizers.terraform import dedupe_case_insensitive_step_names

PROCESS = '"${length(local.project_matches) != 0 ? null : octopusdeploy_process.process_r12[0].id}"'
OTHER_PROCESS = '"${octopusdeploy_process.process_runbook[0].id}"'


def step(label, name, slug, process=PROCESS, kind="octopusdeploy_process_step"):
    return f"""resource "{kind}" "{label}" {{
  name                  = "{name}"
  type                  = "Octopus.Script"
  process_id            = {process}
  slug                  = "{slug}"
}}
"""


class TestDedupeCaseInsensitiveStepNames(unittest.TestCase):
    def test_observed_smoke_test_clash_is_renamed(self):
        config = step("smoke_test", "Smoke test", "smoke-test") + step("template_smoke_test", "Smoke Test", "smoke-test")
        result = dedupe_case_insensitive_step_names(config)
        self.assertIn('name                  = "Smoke test"', result)
        self.assertIn('name                  = "Smoke Test 2"', result)
        self.assertIn('slug                  = "smoke-test-2"', result)
        self.assertEqual(1, result.count('"smoke-test"'))

    def test_same_name_in_different_processes_is_unchanged(self):
        config = step("a", "Run Script", "run-script") + step("b", "Run Script", "run-script", OTHER_PROCESS)
        self.assertEqual(config, dedupe_case_insensitive_step_names(config))

    def test_templated_steps_are_included(self):
        config = step("a", "Notify", "notify") + step("b", "notify", "notify-x", kind="octopusdeploy_process_templated_step")
        result = dedupe_case_insensitive_step_names(config)
        self.assertIn('name                  = "notify 2"', result)
        self.assertIn('slug                  = "notify-x-2"', result)

    def test_third_duplicate_gets_next_number(self):
        config = step("a", "Deploy", "deploy") + step("b", "DEPLOY", "deploy") + step("c", "deploy", "deploy")
        result = dedupe_case_insensitive_step_names(config)
        self.assertIn('"DEPLOY 2"', result)
        self.assertIn('"deploy 3"', result)

    def test_unique_names_are_unchanged(self):
        config = step("a", "Build", "build") + step("b", "Test", "test")
        self.assertEqual(config, dedupe_case_insensitive_step_names(config))

    def test_empty(self):
        self.assertEqual("", dedupe_case_insensitive_step_names(""))
        self.assertIsNone(dedupe_case_insensitive_step_names(None))


if __name__ == "__main__":
    unittest.main()
