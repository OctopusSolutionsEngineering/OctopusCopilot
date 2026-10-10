import unittest

from domain.sanitizers.terraform import add_linked_tenants_to_tenanted_targets

TENANT_PROJECTS = """resource "octopusdeploy_tenant_project" "tenant_project_shard_a" {
  tenant_id  = "${octopusdeploy_tenant.tenant_shard_a[0].id}"
  project_id = "${octopusdeploy_project.project_saas[0].id}"
}
resource "octopusdeploy_tenant_project" "tenant_project_shard_b" {
  tenant_id  = "${octopusdeploy_tenant.tenant_shard_b[0].id}"
  project_id = "${octopusdeploy_project.project_saas[0].id}"
}
"""

TARGET = """resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_mock_k8s" {
  name                              = "Mock K8s"
  tenant_tags                       = []
  tenanted_deployment_participation = "MODE"
  tenants                           = []
}
"""


class TestAddLinkedTenantsToTenantedTargets(unittest.TestCase):
    def test_tenanted_target_gets_linked_tenants(self):
        result = add_linked_tenants_to_tenanted_targets(TENANT_PROJECTS + TARGET.replace("MODE", "Tenanted"))
        self.assertIn(
            'tenants = ["${octopusdeploy_tenant.tenant_shard_a[0].id}", "${octopusdeploy_tenant.tenant_shard_b[0].id}"]', result
        )

    def test_tenanted_or_untenanted_target_gets_linked_tenants(self):
        result = add_linked_tenants_to_tenanted_targets(TENANT_PROJECTS + TARGET.replace("MODE", "TenantedOrUntenanted"))
        self.assertIn("tenant_shard_a", result.split("target_mock_k8s")[1])

    def test_untenanted_target_is_unchanged(self):
        config = TENANT_PROJECTS + TARGET.replace("MODE", "Untenanted")
        self.assertEqual(add_linked_tenants_to_tenanted_targets(config), config)

    def test_target_with_tenant_tags_is_unchanged(self):
        config = TENANT_PROJECTS + TARGET.replace("MODE", "Tenanted").replace('tenant_tags                       = []', 'tenant_tags = ["Plan/Paid"]')
        self.assertEqual(add_linked_tenants_to_tenanted_targets(config), config)

    def test_no_tenant_projects_means_no_change(self):
        config = TARGET.replace("MODE", "Tenanted")
        self.assertEqual(add_linked_tenants_to_tenanted_targets(config), config)

    def test_empty_config(self):
        self.assertEqual(add_linked_tenants_to_tenanted_targets(""), "")
        self.assertIsNone(add_linked_tenants_to_tenanted_targets(None))


if __name__ == "__main__":
    unittest.main()
