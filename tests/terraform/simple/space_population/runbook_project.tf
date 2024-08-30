data "octopusdeploy_feeds" "built_in_feed" {
  feed_type    = "BuiltIn"
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
}

resource "octopusdeploy_project" "copilot_test_runbook_project" {
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  description                          = "Test project"
  discrete_channel_release             = false
  is_disabled                          = false
  is_discrete_channel_release          = false
  is_version_controlled                = false
  lifecycle_id                         = data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id
  name                                 = "Copilot Test Runbook Project"
  project_group_id                     = octopusdeploy_project_group.project_group_test.id
  tenanted_deployment_participation    = "Untenanted"
  space_id                             = var.octopus_space_id
  included_library_variable_sets = []
  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.LastPatch}.#{Octopus.Version.NextRevision}"
  }

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "SkipUnavailableMachines"
  }
}

resource "octopusdeploy_runbook" "runbook" {
  project_id         = octopusdeploy_project.copilot_test_runbook_project.id
  name               = "Backup Database"
  description        = "Test Runbook"
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

resource "octopusdeploy_runbook_process" "runbook" {
  runbook_id = octopusdeploy_runbook.runbook.id

  step {
    condition           = "Success"
    name                = "Hello world (using PowerShell)"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Hello world (using PowerShell)"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = true
      worker_pool_id                     = ""
      properties = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptBody"   = "Write-Host 'Hello world, using PowerShell'\n\n#TODO: Experiment with steps of your own :)\n\nWrite-Host '[Learn more about the types of steps available in Octopus](https://oc.to/OnboardingAddStepsLearnMore)'"
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

resource "octopusdeploy_runbook" "runbook2" {
  project_id         = octopusdeploy_project.copilot_test_runbook_project.id
  name               = "Long Running Runbook"
  description        = "Test Runbook"
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

resource "octopusdeploy_runbook_process" "runbook2" {
  runbook_id = octopusdeploy_runbook.runbook2.id

  step {
    condition           = "Success"
    name                = "Hello world (using PowerShell)"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Hello world (using PowerShell)"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = true
      worker_pool_id                     = ""
      properties = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptBody"   = "Write-Host 'Hello world, using PowerShell'\n\n#TODO: Experiment with steps of your own :)\n\nWrite-Host '[Learn more about the types of steps available in Octopus](https://oc.to/OnboardingAddStepsLearnMore)'\n\nsleep 60"
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

resource "octopusdeploy_runbook" "runbook3" {
  project_id         = octopusdeploy_project.copilot_test_runbook_project.id
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

resource "octopusdeploy_runbook_process" "runbook3" {
  runbook_id = octopusdeploy_runbook.runbook3.id

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
# Prompted variables scoped to only the one runbook as one is a required value
resource "octopusdeploy_variable" "copilot_test_runbook_slot_variable" {
  owner_id     = octopusdeploy_project.copilot_test_runbook_project.id
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

  scope {
     processes = [octopusdeploy_runbook.runbook3.id]
  }
  depends_on = [octopusdeploy_runbook.runbook3, octopusdeploy_runbook_process.runbook3]
}

resource "octopusdeploy_variable" "copilot_test_runbook_notify_variable" {
  owner_id     = octopusdeploy_project.copilot_test_runbook_project.id
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

  scope {
     processes = [octopusdeploy_runbook.runbook3.id]
  }
  depends_on = [octopusdeploy_runbook.runbook3, octopusdeploy_runbook_process.runbook3]
}