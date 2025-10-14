provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.3.10" }
  }
  required_version = ">= 1.6.0"
}

variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
}

data "octopusdeploy_lifecycles" "system_lifecycle_firstlifecycle" {
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
}

data "octopusdeploy_project_groups" "project_group_script" {
  ids          = null
  partial_name = "${var.project_group_script_name}"
  skip         = 0
  take         = 1
}
variable "project_group_script_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Script"
}
resource "octopusdeploy_project_group" "project_group_script" {
  count = "${length(data.octopusdeploy_project_groups.project_group_script.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_script_name}"
  lifecycle {
    prevent_destroy = true
  }
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

data "octopusdeploy_environments" "environment_test" {
  ids          = null
  partial_name = "Test"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_test" {
  count                        = "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? 0 : 1}"
  name                         = "Test"
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
  depends_on = [octopusdeploy_environment.environment_development]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_production" {
  ids          = null
  partial_name = "Production"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_production" {
  count                        = "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? 0 : 1}"
  name                         = "Production"
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
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_test]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_application" {
  ids          = null
  partial_name = "Application"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_application" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? 0 : 1}"
  name        = "Application"
  description = "This is an example lifecycle that automatically deploys to the first environment"

  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    name                                  = "Development"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
    name                                  = "Test"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
    name                                  = "Production"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }

  release_retention_policy {
    quantity_to_keep = 30
    unit             = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep = 30
    unit             = "Days"
  }
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_default_lifecycle" {
  ids          = null
  partial_name = "Default Lifecycle"
  skip         = 0
  take         = 1
}

data "octopusdeploy_channels" "channel_script_default" {
  ids          = []
  partial_name = "Default"
  skip         = 0
  take         = 1
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

resource "octopusdeploy_process" "process_script" {
  count      = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? data.octopusdeploy_projects.project_script.projects[0].id : octopusdeploy_project.project_script[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_script_hello_world" {
  count                 = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  name                  = "Hello World"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? null : octopusdeploy_process.process_script[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "An example script step."
  package_requirement   = "LetOctopusDecide"
  slug                  = "hello-world"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"#{Project.Message}\""
        "OctopusUseBundledTooling" = "False"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_script" {
  count      = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? null : octopusdeploy_process.process_script[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_script.projects) != 0 ? null : octopusdeploy_process_step.process_step_script_hello_world[0].id}"]
}

data "octopusdeploy_worker_pools" "workerpool_default_worker_pool" {
  ids          = null
  partial_name = "Default Worker Pool"
  skip         = 0
  take         = 1
}

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_variable" "script_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_script.projects) == 0 ?octopusdeploy_project.project_script[0].id : data.octopusdeploy_projects.project_script.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.Hosted Ubuntu.worker_pools[0].id}"
  name         = "Project.WorkerPool"
  type         = "WorkerPool"
  description  = "The workerpool used by the steps. Defining the workerpool as a variable allows it to be changed in a single location for multiple steps."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "script_project_message_1" {
  count        = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_script.projects) == 0 ?octopusdeploy_project.project_script[0].id : data.octopusdeploy_projects.project_script.projects[0].id}"
  value        = "Hello World!"
  name         = "Project.Message"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "project_script_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Script"
  default     = "Script"
}
variable "project_script_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Script"
  default     = ""
}
variable "project_script_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Script"
  default     = ""
}
variable "project_script_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Script"
  default     = "This project runs a script step."
}
variable "project_script_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_script" {
  ids          = null
  partial_name = "${var.project_script_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_script" {
  count                                = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_script_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_application[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_script.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_script.project_groups[0].id : octopusdeploy_project_group.project_group_script[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_script_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_script_description_prefix}${var.project_script_description}${var.project_script_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_script" {
  count      = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_script.projects) != 0 ? data.octopusdeploy_projects.project_script.projects[0].id : octopusdeploy_project.project_script[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


