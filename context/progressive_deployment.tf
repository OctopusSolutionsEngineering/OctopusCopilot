provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.18.2" }
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

data "octopusdeploy_project_groups" "project_group_progressive" {
  ids          = null
  partial_name = "${var.project_group_progressive_name}"
  skip         = 0
  take         = 1
}
variable "project_group_progressive_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Progressive"
}
resource "octopusdeploy_project_group" "project_group_progressive" {
  count = "${length(data.octopusdeploy_project_groups.project_group_progressive.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_progressive_name}"
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
  use_guided_failure           = true

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

data "octopusdeploy_environments" "environment_prod_10" {
  ids          = null
  partial_name = "Prod 10"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_prod_10" {
  count                        = "${length(data.octopusdeploy_environments.environment_prod_10.environments) != 0 ? 0 : 1}"
  name                         = "Prod 10"
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

data "octopusdeploy_environments" "environment_prod_50" {
  ids          = null
  partial_name = "Prod 50"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_prod_50" {
  count                        = "${length(data.octopusdeploy_environments.environment_prod_50.environments) != 0 ? 0 : 1}"
  name                         = "Prod 50"
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
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_prod_10]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_environments" "environment_prod_100" {
  ids          = null
  partial_name = "Prod 100"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_prod_100" {
  count                        = "${length(data.octopusdeploy_environments.environment_prod_100.environments) != 0 ? 0 : 1}"
  name                         = "Prod 100"
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
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_prod_10,octopusdeploy_environment.environment_prod_50]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_progressive" {
  ids          = null
  partial_name = "Progressive"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_progressive" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_progressive.lifecycles) != 0 ? 0 : 1}"
  name        = "Progressive"
  description = ""

  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    name                                  = "Development"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_prod_10.environments) != 0 ? data.octopusdeploy_environments.environment_prod_10.environments[0].id : octopusdeploy_environment.environment_prod_10[0].id}"]
    name                                  = "Prod 10"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_prod_50.environments) != 0 ? data.octopusdeploy_environments.environment_prod_50.environments[0].id : octopusdeploy_environment.environment_prod_50[0].id}"]
    name                                  = "Prod 50"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_prod_100.environments) != 0 ? data.octopusdeploy_environments.environment_prod_100.environments[0].id : octopusdeploy_environment.environment_prod_100[0].id}"]
    name                                  = "Prod 100"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }

  release_retention_with_strategy {
    strategy = "Default"
  }

  tentacle_retention_with_strategy {
    strategy = "Default"
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

data "octopusdeploy_channels" "channel_progressive_deployment_default" {
  ids          = []
  partial_name = "Default"
  project_id   = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? data.octopusdeploy_projects.project_progressive_deployment.projects[0].id : octopusdeploy_project.project_progressive_deployment[0].id}"
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

data "octopusdeploy_community_step_template" "communitysteptemplate_run_octopus_deploy_runbook" {
  website = "https://library.octopus.com/step-templates/0444b0b3-088e-4689-b755-112d1360ffe3"
}
data "octopusdeploy_step_template" "steptemplate_run_octopus_deploy_runbook" {
  name = "Run Octopus Deploy Runbook"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_run_octopus_deploy_runbook" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_run_octopus_deploy_runbook.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_run_octopus_deploy_runbook.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_run_octopus_deploy_runbook.step_template != null ? 0 : 1}"
}

resource "octopusdeploy_process" "process_progressive_deployment" {
  count      = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? data.octopusdeploy_projects.project_progressive_deployment.projects[0].id : octopusdeploy_project.project_progressive_deployment[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_progressive_deployment_deploy_app" {
  count                 = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  name                  = "Deploy App"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process.process_progressive_deployment[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "deploy-app"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"Deploying app\""
      }
}

resource "octopusdeploy_process_step" "process_step_progressive_deployment_simulate_failure" {
  count                 = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  name                  = "Simulate Failure"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process.process_progressive_deployment[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "simulate-failure"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  depends_on            = [octopusdeploy_process_step.process_step_progressive_deployment_deploy_app]
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = <<EOT
if ($OctopusParameters["Project.SimulateFail"] -eq "True") {
  Write-Host "Simulating a failure"
  exit 1
}
EOT
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_progressive_deployment_run_octopus_deploy_runbook" {
  count                 = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  name                  = "Run Octopus Deploy Runbook"
  process_id            = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process.process_progressive_deployment[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_run_octopus_deploy_runbook.step_template != null ? data.octopusdeploy_step_template.steptemplate_run_octopus_deploy_runbook.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_run_octopus_deploy_runbook[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_run_octopus_deploy_runbook.step_template != null ? data.octopusdeploy_step_template.steptemplate_run_octopus_deploy_runbook.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_run_octopus_deploy_runbook[0].version}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_prod_10.environments) != 0 ? data.octopusdeploy_environments.environment_prod_10.environments[0].id : octopusdeploy_environment.environment_prod_10[0].id}", "${length(data.octopusdeploy_environments.environment_prod_50.environments) != 0 ? data.octopusdeploy_environments.environment_prod_50.environments[0].id : octopusdeploy_environment.environment_prod_50[0].id}"]
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-octopus-deploy-runbook"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  depends_on            = [octopusdeploy_process_step.process_step_progressive_deployment_simulate_failure]
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "Run.Runbook.Waitforfinish" = "False"
        "Run.Runbook.CustomNotes.Toggle" = "False"
        "Run.Runbook.Project.Name" = "#{Octopus.Project.Name}"
        "Run.Runbook.CancelInSeconds" = "1800"
        "Run.Runbook.UsePublishedSnapShot" = "False"
        "Run.Runbook.AutoApproveManualInterventions" = "No"
        "Run.Runbook.Api.Key" = "#{Project.Octopus.Api.Key}"
        "Run.Runbook.Base.Url" = "#{Octopus.Web.ServerUri}"
        "Run.Runbook.PromptedVariables" = "Project.Release.Id::#{Octopus.Release.Id}"
        "Run.Runbook.Machines" = "N/A"
        "Run.Runbook.Space.Name" = "#{Octopus.Space.Name}"
        "Run.Runbook.DateTime" = "N/A"
        "Run.Runbook.ManualIntervention.EnvironmentToUse" = "#{Octopus.Environment.Name}"
        "Run.Runbook.Environment.Name" = "#{if Octopus.Environment.Name == \"Prod 10\"}Prod 50#{/if}#{if Octopus.Environment.Name == \"Prod 50\"}Prod 100#{/if}"
        "Run.Runbook.Name" = "Deploy Release"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_progressive_deployment" {
  count      = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process.process_progressive_deployment[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process_step.process_step_progressive_deployment_deploy_app[0].id}", "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process_step.process_step_progressive_deployment_simulate_failure[0].id}", "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_progressive_deployment_run_octopus_deploy_runbook[0].id}"]
}

resource "octopusdeploy_variable" "progressive_deployment_project_release_id_1" {
  count        = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) == 0 ?octopusdeploy_project.project_progressive_deployment[0].id : data.octopusdeploy_projects.project_progressive_deployment.projects[0].id}"
  name         = "Project.Release.Id"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
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

resource "octopusdeploy_variable" "progressive_deployment_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) == 0 ?octopusdeploy_project.project_progressive_deployment[0].id : data.octopusdeploy_projects.project_progressive_deployment.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  name         = "Project.WorkerPool"
  type         = "WorkerPool"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "progressive_deployment_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) == 0 ?octopusdeploy_project.project_progressive_deployment[0].id : data.octopusdeploy_projects.project_progressive_deployment.projects[0].id}"
  name            = "Project.Octopus.Api.Key"
  type            = "Sensitive"
  is_sensitive    = true
  sensitive_value = "Change Me!"
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "progressive_deployment_project_simulatefail_1" {
  count        = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) == 0 ?octopusdeploy_project.project_progressive_deployment[0].id : data.octopusdeploy_projects.project_progressive_deployment.projects[0].id}"
  value        = "False"
  name         = "Project.SimulateFail"
  type         = "String"
  description  = "Enable this variable to simulate a failure"
  is_sensitive = false

  prompt {
    description = "Enable this variable to simulate a failure"
    label       = ""
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_process" "process_progressive_deployment_deploy_release" {
  count      = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? data.octopusdeploy_projects.project_progressive_deployment.projects[0].id : octopusdeploy_project.project_progressive_deployment[0].id}"
  runbook_id = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_runbook.runbook_progressive_deployment_deploy_release[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_progressive_deployment_deploy_release_sleep" {
  count                 = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  name                  = "Sleep"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process.process_progressive_deployment_deploy_release[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This sleep step allows the deployment to succeed in the current environment before initiating the release to a new environment."
  package_requirement   = "LetOctopusDecide"
  slug                  = "sleep"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = <<EOT
Start-Sleep 60

# -----------------------------------------------------------------------------
# Octopus Context Variables (Automatically Populated)
# -----------------------------------------------------------------------------
$OctopusUrl    = $OctopusParameters["Octopus.Web.ServerUri"]
$ApiKey        = $OctopusParameters["Project.Octopus.Api.Key"]       
$SpaceId       = $OctopusParameters["Octopus.Space.Id"]
$ProjectId     = $OctopusParameters["Octopus.Project.Id"]
$ReleaseId     = $OctopusParameters["Project.Release.Id"]
$TargetEnvId = $OctopusParameters["Octopus.Environment.Id"]  

# -----------------------------------------------------------------------------
# Script Execution
# -----------------------------------------------------------------------------
$ErrorActionPreference = "Stop"

# Define API headers using the native Octopus context
$Headers = @{ 
    "X-Octopus-ApiKey" = $ApiKey 
    "Content-Type"     = "application/json"
}

# 1. Formulate the Deployment Payload
$DeploymentBody = @{
    ReleaseId     = $ReleaseId
    EnvironmentId = $TargetEnvId
    Comments      = "Chained deployment triggered automatically from Task $($OctopusParameters['Octopus.Task.Id'])"
} | ConvertTo-Json -Depth 10

# 3. Fire the deployment API POST command
Write-Host "Triggering deployment of current release to environment: $TargetEnvName ($TargetEnvId)..."
$DeploymentResult = Invoke-RestMethod -Uri "$OctopusUrl/api/$SpaceId/deployments" -Method Post -Headers $Headers -Body $DeploymentBody

# Output tracking logs directly into the Octopus Task Log
Write-Host "Deployment task successfully created!"
Write-Host "New Task Link: $OctopusUrl/app#/$SpaceId/tasks/$($DeploymentResult.TaskId)"

EOT
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_progressive_deployment_deploy_release" {
  count      = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process.process_progressive_deployment_deploy_release[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? null : octopusdeploy_process_step.process_step_progressive_deployment_deploy_release_sleep[0].id}"]
}

variable "runbook_progressive_deployment_deploy_release_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Deploy Release"
  default     = "Deploy Release"
}
resource "octopusdeploy_runbook" "runbook_progressive_deployment_deploy_release" {
  count                       = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_progressive_deployment_deploy_release_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? data.octopusdeploy_projects.project_progressive_deployment.projects[0].id : octopusdeploy_project.project_progressive_deployment[0].id}"
  environment_scope           = "Specified"
  environments                = ["${length(data.octopusdeploy_environments.environment_prod_50.environments) != 0 ? data.octopusdeploy_environments.environment_prod_50.environments[0].id : octopusdeploy_environment.environment_prod_50[0].id}", "${length(data.octopusdeploy_environments.environment_prod_100.environments) != 0 ? data.octopusdeploy_environments.environment_prod_100.environments[0].id : octopusdeploy_environment.environment_prod_100[0].id}"]
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = ""
  multi_tenancy_mode          = "Untenanted"

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

variable "project_progressive_deployment_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Progressive Deployment"
  default     = "Progressive Deployment"
}
variable "project_progressive_deployment_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Progressive Deployment"
  default     = ""
}
variable "project_progressive_deployment_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Progressive Deployment"
  default     = ""
}
variable "project_progressive_deployment_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Progressive Deployment"
  default     = ""
}
variable "project_progressive_deployment_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_progressive_deployment" {
  ids          = null
  partial_name = "${var.project_progressive_deployment_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_progressive_deployment" {
  count                                = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_progressive_deployment_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_progressive.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_progressive.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_progressive[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_progressive.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_progressive.project_groups[0].id : octopusdeploy_project_group.project_group_progressive[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_progressive_deployment_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_progressive_deployment_description_prefix}${var.project_progressive_deployment_description}${var.project_progressive_deployment_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_progressive_deployment" {
  count      = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_progressive_deployment.projects) != 0 ? data.octopusdeploy_projects.project_progressive_deployment.projects[0].id : octopusdeploy_project.project_progressive_deployment[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}


