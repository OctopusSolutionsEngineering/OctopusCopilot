import unittest

from domain.sanitizers.terraform import configuration_has_octopus_resources

ONLY_VARIABLES = """variable "octopus_space_id" {
  type = string
}
variable "octopus_server" {
  type = string
}
"""


class TestConfigurationHasOctopusResources(unittest.TestCase):
    def test_only_variables_is_rejected(self):
        self.assertFalse(configuration_has_octopus_resources(ONLY_VARIABLES))

    def test_data_sources_only_is_rejected(self):
        self.assertFalse(configuration_has_octopus_resources('data "octopusdeploy_feeds" "f" {\n}\n'))

    def test_resource_is_accepted(self):
        self.assertTrue(
            configuration_has_octopus_resources(ONLY_VARIABLES + 'resource "octopusdeploy_project" "p" {\n  name = "X"\n}\n')
        )

    def test_empty(self):
        self.assertFalse(configuration_has_octopus_resources(""))
        self.assertFalse(configuration_has_octopus_resources(None))


if __name__ == "__main__":
    unittest.main()
