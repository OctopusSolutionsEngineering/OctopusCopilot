import unittest

from domain.sanitizers.terraform import fix_yaml_source


class SanitizeYamlResourcesTest(unittest.TestCase):

    def test_no_yaml_key(self):
        """Config without Octopus.KubernetesDeployRawYaml is returned unchanged."""
        config = 'resource "octopusdeploy_project" "project" {}'
        self.assertEqual(fix_yaml_source(config), config)

    def test_empty_config(self):
        """Empty config returns an empty string."""
        self.assertEqual(fix_yaml_source(""), "")

    def test_yaml_source_no_script_source(self):
        """Resource with Octopus.KubernetesDeployRawYaml but no ScriptSource is returned unchanged."""
        config = """resource "octopusdeploy_process_step" "process_step_deploy_yaml" {
  name                  = "Deploy YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "octopusdeploy_process.process_deploy_yaml[0].id"
  condition             = "Success"
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
      }
}"""
        self.assertEqual(fix_yaml_source(config), config)

    def test_yaml_source_git_repository_with_filename_unchanged(self):
        """GitRepository source that already has CustomResourceYamlFileName is returned unchanged."""
        config = """resource "octopusdeploy_process_step" "process_step_deploy_yaml" {
  name                  = "Deploy YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "octopusdeploy_process.process_deploy_yaml[0].id"
  condition             = "Success"
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "deploy.yaml"
        "Octopus.Action.RunOnServer" = "true"
      }
}"""
        self.assertEqual(fix_yaml_source(config), config)

    def test_yaml_source_git_repository_adds_default_filename(self):
        """GitRepository source without a CustomResourceYamlFileName gets resource.yaml injected."""
        config = """resource "octopusdeploy_process_step" "process_step_deploy_yaml" {
  name                  = "Deploy YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "octopusdeploy_process.process_deploy_yaml[0].id"
  condition             = "Success"
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.RunOnServer" = "true"
      }
}"""
        fixed = fix_yaml_source(config)

        self.assertIn(
            "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName", fixed
        )
        self.assertIn("resource.yaml", fixed)
        # The original ScriptSource line must still be present
        self.assertIn('"Octopus.Action.Script.ScriptSource" = "GitRepository"', fixed)

    def test_yaml_source_non_git_repository_unchanged(self):
        """A resource whose ScriptSource is not GitRepository is returned unchanged."""
        config = """resource "octopusdeploy_process_step" "process_step_deploy_yaml" {
  name                  = "Deploy YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "octopusdeploy_process.process_deploy_yaml[0].id"
  condition             = "Success"
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.RunOnServer" = "true"
      }
}"""
        self.assertEqual(fix_yaml_source(config), config)

    def test_bad_indents_yaml_source(self):
        """When the closing brace is not at column 0, the resource is not detected and config is returned unchanged."""
        # Note the leading space before the final closing brace
        config = """resource "octopusdeploy_process_step" "process_step_deploy_yaml" {
  name                  = "Deploy YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "octopusdeploy_process.process_deploy_yaml[0].id"
  condition             = "Success"
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.RunOnServer" = "true"
      }
   }"""
        self.assertEqual(fix_yaml_source(config), config)

    def test_bad_indents_yaml_source_leading_space_on_resource(self):
        """When the resource keyword has a leading space it is not detected and config is returned unchanged."""
        config = """  resource "octopusdeploy_process_step" "process_step_deploy_yaml" {
  name                  = "Deploy YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  condition             = "Success"
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.RunOnServer" = "true"
      }
}"""
        self.assertEqual(fix_yaml_source(config), config)

    def test_non_yaml_resource_alongside_yaml_resource(self):
        """Non-YAML resources that precede the YAML step are preserved unchanged."""
        config = """resource "octopusdeploy_project" "project" {
  name = "My Project"
}
resource "octopusdeploy_process_step" "process_step_deploy_yaml" {
  name                  = "Deploy YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  condition             = "Success"
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.RunOnServer" = "true"
      }
}"""
        fixed = fix_yaml_source(config)

        self.assertIn('resource "octopusdeploy_project" "project"', fixed)
        self.assertIn(
            "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName", fixed
        )
        self.assertIn("resource.yaml", fixed)


if __name__ == "__main__":
    unittest.main()
