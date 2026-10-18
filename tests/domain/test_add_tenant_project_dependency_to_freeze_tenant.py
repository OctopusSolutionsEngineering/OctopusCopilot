import unittest

from domain.sanitizers.terraform import add_tenant_project_dependency_to_freeze_tenant

TENANT_PROJECTS = """resource "octopusdeploy_tenant_project" "tenant_project_contoso_q68" {
  count = 1
}
resource "octopusdeploy_tenant_project" "tenant_project_fabrikam_q68" {
  count = 1
}
"""

FREEZE_TENANT = """resource "octopusdeploy_deployment_freeze_tenant" "deploymentfreeze_q68_fabrikam" {
  count               = "${length(local.tenant_fabrikam_tenants_matches) != 0 ? 0 : 1}"
  deploymentfreeze_id = "${octopusdeploy_deployment_freeze.freeze[0].id}"
  tenant_id           = "${octopusdeploy_tenant.tenant_fabrikam[0].id}"
}
"""


class TestAddTenantProjectDependencyToFreezeTenant(unittest.TestCase):
    def test_observed_freeze_without_depends_on(self):
        result = add_tenant_project_dependency_to_freeze_tenant(TENANT_PROJECTS + FREEZE_TENANT)
        self.assertIn(
            "depends_on = [octopusdeploy_tenant_project.tenant_project_contoso_q68, "
            "octopusdeploy_tenant_project.tenant_project_fabrikam_q68]",
            result,
        )
        self.assertTrue(result.rstrip().endswith("}"))
        self.assertEqual(result.count("{"), result.count("}"))

    def test_existing_depends_on_is_merged(self):
        freeze = FREEZE_TENANT.replace(
            '  tenant_id', '  depends_on = [octopusdeploy_project.p, octopusdeploy_tenant_project.tenant_project_contoso_q68]\n  tenant_id'
        )
        result = add_tenant_project_dependency_to_freeze_tenant(TENANT_PROJECTS + freeze)
        self.assertIn(
            "depends_on = [octopusdeploy_project.p, octopusdeploy_tenant_project.tenant_project_contoso_q68, "
            "octopusdeploy_tenant_project.tenant_project_fabrikam_q68]",
            result,
        )
        self.assertEqual(1, result.count("depends_on"))

    def test_without_tenant_projects_is_unchanged(self):
        self.assertEqual(FREEZE_TENANT, add_tenant_project_dependency_to_freeze_tenant(FREEZE_TENANT))

    def test_without_freeze_tenant_is_unchanged(self):
        self.assertEqual(TENANT_PROJECTS, add_tenant_project_dependency_to_freeze_tenant(TENANT_PROJECTS))

    def test_two_freezes(self):
        second = FREEZE_TENANT.replace("deploymentfreeze_q68_fabrikam", "deploymentfreeze_q68_contoso")
        result = add_tenant_project_dependency_to_freeze_tenant(TENANT_PROJECTS + FREEZE_TENANT + second)
        self.assertEqual(2, result.count("depends_on"))

    def test_empty(self):
        self.assertEqual("", add_tenant_project_dependency_to_freeze_tenant(""))
        self.assertIsNone(add_tenant_project_dependency_to_freeze_tenant(None))


if __name__ == "__main__":
    unittest.main()
