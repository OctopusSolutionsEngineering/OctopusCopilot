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

data "octopusdeploy_project_groups" "project_group_demo_apps_cloud" {
  ids          = null
  partial_name = "${var.project_group_demo_apps_cloud_name}"
  skip         = 0
  take         = 1
}
variable "project_group_demo_apps_cloud_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Demo Apps Cloud"
}
resource "octopusdeploy_project_group" "project_group_demo_apps_cloud" {
  count = "${length(data.octopusdeploy_project_groups.project_group_demo_apps_cloud.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_demo_apps_cloud_name}"
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

data "octopusdeploy_channels" "channel_azure_function_demo_default" {
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

variable "project_azure_function_demo_step_deploy_accept_message_azure_function___staging_slot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy accept_message Azure Function - Staging Slot in project Azure Function Demo"
  default     = "com.octopus:OctopusSamples.accept-message"
}
variable "project_azure_function_demo_step_deploy_process_message_azure_app_service___staging_slot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy process_message Azure App Service - Staging Slot in project Azure Function Demo"
  default     = "com.octopus:OctopusSamples.process-message"
}
variable "project_azure_function_demo_step_deploy_accept_message_azure_function___production_slot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy accept_message Azure Function - Production Slot in project Azure Function Demo"
  default     = "com.octopus:OctopusSamples.accept-message"
}
variable "project_azure_function_demo_step_deploy_process_message_azure_app_service___production_slot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy process_message Azure App Service - Production Slot in project Azure Function Demo"
  default     = "com.octopus:OctopusSamples.process-message"
}
resource "octopusdeploy_deployment_process" "deployment_process_azure_function_demo" {
  project_id = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? data.octopusdeploy_projects.project_azure_function_demo.projects[0].id : octopusdeploy_project.project_azure_function_demo[0].id}"

  step {
    condition           = "Success"
    name                = "Verify setup"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Verify setup"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "# Define variables\n$errorCollection = @()\n\ntry\n{\n  $azureConfigured = $true\n\n  # Ensure Azure account is configured\n  Write-Host \"Verifying Azure Account has been configured ...\"\n\n  # Check the Azure Account properties\n  if ($OctopusParameters['Project.Azure.Account.SubscriptionNumber'] -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Subscription Number has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if ($OctopusParameters['Project.Azure.Account.Client'] -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Client Id has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if ($OctopusParameters['Project.Azure.Account.TenantId'] -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Tenant Id has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if ($OctopusParameters['Project.Azure.Account.Password'] -eq \"dummy\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Password has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if (-not $azureConfigured) {\n    $errorCollection += @(\"See the [documentation](https://octopus.com/docs/infrastructure/accounts/azure#azure-service-principal) for details on configuring an Azure Service Principal\")\n  }\n\n  Write-Host \"Checking to see if Project variables have been configured ...\"\n\n  # Check Project variables\n\n  if ($OctopusParameters['Project.Slack.Url'] -eq \"dummy\")\n  {\n    $errorCollection += @(\n      \"The project variable Project.Slack.Url has not been configured.\",\n      \"See the [Slack documentation](https://api.slack.com/messaging/webhooks) for details on configuraing a Slack webhook URL.\"  \n    )\n  }\n\n  if ($OctopusParameters['Project.Azure.Queue.ConnectionString'] -eq \"dummy\")\n  {\n    $errorCollection += @(\"The project variable Project.Azure.Queue.ConnectionString has not been updated, have you run the Create Infrastructure runbook?\")\n  }\n\n  if ($OctopusParameters['Project.Octopus.Api.Key'] -eq \"dummy\")\n  {\n    $errorCollection += @(\n      \"The project variable Project.Octopus.Api.Key has not been configured.\",\n      \"See the [Octopus documentation](https://octopus.com/docs/octopus-rest-api/how-to-create-an-api-key) for details on creating an API key.\"\n    )\n    throw \"The Api Key has not been configured, unable to proceed with checks!\"\n  }\n\n  Write-Host \"Checking for deployment targets ...\"\n\n  # Check to make sure targets have been created\n  if ([string]::IsNullOrWhitespace($OctopusParameters['Octopus.Web.ServerUri']))\n  {\n    $octopusUrl = $OctopusParameters['Octopus.Web.BaseUrl']\n  }\n  else\n  {\n    $octopusUrl = $OctopusParameters['Octopus.Web.ServerUri']\n  }\n  $apiKey = $OctopusParameters['Project.Octopus.Api.Key']\n  $spaceId = $OctopusParameters['Octopus.Space.Id']\n  $headers = @{\"X-Octopus-ApiKey\"=\"$apiKey\"}\n\n  $azureFunctionTargets = Invoke-RestMethod -Method Get -Uri \"$octopusUrl/api/$spaceId/machines?roles=accept-message,process-message\" -Headers $headers\n  \n  if ($azureFunctionTargets.Items.Count -lt 2)\n  {\n    $errorCollection += @(\"Expected 2 targets, one for the accept-message role and one for the process-message role, but found $($azureFunctionTargets.Items.Count).  Have you run the Create Infrastructure runbook?\")\n  }\n}\ncatch\n{\n  Write-Verbose \"Fatal error occurred:\"\n  Write-Verbose \"$($_.Exception.Message)\"\n}\nfinally\n{\n  # Check to see if any errors were recorded\n  if ($errorCollection.Count -gt 0)\n  {\n    # Display the messages\n    Write-Highlight \"$($errorCollection -join \"`r`n\")\"\n  }\n  else\n  {\n    Write-Host \"All checks succeeded!\"\n  }\n}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
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
  step {
    condition           = "Success"
    name                = "Deploy accept_message Azure Function - Staging Slot"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureAppService"
      name                               = "Deploy accept_message Azure Function - Staging Slot"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Azure.DeploymentType" = "Package"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.DeploymentSlot" = "staging"
        "Octopus.Action.Azure.AppSettings" = jsonencode([
        {
        "name" = "AZURE_STORAGE_CONNECTION_STRING"
        "value" = "#{Project.Azure.Queue.ConnectionString}"
        "slotSetting" = "false"
                },
        {
        "name" = "QUEUE_NAME"
        "value" = "#{Project.Queue.Name}"
        "slotSetting" = "false"
                },
        ])
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_azure_function_demo_step_deploy_accept_message_azure_function___staging_slot_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["Octopus.Features.JsonConfigurationVariables", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["accept-message"]
  }
  step {
    condition           = "Success"
    name                = "Deploy process_message Azure App Service - Staging Slot"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureAppService"
      name                               = "Deploy process_message Azure App Service - Staging Slot"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.DeploymentSlot" = "staging"
        "Octopus.Action.Azure.AppSettings" = jsonencode([
        {
        "name" = "SlackUrl"
        "value" = "#{Project.Slack.Url}"
        "slotSetting" = "false"
                },
        {
        "slotSetting" = "false"
        "name" = "SlackChannel"
        "value" = "#{Project.Slack.Channel}"
                },
        ])
        "Octopus.Action.Azure.DeploymentType" = "Package"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_azure_function_demo_step_deploy_process_message_azure_app_service___staging_slot_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["Octopus.Features.JsonConfigurationVariables", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["process-message"]
  }
  step {
    condition           = "Success"
    name                = "Manual approval"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Manual"
      name                               = "Manual approval"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties                         = {
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Please review the Staging slot for the function apps"
        "Octopus.Action.Manual.ResponsibleTeamIds" = "teams-everyone"
      }
      environments                       = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []
      features                           = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Deploy accept_message Azure Function - Production Slot"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureAppService"
      name                               = "Deploy accept_message Azure Function - Production Slot"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Azure.DeploymentSlot" = "production"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.DeploymentType" = "Package"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.AppSettings" = jsonencode([
        {
        "name" = "AZURE_STORAGE_CONNECTION_STRING"
        "value" = "#{Project.Azure.Queue.ConnectionString}"
        "slotSetting" = "false"
                },
        {
        "name" = "QUEUE_NAME"
        "value" = "#{Project.Queue.Name}"
        "slotSetting" = "false"
                },
        ])
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_azure_function_demo_step_deploy_accept_message_azure_function___production_slot_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["Octopus.Features.JsonConfigurationVariables", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["accept-message"]
  }
  step {
    condition           = "Success"
    name                = "Deploy process_message Azure App Service - Production Slot"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureAppService"
      name                               = "Deploy process_message Azure App Service - Production Slot"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.DeploymentType" = "Package"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Azure.AppSettings" = jsonencode([
        {
        "name" = "SlackUrl"
        "value" = "#{Project.Slack.Url}"
        "slotSetting" = "false"
                },
        {
        "name" = "SlackChannel"
        "value" = "#{Project.Slack.Channel}"
        "slotSetting" = "false"
                },
        ])
        "Octopus.Action.Azure.DeploymentSlot" = "production"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_azure_function_demo_step_deploy_process_message_azure_app_service___production_slot_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["Octopus.Features.JsonConfigurationVariables", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["process-message"]
  }
  depends_on = []
}

variable "variable_b1265e86961e0e00b739c8f23b865191b557efcc80872944135dab94c81d19a9_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Queue.Name"
  default     = "octopusdeploy"
}
resource "octopusdeploy_variable" "azure_function_demo_project_queue_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_b1265e86961e0e00b739c8f23b865191b557efcc80872944135dab94c81d19a9_value}"
  name         = "Project.Queue.Name"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_6dfa5a8a0f8799a12f1d31a6721b1abd20001341a17205c5999bc9aea5276d1b_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Slack.Channel"
  default     = "random"
}
resource "octopusdeploy_variable" "azure_function_demo_project_slack_channel_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_6dfa5a8a0f8799a12f1d31a6721b1abd20001341a17205c5999bc9aea5276d1b_value}"
  name         = "Project.Slack.Channel"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_5311a1596189415f94649d3af13af5b905c75d8b8284ef60d12bf36a9949be36_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Location"
  default     = "canadacentral"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_location_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_5311a1596189415f94649d3af13af5b905c75d8b8284ef60d12bf36a9949be36_value}"
  name         = "Project.Azure.Location"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_279ce87ec8dce873a931fff855044aeaa68a7322bbb4af2cb717beebc85d555b_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Process-Message.OS"
  default     = "Windows"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_process_message_os_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_279ce87ec8dce873a931fff855044aeaa68a7322bbb4af2cb717beebc85d555b_value}"
  name         = "Project.Azure.Function.Process-Message.OS"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_40b659ece9fb7672267c8233068236eba69b968e9cd8fc65ee1134471de925c1_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Accept-Message.OS"
  default     = "Windows"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_accept_message_os_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_40b659ece9fb7672267c8233068236eba69b968e9cd8fc65ee1134471de925c1_value}"
  name         = "Project.Azure.Function.Accept-Message.OS"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_59f58221260a7583d34d305bc65c9fde838099dcc843ebf4ff55af9b7d5e0930_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Accept-Message.Version"
  default     = "4"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_accept_message_version_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_59f58221260a7583d34d305bc65c9fde838099dcc843ebf4ff55af9b7d5e0930_value}"
  name         = "Project.Azure.Function.Accept-Message.Version"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_5dc79ed48513b373bdba5476507cde505137cfd7a037c28c34f00d9f1f216df8_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Accept-Message.Runtime"
  default     = "node"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_accept_message_runtime_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_5dc79ed48513b373bdba5476507cde505137cfd7a037c28c34f00d9f1f216df8_value}"
  name         = "Project.Azure.Function.Accept-Message.Runtime"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_61d1dd1eabc07fa97e041a462f9047e9f467b3704241abfecd5dd57430bc91a9_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Process-Message.Version"
  default     = "4"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_process_message_version_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_61d1dd1eabc07fa97e041a462f9047e9f467b3704241abfecd5dd57430bc91a9_value}"
  name         = "Project.Azure.Function.Process-Message.Version"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_6e27ff4a889981d031f60cd0a65064486359f398d9df3bbfaf31d6bd7cb26e0a_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Process-Message.Runtime"
  default     = "dotnet"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_process_message_runtime_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_6e27ff4a889981d031f60cd0a65064486359f398d9df3bbfaf31d6bd7cb26e0a_value}"
  name         = "Project.Azure.Function.Process-Message.Runtime"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_412aa72e51cf8a4cefe165f35a02952018f36675775f8ac6d1af29bd34721280_sensitive_value" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable Project.Slack.Url"
  default     = "Change Me!"
}
resource "octopusdeploy_variable" "azure_function_demo_project_slack_url_1" {
  count           = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  name            = "Project.Slack.Url"
  type            = "Sensitive"
  is_sensitive    = true
  sensitive_value = var.variable_412aa72e51cf8a4cefe165f35a02952018f36675775f8ac6d1af29bd34721280_sensitive_value
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_environment" "environment_development" {
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
}

resource "octopusdeploy_environment" "environment_test" {
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
}

data "octopusdeploy_accounts" "account_octopussamples_azure_account" {
  ids          = null
  partial_name = "OctopusSamples Azure Account"
  skip         = 0
  take         = 1
  account_type = "AzureServicePrincipal"
}
resource "octopusdeploy_azure_service_principal" "account_octopussamples_azure_account" {
  count                             = "${length(data.octopusdeploy_accounts.account_octopussamples_azure_account.accounts) != 0 ? 0 : 1}"
  name                              = "OctopusSamples Azure Account"
  description                       = "This account was added to give the Octopus Samples projects an account to work with.  It is initially set with dummy values and will need to be configured."
  environments                      = ["${octopusdeploy_environment.environment_development.id}", "${octopusdeploy_environment.environment_test.id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  application_id                    = "00000000-0000-0000-0000-000000000000"
  password                          = "${var.account_octopussamples_azure_account}"
  subscription_id                   = "00000000-0000-0000-0000-000000000000"
  tenant_id                         = "00000000-0000-0000-0000-000000000000"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_octopussamples_azure_account" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Azure secret associated with the account OctopusSamples Azure Account"
  default     = "Change Me!"
}

resource "octopusdeploy_variable" "azure_function_demo_project_azure_account_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_octopussamples_azure_account.accounts) != 0 ? data.octopusdeploy_accounts.account_octopussamples_azure_account.accounts[0].id : octopusdeploy_azure_service_principal.account_octopussamples_azure_account[0].id}"
  name         = "Project.Azure.Account"
  type         = "AzureAccount"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_17294f014988bb0b5ac60d5df05478394bcbd467c6dab16d1ac4a3a771458a4f_sensitive_value" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable Project.Octopus.Api.Key"
  default     = "Change Me!"
}
resource "octopusdeploy_variable" "azure_function_demo_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  name            = "Project.Octopus.Api.Key"
  type            = "Sensitive"
  is_sensitive    = true
  sensitive_value = var.variable_17294f014988bb0b5ac60d5df05478394bcbd467c6dab16d1ac4a3a771458a4f_sensitive_value
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_51c044c15dc0b8e2bfd3fa80fb75a89d0e47f87f9fb4021ab6360fe941c7447e_sensitive_value" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable Project.Azure.Queue.ConnectionString"
  default     = "Change Me!"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_queue_connectionstring_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  name         = "Project.Azure.Queue.ConnectionString"
  type         = "Sensitive"
  is_sensitive = true

  scope {
    actions      = null
    channels     = null
    environments = ["${octopusdeploy_environment.environment_development.id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
  }
  sensitive_value = var.variable_51c044c15dc0b8e2bfd3fa80fb75a89d0e47f87f9fb4021ab6360fe941c7447e_sensitive_value
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_58302637156700682ac8076197e4d199e26df6761d8b021fe141e3308079eaaa_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.ResourceGroup.Name"
  default     = "Azure-Function-Development"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_resourcegroup_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_58302637156700682ac8076197e4d199e26df6761d8b021fe141e3308079eaaa_value}"
  name         = "Project.Azure.ResourceGroup.Name"
  type         = "String"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${octopusdeploy_environment.environment_development.id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_45045cca08ef6d30274d17c7575c621bd78f3c357de24140ca7d80fe1b24c9d1_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.ResourceGroup.Name"
  default     = "Azure-Function-Test"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_resourcegroup_name_2" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_45045cca08ef6d30274d17c7575c621bd78f3c357de24140ca7d80fe1b24c9d1_value}"
  name         = "Project.Azure.ResourceGroup.Name"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${octopusdeploy_environment.environment_test.id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_b504c66f6fc2b6d9d9a913dfb3b58a243bcebb8e84d10beb912c99ddc87b64f8_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.ResourceGroup.Name"
  default     = "Azure-Function-Production"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_resourcegroup_name_3" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_b504c66f6fc2b6d9d9a913dfb3b58a243bcebb8e84d10beb912c99ddc87b64f8_value}"
  name         = "Project.Azure.ResourceGroup.Name"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_5e8ab411a534f7a1d07ffb1f8253d73df0012b91170773d7e69e119cdfe235d9_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.StorageAccount.Name"
  default     = "azfunc#{Octopus.Environment.Name | ToLower}"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_storageaccount_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_5e8ab411a534f7a1d07ffb1f8253d73df0012b91170773d7e69e119cdfe235d9_value}"
  name         = "Project.Azure.StorageAccount.Name"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_b4f56b4f4c1b093fb105f467616c80cca39e92cf9dbdac296866e9fe32b17142_sensitive_value" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable Project.Azure.Queue.ConnectionString"
  default     = "Change Me!"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_queue_connectionstring_2" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  name         = "Project.Azure.Queue.ConnectionString"
  type         = "Sensitive"
  description  = ""
  is_sensitive = true

  scope {
    actions      = null
    channels     = null
    environments = ["${octopusdeploy_environment.environment_test.id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
  }
  sensitive_value = var.variable_b4f56b4f4c1b093fb105f467616c80cca39e92cf9dbdac296866e9fe32b17142_sensitive_value
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_5becf794f76509c2c5760df3d84d656608d31223173dcfe720a38a98d7461271_sensitive_value" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable Project.Azure.Queue.ConnectionString"
  default     = "Change Me!"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_queue_connectionstring_3" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  name         = "Project.Azure.Queue.ConnectionString"
  type         = "Sensitive"
  description  = ""
  is_sensitive = true

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
  }
  sensitive_value = var.variable_5becf794f76509c2c5760df3d84d656608d31223173dcfe720a38a98d7461271_sensitive_value
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_5c915e264ca69b81e07b74a9eb630edd0a7383d8b7574b2204ff82c9a649d7c0_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Accept-Message.Name"
  default     = "octo-accept-message-#{Octopus.Environment.Name | ToLower}"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_accept_message_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_5c915e264ca69b81e07b74a9eb630edd0a7383d8b7574b2204ff82c9a649d7c0_value}"
  name         = "Project.Azure.Function.Accept-Message.Name"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_b86758c2f39de20fbe4ab8712c174ca9fa602013498757d67e32287421f273ae_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Project.Azure.Function.Process-Message.Name"
  default     = "octo-process-message-#{Octopus.Environment.Name | ToLower}"
}
resource "octopusdeploy_variable" "azure_function_demo_project_azure_function_process_message_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) == 0 ?octopusdeploy_project.project_azure_function_demo[0].id : data.octopusdeploy_projects.project_azure_function_demo.projects[0].id}"
  value        = "${var.variable_b86758c2f39de20fbe4ab8712c174ca9fa602013498757d67e32287421f273ae_value}"
  name         = "Project.Azure.Function.Process-Message.Name"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_feeds" "feed_docker_hub" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "Docker Hub"
  skip         = 0
  take         = 1
}
variable "feed_docker_hub_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Docker Hub"
  default     = "Change Me!"
}
resource "octopusdeploy_docker_container_registry" "feed_docker_hub" {
  count                                = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? 0 : 1}"
  name                                 = "Docker Hub"
  password                             = "${var.feed_docker_hub_password}"
  registry_path                        = ""
  username                             = "mcasperson"
  api_version                          = ""
  feed_uri                             = "https://index.docker.io"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

resource "octopusdeploy_runbook_process" "runbook_process_create_infrastructure" {
  count      = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  runbook_id = "${length(data.octopusdeploy_projects.runbook_azure_function_demo_create_infrastructure.projects) != 0 ? null : octopusdeploy_runbook.runbook_azure_function_demo_create_infrastructure[0].id}"

  step {
    condition           = "Success"
    name                = "Verify setup"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Verify setup"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "# Define variables\n$errorCollection = @()\n\ntry\n{\n  # Ensure Azure account is configured\n  Write-Host \"Verifying Azure Account has been configured ...\"\n\n  # Check the Azure Account properties\n  if ($OctopusParameters['Project.Azure.Account.SubscriptionNumber'] -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Subscription Number has not been configured.\")\n  }\n\n  if ($OctopusParameters['Project.Azure.Account.Client'] -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Client Id has not been configured.\")\n  }\n\n  if ($OctopusParameters['Project.Azure.Account.TenantId'] -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Tenant Id has not been configured.\")\n  }\n\n  if ($OctopusParameters['Project.Azure.Account.Password'] -eq \"dummy\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Password has not been configured.\")\n  }\n\n  Write-Host \"Checking to see if Project variables have been configured ...\"\n\n  # Check Project variables\n\n  if ($OctopusParameters['Project.Slack.Url'] -eq \"dummy\")\n  {\n    $errorCollection += @(\"The project variable Project.Slack.Url has not been configured.\")\n  }\n\n  if ($OctopusParameters['Project.Azure.Queue.ConnectionString'] -eq \"dummy\")\n  {\n    $errorCollection += @(\"The project variable Project.Azure.Queue.ConnectionString has not been updated, have you run the Create Infrastructure runbook?\")\n  }\n\n  if ($OctopusParameters['Project.Octopus.Api.Key'] -eq \"dummy\")\n  {\n    $errorCollection += @(\"The project variable Project.Octopus.Api.Key has not been configured.\")\n    throw \"The Api Key has not been configured, unable to proceed with checks!\"\n  }\n\n  Write-Host \"Checking for deployment targets ...\"\n\n  # Check to make sure targets have been created\n  if ([string]::IsNullOrWhitespace($OctopusParameters['Octopus.Web.ServerUri']))\n  {\n    $octopusUrl = $OctopusParameters['Octopus.Web.BaseUrl']\n  }\n  else\n  {\n    $octopusUrl = $OctopusParameters['Octopus.Web.ServerUri']\n  }\n  $apiKey = $OctopusParameters['Project.Octopus.Api.Key']\n  $spaceId = $OctopusParameters['Octopus.Space.Id']\n  $headers = @{\"X-Octopus-ApiKey\"=\"$apiKey\"}\n\n  $azureFunctionTargets = Invoke-RestMethod -Method Get -Uri \"$octopusUrl/api/$spaceId/machines?roles=accept-message,process-message\" -Headers $headers\n  \n  if ($azureFunctionTargets.Items.Count -lt 2)\n  {\n    $errorCollection += @(\"Expected 2 targets, one for the accept-message role and one for the process-message role, but found $($azureFunctionTargets.Items.Count).  Have you run the Create Infrastructure runbook?\")\n  }\n\n}\ncatch\n{\n  Write-Warning \"Fatal error occurred:\"\n  Write-Warning \"$($_.Exception.Message)\"\n}\nfinally\n{\n  # Check to see if any errors were recorded\n  if ($errorCollection.Count -gt 0)\n  {\n    # Display the messages\n    Write-Error \"$($errorCollection -join \"`r`n\")\"\n  }\n  else\n  {\n    Write-Host \"All checks succeeded!\"\n  }\n}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
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
  step {
    condition           = "Success"
    name                = "Create Resource Group"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Create Resource Group"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$azureLocation = $OctopusParameters['Project.Azure.Location']\n\n# Create resourece group\nWrite-Host \"Creating resource group $resourceGroupName in $azureLocation...\"\naz group create --location $azureLocation --name $resourceGroupName"
        "OctopusUseBundledTooling" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
        image   = "octopusdeploy/worker-tools:ubuntu.22.04"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Create Storage Account"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Create Storage Account"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$storageAccountName = $OctopusParameters['Project.Azure.StorageAccount.Name']\n$queueName = $OctopusParameters['Project.Queue.Name']\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$azureLocation = $OctopusParameters['Project.Azure.Location']\n\n# Create Azure storage account\nWrite-Host \"Creating storage account ...\"\naz storage account create --name $storageAccountName --resource-group $resourceGroupName --location $azureLocation\n\n# Get account keys\n$accountKeys = (az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName) | ConvertFrom-JSON\n\n# Create Azure storage queue\nWrite-Host \"Creating queue ...\"\naz storage queue create --name $queueName --account-name $storageAccountName --account-key $accountKeys[0].Value"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
        image   = "octopusdeploy/worker-tools:ubuntu.22.04"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Create Accept-Message Function App"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Create Accept-Message Function App"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$appServiceName = $OctopusParameters['Project.Azure.Function.Accept-Message.Name']\n$appServiceRuntime = $OctopusParameters['Project.Azure.Function.Accept-Message.Runtime']\n#$appServicePlanName = $octopusParameters['Azure.AppServicePlan.Name']\n$storageAccountName = $OctopusParameters['Project.Azure.StorageAccount.Name']\n$osType = $OctopusParameters['Project.Azure.Function.Accept-Message.OS']\n$functionsVersion = [int]$OctopusParameters['Project.Azure.Function.Accept-Message.Version']\n$azureLocation = $OctopusParameters['Project.Azure.Location']\n$azureAccount = $OctopusParameters['Project.Azure.Account']\n\n# Fix ANSI Color on PWSH Core issues when displaying objects\nif ($PSEdition -eq \"Core\") {\n    $PSStyle.OutputRendering = \"PlainText\"\n}\n\n# Create App Service\nWrite-Host \"Creating Accept function app service ...\"\n$functionApp = (az functionapp create --name $appServiceName --consumption-plan-location $azureLocation --resource-group $resourceGroupName --runtime $appServiceRuntime --storage-account $storageAccountName --os-type $osType --functions-version $functionsVersion | ConvertFrom-Json)\n\n# Consumption plans are created automatically in the resource group, however, take a bit show up\n$planName = $functionApp.serverfarmId.SubString($functionApp.serverFarmId.LastIndexOf(\"/\") + 1)\n$functionAppPlans = (az functionapp plan list --resource-group $resourceGroupName | ConvertFrom-Json)\n\nWrite-Host \"Consumption based plans auto create and will sometimes take a bit to show up in the resource group, this loop will wait until it's available so the Slot creation doesn't fail ...\"\nwhile ($null -eq ($functionAppPlans | Where-Object {$_.Name -eq $planName}))\n{\n  Write-Host \"Waiting 10 seconds for app plan to show up ...\"\n  Start-Sleep -Seconds 10\n  $functionAppPlans = (az functionapp plan list --resource-group $resourceGroupName | ConvertFrom-Json)\n}\n\nWrite-Host \"It showed up!\"\n\n# Create deployment slots\nWrite-Host \"Creating deployment slots ...\"\naz functionapp deployment slot create --resource-group $resourceGroupName --name $appServiceName --slot \"staging\"\n\nWrite-Host \"Creating Octopus Azure Web App target for $appServiceName\"\nNew-OctopusAzureWebAppTarget -Name $appServiceName -AzureWebApp $appServiceName -AzureResourceGroupName $resourceGroupName -OctopusAccountIdOrName $azureAccount -OctopusRoles \"accept-message\" -updateIfExisting"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
        image   = "octopusdeploy/worker-tools:ubuntu.22.04"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Create Process-Message Function App"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Create Process-Message Function App"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$appServiceName = $OctopusParameters['Project.Azure.Function.Process-Message.Name']\n$appServiceRuntime = $OctopusParameters['Project.Azure.Function.Process-Message.Runtime']\n#$appServicePlanName = $octopusParameters['Azure.AppServicePlan.Name']\n$storageAccountName = $OctopusParameters['Project.Azure.StorageAccount.Name']\n$osType = $OctopusParameters['Project.Azure.Function.Process-Message.OS']\n#$functionsVersion = [int]$OctopusParameters['Project.Azure.Function.Process-Message.Version']\n$functionsVersion = $OctopusParameters['Project.Azure.Function.Process-Message.Version']\n$azureLocation = $OctopusParameters['Project.Azure.Location']\n$azureAccount = $OctopusParameters['Project.Azure.Account']\n\n# Fix ANSI Color on PWSH Core issues when displaying objects\nif ($PSEdition -eq \"Core\") {\n    $PSStyle.OutputRendering = \"PlainText\"\n}\n\n# Create App Service\nWrite-Host \"Creating Process function app service ...\"\n$functionApp = (az functionapp create --name $appServiceName --consumption-plan-location $azureLocation --resource-group $resourceGroupName --runtime $appServiceRuntime --storage-account $storageAccountName --os-type $osType --functions-version $functionsVersion | ConvertFrom-Json)\n\n# Create deployment slots\nWrite-Host \"Creating deployment slots ...\"\naz functionapp deployment slot create --resource-group $resourceGroupName --name $appServiceName --slot \"staging\"\n\nNew-OctopusAzureWebAppTarget -Name $appServiceName -AzureWebApp $appServiceName -AzureResourceGroupName $resourceGroupName -OctopusAccountIdOrName $azureAccount -OctopusRoles \"process-message\" -updateIfExisting"
        "OctopusUseBundledTooling" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
        image   = "octopusdeploy/worker-tools:ubuntu.22.04"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Update Storage Account Connection String"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Update Storage Account Connection String"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$storageAccountName = $OctopusParameters['Project.Azure.StorageAccount.Name']\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$apiKey = $OctopusParameters['Project.Octopus.Api.Key']\n$spaceId = $OctopusParameters['Octopus.Space.Id']\n$projectId = $OctopusParameters['Octopus.Project.Id']\n$environmentId = $OctopusParameters['Octopus.Environment.Id']\n$headers = @{\"X-Octopus-ApiKey\"=\"$apiKey\"}\n\nif ([String]::IsNullOrWhitespace($OctopusParameters['Octopus.Web.ServerUri']))\n{\n  $octopusUrl = $OctopusParameters['Octopus.Web.BaseUrl']\n}\nelse\n{\n  $octopusUrl = $OctopusParameters['Octopus.Web.ServerUri']\n}\n\n# Get the connection string\n$connectionstring = (az storage account show-connection-string --name $storageAccountName --resource-group $resourceGroupName)\n$connectionstring = ($connectionstring | ConvertFrom-Json)\n\n# Get variables for project\n$project = Invoke-RestMethod -Method Get -Uri \"$octopusUrl/api/$spaceId/projects/$projectId\" -Headers $headers\n$projectVariables = Invoke-RestMethod -Method Get -Uri \"$octopusurl/api/$($spaceId)/variables/$($project.VariableSetId)\" -Headers $headers\n\n# Get the connection string variable\n$connectionStringVariable = $projectVariables.Variables | Where-Object {$_.Name -eq \"Project.Azure.Queue.ConnectionString\"}\n\n# Update the value for the environment\n#$connectionStringVariable.Value = $connectionstring.connectionString\n($connectionStringVariable | Where-Object {$_.Scope.Environment -contains $environmentId}).Value = $connectionstring.connectionstring\nInvoke-RestMethod -Method Put -Uri \"$octopusurl/api/$($spaceId)/variables/$($project.VariableSetId)\" -Headers $headers -Body ($projectVariables | ConvertTo-Json -Depth 10)"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
        image   = "octopusdeploy/worker-tools:ubuntu.22.04"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  depends_on = []
}

data "octopusdeploy_projects" "runbook_azure_function_demo_create_infrastructure" {
  ids          = null
  partial_name = "Azure Function Demo"
  skip         = 0
  take         = 1
}
variable "runbook_azure_function_demo_create_infrastructure_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Create Infrastructure"
  default     = "Create Infrastructure"
}
resource "octopusdeploy_runbook" "runbook_azure_function_demo_create_infrastructure" {
  count                       = "${length(data.octopusdeploy_projects.runbook_azure_function_demo_create_infrastructure.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_azure_function_demo_create_infrastructure_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? data.octopusdeploy_projects.project_azure_function_demo.projects[0].id : octopusdeploy_project.project_azure_function_demo[0].id}"
  environment_scope           = "All"
  environments                = []
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "Creates the infrastructure necessary to support this Azure function:\n- Resource group\n- accept-message Function\n- process-message Function\n- Storage Account\n- Consumption-based App Service Plan"
  multi_tenancy_mode          = "Untenanted"

  retention_policy {
    quantity_to_keep = 100
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }
}

resource "octopusdeploy_runbook_process" "runbook_process_destroy_infrastructure" {
  count      = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  runbook_id = "${length(data.octopusdeploy_projects.runbook_azure_function_demo_destroy_infrastructure.projects) != 0 ? null : octopusdeploy_runbook.runbook_azure_function_demo_destroy_infrastructure[0].id}"

  step {
    condition           = "Success"
    name                = "Destroy resource group"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Destroy resource group"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$appAcceptServiceName = $OctopusParameters['Project.Azure.Function.Accept-Message.Name']\n$appProcessServiceName = $OctopusParameters['Project.Azure.Function.Process-Message.Name']\n$apiKey = $OctopusParameters['Project.Octopus.Api.Key']\n$spaceId = $OctopusParameters['Octopus.Space.Id']\n$environmentId = $OctopusParameters['Octopus.Environment.Id']\n$headers = @{\"X-Octopus-ApiKey\"=\"$apiKey\"}\n\nfunction Deregister-Target\n{\n  # Define parameters\n  param (\n    $ItemCollection\n  )\n\n  if ($ItemCollection.Items.Count -eq 1)\n  {\n    Write-Host \"Deregistering target $($ItemCollection.Items[0].Name)\"\n    Invoke-RestMethod -Method Delete -Uri \"$octopusUrl/api/$spaceId/machines/$($ItemCollection.Items[0].Id)\" -Headers $headers\n  }\n  else\n  {\n    Write-Warning \"Expected 1 target, but found $($ItemCollection.Items.Count).\"\n  }\n}\n\n# Fix ANSI Color on PWSH Core issues when displaying objects\nif ($PSEdition -eq \"Core\") {\n    $PSStyle.OutputRendering = \"PlainText\"\n}\n\nif ([String]::IsNullOrWhitespace($OctopusParameters['Octopus.Web.ServerUri']))\n{\n  $octopusUrl = $OctopusParameters['Octopus.Web.BaseUrl']\n}\nelse\n{\n  $octopusUrl = $OctopusParameters['Octopus.Web.ServerUri']\n}\n\n# Deregister targets\n$acceptTarget = Invoke-RestMethod -Method Get -Uri \"$octopusUrl/api/$spaceId/machines?name=$appAcceptServiceName\" -Headers $headers\n$processTarget = Invoke-RestMethod -Method Get -Uri \"$octopusUrl/api/$spaceId/machines?name=$appProcessServiceName\" -Headers $headers\nDeregister-Target -ItemCollection $acceptTarget\nDeregister-Target -ItemCollection $processTarget\n\n# Destroy the resource group\naz group delete --name $resourceGroupName --yes"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
        image   = "octopusdeploy/worker-tools:ubuntu.22.04"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  depends_on = []
}

data "octopusdeploy_projects" "runbook_azure_function_demo_destroy_infrastructure" {
  ids          = null
  partial_name = "Azure Function Demo"
  skip         = 0
  take         = 1
}
variable "runbook_azure_function_demo_destroy_infrastructure_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Destroy Infrastructure"
  default     = "Destroy Infrastructure"
}
resource "octopusdeploy_runbook" "runbook_azure_function_demo_destroy_infrastructure" {
  count                       = "${length(data.octopusdeploy_projects.runbook_azure_function_demo_destroy_infrastructure.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_azure_function_demo_destroy_infrastructure_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? data.octopusdeploy_projects.project_azure_function_demo.projects[0].id : octopusdeploy_project.project_azure_function_demo[0].id}"
  environment_scope           = "All"
  environments                = []
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "Destroys the Infrastructure for the Azure Functions:\n- Destroys Resource Group\n - This will remove all other resources for the Functions\n- Deregisters the Octopus Targets"
  multi_tenancy_mode          = "Untenanted"

  retention_policy {
    quantity_to_keep = 100
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }
}

variable "project_azure_function_demo_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Azure Function Demo"
  default     = "Azure Function Demo"
}
variable "project_azure_function_demo_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Azure Function Demo"
  default     = ""
}
variable "project_azure_function_demo_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Azure Function Demo"
  default     = ""
}
variable "project_azure_function_demo_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Azure Function Demo"
  default     = "Demo deploying an Azure Function."
}
variable "project_azure_function_demo_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_azure_function_demo" {
  ids          = null
  partial_name = "${var.project_azure_function_demo_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_azure_function_demo" {
  count                                = "${length(data.octopusdeploy_projects.project_azure_function_demo.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_azure_function_demo_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_demo_apps_cloud.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_demo_apps_cloud.project_groups[0].id : octopusdeploy_project_group.project_group_demo_apps_cloud[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_azure_function_demo_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
  }
  description = "${var.project_azure_function_demo_description_prefix}${var.project_azure_function_demo_description}${var.project_azure_function_demo_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


