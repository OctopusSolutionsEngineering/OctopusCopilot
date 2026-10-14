import unittest

from domain.sanitizers.terraform import add_missing_standard_lifecycle_lookups

PROJECT = """resource "octopusdeploy_project" "project_microservice_1" {
  name         = "20. Microservice 1"
  lifecycle_id = "${length(data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id : data.octopusdeploy_lifecycles.system_lifecycle_firstlifecycle.lifecycles[0].id}"
}
"""
FIRST_LIFECYCLE = """data "octopusdeploy_lifecycles" "system_lifecycle_firstlifecycle" {
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
}
"""


class TestAddMissingStandardLifecycleLookups(unittest.TestCase):
    def test_missing_default_lifecycle_lookup_is_added(self):
        result = add_missing_standard_lifecycle_lookups(FIRST_LIFECYCLE + PROJECT)
        self.assertIn('data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle" {', result)
        self.assertIn('partial_name = "Default Lifecycle"', result)
        self.assertEqual(1, result.count('data "octopusdeploy_lifecycles" "system_lifecycle_firstlifecycle"'))

    def test_both_missing_lookups_are_added(self):
        result = add_missing_standard_lifecycle_lookups(PROJECT)
        self.assertIn('data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle" {', result)
        self.assertIn('data "octopusdeploy_lifecycles" "system_lifecycle_firstlifecycle" {', result)

    def test_declared_lookups_are_not_duplicated(self):
        config = (
            'data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle" {\n  partial_name = "Default Lifecycle"\n}\n'
            + FIRST_LIFECYCLE
            + PROJECT
        )
        self.assertEqual(config, add_missing_standard_lifecycle_lookups(config))

    def test_unknown_lifecycle_lookup_is_left_alone(self):
        config = 'x = "${data.octopusdeploy_lifecycles.lifecycle_custom.lifecycles[0].id}"\n'
        self.assertEqual(config, add_missing_standard_lifecycle_lookups(config))

    def test_unreferenced_lookups_are_not_added(self):
        config = 'resource "octopusdeploy_project" "p" {\n  name = "P"\n}\n'
        self.assertEqual(config, add_missing_standard_lifecycle_lookups(config))

    def test_none_and_empty(self):
        self.assertIsNone(add_missing_standard_lifecycle_lookups(None))
        self.assertEqual("", add_missing_standard_lifecycle_lookups(""))


if __name__ == "__main__":
    unittest.main()
