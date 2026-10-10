import unittest

from domain.sanitizers.terraform import remove_git_triggers_without_git_dependency

INLINE_STEP = """resource "octopusdeploy_process_step" "process_step_gate" {
  name = "Gate"
  slug = "gate"
  execution_properties = {
    "Octopus.Action.Script.ScriptSource" = "Inline"
  }
}
"""

GIT_STEP = """resource "octopusdeploy_process_step" "process_step_run_policy" {
  name             = "Run Policy"
  slug             = "run-policy"
  git_dependencies = { "" = { default_branch = "main", repository_uri = "https://github.com/acme/policies.git" } }
}
"""

TRIGGER = """resource "octopusdeploy_git_trigger" "projecttrigger_git" {
  name    = "Git Trigger"
  sources = [{ deployment_action_slug = "SLUG", exclude_file_paths = [], git_dependency_name = "", include_file_paths = ["policies/*"] }]
  lifecycle {
    prevent_destroy = true
  }
}
"""


class TestRemoveGitTriggersWithoutGitDependency(unittest.TestCase):
    def test_trigger_on_inline_step_is_removed(self):
        result = remove_git_triggers_without_git_dependency(INLINE_STEP + TRIGGER.replace("SLUG", "gate"))
        self.assertNotIn("octopusdeploy_git_trigger", result)
        self.assertIn('slug = "gate"', result)

    def test_trigger_on_git_step_is_kept(self):
        config = GIT_STEP + TRIGGER.replace("SLUG", "run-policy")
        self.assertEqual(remove_git_triggers_without_git_dependency(config), config)

    def test_trigger_on_missing_step_is_removed(self):
        result = remove_git_triggers_without_git_dependency(GIT_STEP + TRIGGER.replace("SLUG", "nope"))
        self.assertNotIn("octopusdeploy_git_trigger", result)

    def test_null_git_dependencies_counts_as_none(self):
        step = GIT_STEP.replace('{ "" = { default_branch = "main", repository_uri = "https://github.com/acme/policies.git" } }', "null")
        result = remove_git_triggers_without_git_dependency(step + TRIGGER.replace("SLUG", "run-policy"))
        self.assertNotIn("octopusdeploy_git_trigger", result)

    def test_only_bad_trigger_is_removed(self):
        good = TRIGGER.replace("SLUG", "run-policy")
        bad = TRIGGER.replace("SLUG", "gate").replace("projecttrigger_git", "projecttrigger_bad")
        result = remove_git_triggers_without_git_dependency(INLINE_STEP + GIT_STEP + bad + good)
        self.assertIn("projecttrigger_git", result)
        self.assertNotIn("projecttrigger_bad", result)

    def test_empty_config(self):
        self.assertEqual(remove_git_triggers_without_git_dependency(""), "")
        self.assertIsNone(remove_git_triggers_without_git_dependency(None))


if __name__ == "__main__":
    unittest.main()
