import unittest

from domain.sanitizers.terraform import remove_undeclared_resource_fallbacks

LOOKUP = "data.octopusdeploy_parent_environments.parent_environment_features.parent_environments"
FALLBACK = (
    f'"${{length({LOOKUP}) != 0 ? {LOOKUP}[0].id : '
    'octopusdeploy_parent_environment.parent_environment_features[0].id}"'
)
CONFIG = f"""data "octopusdeploy_parent_environments" "parent_environment_features" {{
  partial_name = "Features"
  skip         = 0
  take         = 1
}}
resource "octopusdeploy_runbook" "runbook_provision_environment" {{
  name         = "Provision Environment"
  environments = [{FALLBACK}]
}}
"""

FOR_EXPRESSION = (
    '"${length(local.environment_development_matches) != 0 ? '
    '[for env in data.octopusdeploy_environments.environment_development.environments : env if env.name == "Development"][0].id : '
    'octopusdeploy_environment.environment_development[0].id}"'
)


class TestRemoveUndeclaredResourceFallbacks(unittest.TestCase):
    def test_undeclared_fallback_is_replaced_with_lookup(self):
        result = remove_undeclared_resource_fallbacks(CONFIG)
        self.assertIn(f'environments = ["${{{LOOKUP}[0].id}}"]', result)
        self.assertNotIn("octopusdeploy_parent_environment.parent_environment_features", result)

    def test_declared_fallback_is_kept(self):
        config = CONFIG + 'resource "octopusdeploy_parent_environment" "parent_environment_features" {\n  count = 1\n}\n'
        self.assertEqual(config, remove_undeclared_resource_fallbacks(config))

    def test_lookup_with_for_expression(self):
        result = remove_undeclared_resource_fallbacks(f"  environments = [{FOR_EXPRESSION}]\n")
        self.assertEqual(
            '  environments = ["${[for env in data.octopusdeploy_environments.environment_development.environments : '
            'env if env.name == "Development"][0].id}"]\n',
            result,
        )

    def test_only_the_undeclared_interpolation_on_a_line_changes(self):
        declared = 'resource "octopusdeploy_environment" "environment_test" {\n  count = 1\n}\n'
        line = (
            '  name = "${length(local.a) != 0 ? local.a[0].id : octopusdeploy_environment.environment_test[0].id}-'
            '${length(local.b) != 0 ? local.b[0].id : octopusdeploy_environment.environment_prod[0].id}"\n'
        )
        result = remove_undeclared_resource_fallbacks(declared + line)
        self.assertIn("octopusdeploy_environment.environment_test[0].id}-${local.b[0].id}", result)

    def test_nested_ternary_keeps_outer_branches(self):
        line = (
            '  environments = ["${length(local.environment_features_matches) != 0 ? local.environment_features_matches[0].id : '
            f'length({LOOKUP}) != 0 ? {LOOKUP}[0].id : octopusdeploy_environment.environment_features[0].id}}"]\n'
        )
        result = remove_undeclared_resource_fallbacks(line)
        self.assertEqual(
            '  environments = ["${length(local.environment_features_matches) != 0 ? local.environment_features_matches[0].id : '
            f'{LOOKUP}[0].id}}"]\n',
            result,
        )

    def test_nested_ternary_with_declared_resource_is_unchanged(self):
        config = (
            'resource "octopusdeploy_environment" "environment_features" {\n  count = 1\n}\n'
            '  environments = ["${length(local.environment_features_matches) != 0 ? local.environment_features_matches[0].id : '
            f'length({LOOKUP}) != 0 ? {LOOKUP}[0].id : octopusdeploy_environment.environment_features[0].id}}"]\n'
        )
        self.assertEqual(config, remove_undeclared_resource_fallbacks(config))

    def test_none_and_empty(self):
        self.assertIsNone(remove_undeclared_resource_fallbacks(None))
        self.assertEqual("", remove_undeclared_resource_fallbacks(""))


if __name__ == "__main__":
    unittest.main()
