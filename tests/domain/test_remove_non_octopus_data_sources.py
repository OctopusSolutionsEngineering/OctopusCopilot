import unittest

from domain.sanitizers.terraform import remove_non_octopus_data_sources


class RemoveNonOctopusDataSourcesTest(unittest.TestCase):
    def test_none_config(self):
        self.assertEqual("", remove_non_octopus_data_sources(None))

    def test_empty_config(self):
        self.assertEqual("", remove_non_octopus_data_sources(""))

    def test_no_data_sources(self):
        config = """variable "octopus_space_id" {
  type = string
}"""
        self.assertEqual(config, remove_non_octopus_data_sources(config))

    def test_only_octopus_data_sources(self):
        config = """data "octopusdeploy_environments" "environment" {
  ids = null
}
data "octopusdeploy_lifecycles" "lifecycle" {
  partial_name = "Default Lifecycle"
}"""
        self.assertEqual(config, remove_non_octopus_data_sources(config))

    def test_remove_other_provider_data_sources(self):
        config = """data "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
}
data "octopusdeploy_environments" "environment" {
  ids = null
}
data "azurerm_resource_group" "rg" {
  name = "my-resource-group"
}"""
        self.assertEqual(
            """data "octopusdeploy_environments" "environment" {
  ids = null
}""",
            remove_non_octopus_data_sources(config),
        )

    def test_retain_other_block_types(self):
        config = """variable "octopus_space_id" {
  type = string
}
resource "octopusdeploy_project" "project" {
  name = "Test Project"
}
data "external" "example" {
  program = ["echo"]
}
output "project_id" {
  value = octopusdeploy_project.project.id
}"""
        self.assertEqual(
            """variable "octopus_space_id" {
  type = string
}
resource "octopusdeploy_project" "project" {
  name = "Test Project"
}
output "project_id" {
  value = octopusdeploy_project.project.id
}""",
            remove_non_octopus_data_sources(config),
        )

    def test_retain_data_sources_in_heredocs(self):
        """
        Terraform templates embedded in a step are unindented, so the data sources they define must not
        be treated as top level data sources.
        """
        config = """resource "octopusdeploy_process_step" "step" {
  properties = {
    "Octopus.Action.Terraform.Template" = <<EOT
data "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}
EOT
  }
}"""
        self.assertEqual(config, remove_non_octopus_data_sources(config))

    def test_bad_indents(self):
        config = """data "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
  }"""
        self.assertEqual(config, remove_non_octopus_data_sources(config))
