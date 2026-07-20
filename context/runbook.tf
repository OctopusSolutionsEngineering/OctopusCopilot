provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.17.0" }
  }
  required_version = ">= 1.6.0"
}

variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
}

variable "project_every_step_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project to attach the runbook to"
  default     = "Every Step Project"
}
data "octopusdeploy_projects" "project_every_step_project" {
  ids          = null
  partial_name = "${var.project_every_step_project_name}"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve an project called \"Every Step Project\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.projects) != 0
    }
  }
}

data "octopusdeploy_feeds" "feed_octopus_server__built_in_" {
  feed_type    = "BuiltIn"
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"BuiltIn\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
  }
}

data "octopusdeploy_worker_pools" "workerpool_default_worker_pool" {
  ids          = null
  partial_name = "Default Worker Pool"
  skip         = 0
  take         = 1
}

data "octopusdeploy_worker_pools" "workerpool_hosted_windows" {
  ids          = null
  partial_name = "Hosted Windows"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_process" "process_every_step_project_example_runbook" {
  project_id = "${data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  runbook_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_runbook.runbook_every_step_project_example_runbook[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_every_step_project_example_runbook_run_a_script" {
  name                  = "Run a Script"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project_example_runbook[0].id}"
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
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"This is an example script step\""
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_every_step_project_example_runbook" {
  process_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project_example_runbook[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_example_runbook_run_a_script[0].id}"]
}

data "octopusdeploy_environments" "environment_development" {
  ids          = null
  partial_name = "Development"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_development" {
  count                        = "${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? 0 : 1}"
  name                         = "Development"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = false

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
  depends_on = []
  lifecycle {
    prevent_destroy = true
  }
}

variable "runbook_every_step_project_example_runbook_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Example Runbook"
  default     = "Example Runbook"
}
resource "octopusdeploy_runbook" "runbook_every_step_project_example_runbook" {
  count                       = "1"
  name                        = "${var.runbook_every_step_project_example_runbook_name}"
  project_id                  = "${data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  environment_scope           = "Specified"
  environments                = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "This is an example of a runbook"
  multi_tenancy_mode          = "TenantedOrUntenanted"

  retention_policy {
    should_keep_forever = true
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
}


