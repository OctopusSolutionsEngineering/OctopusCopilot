import unittest

from domain.sanitizers.terraform import fix_empty_terraform_params


class FixEmptyTerraformParamsTests(unittest.TestCase):
    def test_removes_empty_action_and_init_params(self):
        config = (
            "execution_properties = {\n"
            '  "Octopus.Action.Terraform.AdditionalActionParams" = ""\n'
            '  "Octopus.Action.Terraform.AdditionalInitParams"   = ""\n'
            '  "Octopus.Action.RunOnServer" = "true"\n'
            "}\n"
        )
        expected = 'execution_properties = {\n  "Octopus.Action.RunOnServer" = "true"\n}\n'
        self.assertEqual(expected, fix_empty_terraform_params(config))

    def test_keeps_non_empty_params(self):
        config = '  "Octopus.Action.Terraform.AdditionalInitParams" = "-backend-config=\\"key=a\\""\n'
        self.assertEqual(config, fix_empty_terraform_params(config))

    def test_keeps_other_empty_properties(self):
        config = '  "Octopus.Action.Terraform.Workspace" = ""\n'
        self.assertEqual(config, fix_empty_terraform_params(config))


if __name__ == "__main__":
    unittest.main()
