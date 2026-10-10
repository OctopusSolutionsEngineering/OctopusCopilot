import unittest

from domain.sanitizers.terraform import (
    fix_undeclared_deployment_freeze_lookup,
    link_projects_to_existing_deployment_freezes,
)

LINK = """resource "octopusdeploy_deployment_freeze_project" "deploymentfreeze_holiday_freeze_edge" {
  deploymentfreeze_id = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_holiday_freeze.deployment_freezes) != 0 ? data.octopusdeploy_deployment_freezes.deploymentfreeze_holiday_freeze.deployment_freezes[0].id : octopusdeploy_deployment_freeze.deploymentfreeze_holiday_freeze[0].id}"
  project_id          = "${octopusdeploy_project.project_edge[0].id}"
}
"""

DATA = """data "octopusdeploy_deployment_freezes" "deploymentfreeze_holiday_freeze" {
  partial_name = "Holiday Freeze"
  skip         = 0
  take         = 1
}
"""


class TestFixUndeclaredDeploymentFreezeLookup(unittest.TestCase):
    def test_undeclared_lookup_becomes_resource_reference(self):
        result = fix_undeclared_deployment_freeze_lookup(LINK)
        self.assertIn(
            'deploymentfreeze_id = "${octopusdeploy_deployment_freeze.deploymentfreeze_holiday_freeze[0].id}"', result
        )
        self.assertNotIn("data.octopusdeploy_deployment_freezes", result)

    def test_declared_lookup_is_unchanged(self):
        config = DATA + LINK
        self.assertEqual(fix_undeclared_deployment_freeze_lookup(config), config)

    def test_only_the_undeclared_lookup_is_replaced(self):
        other = LINK.replace("deploymentfreeze_holiday_freeze", "deploymentfreeze_eofy_freeze")
        result = fix_undeclared_deployment_freeze_lookup(DATA + LINK + other)
        self.assertIn("data.octopusdeploy_deployment_freezes.deploymentfreeze_holiday_freeze.deployment_freezes[0].id", result)
        self.assertIn('"${octopusdeploy_deployment_freeze.deploymentfreeze_eofy_freeze[0].id}"', result)

    def test_no_freeze_lookup_means_no_change(self):
        config = 'resource "octopusdeploy_deployment_freeze" "f" {\n  name = "F"\n}\n'
        self.assertEqual(fix_undeclared_deployment_freeze_lookup(config), config)

    def test_lookup_written_by_link_sanitizer_is_reverted_without_data_source(self):
        config = """resource "octopusdeploy_deployment_freeze_project" "freeze_edge" {
  deploymentfreeze_id = "${octopusdeploy_deployment_freeze.deploymentfreeze_holiday_freeze[0].id}"
  project_id          = "${length(data.octopusdeploy_projects.project_edge.projects) != 0 ? data.octopusdeploy_projects.project_edge.projects[0].id : octopusdeploy_project.project_edge[0].id}"
}"""
        result = fix_undeclared_deployment_freeze_lookup(link_projects_to_existing_deployment_freezes(config))
        self.assertIn(
            'deploymentfreeze_id = "${octopusdeploy_deployment_freeze.deploymentfreeze_holiday_freeze[0].id}"', result
        )
        self.assertNotIn("data.octopusdeploy_deployment_freezes", result)

    def test_empty_config(self):
        self.assertEqual(fix_undeclared_deployment_freeze_lookup(""), "")
        self.assertIsNone(fix_undeclared_deployment_freeze_lookup(None))


if __name__ == "__main__":
    unittest.main()
