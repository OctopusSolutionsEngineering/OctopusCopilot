import unittest

from domain.sanitizers.terraform import link_projects_to_existing_deployment_freezes

LINK = """resource "octopusdeploy_deployment_freeze_project" "freeze_payments" {
  count               = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_black_friday_freeze.deployment_freezes) != 0 ? 0 : 1}"
  deploymentfreeze_id = "${octopusdeploy_deployment_freeze.deploymentfreeze_black_friday_freeze[0].id}"
  project_id          = "${length(data.octopusdeploy_projects.project_payments.projects) != 0 ? data.octopusdeploy_projects.project_payments.projects[0].id : octopusdeploy_project.project_payments[0].id}"
}"""


class LinkProjectsToExistingDeploymentFreezesTest(unittest.TestCase):
    def test_none(self):
        self.assertIsNone(link_projects_to_existing_deployment_freezes(None))

    def test_rewrites_count_and_id(self):
        fixed = link_projects_to_existing_deployment_freezes(LINK)
        self.assertIn(
            'count               = "${length(data.octopusdeploy_projects.project_payments.projects) != 0 ? 0 : 1}"',
            fixed,
        )
        self.assertIn(
            'deploymentfreeze_id = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_black_friday_freeze.deployment_freezes) != 0 '
            "? data.octopusdeploy_deployment_freezes.deploymentfreeze_black_friday_freeze.deployment_freezes[0].id "
            ': octopusdeploy_deployment_freeze.deploymentfreeze_black_friday_freeze[0].id}"',
            fixed,
        )
        self.assertNotIn("deployment_freezes) != 0 ? 0 : 1", fixed)

    def test_removes_count_without_project_lookup(self):
        config = LINK.replace(
            'project_id          = "${length(data.octopusdeploy_projects.project_payments.projects) != 0 ? data.octopusdeploy_projects.project_payments.projects[0].id : octopusdeploy_project.project_payments[0].id}"',
            'project_id          = "Projects-1"',
        )
        self.assertNotIn("count", link_projects_to_existing_deployment_freezes(config))

    def test_leaves_freeze_resource_alone(self):
        config = """resource "octopusdeploy_deployment_freeze" "deploymentfreeze_black_friday_freeze" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_black_friday_freeze.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Black Friday Freeze"
}"""
        self.assertEqual(config, link_projects_to_existing_deployment_freezes(config))
