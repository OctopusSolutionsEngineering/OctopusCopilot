import unittest

from domain.sanitizers.terraform import remove_empty_variable_scope_blocks

NULL_SCOPE = """resource "octopusdeploy_variable" "kiosk_portal_kiosk_theme_light_1" {
  name         = "Kiosk.Theme"
  value        = "light"
  is_sensitive = false
  scope {
    actions      = null
    channels     = null
    environments = null
    machines     = null
    roles        = null
    tenant_tags  = null
    processes    = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}
"""

REAL_SCOPE = """resource "octopusdeploy_variable" "kiosk_portal_kiosk_theme_dark_1" {
  name  = "Kiosk.Theme"
  value = "dark"
  scope {
    actions      = null
    environments = ["${octopusdeploy_environment.environment_store_live[0].id}"]
    tenant_tags  = null
  }
}
"""


class TestRemoveEmptyVariableScopeBlocks(unittest.TestCase):
    def test_all_null_scope_is_removed(self):
        result = remove_empty_variable_scope_blocks(NULL_SCOPE)
        self.assertNotIn("scope {", result)
        self.assertIn('value        = "light"', result)
        self.assertIn("lifecycle {", result)
        self.assertIn("prevent_destroy = true", result)
        self.assertIn("depends_on = []", result)

    def test_empty_braces_and_empty_lists_are_removed(self):
        config = (
            'resource "octopusdeploy_variable" "a" {\n  name = "A"\n  scope {}\n}\n'
            'resource "octopusdeploy_variable" "b" {\n  name = "B"\n  scope {\n    environments = []\n    roles = null\n  }\n}\n'
        )
        result = remove_empty_variable_scope_blocks(config)
        self.assertNotIn("scope", result)
        self.assertIn('name = "A"', result)
        self.assertIn('name = "B"', result)

    def test_real_scope_is_kept(self):
        self.assertEqual(remove_empty_variable_scope_blocks(REAL_SCOPE), REAL_SCOPE)

    def test_mixed_resources(self):
        result = remove_empty_variable_scope_blocks(REAL_SCOPE + NULL_SCOPE)
        self.assertEqual(result.count("scope {"), 1)
        self.assertIn("environment_store_live", result)

    def test_other_resources_are_untouched(self):
        config = 'resource "octopusdeploy_tenant_common_variable" "t" {\n  scope {\n    environment_ids = null\n  }\n}\n'
        self.assertEqual(remove_empty_variable_scope_blocks(config), config)

    def test_empty_config(self):
        self.assertEqual(remove_empty_variable_scope_blocks(""), "")
        self.assertIsNone(remove_empty_variable_scope_blocks(None))


if __name__ == "__main__":
    unittest.main()
