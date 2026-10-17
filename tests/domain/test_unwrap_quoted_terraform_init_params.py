import unittest

from domain.sanitizers.terraform import unwrap_quoted_terraform_init_params


def step(value):
    return (
        'resource "octopusdeploy_process_step" "plan" {\n'
        "  execution_properties = {\n"
        f'    "Octopus.Action.Terraform.AdditionalInitParams" = "{value}"\n'
        "  }\n"
        "}\n"
    )


class TestUnwrapQuotedTerraformInitParams(unittest.TestCase):
    def test_observed_wrapped_value_is_unwrapped(self):
        wrapped = '\\"-backend-config=storage_account_name=tfstate45 -backend-config=key=#{Octopus.Deployment.Tenant.Name}.tfstate\\"'
        result = unwrap_quoted_terraform_init_params(step(wrapped))
        self.assertIn(
            '"Octopus.Action.Terraform.AdditionalInitParams" = "-backend-config=storage_account_name=tfstate45 '
            '-backend-config=key=#{Octopus.Deployment.Tenant.Name}.tfstate"',
            result,
        )

    def test_unwrapped_value_is_unchanged(self):
        config = step("-upgrade -backend-config=key=x.tfstate")
        self.assertEqual(config, unwrap_quoted_terraform_init_params(config))

    def test_inner_quotes_are_unchanged(self):
        config = step('-upgrade -backend-config=\\"bucket=r28-tf-state\\" -backend-config=\\"region=us-west-2\\"')
        self.assertEqual(config, unwrap_quoted_terraform_init_params(config))

    def test_other_properties_are_unchanged(self):
        config = 'resource "x" "y" {\n  "Octopus.Action.Terraform.Workspace" = "\\"ws\\""\n}\n'
        self.assertEqual(config, unwrap_quoted_terraform_init_params(config))

    def test_empty(self):
        self.assertEqual("", unwrap_quoted_terraform_init_params(""))
        self.assertIsNone(unwrap_quoted_terraform_init_params(None))


if __name__ == "__main__":
    unittest.main()
