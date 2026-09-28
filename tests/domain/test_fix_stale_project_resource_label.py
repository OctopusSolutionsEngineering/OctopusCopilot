import unittest

from domain.sanitizers.terraform import fix_stale_project_resource_label


class FixStaleProjectResourceLabelTest(unittest.TestCase):
    def test_none(self):
        self.assertIsNone(fix_stale_project_resource_label(None))

    def test_empty(self):
        self.assertEqual("", fix_stale_project_resource_label(""))

    def test_no_project_resource(self):
        config = """data "octopusdeploy_environments" "env" {
  name = "Dev"
}"""
        self.assertEqual(config, fix_stale_project_resource_label(config))

    def test_multiple_declared_project_labels_left_unchanged(self):
        """
        With more than one declared octopusdeploy_project resource, it is not safe to guess which
        one a stale reference was meant to point at, so the configuration must be left unchanged.
        """
        config = """resource "octopusdeploy_project" "project_a" {
  name = "A"
}
resource "octopusdeploy_project" "project_b" {
  name = "B"
}
resource "octopusdeploy_variable" "var1" {
  owner_id = octopusdeploy_project.project_progressive_deployment[0].id
}"""
        self.assertEqual(config, fix_stale_project_resource_label(config))

    def test_stale_resource_reference_is_fixed(self):
        config = """resource "octopusdeploy_project" "project_argo_cd_rollouts" {
  name = "My Project"
}
resource "octopusdeploy_variable" "argo_cd_rollouts_project_workerpool_1" {
  owner_id = octopusdeploy_project.project_progressive_deployment[0].id
  value    = "pool"
}"""
        fixed = fix_stale_project_resource_label(config)
        self.assertEqual(
            """resource "octopusdeploy_project" "project_argo_cd_rollouts" {
  name = "My Project"
}
resource "octopusdeploy_variable" "argo_cd_rollouts_project_workerpool_1" {
  owner_id = octopusdeploy_project.project_argo_cd_rollouts[0].id
  value    = "pool"
}""",
            fixed,
        )

    def test_stale_data_source_reference_is_fixed(self):
        config = """resource "octopusdeploy_project" "project_argo_cd_rollouts" {
  name = "My Project"
}
resource "octopusdeploy_variable" "var1" {
  value = data.octopusdeploy_projects.project_progressive_deployment.projects[0].id
}"""
        fixed = fix_stale_project_resource_label(config)
        self.assertEqual(
            """resource "octopusdeploy_project" "project_argo_cd_rollouts" {
  name = "My Project"
}
resource "octopusdeploy_variable" "var1" {
  value = data.octopusdeploy_projects.project_argo_cd_rollouts.projects[0].id
}""",
            fixed,
        )

    def test_reference_to_declared_data_source_left_unchanged(self):
        """
        A reference is only "stale" if it does not match any declared octopusdeploy_project resource
        or octopusdeploy_projects data source label. A reference to a genuinely declared data source
        (e.g. an existing project looked up by name) must not be rewritten.
        """
        config = """resource "octopusdeploy_project" "project_argo_cd_rollouts" {
  name = "My Project"
}
data "octopusdeploy_projects" "project_existing" {
  name = "Existing"
}
resource "octopusdeploy_variable" "var1" {
  value = data.octopusdeploy_projects.project_existing.projects[0].id
}"""
        self.assertEqual(config, fix_stale_project_resource_label(config))

    def test_reference_already_consistent_left_unchanged(self):
        config = """resource "octopusdeploy_project" "project_argo_cd_rollouts" {
  name = "My Project"
}
resource "octopusdeploy_variable" "var1" {
  owner_id = octopusdeploy_project.project_argo_cd_rollouts[0].id
}"""
        self.assertEqual(config, fix_stale_project_resource_label(config))
