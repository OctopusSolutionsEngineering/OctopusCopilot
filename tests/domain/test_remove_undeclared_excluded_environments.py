import unittest

from domain.sanitizers.terraform import remove_undeclared_excluded_environments

DEVELOPMENT_LOOKUP = """data "octopusdeploy_environments" "environment_development" {
  partial_name = "Development"
  skip         = 0
  take         = 1
}
"""

DEVELOPMENT_REFERENCE = '"${data.octopusdeploy_environments.environment_development.environments[0].id}"'
SECURITY_REFERENCE = '"${data.octopusdeploy_environments.environment_security.environments[0].id}"'


def step(excluded):
    return f"""resource "octopusdeploy_process_step" "process_step_check_smtp" {{
  name                  = "Octopus - Check SMTP Server Configured"
  {excluded}
  notes                 = "Checks SMTP"
}}
"""


class TestRemoveUndeclaredExcludedEnvironments(unittest.TestCase):
    def test_observed_undeclared_security_lookup_is_removed(self):
        config = DEVELOPMENT_LOOKUP + step(f"excluded_environments = [{SECURITY_REFERENCE}]")
        result = remove_undeclared_excluded_environments(config)
        self.assertNotIn("excluded_environments", result)
        self.assertIn('notes                 = "Checks SMTP"', result)
        self.assertIn('name                  = "Octopus - Check SMTP Server Configured"', result)

    def test_declared_entries_are_kept(self):
        config = DEVELOPMENT_LOOKUP + step(f"excluded_environments = [{DEVELOPMENT_REFERENCE}, {SECURITY_REFERENCE}]")
        result = remove_undeclared_excluded_environments(config)
        self.assertIn(f"excluded_environments = [{DEVELOPMENT_REFERENCE}]", result)
        self.assertNotIn("environment_security", result)

    def test_fully_declared_list_is_unchanged(self):
        config = DEVELOPMENT_LOOKUP + step(f"excluded_environments = [{DEVELOPMENT_REFERENCE}]")
        self.assertEqual(config, remove_undeclared_excluded_environments(config))

    def test_ternary_with_declared_lookup_and_resource_is_kept(self):
        ternary = (
            '"${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? '
            "data.octopusdeploy_environments.environment_security.environments[0].id : "
            'octopusdeploy_environment.environment_security[0].id}"'
        )
        config = (
            'data "octopusdeploy_environments" "environment_security" {\n  partial_name = "Security"\n}\n'
            + 'resource "octopusdeploy_environment" "environment_security" {\n  name = "Security"\n}\n'
            + step(f"excluded_environments = [{ternary}]")
        )
        self.assertEqual(config, remove_undeclared_excluded_environments(config))

    def test_ternary_with_undeclared_resource_is_removed(self):
        ternary = (
            '"${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? '
            "data.octopusdeploy_environments.environment_security.environments[0].id : "
            'octopusdeploy_environment.environment_security[0].id}"'
        )
        config = (
            'data "octopusdeploy_environments" "environment_security" {\n  partial_name = "Security"\n}\n'
            + step(f"excluded_environments = [{ternary}]")
        )
        self.assertNotIn("excluded_environments", remove_undeclared_excluded_environments(config))

    def test_multi_line_list(self):
        config = DEVELOPMENT_LOOKUP + step(
            f"excluded_environments = [\n    {DEVELOPMENT_REFERENCE},\n    {SECURITY_REFERENCE}\n  ]"
        )
        result = remove_undeclared_excluded_environments(config)
        self.assertIn(f"  excluded_environments = [{DEVELOPMENT_REFERENCE}]\n", result)
        self.assertNotIn("environment_security", result)
        self.assertIn('notes                 = "Checks SMTP"', result)

    def test_environments_attribute_is_not_changed(self):
        config = DEVELOPMENT_LOOKUP + step(f"environments = [{SECURITY_REFERENCE}]")
        self.assertEqual(config, remove_undeclared_excluded_environments(config))

    def test_multiple_steps(self):
        config = DEVELOPMENT_LOOKUP + step(f"excluded_environments = [{SECURITY_REFERENCE}]") + step(
            f"excluded_environments = [{SECURITY_REFERENCE}]"
        )
        self.assertNotIn("excluded_environments", remove_undeclared_excluded_environments(config))

    def test_observed_undeclared_local_is_removed(self):
        config = step('excluded_environments = ["${local.environment_security_matches[0].id}"]')
        self.assertNotIn("excluded_environments", remove_undeclared_excluded_environments(config))

    def test_declared_local_is_kept(self):
        config = (
            "locals {\n"
            '  environment_security_matches = [for env in data.octopusdeploy_environments.environment_security.environments : env if env.name == "Security"]\n'
            "}\n"
            + 'data "octopusdeploy_environments" "environment_security" {\n  partial_name = "Security"\n}\n'
            + step('excluded_environments = ["${local.environment_security_matches[0].id}"]')
        )
        self.assertEqual(config, remove_undeclared_excluded_environments(config))

    def test_empty(self):
        self.assertEqual("", remove_undeclared_excluded_environments(""))
        self.assertIsNone(remove_undeclared_excluded_environments(None))


if __name__ == "__main__":
    unittest.main()
