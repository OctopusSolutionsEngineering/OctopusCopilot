provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeployLabs/octopusdeploy", version = "0.43.0" }
  }
  required_version = ">= 1.6.0"
}

variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
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
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a lifecycle called \"Default Lifecycle\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.lifecycles) != 0
    }
  }
}

data "octopusdeploy_channels" "channel_iis_default" {
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

variable "project_iis_step_deploy_to_iis_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy to IIS in project IIS"
  default     = "com.octopus:octopub-frontend"
}
variable "project_iis_step_scan_for_vulnerabilities_package_webapp_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named webapp from step Scan for Vulnerabilities in project IIS"
  default     = "com.octopus:octopub-frontend"
}
resource "octopusdeploy_deployment_process" "deployment_process_iis" {
  count      = "${length(data.octopusdeploy_projects.project_iis.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_iis.projects) != 0 ? data.octopusdeploy_projects.project_iis.projects[0].id : octopusdeploy_project.project_iis[0].id}"

  step {
    condition           = "Success"
    name                = "Deploy to IIS"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.IIS"
      name                               = "Deploy to IIS"
      notes                              = "This step deploys a website to IIS"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.IISWebSite.EnableAnonymousAuthentication" = "True"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.StartWebSite" = "True"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.IISWebSite.EnableWindowsAuthentication" = "False"
        "Octopus.Action.IISWebSite.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.IISWebSite.ApplicationPoolName" = "WebApps"
        "Octopus.Action.IISWebSite.WebSiteName" = "MyWebApp"
        "Octopus.Action.IISWebSite.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.WebRootType" = "packageRoot"
        "Octopus.Action.IISWebSite.CreateOrUpdateWebSite" = "True"
        "Octopus.Action.IISWebSite.DeploymentType" = "webSite"
        "Octopus.Action.IISWebSite.StartApplicationPool" = "True"
        "Octopus.Action.IISWebSite.Bindings" = jsonencode([
        {
        "port" = "80"
        "host" = ""
        "thumbprint" = null
        "certificateVariable" = null
        "requireSni" = "False"
        "enabled" = "True"
        "protocol" = "http"
                },
        ])
        "Octopus.Action.IISWebSite.EnableBasicAuthentication" = "False"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
      }
      environments                       = []
      excluded_environments              = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_iis_step_deploy_to_iis_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.IISWebSite", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.ConfigurationVariables"]
    }

    properties   = {}
    target_roles = ["OctoPub-Windows-IIS"]
  }
  step {
    condition           = "Success"
    name                = "Print Message when No Targets"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Print Message when No Targets"
      notes                              = "This step detects when the previous steps were skipped due to no targets being defined and prints a message with a link to documentation for creating targets."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_variable               = "Project.WorkerPool"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "# The variable to check must be in the format\n# #{Octopus.Step[\u003cname of the step that deploys the web app\u003e].Status.Code}\nif (\"#{Octopus.Step[Deploy to IIS].Status.Code}\" -eq \"Abandoned\") {\n  Write-Highlight \"To complete the deployment you must have a Windows target with the tag 'Octopub-Windows-IIS'.\"\n  Write-Highlight \"We recommend the [Polling Tentacle](https://octopus.com/docs/infrastructure/deployment-targets/tentacle/tentacle-communication).\"\n}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
      environments                       = []
      excluded_environments              = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
      channels                           = []
      tenant_tags                        = []
      features                           = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Scan for Vulnerabilities"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Scan for Vulnerabilities"
      notes                              = "This step extracts the application package, finds any bom.json files, and scans them for vulnerabilities using Trivy. \n\nThis step is expected to be run with each deployment to ensure vulnerabilities are discovered as early as possible. \n\nIt is also run daily via a project trigger that reruns the deployment in the Security environment. This allows unknown vulnerabilities to be discovered after a production deployment."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_variable               = "Project.WorkerPool"
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/DirectorySbomScan.ps1"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      package {
        name                      = "webapp"
        package_id                = "${var.project_iis_step_scan_for_vulnerabilities_package_webapp_packageid}"
        acquisition_location      = "Server"
        extract_during_deployment = false
        feed_id                   = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties                = { Extract = "True", Purpose = "", SelectionMode = "immediate" }
      }
      features = []

      git_dependency {
        repository_uri      = "https://github.com/OctopusSolutionsEngineering/Octopub.git"
        default_branch      = "main"
        git_credential_type = "Anonymous"
        git_credential_id   = ""
      }
    }

    properties   = {}
    target_roles = []
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

resource "octopusdeploy_variable" "iis_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_iis.projects) == 0 ?octopusdeploy_project.project_iis[0].id : data.octopusdeploy_projects.project_iis.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
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

data "octopusdeploy_projects" "projecttrigger_iis_daily_security_scan" {
  ids          = null
  partial_name = "IIS"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_iis_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.projecttrigger_iis_daily_security_scan.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = ""
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_iis.projects) != 0 ? data.octopusdeploy_projects.project_iis.projects[0].id : octopusdeploy_project.project_iis[0].id}"
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

variable "project_iis_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from IIS"
  default     = "IIS"
}
variable "project_iis_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project IIS"
  default     = ""
}
variable "project_iis_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project IIS"
  default     = ""
}
variable "project_iis_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from IIS"
  default     = "This project deploys an IIS web application to a Windows target."
}
variable "project_iis_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_iis" {
  ids          = null
  partial_name = "${var.project_iis_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_iis" {
  count                                = "${length(data.octopusdeploy_projects.project_iis.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_iis_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_windows.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_windows.project_groups[0].id : octopusdeploy_project_group.project_group_windows[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_iis_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
  }
  description = "${var.project_iis_description_prefix}${var.project_iis_description}${var.project_iis_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


