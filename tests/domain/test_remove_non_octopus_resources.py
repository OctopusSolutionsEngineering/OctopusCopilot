import unittest

from domain.sanitizers.terraform import remove_non_octopus_resources


class RemoveNonOctopusResourcesTest(unittest.TestCase):
    def test_none_config(self):
        self.assertEqual("", remove_non_octopus_resources(None))

    def test_empty_config(self):
        self.assertEqual("", remove_non_octopus_resources(""))

    def test_no_resources(self):
        config = """variable "octopus_space_id" {
  type = string
}"""
        self.assertEqual(config, remove_non_octopus_resources(config))

    def test_only_octopus_resources(self):
        config = """resource "octopusdeploy_project_group" "group" {
  name = "Test"
}
resource "octopusdeploy_project" "project" {
  name = "Test Project"
}"""
        self.assertEqual(config, remove_non_octopus_resources(config))

    def test_remove_other_provider_resources(self):
        config = """resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
}
resource "octopusdeploy_project" "project" {
  name = "Test Project"
}
resource "azurerm_resource_group" "rg" {
  name = "my-resource-group"
}"""
        self.assertEqual(
            """resource "octopusdeploy_project" "project" {
  name = "Test Project"
}""",
            remove_non_octopus_resources(config),
        )

    def test_retain_other_block_types(self):
        config = """variable "octopus_space_id" {
  type = string
}
data "octopusdeploy_environments" "environment" {
  ids = null
}
resource "random_password" "password" {
  length = 10
}
output "project_id" {
  value = octopusdeploy_project.project.id
}"""
        self.assertEqual(
            """variable "octopus_space_id" {
  type = string
}
data "octopusdeploy_environments" "environment" {
  ids = null
}
output "project_id" {
  value = octopusdeploy_project.project.id
}""",
            remove_non_octopus_resources(config),
        )

    def test_retain_resources_in_heredocs(self):
        """
        Terraform templates embedded in a step are unindented, so the resources they define must not
        be treated as top level resources.
        """
        config = """resource "octopusdeploy_process_step" "step" {
  properties = {
    "Octopus.Action.Terraform.Template" = <<EOT
resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
}
EOT
  }
}"""
        self.assertEqual(config, remove_non_octopus_resources(config))

    def test_bad_indents(self):
        config = """resource "aws_s3_bucket" "bucket" {
  bucket = "my-bucket"
  }"""
        self.assertEqual(config, remove_non_octopus_resources(config))
