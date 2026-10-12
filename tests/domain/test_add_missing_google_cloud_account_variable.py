import unittest

from domain.sanitizers.terraform import add_missing_google_cloud_account_variable

ACCOUNT_VARIABLE = """resource "octopusdeploy_variable" "gke_clusters_project_gcp_account_1" {
  owner_id     = "${octopusdeploy_project.project_gke_clusters[0].id}"
  value        = "${octopusdeploy_gcp_account.account_gcp_deployer[0].id}"
  name         = "Project.GCP.Account"
  type         = "GoogleCloudAccount"
  is_sensitive = false
}
"""

GCLOUD_STEP = """resource "octopusdeploy_process_step" "process_step_gke_clusters_scale_nodes_run_gcloud_in_a_script" {
  name                  = "Run gcloud in a Script"
  type                  = "Octopus.GoogleCloudScripting"
  execution_properties  = {
    "Octopus.Action.Script.ScriptBody" = "gcloud container clusters resize gke-prod --quiet"
    "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "False"
    "Octopus.Action.GoogleCloud.Project" = "acme-platform"
  }
}
"""


class TestAddMissingGoogleCloudAccountVariable(unittest.TestCase):
    def test_account_variable_is_added(self):
        result = add_missing_google_cloud_account_variable(ACCOUNT_VARIABLE + GCLOUD_STEP)
        self.assertIn(
            '    "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "False"\n'
            '    "Octopus.Action.GoogleCloudAccount.Variable" = "Project.GCP.Account"\n',
            result,
        )

    def test_existing_account_variable_is_kept(self):
        step = GCLOUD_STEP.replace(
            '"Octopus.Action.GoogleCloud.Project"',
            '"Octopus.Action.GoogleCloudAccount.Variable" = "Other.Account"\n    "Octopus.Action.GoogleCloud.Project"',
        )
        config = ACCOUNT_VARIABLE + step
        self.assertEqual(add_missing_google_cloud_account_variable(config), config)

    def test_vm_service_account_step_is_untouched(self):
        config = ACCOUNT_VARIABLE + GCLOUD_STEP.replace('UseVMServiceAccount" = "False"', 'UseVMServiceAccount" = "True"')
        self.assertEqual(add_missing_google_cloud_account_variable(config), config)

    def test_no_google_cloud_account_variable_means_no_change(self):
        self.assertEqual(add_missing_google_cloud_account_variable(GCLOUD_STEP), GCLOUD_STEP)

    def test_other_step_types_are_untouched(self):
        step = GCLOUD_STEP.replace('"Octopus.GoogleCloudScripting"', '"Octopus.Script"')
        config = ACCOUNT_VARIABLE + step + GCLOUD_STEP.replace("run_gcloud_in_a_script", "other")
        result = add_missing_google_cloud_account_variable(config)
        self.assertEqual(result.count("Octopus.Action.GoogleCloudAccount.Variable"), 1)

    def test_every_gcloud_step_is_fixed(self):
        config = ACCOUNT_VARIABLE + GCLOUD_STEP + GCLOUD_STEP.replace("run_gcloud_in_a_script", "second")
        result = add_missing_google_cloud_account_variable(config)
        self.assertEqual(result.count('"Octopus.Action.GoogleCloudAccount.Variable" = "Project.GCP.Account"'), 2)

    def test_empty_config(self):
        self.assertEqual(add_missing_google_cloud_account_variable(""), "")
        self.assertIsNone(add_missing_google_cloud_account_variable(None))


if __name__ == "__main__":
    unittest.main()
