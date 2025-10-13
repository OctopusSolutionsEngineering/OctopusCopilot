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

data "octopusdeploy_project_groups" "project_group_windows" {
  ids          = null
  partial_name = "${var.project_group_windows_name}"
  skip         = 0
  take         = 1
}
variable "project_group_windows_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Windows"
}
resource "octopusdeploy_project_group" "project_group_windows" {
  count = "${length(data.octopusdeploy_project_groups.project_group_windows.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_windows_name}"
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

data "octopusdeploy_environments" "environment_security" {
  ids          = null
  partial_name = "Security"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_security" {
  count                        = "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? 0 : 1}"
  name                         = "Security"
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
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_test,octopusdeploy_environment.environment_production]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_devsecops" {
  ids          = null
  partial_name = "DevSecOps"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_devsecops" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? 0 : 1}"
  name        = "DevSecOps"
  description = "This lifecycle automatically deploys to the Development environment, progresses through the Test and Production environments, and then automatically deploys to the Security environment. The Security environment is used to scan SBOMs for any vulnerabilities and deployments to the Security environment are initiated by triggers on a daily basis."

  phase {
    automatic_deployment_targets          = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    optional_deployment_targets           = []
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
  phase {
    automatic_deployment_targets          = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
    optional_deployment_targets           = []
    name                                  = "Security"
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

data "octopusdeploy_channels" "channel_windows_service_default" {
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

data "octopusdeploy_feeds" "feed_octopus_maven_feed" {
  feed_type    = "Maven"
  ids          = null
  partial_name = "Octopus Maven Feed"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_maven_feed" "feed_octopus_maven_feed" {
  count                                = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? 0 : 1}"
  name                                 = "Octopus Maven Feed"
  feed_uri                             = "http://octopus-sales-public-maven-repo.s3-website-ap-southeast-2.amazonaws.com/snapshot"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

resource "octopusdeploy_process" "process_windows_service" {
  count      = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? data.octopusdeploy_projects.project_windows_service.projects[0].id : octopusdeploy_project.project_windows_service[0].id}"
  depends_on = []
}

variable "project_windows_service_step_deploy_a_windows_service_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Windows Service in project Windows Service"
  default     = "com.octopus:windowsservice"
}
resource "octopusdeploy_process_step" "process_step_windows_service_deploy_a_windows_service" {
  count                 = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Windows Service"
  type                  = "Octopus.WindowsService"
  process_id            = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? null : octopusdeploy_process.process_windows_service[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a Windows service."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_windows_service_step_deploy_a_windows_service_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-a-windows-service"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Windows-Service"
      }
  execution_properties  = {
        "Octopus.Action.WindowsService.ServiceName" = "JokeService"
        "Octopus.Action.EnabledFeatures" = ",Octopus.Features.WindowsService,Octopus.Features.ConfigurationTransforms,Octopus.Features.ConfigurationVariables"
        "Octopus.Action.WindowsService.StartMode" = "auto"
        "Octopus.Action.WindowsService.DesiredStatus" = "Default"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.WindowsService.CreateOrUpdateService" = "True"
        "Octopus.Action.WindowsService.Description" = "A sample windows service"
        "Octopus.Action.WindowsService.ExecutablePath" = "WindowsServiceDotNETCore.exe"
        "Octopus.Action.WindowsService.ServiceAccount" = "LocalSystem"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.WindowsService.DisplayName" = "Joke Service"
      }
}

resource "octopusdeploy_process_step" "process_step_windows_service_print_message_when_no_targets" {
  count                 = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  name                  = "Print Message when No Targets"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? null : octopusdeploy_process.process_windows_service[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step detects when the previous steps were skipped due to no targets being defined and prints a message with a link to documentation for creating targets."
  package_requirement   = "LetOctopusDecide"
  slug                  = "print-message-when-no-targets"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = "# The variable to check must be in the format\n# #{Octopus.Step[\u003cname of the step that deploys the web app\u003e].Status.Code}\nif (\"#{Octopus.Step[Deploy to IIS].Status.Code}\" -eq \"Abandoned\") {\n  Write-Highlight \"To complete the deployment you must have a Windows target with the tag 'Windows-Service'.\"\n  Write-Highlight \"We recommend the [Polling Tentacle](https://octopus.com/docs/infrastructure/deployment-targets/tentacle/tentacle-communication).\"\n}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
}

variable "project_windows_service_step_scan_for_vulnerabilities_package_webapp_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named webapp from step Scan for Vulnerabilities in project Windows Service"
  default     = "com.octopus:windowsservice"
}
resource "octopusdeploy_process_step" "process_step_windows_service_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? null : octopusdeploy_process.process_windows_service[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step extracts the application package, finds any bom.json files, and scans them for vulnerabilities using Trivy. \n\nThis step is expected to be run with each deployment to ensure vulnerabilities are discovered as early as possible. \n\nIt is also run daily via a project trigger that reruns the deployment in the Security environment. This allows unknown vulnerabilities to be discovered after a production deployment."
  package_requirement   = "LetOctopusDecide"
  packages              = { webapp = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_windows_service_step_scan_for_vulnerabilities_package_webapp_packageid}", properties = { Extract = "True", Purpose = "", SelectionMode = "immediate" } } }
  slug                  = "scan-for-vulnerabilities"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/DirectorySbomScan.ps1"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_windows_service" {
  count      = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? null : octopusdeploy_process.process_windows_service[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? null : octopusdeploy_process_step.process_step_windows_service_deploy_a_windows_service[0].id}", "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? null : octopusdeploy_process_step.process_step_windows_service_print_message_when_no_targets[0].id}", "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? null : octopusdeploy_process_step.process_step_windows_service_scan_for_vulnerabilities[0].id}"]
}

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_variable" "windows_service_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_windows_service.projects) == 0 ?octopusdeploy_project.project_windows_service[0].id : data.octopusdeploy_projects.project_windows_service.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : null}"
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

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_windows_service_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = ""
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? data.octopusdeploy_projects.project_windows_service.projects[0].id : octopusdeploy_project.project_windows_service[0].id}"
  tenant_ids  = []

  once_daily_schedule {
    start_time   = "2025-05-12T09:00:00"
    days_of_week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  }

  deploy_latest_release_action {
    source_environment_id      = "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"
    destination_environment_id = "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"
    should_redeploy            = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

variable "project_windows_service_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Windows Service"
  default     = "Windows Service"
}
variable "project_windows_service_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Windows Service"
  default     = ""
}
variable "project_windows_service_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Windows Service"
  default     = ""
}
variable "project_windows_service_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Windows Service"
  default     = "This project deploys a service to a Windows target."
}
variable "project_windows_service_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_windows_service" {
  ids          = null
  partial_name = "${var.project_windows_service_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_windows_service" {
  count                                = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_windows_service_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_windows.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_windows.project_groups[0].id : octopusdeploy_project_group.project_group_windows[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_windows_service_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_windows_service_description_prefix}${var.project_windows_service_description}${var.project_windows_service_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_windows_service" {
  count      = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_windows_service.projects) != 0 ? data.octopusdeploy_projects.project_windows_service.projects[0].id : octopusdeploy_project.project_windows_service[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


