import unittest

from domain.sanitizers.terraform import (
    convert_primary_package_to_referenced_package,
    sanitize_inline_script,
)

STEP = """resource "octopusdeploy_process_step" "rolling_restart" {
  type            = "Octopus.Script"
  primary_package = { acquisition_location = "Server", feed_id = "Feeds-1", id = null, package_id = "Search.Scripts", properties = { SelectionMode = "immediate" }, version = null }
  execution_properties = {
    "Octopus.Action.Script.ScriptSource" = "Inline"
    "Octopus.Action.Script.ScriptBody" = "bash #{Octopus.Action.Package[Search.Scripts].ExtractedPath}/rolling-restart.sh"
  }
}"""


class ConvertPrimaryPackageToReferencedPackageTest(unittest.TestCase):
    def test_converts_primary_package(self):
        fixed = convert_primary_package_to_referenced_package(STEP)
        self.assertNotIn("primary_package", fixed)
        self.assertIn('packages = { "Search.Scripts" = {', fixed)
        self.assertIn('properties = { Extract = "True", SelectionMode = "immediate" }', fixed)
        self.assertIn('package_id = "Search.Scripts"', fixed)

    def test_sanitize_inline_script_keeps_package(self):
        fixed = sanitize_inline_script(STEP.splitlines())
        self.assertIn('packages = { "Search.Scripts" = {', fixed)
        self.assertNotIn("primary_package", fixed)

    def test_no_reference_leaves_primary_package(self):
        config = STEP.replace("#{Octopus.Action.Package[Search.Scripts].ExtractedPath}", "/opt")
        self.assertEqual(config, convert_primary_package_to_referenced_package(config))

    def test_existing_packages_map_untouched(self):
        config = STEP.replace('type            = "Octopus.Script"', 'type = "Octopus.Script"\n  packages = {}')
        self.assertEqual(config, convert_primary_package_to_referenced_package(config))

    def test_keeps_explicit_extract_false(self):
        config = STEP.replace(
            'properties = { SelectionMode = "immediate" }',
            'properties = { Extract = "False", SelectionMode = "immediate" }',
        ).replace(".ExtractedPath}/rolling-restart.sh", ".PackageFilePath}")
        fixed = convert_primary_package_to_referenced_package(config)
        self.assertIn('properties = { Extract = "False", SelectionMode = "immediate" }', fixed)
        self.assertEqual(1, fixed.count("Extract ="))

    def test_does_not_extract_without_extracted_path(self):
        config = STEP.replace(".ExtractedPath}/rolling-restart.sh", ".PackageFilePath}")
        fixed = convert_primary_package_to_referenced_package(config)
        self.assertIn('packages = { "Search.Scripts" = {', fixed)
        self.assertNotIn("Extract", fixed)
