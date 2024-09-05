variable "prompted_variable_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Prompted Variable Project"
  default     = "Prompted Variable Project"
}
variable "prompted_variable_project_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Prompted Variable Project"
  default     = ""
}
variable "prompted_variable_project_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Prompted Variable Project"
  default     = ""
}
variable "prompted_variable_project_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Prompted Variable Project"
  default     = ""
}
variable "prompted_variable_project_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
resource "octopusdeploy_project" "prompted_variable_project" {
  name                                 = "${var.prompted_variable_project_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "On"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${octopusdeploy_lifecycle.lifecycle_application.id}"
  project_group_id                     = "${octopusdeploy_project_group.project_group_test.id}"
  included_library_variable_sets = []
  tenanted_deployment_participation    = "TenantedOrUntenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
  }

  lifecycle {
    ignore_changes = []
  }
}

resource "octopusdeploy_deployment_process" "deployment_process_prompted_variable_project" {
  project_id = "${octopusdeploy_project.prompted_variable_project.id}"

  step {
    condition           = "Success"
    name                = "Step that will fail"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Step that will fail"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptBody"   = "Write-Highlight \"Notify is: $notify\"\nWrite-Highlight \"Slot is: $slot\""
        "Octopus.Action.Script.Syntax"       = "PowerShell"
        "Octopus.Action.RunOnServer"         = "true"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []
      features                           = []
    }

    properties   = {}
    target_roles = []
  }

  depends_on = []
}

resource "octopusdeploy_runbook" "prompted_variable_project_runbook" {
  project_id         = octopusdeploy_project.prompted_variable_project.id
  name               = "Prompted Variables Runbook"
  description        = "Runbook with Prompted variables"
  multi_tenancy_mode = "Untenanted"
  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "SkipUnavailableMachines"
  }
  retention_policy {
    quantity_to_keep = 10
  }
  environment_scope           = "Specified"
  environments = [octopusdeploy_environment.environment_development.id]
  default_guided_failure_mode = "EnvironmentDefault"
  force_package_download      = true
}

resource "octopusdeploy_runbook_process" "prompted_variable_project_runbook_process" {
  runbook_id = octopusdeploy_runbook.prompted_variable_project_runbook.id

  step {
    condition           = "Success"
    name                = "Print variable names"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Print variable names"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = true
      worker_pool_id                     = ""
      properties = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptBody"   = "Write-Highlight \"Notify is: $notify\"\nWrite-Highlight \"Slot is: $slot\""
        "Octopus.Action.Script.Syntax"       = "PowerShell"
      }
      environments = [octopusdeploy_environment.environment_development.id]
      excluded_environments = []
      channels = []
      tenant_tags = []
      features = ["Octopus.Features.JsonConfigurationVariables"]
    }

    properties = {}
    target_roles = []
  }
}

# Prompted variables not scoped, so will apply to both deployment and runbooks.
resource "octopusdeploy_variable" "prompted_variable_project_slot_variable" {
  owner_id     = octopusdeploy_project.prompted_variable_project.id
  value        = ""
  name         = "slot"
  type         = "String"
  description  = "The deployment slot"
  is_sensitive = false

  prompt {
    description = "The deployment slot"
    label       = "DeploymentSlot"
    is_required = true

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_variable" "prompted_variable_project_notify_variable" {
  owner_id     = octopusdeploy_project.prompted_variable_project.id
  value        = ""
  name         = "notify"
  type         = "String"
  description  = "Notify users"
  is_sensitive = false

  prompt {
    description = "Should we notify users?"
    label       = "Notify Users"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}