import unittest

from domain.sanitizers.terraform import fix_provider_block, PROVIDER_BLOCK


class FixProviderBlockTests(unittest.TestCase):
    def test_removes_address_and_api_key(self):
        config = (
            'provider "octopusdeploy" {\n'
            "  address  = var.octopus_server\n"
            "  api_key  = var.octopus_apikey\n"
            "  space_id = trimspace(var.octopus_space_id)\n"
            "}\n"
            'variable "octopus_space_id" {}'
        )
        self.assertEqual(PROVIDER_BLOCK + '\nvariable "octopus_space_id" {}', fix_provider_block(config))

    def test_removes_address_only(self):
        config = 'provider "octopusdeploy" {\n  address  = "${var.octopus_server}"\n  space_id = "${trimspace(var.octopus_space_id)}"\n}'
        self.assertEqual(PROVIDER_BLOCK, fix_provider_block(config))

    def test_adds_space_id(self):
        self.assertEqual(PROVIDER_BLOCK, fix_provider_block('provider "octopusdeploy" {\n}'))

    def test_leaves_config_without_provider_block(self):
        config = 'terraform {\n  required_providers {\n    octopusdeploy = {\n      source = "OctopusDeploy/octopusdeploy"\n    }\n  }\n}'
        self.assertEqual(config, fix_provider_block(config))

    def test_leaves_unbalanced_block(self):
        config = 'provider "octopusdeploy" {\n  address = var.octopus_server\n'
        self.assertEqual(config, fix_provider_block(config))


if __name__ == "__main__":
    unittest.main()
