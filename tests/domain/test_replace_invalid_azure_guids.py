import sys
import unittest
from unittest.mock import MagicMock

try:
    import lxml.html.diff  # noqa: F401
except ImportError:
    for name in ("lxml", "lxml.html", "lxml.html.diff", "lxml.etree"):
        sys.modules[name] = MagicMock()

from domain.sanitizers.terraform import (  # noqa: E402
    add_missing_project_group_resources,
    convert_prompt_named_project_group_lookup,
    remove_postcondition_from_created_project_groups,
    replace_invalid_azure_guids,
)

PLACEHOLDER = "00000000-0000-0000-0000-000000000000"
VALID = "123e4567-e89b-12d3-a456-426614174000"


class TestReplaceInvalidAzureGuids(unittest.TestCase):
    def test_replaces_malformed_service_principal_ids(self):
        config = """resource "octopusdeploy_azure_service_principal" "account_azure_prod" {
  name            = "Azure Prod"
  application_id  = "abc"
  subscription_id = "not-a-guid"
  tenant_id       = "12345"
  password        = "CHANGE ME"
}
"""
        result = replace_invalid_azure_guids(config)
        self.assertEqual(result.count(f'"{PLACEHOLDER}"'), 3)
        self.assertNotIn("not-a-guid", result)
        self.assertIn('password        = "CHANGE ME"', result)

    def test_keeps_valid_uuids(self):
        config = f"""resource "octopusdeploy_azure_service_principal" "a" {{
  application_id  = "{VALID}"
  subscription_id = "{VALID.upper()}"
  tenant_id       = "{VALID}"
}}
"""
        self.assertEqual(replace_invalid_azure_guids(config), config)

    def test_replaces_openid_connect_ids(self):
        config = """resource "octopusdeploy_azure_openid_connect" "a" {
  subscription_id = "sub"
  application_id  = "app"
  tenant_id       = "ten"
}
"""
        self.assertEqual(replace_invalid_azure_guids(config).count(PLACEHOLDER), 3)

    def test_leaves_other_resources_and_interpolations(self):
        config = """resource "octopusdeploy_tenant_project_variable" "v" {
  tenant_id = "Tenants-1"
}
resource "octopusdeploy_azure_service_principal" "a" {
  tenant_id = "${var.tenant}"
}
"""
        self.assertEqual(replace_invalid_azure_guids(config), config)

    def test_handles_multiple_blocks_and_nested_braces(self):
        config = """resource "octopusdeploy_azure_service_principal" "a" {
  tenant_id = "x"
  lifecycle {
    ignore_changes = [password]
  }
  application_id = "y"
}
resource "octopusdeploy_azure_service_principal" "b" {
  subscription_id = "z"
}
"""
        result = replace_invalid_azure_guids(config)
        self.assertEqual(result.count(PLACEHOLDER), 3)
        self.assertIn("ignore_changes = [password]", result)


PROJECT_GROUP_CONFIG = """variable "project_group_data_platform_name" {
  type    = string
  default = "Data Platform"
}
data "octopusdeploy_project_groups" "project_group_data_platform" {
  partial_name = "${var.project_group_data_platform_name}"
}
resource "octopusdeploy_project" "p" {
  project_group_id = "${length(data.octopusdeploy_project_groups.project_group_data_platform.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_data_platform.project_groups[0].id : octopusdeploy_project_group.project_group_data_platform[0].id}"
}
"""


class TestAddMissingProjectGroupResources(unittest.TestCase):
    def test_adds_undeclared_resource(self):
        result = add_missing_project_group_resources(PROJECT_GROUP_CONFIG)
        self.assertIn('resource "octopusdeploy_project_group" "project_group_data_platform" {', result)
        self.assertIn("name  = \"${var.project_group_data_platform_name}\"", result)
        self.assertIn("count = \"${length(data.octopusdeploy_project_groups.project_group_data_platform.project_groups) != 0 ? 0 : 1}\"", result)

    def test_leaves_declared_resource_alone(self):
        config = PROJECT_GROUP_CONFIG + 'resource "octopusdeploy_project_group" "project_group_data_platform" {\n  name = "x"\n}\n'
        self.assertEqual(add_missing_project_group_resources(config), config)

    def test_skips_when_name_variable_missing(self):
        config = 'resource "octopusdeploy_project" "p" {\n  project_group_id = octopusdeploy_project_group.other[0].id\n}\n'
        self.assertEqual(add_missing_project_group_resources(config), config)


class TestRemovePostconditionFromCreatedProjectGroups(unittest.TestCase):
    CONFIG = """data "octopusdeploy_project_groups" "project_group_data_platform" {
  partial_name = "${var.project_group_data_platform_name}"
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a project group"
      condition     = length(self.project_groups) != 0
    }
  }
}
resource "octopusdeploy_project_group" "project_group_data_platform" {
  name = "Data Platform"
}
"""

    def test_removes_postcondition_when_resource_declared(self):
        result = remove_postcondition_from_created_project_groups(self.CONFIG)
        self.assertNotIn("postcondition", result)
        self.assertNotIn("lifecycle", result)
        self.assertIn('partial_name = "${var.project_group_data_platform_name}"', result)
        self.assertIn('resource "octopusdeploy_project_group" "project_group_data_platform"', result)

    def test_keeps_postcondition_for_lookup_only_group(self):
        config = self.CONFIG.split("resource ")[0]
        self.assertEqual(remove_postcondition_from_created_project_groups(config), config)

    def test_combines_with_missing_resource_sanitizer(self):
        config = (
            'variable "project_group_data_platform_name" {\n  default = "Data Platform"\n}\n'
            'data "octopusdeploy_project_groups" "project_group_data_platform" {\n'
            "  lifecycle {\n    postcondition {\n      condition = length(self.project_groups) != 0\n    }\n  }\n}\n"
            "x = octopusdeploy_project_group.project_group_data_platform[0].id\n"
        )
        result = remove_postcondition_from_created_project_groups(add_missing_project_group_resources(config))
        self.assertNotIn("postcondition", result)
        self.assertIn('resource "octopusdeploy_project_group" "project_group_data_platform"', result)


LOOKUP_ONLY_CONFIG = """variable "project_group_data_platform_name" {
  type    = string
  default = "Data Platform"
}
data "octopusdeploy_project_groups" "project_group_data_platform" {
  ids          = null
  partial_name = "${var.project_group_data_platform_name}"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a project group"
      condition     = length(self.project_groups) != 0
    }
  }
}
resource "octopusdeploy_project" "p" {
  project_group_id = "${data.octopusdeploy_project_groups.project_group_data_platform.project_groups[0].id}"
}
"""


class TestConvertPromptNamedProjectGroupLookup(unittest.TestCase):
    def test_converts_lookup_only_group_to_create_pattern(self):
        result = convert_prompt_named_project_group_lookup(LOOKUP_ONLY_CONFIG)
        self.assertNotIn("postcondition", result)
        self.assertIn('resource "octopusdeploy_project_group" "project_group_data_platform" {', result)
        self.assertIn('name  = "${var.project_group_data_platform_name}"', result)
        self.assertIn(
            "project_group_id = \"${length(data.octopusdeploy_project_groups.project_group_data_platform.project_groups) != 0 ? "
            "data.octopusdeploy_project_groups.project_group_data_platform.project_groups[0].id : "
            'octopusdeploy_project_group.project_group_data_platform[0].id}"',
            result,
        )

    def test_is_idempotent(self):
        once = convert_prompt_named_project_group_lookup(LOOKUP_ONLY_CONFIG)
        self.assertEqual(convert_prompt_named_project_group_lookup(once), once)

    def test_keeps_default_project_group_lookup(self):
        config = LOOKUP_ONLY_CONFIG.replace("Data Platform", "Default Project Group")
        self.assertEqual(convert_prompt_named_project_group_lookup(config), config)

    def test_literal_partial_name(self):
        config = LOOKUP_ONLY_CONFIG.replace('"${var.project_group_data_platform_name}"', '"Data Platform"', 1)
        result = convert_prompt_named_project_group_lookup(config)
        self.assertIn('name  = "Data Platform"', result)
        self.assertNotIn("postcondition", result)

    def test_ignores_config_without_postcondition(self):
        config = 'data "octopusdeploy_project_groups" "g" {\n  partial_name = "X"\n}\n'
        self.assertEqual(convert_prompt_named_project_group_lookup(config), config)

    def test_does_not_duplicate_an_existing_resource(self):
        config = LOOKUP_ONLY_CONFIG + 'resource "octopusdeploy_project_group" "project_group_data_platform" {\n  name = "x"\n}\n'
        result = convert_prompt_named_project_group_lookup(config)
        self.assertEqual(result.count('resource "octopusdeploy_project_group" "project_group_data_platform"'), 1)

    def test_skips_lookup_without_a_resolvable_name(self):
        config = LOOKUP_ONLY_CONFIG.replace(
            '"${var.project_group_data_platform_name}"', '"${var.undefined_name}"', 1
        )
        self.assertEqual(convert_prompt_named_project_group_lookup(config), config)


class TestEdgeCases(unittest.TestCase):
    def test_azure_guids_unchanged_without_matching_resources(self):
        config = 'resource "octopusdeploy_environment" "e" {\n  tenant_id = "bad"\n}\n'
        self.assertEqual(replace_invalid_azure_guids(config), config)
        self.assertEqual(replace_invalid_azure_guids(""), "")

    def test_postcondition_removal_without_lifecycle_is_a_no_op(self):
        config = (
            'data "octopusdeploy_project_groups" "g" {\n  partial_name = "X"\n}\n'
            'resource "octopusdeploy_project_group" "g" {\n  name = "X"\n}\n'
        )
        self.assertEqual(remove_postcondition_from_created_project_groups(config), config)

    def test_add_missing_resource_skips_when_data_source_missing(self):
        config = (
            'variable "g_name" {\n  default = "G"\n}\n'
            "x = octopusdeploy_project_group.g[0].id\n"
        )
        self.assertEqual(add_missing_project_group_resources(config), config)


if __name__ == "__main__":
    unittest.main()
