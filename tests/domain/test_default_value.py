import unittest

import hcl2

from domain.sanitizers.terraform import (
    advanced_cleanup,
)


class DuplicateScriptSourceRemovalTest(unittest.TestCase):
    def test_no_duplicates(self):
        config = """resource "aws_s3_bucket" "bucket" {
            bucket = "bucket_id"
            force_destroy = true
        }"""  # noqa: W293

        fixed_config = advanced_cleanup(config)

        print(fixed_config)

        self.assertEqual(hcl2.loads(config), hcl2.loads(fixed_config))

    def test_empty_default_values(self):
        config = """resource "octopusdeploy_project" "project_every_step_project" {
          count                                = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
          name                                 = "${var.project_every_step_project_name}"
          default_guided_failure_mode          = "EnvironmentDefault"
          default_to_skip_if_already_installed = false
          is_discrete_channel_release          = false
          is_disabled                          = false
          is_version_controlled                = false
          lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_application[0].id}"
          project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
          included_library_variable_sets       = ["${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"]
          tenanted_deployment_participation    = "${var.project_every_step_project_tenanted}"
        
          template {
            name             = "Example.Tenant.Variable"
            label            = "An example tenant variable required to be defined by all tenants that deploy this project."
            help_text        = "This is where the help text associated with the variable is defined."
            default_value    = ""
            display_settings = { "Octopus.ControlType" = "MultiLineText" }
          }
          template {
            name             = "Another.Tenant.Variable"
            label            = "This is another example of a tenant variable"
            help_text        = "The help text. "
            default_value    = ""
            display_settings = { "Octopus.ControlType" = "MultiLineText" }
          }
          template {
            name             = "Another.Tenant.Variable"
            label            = "This is another example of a tenant variable"
            help_text        = "The help text. "
            default_value    = "blah"
            display_settings = { "Octopus.ControlType" = "MultiLineText" }
          }
        
          connectivity_policy {
            allow_deployments_to_no_targets = true
            exclude_unhealthy_targets       = false
            skip_machine_behavior           = "None"
            target_roles                    = []
          }
          description = "${var.project_every_step_project_description_prefix}${var.project_every_step_project_description}${var.project_every_step_project_description_suffix}"
          lifecycle {
            prevent_destroy = true
          }
        }
            """  # noqa: W293

        fixed_config = advanced_cleanup(config)

        parsed_fixed_config = hcl2.loads(fixed_config)

        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_project"][
                "project_every_step_project"
            ]
            .get("template", [])[0]
            .get("default_value", None)
            is None
        )

        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_project"][
                "project_every_step_project"
            ]
            .get("template", [])[1]
            .get("default_value", None)
            is None
        )

        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_project"][
                "project_every_step_project"
            ]
            .get("template", [])[2]
            .get("default_value", None)
            == "blah"
        )
