import unittest

from domain.sanitizers.terraform import remove_duplicate_unscoped_tenant_common_variables

VARIABLE = """resource "octopusdeploy_tenant_common_variable" "LABEL" {
  library_variable_set_id = "${octopusdeploy_library_variable_set.claims[0].id}"
  template_id             = "${octopusdeploy_library_variable_set.claims[0].template[0].id}"
  tenant_id               = "${octopusdeploy_tenant.TENANT[0].id}"
  value                   = "VALUE"
}
"""


def variable(label, tenant, value):
    return VARIABLE.replace("LABEL", label).replace("TENANT", tenant).replace("VALUE", value)


class TestRemoveDuplicateUnscopedTenantCommonVariables(unittest.TestCase):
    def test_per_environment_copies_are_removed(self):
        config = variable("nz_dev", "claims_nz", "NZ") + variable("nz_test", "claims_nz", "NZ") + variable("nz_prod", "claims_nz", "NZ")
        result = remove_duplicate_unscoped_tenant_common_variables(config)
        self.assertEqual(result.count("octopusdeploy_tenant_common_variable"), 1)
        self.assertIn('"nz_dev"', result)

    def test_different_tenants_are_kept(self):
        config = variable("nz", "claims_nz", "NZ") + variable("au", "claims_au", "AU")
        self.assertEqual(remove_duplicate_unscoped_tenant_common_variables(config), config)

    def test_scoped_values_are_kept(self):
        scoped = variable("nz_prod", "claims_nz", "NZP").replace(
            '  value                   = "NZP"\n', '  value                   = "NZP"\n  scope {\n    environment_ids = ["Environments-1"]\n  }\n'
        )
        config = variable("nz", "claims_nz", "NZ") + scoped
        self.assertEqual(remove_duplicate_unscoped_tenant_common_variables(config), config)

    def test_other_resources_are_untouched(self):
        config = 'resource "octopusdeploy_tenant_project_variable" "a" {\n  tenant_id = "x"\n}\n' * 2
        self.assertEqual(remove_duplicate_unscoped_tenant_common_variables(config), config)

    def test_empty_config(self):
        self.assertEqual(remove_duplicate_unscoped_tenant_common_variables(""), "")
        self.assertIsNone(remove_duplicate_unscoped_tenant_common_variables(None))


if __name__ == "__main__":
    unittest.main()
