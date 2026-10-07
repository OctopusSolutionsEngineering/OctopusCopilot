import unittest

from domain.sanitizers.terraform import add_missing_enabled_features


class AddMissingEnabledFeaturesTest(unittest.TestCase):
    def test_none(self):
        self.assertIsNone(add_missing_enabled_features(None))

    def test_adds_custom_directory_feature(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  type = "Octopus.TentaclePackage"
  execution_properties = {
    "Octopus.Action.Package.CustomInstallationDirectory" = "/etc/nginx"
    "Octopus.Action.EnabledFeatures" = ",Octopus.Features.SubstituteInFiles,Octopus.Features.CustomScripts"
  }
}"""
        self.assertIn(
            '"Octopus.Action.EnabledFeatures" = ",Octopus.Features.SubstituteInFiles,Octopus.Features.CustomScripts,Octopus.Features.CustomDirectory"',
            add_missing_enabled_features(config),
        )

    def test_adds_substitute_in_files_feature(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.SubstituteInFiles.TargetFiles" = "index.html"
    "Octopus.Action.EnabledFeatures" = ",Octopus.Features.CustomDirectory"
  }
}"""
        self.assertIn(
            '"Octopus.Action.EnabledFeatures" = ",Octopus.Features.CustomDirectory,Octopus.Features.SubstituteInFiles"',
            add_missing_enabled_features(config),
        )

    def test_keeps_existing_feature(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.Package.CustomInstallationDirectory" = "/etc/nginx"
    "Octopus.Action.EnabledFeatures" = "Octopus.Features.CustomDirectory"
  }
}"""
        self.assertEqual(config, add_missing_enabled_features(config))

    def test_ignores_steps_without_feature_properties(self):
        config = """resource "octopusdeploy_process_step" "other" {
  execution_properties = {
    "Octopus.Action.EnabledFeatures" = "Octopus.Features.SubstituteInFiles"
  }
}"""
        self.assertEqual(config, add_missing_enabled_features(config))

    def test_adds_missing_enabled_features(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.Package.CustomInstallationDirectory" = "/etc/nginx"
    "Octopus.Action.CustomScripts.PostDeploy.sh" = "echo done"
  }
}"""
        self.assertEqual(
            """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.Package.CustomInstallationDirectory" = "/etc/nginx"
    "Octopus.Action.EnabledFeatures" = "Octopus.Features.CustomDirectory,Octopus.Features.CustomScripts"
    "Octopus.Action.CustomScripts.PostDeploy.sh" = "echo done"
  }
}""",
            add_missing_enabled_features(config),
        )

    def test_renames_invalid_substitute_property(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.Package.SubstituteInFiles.TargetFiles" = "config/database.yml"
    "Octopus.Action.EnabledFeatures" = ",Octopus.Features.CustomScripts"
  }
}"""
        fixed = add_missing_enabled_features(config)
        self.assertIn('"Octopus.Action.SubstituteInFiles.TargetFiles" = "config/database.yml"', fixed)
        self.assertNotIn("Octopus.Action.Package.SubstituteInFiles", fixed)
        self.assertIn(",Octopus.Features.CustomScripts,Octopus.Features.SubstituteInFiles", fixed)

    def test_adds_xml_configuration_features(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.EnabledFeatures" = ",Octopus.Features.IISWebSite"
    "Octopus.Action.Package.AdditionalXmlConfigurationTransforms" = "Web.Release.config => Web.config"
    "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
  }
}"""
        self.assertIn(
            '",Octopus.Features.IISWebSite,Octopus.Features.ConfigurationTransforms,Octopus.Features.ConfigurationVariables"',
            add_missing_enabled_features(config),
        )

    def test_ignores_disabled_app_settings_replacement(self):
        config = """resource "octopusdeploy_process_step" "deploy" {
  execution_properties = {
    "Octopus.Action.EnabledFeatures" = ",Octopus.Features.IISWebSite"
    "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "False"
  }
}"""
        self.assertEqual(config, add_missing_enabled_features(config))
