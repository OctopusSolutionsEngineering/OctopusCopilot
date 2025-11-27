import unittest

import hcl2

from domain.sanitizers.terraform import remove_duplicate_script_sources


class DuplicateScriptSourceRemovalTest(unittest.TestCase):
    def test_no_duplicates(self):
        config = """resource "aws_s3_bucket" "bucket" {
            bucket = "bucket_id"
            force_destroy = true
        }"""  # noqa: W293

        fixed_config = remove_duplicate_script_sources(config)

        self.assertEqual(hcl2.loads(config), hcl2.loads(fixed_config))

    def test_no_duplicate_definitions(self):
        config = """resource "octopusdeploy_process_step" "process_step_child_project_run_a_script" {
            count                 = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
            name                  = "Run a Script"
            type                  = "Octopus.Script"
            process_id            = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process.process_child_project[0].id}"
            channels              = null
            condition             = "Success"
            environments          = null
            excluded_environments = null
            package_requirement   = "LetOctopusDecide"
            slug                  = "run-a-script"
            start_trigger         = "StartAfterPrevious"
            tenant_tags           = null
            worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
            properties            = {
              }
            execution_properties  = {
                "Octopus.Action.Script.Syntax" = "PowerShell"
                "Octopus.Action.Script.ScriptBody" = "echo \\\"Hello world\\\""
                "OctopusUseBundledTooling" = "False"
                "Octopus.Action.RunOnServer" = "true"
                "Octopus.Action.Script.ScriptSource" = "Inline"
              }
            }
            
            resource "octopusdeploy_process_step" "step2" {}
            """  # noqa: W293

        fixed_config = remove_duplicate_script_sources(config)

        self.assertEqual(hcl2.loads(config), hcl2.loads(fixed_config))

    def test_package_with_inline_definitions(self):
        config = """resource "octopusdeploy_process_step" "process_step_child_project_run_a_script" {
            count                 = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
            name                  = "Run a Script"
            type                  = "Octopus.Script"
            process_id            = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process.process_child_project[0].id}"
            channels              = null
            condition             = "Success"
            environments          = null
            excluded_environments = null
            package_requirement   = "LetOctopusDecide"
            slug                  = "run-a-script"
            start_trigger         = "StartAfterPrevious"
            tenant_tags           = null
            worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
            primary_package       = {
                acquisition_location = "Server"
                feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
                id = null
                package_id = "${var.project_every_step_project_step_run_a_script_from_a_package_packageid}"
                properties = {
                    SelectionMode = "immediate"
                }
              }
            properties            = {
              }
            execution_properties  = {
                "Octopus.Action.Script.Syntax" = "PowerShell"
                "Octopus.Action.Script.ScriptBody" = "echo \\\"Hello world\\\""
                "OctopusUseBundledTooling" = "False"
                "Octopus.Action.RunOnServer" = "true"
                "Octopus.Action.Script.ScriptSource" = "Inline"
                "Octopus.Action.Script.ScriptFileName" = "MyScript.ps1"
              }
            }

            resource "octopusdeploy_process_step" "step2" {}
            """  # noqa: W293

        fixed_config = remove_duplicate_script_sources(config)
        parsed_fixed_config = hcl2.loads(fixed_config)

        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_process_step"][
                "process_step_child_project_run_a_script"
            ].get("primary_package", None)
            is None
        )
        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_process_step"][
                "process_step_child_project_run_a_script"
            ]
            .get("execution_properties", [])
            .get("Octopus.Action.Script.ScriptFileName")
            is None
        )

    def test_package_with_package_definitions(self):
        config = """resource "octopusdeploy_process_step" "process_step_child_project_run_a_script" {
            count                 = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
            name                  = "Run a Script"
            type                  = "Octopus.Script"
            process_id            = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process.process_child_project[0].id}"
            channels              = null
            condition             = "Success"
            environments          = null
            excluded_environments = null
            package_requirement   = "LetOctopusDecide"
            slug                  = "run-a-script"
            start_trigger         = "StartAfterPrevious"
            tenant_tags           = null
            worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
            primary_package       = {
                acquisition_location = "Server"
                feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
                id = null
                package_id = "${var.project_every_step_project_step_run_a_script_from_a_package_packageid}"
                properties = {
                    SelectionMode = "immediate"
                }
              }
            properties            = {
              }
            execution_properties  = {
                "Octopus.Action.Script.Syntax" = "PowerShell"
                "Octopus.Action.Script.ScriptBody" = "echo \\\"Hello world\\\""
                "OctopusUseBundledTooling" = "False"
                "Octopus.Action.RunOnServer" = "true"
                "Octopus.Action.Script.ScriptSource" = "Package"
                "Octopus.Action.Script.ScriptFileName" = "MyScript.ps1"
              }
            }

            resource "octopusdeploy_process_step" "step2" {}
            """  # noqa: W293

        fixed_config = remove_duplicate_script_sources(config)
        parsed_fixed_config = hcl2.loads(fixed_config)

        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_process_step"][
                "process_step_child_project_run_a_script"
            ].get("primary_package", None)
            is not None
        )
        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_process_step"][
                "process_step_child_project_run_a_script"
            ]
            .get("execution_properties", [])
            .get("Octopus.Action.Script.ScriptFileName")
            is not None
        )
        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_process_step"][
                "process_step_child_project_run_a_script"
            ]
            .get("execution_properties", [])
            .get("Octopus.Action.Script.Syntax")
            is None
        )
        self.assertTrue(
            parsed_fixed_config["resource"][0]["octopusdeploy_process_step"][
                "process_step_child_project_run_a_script"
            ]
            .get("execution_properties", [])
            .get("Octopus.Action.Script.ScriptBody")
            is None
        )
