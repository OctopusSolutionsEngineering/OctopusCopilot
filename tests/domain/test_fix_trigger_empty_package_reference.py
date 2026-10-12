import unittest

from domain.sanitizers.terraform import fix_trigger_empty_package_reference

STEP = """resource "octopusdeploy_process_step" "process_step_booking_site_deploy_azure_web_app_container" {
  name                  = "Deploy Azure Web App Container"
  type                  = "Octopus.AzurePowerShell"
  packages = { "Acme.Booking.Web" = {
    acquisition_location = "Server"
    package_id           = "Acme.Booking.Web"
    properties           = { SelectionMode = "immediate" }
  } }
  slug                  = "deploy-azure-web-app-container"
}
"""

TRIGGER = """resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_booking_site_external_feed_trigger" {
  name       = "External Feed Trigger"
  package {
    deployment_action_slug = "deploy-azure-web-app-container"
    package_reference      = ""
  }
}
"""


class TestFixTriggerEmptyPackageReference(unittest.TestCase):
    def test_empty_reference_becomes_packages_key(self):
        result = fix_trigger_empty_package_reference(STEP + TRIGGER)
        self.assertIn('package_reference      = "Acme.Booking.Web"', result)

    def test_unquoted_packages_key(self):
        step = STEP.replace('packages = { "Acme.Booking.Web" = {', "packages = { webapp = {")
        result = fix_trigger_empty_package_reference(step + TRIGGER)
        self.assertIn('package_reference      = "webapp"', result)

    def test_primary_package_step_is_untouched(self):
        step = STEP.replace("  slug", '  primary_package = { package_id = "Acme.Booking.Web" }\n  slug')
        config = step + TRIGGER
        self.assertEqual(fix_trigger_empty_package_reference(config), config)

    def test_step_without_packages_is_untouched(self):
        step = STEP.replace('packages = { "Acme.Booking.Web" = {', "other = { x = {")
        config = step + TRIGGER
        self.assertEqual(fix_trigger_empty_package_reference(config), config)

    def test_existing_reference_is_kept(self):
        config = STEP + TRIGGER.replace('package_reference      = ""', 'package_reference      = "other"')
        self.assertEqual(fix_trigger_empty_package_reference(config), config)

    def test_trigger_for_another_step_is_untouched(self):
        config = STEP + TRIGGER.replace('"deploy-azure-web-app-container"\n', '"some-other-step"\n')
        self.assertEqual(fix_trigger_empty_package_reference(config), config)

    def test_empty_config(self):
        self.assertEqual(fix_trigger_empty_package_reference(""), "")
        self.assertIsNone(fix_trigger_empty_package_reference(None))


if __name__ == "__main__":
    unittest.main()
