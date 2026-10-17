import unittest

from domain.sanitizers.terraform import remove_script_syntax_from_git_scripts


def step(source, syntax_line='        "Octopus.Action.Script.Syntax" = "Bash"\n'):
    return (
        'resource "octopusdeploy_process_step" "process_step_switch_traffic" {\n'
        '  name                 = "Switch Traffic"\n'
        '  type                 = "Octopus.Script"\n'
        "  execution_properties = {\n"
        f'        "Octopus.Action.Script.ScriptSource" = "{source}"\n'
        '        "Octopus.Action.Script.ScriptFileName" = "scripts/switch.sh"\n'
        + syntax_line
        + '        "Octopus.Action.RunOnServer" = "true"\n'
        "  }\n"
        "}\n"
    )


class TestRemoveScriptSyntaxFromGitScripts(unittest.TestCase):
    def test_observed_git_script_syntax_is_removed(self):
        result = remove_script_syntax_from_git_scripts(step("GitRepository"))
        self.assertNotIn("Octopus.Action.Script.Syntax", result)
        self.assertIn('"Octopus.Action.Script.ScriptFileName" = "scripts/switch.sh"', result)
        self.assertIn('"Octopus.Action.RunOnServer" = "true"', result)

    def test_inline_script_keeps_syntax(self):
        config = step("Inline")
        self.assertEqual(config, remove_script_syntax_from_git_scripts(config))

    def test_package_script_keeps_syntax(self):
        config = step("Package")
        self.assertEqual(config, remove_script_syntax_from_git_scripts(config))

    def test_only_git_step_is_changed(self):
        inline = step("Inline").replace("process_step_switch_traffic", "process_step_inline")
        result = remove_script_syntax_from_git_scripts(step("GitRepository") + inline)
        self.assertEqual(1, result.count("Octopus.Action.Script.Syntax"))
        self.assertIn('resource "octopusdeploy_process_step" "process_step_inline"', result)

    def test_git_step_without_syntax_is_unchanged(self):
        config = step("GitRepository", syntax_line="") + step("Inline").replace(
            "process_step_switch_traffic", "process_step_inline"
        )
        self.assertEqual(config, remove_script_syntax_from_git_scripts(config))

    def test_empty(self):
        self.assertEqual("", remove_script_syntax_from_git_scripts(""))
        self.assertIsNone(remove_script_syntax_from_git_scripts(None))


if __name__ == "__main__":
    unittest.main()
