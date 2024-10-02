import unittest
from domain.categorization.octopus_target import (
    project_includes_azure_steps,
    project_includes_aws_steps,
    project_includes_gcp_steps,
    project_includes_windows_steps,
    has_unknown_steps,
)


class TestOctopusTarget(unittest.TestCase):
    def test_project_includes_azure_steps(self):
        self.assertTrue(
            project_includes_azure_steps('action_type = "Octopus.AzureWebApp"')
        )
        self.assertTrue(
            project_includes_azure_steps(
                'action_type    =        "Octopus.AzureWebApp"'
            )
        )
        self.assertFalse(
            project_includes_azure_steps('action_type = "Octopus.AWSLambda"')
        )
        self.assertFalse(project_includes_azure_steps(None))
        self.assertFalse(project_includes_azure_steps(""))

    def test_project_includes_aws_steps(self):
        self.assertTrue(project_includes_aws_steps('action_type = "Octopus.AWSLambda"'))
        self.assertTrue(
            project_includes_aws_steps('action_type    =    "Octopus.AWSLambda"')
        )
        self.assertFalse(
            project_includes_aws_steps('action_type = "Octopus.AzureWebApp"')
        )
        self.assertFalse(project_includes_aws_steps(None))
        self.assertFalse(project_includes_aws_steps(""))

    def test_project_includes_gcp_steps(self):
        self.assertTrue(
            project_includes_gcp_steps('action_type = "Octopus.GoogleCloudFunction"')
        )
        self.assertTrue(
            project_includes_gcp_steps(
                'action_type    =    "Octopus.GoogleCloudFunction"'
            )
        )
        self.assertFalse(
            project_includes_gcp_steps('action_type = "Octopus.AzureWebApp"')
        )
        self.assertFalse(project_includes_gcp_steps(None))
        self.assertFalse(project_includes_gcp_steps(""))

    def test_project_includes_windows_steps(self):
        self.assertTrue(project_includes_windows_steps('action_type = "Octopus.IIS"'))
        self.assertTrue(
            project_includes_windows_steps('action_type    =    "Octopus.IIS"')
        )
        self.assertTrue(
            project_includes_windows_steps('action_type = "Octopus.WindowsService"')
        )
        self.assertFalse(
            project_includes_windows_steps('action_type = "Octopus.AzureWebApp"')
        )
        self.assertFalse(project_includes_windows_steps(None))
        self.assertFalse(project_includes_windows_steps(""))

    def test_has_unknown_steps(self):
        self.assertTrue(has_unknown_steps('action_type = "Octopus.UnknownStep"'))
        self.assertFalse(has_unknown_steps('action_type = "Octopus.AzureWebApp"'))
        self.assertFalse(has_unknown_steps('action_type = "Octopus.AWSLambda"'))
        self.assertFalse(
            has_unknown_steps('action_type = "Octopus.GoogleCloudFunction"')
        )
        self.assertFalse(has_unknown_steps('action_type = "Octopus.IIS"'))
        self.assertFalse(has_unknown_steps('action_type = "Octopus.WindowsService"'))
        self.assertTrue(has_unknown_steps(None))
        self.assertTrue(has_unknown_steps(""))


if __name__ == "__main__":
    unittest.main()
