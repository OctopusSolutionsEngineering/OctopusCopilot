import unittest

from domain.sanitizers.terraform import disable_gcp_impersonation_without_emails


class DisableGcpImpersonationWithoutEmailsTest(unittest.TestCase):
    def test_none(self):
        self.assertIsNone(disable_gcp_impersonation_without_emails(None))

    def test_disables_impersonation_without_emails(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  type = "Octopus.GoogleCloudScripting"
  execution_properties = {
    "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "True"
    "Octopus.Action.GoogleCloud.Region" = "australia-southeast1"
  }
}"""
        fixed = disable_gcp_impersonation_without_emails(config)
        self.assertIn('"Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"', fixed)
        self.assertNotIn('"True"', fixed)

    def test_keeps_impersonation_with_emails(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "True"
    "Octopus.Action.GoogleCloud.ServiceAccountEmails" = "deployer@maps.iam.gserviceaccount.com"
  }
}"""
        self.assertEqual(config, disable_gcp_impersonation_without_emails(config))

    def test_only_affects_step_missing_emails(self):
        config = """resource "octopusdeploy_process_step" "one" {
  execution_properties = {
    "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "True"
    "Octopus.Action.GoogleCloud.ServiceAccountEmails" = "a@b.iam.gserviceaccount.com"
  }
}
resource "octopusdeploy_process_step" "two" {
  execution_properties = {
    "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "True"
  }
}"""
        fixed = disable_gcp_impersonation_without_emails(config)
        self.assertEqual(1, fixed.count('"Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "True"'))
        self.assertEqual(1, fixed.count('"Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"'))

    def test_empty_emails_disable_impersonation(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "True"
    "Octopus.Action.GoogleCloud.ServiceAccountEmails" = ""
  }
}"""
        self.assertIn('"Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"',
                      disable_gcp_impersonation_without_emails(config))
