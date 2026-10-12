import unittest

from domain.sanitizers.terraform import remove_glob_from_argocd_input_path

STEP = """resource "octopusdeploy_process_step" "process_step_billing_manifests_update_argo_cd_application_manifests" {
  type                  = "Octopus.ArgoCDUpdateManifests"
  execution_properties  = {
    "Octopus.Action.ArgoCD.InputPath"                = "PATH"
    "Octopus.Action.ArgoCD.ApplicationName"          = "billing-#{Octopus.Environment.Name | ToLower}"
  }
}
"""


def step(path):
    return STEP.replace("PATH", path)


class TestRemoveGlobFromArgoCDInputPath(unittest.TestCase):
    def test_glob_file_becomes_directory(self):
        result = remove_glob_from_argocd_input_path(step("templates/#{Octopus.Environment.Name | ToLower}/*.yaml"))
        self.assertIn('"Octopus.Action.ArgoCD.InputPath"                = "templates/#{Octopus.Environment.Name | ToLower}"', result)

    def test_recursive_glob_is_cut_at_first_glob_segment(self):
        result = remove_glob_from_argocd_input_path(step("k8s/overlays/**/*.yml"))
        self.assertIn('= "k8s/overlays"', result)

    def test_question_mark_glob(self):
        result = remove_glob_from_argocd_input_path(step("k8s/app-?.yaml"))
        self.assertIn('= "k8s"', result)

    def test_plain_file_is_untouched(self):
        config = step("template/deployment.yaml")
        self.assertEqual(remove_glob_from_argocd_input_path(config), config)

    def test_octostache_is_not_a_glob(self):
        config = step("templates/#{Octopus.Action[Get Path].Output.Dir}/app.yaml")
        self.assertEqual(remove_glob_from_argocd_input_path(config), config)

    def test_root_glob_is_left_alone(self):
        config = step("*.yaml")
        self.assertEqual(remove_glob_from_argocd_input_path(config), config)

    def test_empty_config(self):
        self.assertEqual(remove_glob_from_argocd_input_path(""), "")
        self.assertIsNone(remove_glob_from_argocd_input_path(None))


if __name__ == "__main__":
    unittest.main()
