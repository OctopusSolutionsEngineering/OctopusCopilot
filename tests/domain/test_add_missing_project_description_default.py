import sys
import unittest
from unittest.mock import MagicMock

try:
    import lxml.html.diff  # noqa: F401
except ImportError:
    for name in ("lxml", "lxml.html", "lxml.html.diff", "lxml.etree"):
        sys.modules[name] = MagicMock()

from domain.sanitizers.terraform import add_missing_project_description_default  # noqa: E402


class TestAddMissingProjectDescriptionDefault(unittest.TestCase):
    def test_adds_default_from_description(self):
        config = """variable "project_claims_portal_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Claims Portal. NOTE: java_keystore was omitted."
}
variable "project_claims_portal_tenanted" {
  type    = string
  default = "Untenanted"
}"""
        result = add_missing_project_description_default(config)
        self.assertIn(
            'default     = "The description of the project exported from Claims Portal. NOTE: java_keystore was omitted."',
            result,
        )
        self.assertEqual(result.count("default"), 2)
        self.assertIn('variable "project_claims_portal_tenanted"', result)

    def test_leaves_existing_default(self):
        config = """variable "project_x_description" {
  type        = string
  description = "The description"
  default     = "Existing"
}"""
        self.assertEqual(add_missing_project_description_default(config), config)

    def test_ignores_other_variables(self):
        config = """variable "octopus_space_id" {
  type        = string
  description = "The ID of the Octopus space to populate."
}"""
        self.assertEqual(add_missing_project_description_default(config), config)

    def test_falls_back_without_description(self):
        config = """variable "project_x_description" {
  type = string
}"""
        result = add_missing_project_description_default(config)
        self.assertIn('default     = "Project description"', result)


if __name__ == "__main__":
    unittest.main()
