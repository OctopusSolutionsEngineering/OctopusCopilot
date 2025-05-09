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

data "octopusdeploy_project_groups" "project_group_azure" {
  ids          = null
  partial_name = "${var.project_group_azure_name}"
  skip         = 0
  take         = 1
}
variable "project_group_azure_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Azure"
}
resource "octopusdeploy_project_group" "project_group_azure" {
  count       = "${length(data.octopusdeploy_project_groups.project_group_azure.project_groups) != 0 ? 0 : 1}"
  name        = "${var.project_group_azure_name}"
  description = ""
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

data "octopusdeploy_lifecycles" "lifecycle_security" {
  ids          = null
  partial_name = "Security"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_security" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_security.lifecycles) != 0 ? 0 : 1}"
  name        = "Security"
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

data "octopusdeploy_channels" "channel_azure_function_default" {
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

variable "project_azure_function_step_deploy_products_microservice_azurefunction_jvm_azure_function___staging_slot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy products-microservice-azurefunction-jvm Azure Function - Staging Slot in project Azure Function"
  default     = "com.octopus:products-microservice-azurefunction-jvm"
}
variable "project_azure_function_step_deploy_products_microservice_azurefunction_jvm_azure_function___production_slot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy products-microservice-azurefunction-jvm Azure Function - Production Slot in project Azure Function"
  default     = "com.octopus:products-microservice-azurefunction-jvm"
}
variable "project_azure_function_step_scan_for_vulnerabilities_package_products_microservice_azurefunction_jvm_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named products-microservice-azurefunction-jvm from step Scan for Vulnerabilities in project Azure Function"
  default     = "com.octopus:products-microservice-azurefunction-jvm"
}
resource "octopusdeploy_deployment_process" "deployment_process_azure_function" {
  count      = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? data.octopusdeploy_projects.project_azure_function.projects[0].id : octopusdeploy_project.project_azure_function[0].id}"

  step {
    condition           = "Success"
    name                = "Validate setup"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Validate setup"
      notes                              = "This step detects any default values that must be updated before a deployment to Azure can be performed."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptBody" = "# Define variables\n$errorCollection = @()\n\ntry\n{\n  $azureConfigured = $true\n\n  # Ensure Azure account is configured\n  Write-Host \"Verifying Azure Account has been configured ...\"\n\n  # Check the Azure Account properties\n  if (\"#{Project.Azure.Account.SubscriptionNumber}\" -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Subscription Number has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if (\"#{Project.Azure.Account.Client}\" -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Client Id has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if (\"#{Project.Azure.Account.TenantId}\" -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Tenant Id has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if (\"#{Project.Azure.Account.Password}\" -eq \"CHANGE ME\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Password has not been configured.\")\n    $azureConfigured = $false\n  }\n\n  if (-not $azureConfigured) {\n    $errorCollection += @(\"See the [documentation](https://octopus.com/docs/infrastructure/accounts/azure#azure-service-principal) for details on configuring an Azure Service Principal\")\n  }\n\n  Write-Host \"Checking to see if Project variables have been configured ...\"\n\n  if (\"#{Project.Octopus.Api.Key}\" -eq \"CHANGE ME\")\n  {\n    $errorCollection += @(\n      \"The project variable Project.Octopus.Api.Key has not been configured.\",\n      \"See the [Octopus documentation](https://octopus.com/docs/octopus-rest-api/how-to-create-an-api-key) for details on creating an API key.\"\n    )\n    throw \"The Api Key has not been configured, unable to proceed with checks!\"\n  }\n\n  Write-Host \"Checking for deployment targets ...\"\n\n  # Check to make sure targets have been created\n  if ([string]::IsNullOrWhitespace(\"#{Octopus.Web.ServerUri}\"))\n  {\n    $octopusUrl = \"#{Octopus.Web.BaseUrl}\"\n  }\n  else\n  {\n    $octopusUrl = \"#{Octopus.Web.ServerUri}\"\n  }\n  $apiKey = \"#{Project.Octopus.Api.Key}\"\n  $spaceId = \"#{Octopus.Space.Id}\"\n  $headers = @{\"X-Octopus-ApiKey\"=\"$apiKey\"}\n\n  $azureFunctionTargets = Invoke-RestMethod -Method Get -Uri \"$octopusUrl/api/$spaceId/machines?roles=Octopub-Products-Function\" -Headers $headers\n  \n  if ($azureFunctionTargets.Items.Count -lt 1)\n  {\n    $errorCollection += @(\"Expected 1 targets for role Octopub-Products-Function, but found $($azureFunctionTargets.Items.Count).  Have you run the Create Infrastructure runbook?\")\n  }\n}\ncatch\n{\n  Write-Verbose \"Fatal error occurred:\"\n  Write-Verbose \"$($_.Exception.Message)\"\n}\nfinally\n{\n  # Check to see if any errors were recorded\n  if ($errorCollection.Count -gt 0)\n  {\n    # Display the messages\n    Write-Highlight \"$($errorCollection -join \"`r`n\")\"\n  }\n  else\n  {\n    Write-Host \"All checks succeeded!\"\n  }\n}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
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
    name                = "Deploy products-microservice-azurefunction-jvm Azure Function - Staging Slot"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureAppService"
      name                               = "Deploy products-microservice-azurefunction-jvm Azure Function - Staging Slot"
      notes                              = "This step deploys the web app to the staging slot."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.DeploymentType" = "Package"
        "Octopus.Action.Azure.DeploymentSlot" = "staging"
      }
      environments                       = []
      excluded_environments              = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_azure_function_step_deploy_products_microservice_azurefunction_jvm_azure_function___staging_slot_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["Octopus.Features.JsonConfigurationVariables", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["Octopub-Products-Function"]
  }
  step {
    condition           = "Success"
    name                = "Manual approval"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Manual"
      name                               = "Manual approval"
      notes                              = "A production deployment must be approved before deploying to the production Web App slot."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties                         = {
        "Octopus.Action.Manual.Instructions" = "Please review the Staging slot for the function apps"
        "Octopus.Action.Manual.ResponsibleTeamIds" = "teams-managers"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
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
    name                = "Deploy products-microservice-azurefunction-jvm Azure Function - Production Slot"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureAppService"
      name                               = "Deploy products-microservice-azurefunction-jvm Azure Function - Production Slot"
      notes                              = "The web app is deployed to the production azure web app slot."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.DeploymentType" = "Package"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
      environments                       = []
      excluded_environments              = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_azure_function_step_deploy_products_microservice_azurefunction_jvm_azure_function___production_slot_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["Octopus.Features.JsonConfigurationVariables", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["Octopub-Products-Function"]
  }
  step {
    condition           = "Success"
    name                = "Scan for Vulnerabilities"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Scan for Vulnerabilities"
      notes                              = "This step extracts the Docker image, finds any bom.json files, and scans them for vulnerabilities using Trivy. \n\nThis step is expected to be run with each deployment to ensure vulnerabilities are discovered as early as possible. \n\nIt is also run daily via a project trigger that reruns the deployment in the Security environment. This allows unknown vulnerabilities to be discovered after a production deployment."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
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
        name                      = "products-microservice-azurefunction-jvm"
        package_id                = "${var.project_azure_function_step_scan_for_vulnerabilities_package_products_microservice_azurefunction_jvm_packageid}"
        acquisition_location      = "ExecutionTarget"
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

resource "octopusdeploy_variable" "azure_function_project_azure_function_octopub_products_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "octopub-products-#{Octopus.Environment.Name | ToLower}"
  name         = "Project.Azure.Function.Octopub.Products.Name"
  type         = "String"
  description  = "The name of the Azure Function App to create or deploy to."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "azure_function_project_azure_resourcegroup_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "Octopub-Products-Function-Development"
  name         = "Project.Azure.ResourceGroup.Name"
  type         = "String"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
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

resource "octopusdeploy_variable" "azure_function_project_azure_function_octopub_products_os_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "Windows"
  name         = "Project.Azure.Function.Octopub.Products.OS"
  type         = "String"
  description  = "The Operating System (OS) to use to execute the Azure Function."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "azure_function_project_azure_function_octopub_products_runtime_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "java"
  name         = "Project.Azure.Function.Octopub.Products.Runtime"
  type         = "String"
  description  = "The runtime the Azure Function needs to execute.  See list (https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#functions_worker_runtime) for supported Runtimes."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "azure_function_project_azure_function_octopub_products_version_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "4"
  name         = "Project.Azure.Function.Octopub.Products.Version"
  type         = "String"
  description  = "The Runtime Target version, the value of 4 is the stable release."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "azure_function_project_azure_location_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "canadacentral"
  name         = "Project.Azure.Location"
  type         = "String"
  description  = "The Azure Location to create the resources in."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "azure_function_project_azure_storageaccount_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "octopub#{Octopus.Environment.Name | ToLower}"
  name         = "Project.Azure.StorageAccount.Name"
  type         = "String"
  description  = "The name of the Azure Storage Account to create.  Must be unique within your subscription."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
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
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
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

resource "octopusdeploy_variable" "azure_function_project_azure_account_1" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_octopussamples_azure_account.accounts) != 0 ? data.octopusdeploy_accounts.account_octopussamples_azure_account.accounts[0].id : octopusdeploy_azure_service_principal.account_octopussamples_azure_account[0].id}"
  name         = "Project.Azure.Account"
  type         = "AzureAccount"
  description  = "The Azure Account to use to authenticate to Azure."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "azure_function_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  name            = "Project.Octopus.Api.Key"
  type            = "Sensitive"
  description     = "The Octopus API Key used to make API calls to the Octopus Server."
  is_sensitive    = true
  sensitive_value = "Change Me!"
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "azure_function_project_azure_resourcegroup_name_2" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "Octopub-Products-Function-Test"
  name         = "Project.Azure.ResourceGroup.Name"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
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

resource "octopusdeploy_variable" "azure_function_project_azure_resourcegroup_name_3" {
  count        = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_azure_function.projects) == 0 ?octopusdeploy_project.project_azure_function[0].id : data.octopusdeploy_projects.project_azure_function.projects[0].id}"
  value        = "Octopub-Products-Function-Production"
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

data "octopusdeploy_feeds" "feed_ghcr_anonymous" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "GHCR Anonymous"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_docker_container_registry" "feed_ghcr_anonymous" {
  count                                = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? 0 : 1}"
  name                                 = "GHCR Anonymous"
  registry_path                        = ""
  api_version                          = "v2"
  feed_uri                             = "https://ghcrfacade-a6awccayfpcpg4cg.eastus-01.azurewebsites.net"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

resource "octopusdeploy_runbook_process" "runbook_process_create_infrastructure" {
  count      = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  runbook_id = "${length(data.octopusdeploy_projects.runbook_azure_function_create_infrastructure.projects) != 0 ? null : octopusdeploy_runbook.runbook_azure_function_create_infrastructure[0].id}"

  step {
    condition           = "Success"
    name                = "Validate Setup"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Validate Setup"
      notes                              = "This step detects any default values tha must be updated before runbook can create Azure resources."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "# Define variables\n$errorCollection = @()\n$setupValid = $false\n\ntry\n{\n  # Ensure Azure account is configured\n  Write-Host \"Verifying Azure Account has been configured ...\"\n\n  # Check the Azure Account properties\n  if (\"#{Project.Azure.Account.SubscriptionNumber}\" -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Subscription Number has not been configured.\")\n  }\n\n  if (\"#{Project.Azure.Account.Client}\" -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Client Id has not been configured.\")\n  }\n\n  if (\"#{Project.Azure.Account.TenantId}\" -eq \"00000000-0000-0000-0000-000000000000\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Tenant Id has not been configured.\")\n  }\n\n  if (\"#{Project.Azure.Account.Password}\" -eq \"CHANGE ME\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The Azure Account Password has not been configured.\")\n  }\n\n  if ($errorCollection.Count -gt 0)\n  {\n    foreach ($item in $errorCollection)\n    {\n      Write-Highlight \"$item\"\n    }\n  }\n  else\n  {\n    $setupValid = $true\n    Write-Host \"Setup valid!\"\n  }\n\n  Set-OctopusVariable -Name SetupValid -Value $setupValid\n}\ncatch\n{\n  Write-Warning \"Fatal error occurred:\"\n  Write-Warning \"$($_.Exception.Message)\"\n}\n\u003c#finally\n{\n  # Check to see if any errors were recorded\n  if ($errorCollection.Count -gt 0)\n  {\n    # Display the messages\n    Write-Error \"$($errorCollection -join \"`n\")\"\n  }\n  else\n  {\n    Write-Host \"All checks succeeded!\"\n  }\n}#\u003e"
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
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate Setup].Output.SetupValid == \"True\"}true#{/if}#{/unless}"
    name                 = "Get Azure Access Token"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Get Azure Access Token"
      notes                              = "This step uses the Azure Account variable details to generate an Azure Access Token to be used in Azure API calls."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "# Construct json body\n$jsonPayload = @{\n  grant_type = \"client_credentials\"\n  client_id = \"#{Project.Azure.Account.Client}\"\n  client_secret = \"#{Project.Azure.Account.Password}\"\n  resource = \"https://management.azure.com\"\n}\n\nWrite-Host \"Getting Azure Access Token ...\"\n$response = Invoke-RestMethod -Method Post -Uri \"https://login.microsoftonline.com/#{Project.Azure.Account.TenantId}/oauth2/token\" -Body $jsonPayload\n\n# Store as sensitive output variable\nSet-OctopusVariable -Name \"AzureToken\" -Value $response.access_token -Sensitive"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
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
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate Setup].Output.SetupValid == \"True\"}true#{/if}#{/unless}"
    name                 = "Validate Function Name Availability"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Validate Function Name Availability"
      notes                              = "This steps calls the Azure API to determine if Function name specified in the Project.Azure.Function.Octopub.Products.Name Project variable is available."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "# Configure payload\n$jsonPayload = @{\n  name = \"#{Project.Azure.Function.Octopub.Products.Name}\"\n  type = \"Microsoft.Web/sites\"\n  isFQDN = $false\n}\n\n# Construct header\n$headers = @{\n  Authorization = \"Bearer #{Octopus.Action[Get Azure Access Token].Output.AzureToken}\"\n  ContentType = \"application/json\"\n}\n\n# Fix ANSI Color on PWSH Core issues when displaying objects\nif ($PSEdition -eq \"Core\") {\n    $PSStyle.OutputRendering = \"PlainText\"\n}\n\n$response = (Invoke-RestMethod -Method Post -Uri \"https://management.azure.com/subscriptions/#{Project.Azure.Account.SubscriptionNumber}/providers/Microsoft.Web/checknameavailability?api-version=2024-04-01\" -Body $jsonPayload -Headers $headers)\n\n# Set output variable\nSet-OctopusVariable -Name NameAvailable -Value $response.nameAvailable\n\nif ($response.nameAvailable -ne $True)\n{\n  Write-Highlight \"The Function Name of #{Project.Azure.Function.Octopub.Products.Name} is already in use, please change the Project Variable Project.Azure.Function.Octopub.Products.Name to something else.\"\n}\nelse\n{\n  Write-Host \"Function name available!\"\n}\n"
        "OctopusUseBundledTooling" = "False"
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
    condition            = "Variable"
    condition_expression = "#{if Octopus.Action[Validate Setup].Output.SetupValid == \"True\"}true#{/if}"
    name                 = "Create Resource Group"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Create Resource Group"
      notes                              = "This step uses the Azure CLI to create a Resource Group."
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
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$azureLocation = $OctopusParameters['Project.Azure.Location']\n$resourceGroupCreated = $false\n\n# Check to see if the group already exists\n$groupExists = az group exists --name $resourceGroupName\n\nif ($groupExists -eq $true)\n{\n  Write-Highlight \"A Resource Group with the name of $resourceGroupName already exists.  We recommend creating a new Resource Group for this example.\"\n}\nelse\n{\n  # Create resourece group\n  Write-Host \"Creating resource group $resourceGroupName in $azureLocation...\"\n  az group create --location $azureLocation --name $resourceGroupName\n\n  $resourceGroupCreated = $true\n}\n\n# Set output variable\nSet-OctopusVariable -Name \"ResourceGroupCreated\" -Value $resourceGroupCreated"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
        image   = "octopusdeploylabs/azure-workertools"
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
    condition            = "Variable"
    condition_expression = "#{if Octopus.Action[Create Resource Group].Output.ResourceGroupCreated == \"True\"}true#{/if}"
    name                 = "Create Storage Account"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Create Storage Account"
      notes                              = "This step uses the Azure CLI to create a Storage Account resource."
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
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$storageAccountName = $OctopusParameters['Project.Azure.StorageAccount.Name']\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n$azureLocation = $OctopusParameters['Project.Azure.Location']\n$storageAccountCreated = $false\n\n# Check to see if name is already being used in this subscription\n$accountExists = ((az storage account check-name --name $storageAccountName) | ConvertFrom-Json)\n\nif ($accountExists.nameAvailable -ne $true)\n{\n  Write-Highlight \"A storage account with the name $storageAccountName already exists in your subscription.  Please update the Project Variable Project.Azure.StorageAccount.Name\"\n}\nelse\n{\n  # Create Azure storage account\n  Write-Host \"Creating storage account ...\"\n  az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $azureLocation\n\n  $storageAccountCreated = $true\n}\n\nSet-OctopusVariable -Name StorageAccountCreated -Value  $storageAccountCreated\n# Get account keys\n$accountKeys = (az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName) | ConvertFrom-JSON"
        "OctopusUseBundledTooling" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
        image   = "octopusdeploylabs/azure-workertools"
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
    condition            = "Variable"
    condition_expression = "#{if Octopus.Action[Validate Function Name Availability].Output.NameAvailable == \"True\"}#{if Octopus.Action[Create Storage Account].Output.StorageAccountCreated == \"True\"}true#{/if}#{/if}"
    name                 = "Create Octopub Products Function App"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Create Octopub Products Function App"
      notes                              = "This step uses the Azure CLI to create an Azure Function App."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = \"#{Project.Azure.ResourceGroup.Name}\"\n$appServiceName = \"#{Project.Azure.Function.Octopub.Products.Name}\"\n$appServiceRuntime = \"#{Project.Azure.Function.Octopub.Products.Runtime}\"\n$osType = \"#{Project.Azure.Function.Octopub.Products.OS}\"\n$functionsVersion = [int]\"#{Project.Azure.Function.Octopub.Products.Version}\"\n$azureLocation = \"#{Project.Azure.Location}\"\n$azureAccount = \"#{Project.Azure.Account}\"\n$storageAccountName = \"#{Project.Azure.StorageAccount.Name}\"\n\n# Fix ANSI Color on PWSH Core issues when displaying objects\nif ($PSEdition -eq \"Core\") {\n    $PSStyle.OutputRendering = \"PlainText\"\n}\n\n# Create App Service\nWrite-Host \"Creating $appServiceName app service ...\"\n$functionApp = (az functionapp create --name $appServiceName --consumption-plan-location $azureLocation --resource-group $resourceGroupName --runtime $appServiceRuntime --storage-account $storageAccountName --os-type $osType --functions-version $functionsVersion | ConvertFrom-Json)\n\n# Consumption plans are created automatically in the resource group, however, take a bit show up\n$planName = $functionApp.serverfarmId.SubString($functionApp.serverFarmId.LastIndexOf(\"/\") + 1)\n$functionAppPlans = (az functionapp plan list --resource-group $resourceGroupName | ConvertFrom-Json)\n\nWrite-Host \"Consumption based plans auto create and will sometimes take a bit to show up in the resource group, this loop will wait until it's available so the Slot creation doesn't fail ...\"\nwhile ($null -eq ($functionAppPlans | Where-Object {$_.Name -eq $planName}))\n{\n  Write-Host \"Waiting 10 seconds for app plan $planName in $resourceGroupName to show up ...\"\n  Start-Sleep -Seconds 10\n  $functionAppPlans = (az functionapp plan list --resource-group $resourceGroupName | ConvertFrom-Json)\n}\n\nWrite-Host \"It showed up!\"\n\n# Create deployment slots\nWrite-Host \"Creating deployment slots ...\"\naz functionapp deployment slot create --resource-group $resourceGroupName --name $appServiceName --slot \"staging\"\n\nWrite-Host \"Creating Octopus Azure Web App target for $appServiceName\"\nNew-OctopusAzureWebAppTarget -Name $appServiceName -AzureWebApp $appServiceName -AzureResourceGroupName $resourceGroupName -OctopusAccountIdOrName $azureAccount -OctopusRoles \"Octopub-Products-Function\" -updateIfExisting"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
        image   = "octopusdeploylabs/azure-workertools"
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

data "octopusdeploy_projects" "runbook_azure_function_create_infrastructure" {
  ids          = null
  partial_name = "Azure Function"
  skip         = 0
  take         = 1
}
variable "runbook_azure_function_create_infrastructure_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Create Infrastructure"
  default     = "Create Infrastructure"
}
resource "octopusdeploy_runbook" "runbook_azure_function_create_infrastructure" {
  count                       = "${length(data.octopusdeploy_projects.runbook_azure_function_create_infrastructure.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_azure_function_create_infrastructure_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? data.octopusdeploy_projects.project_azure_function.projects[0].id : octopusdeploy_project.project_azure_function[0].id}"
  environment_scope           = "Specified"
  environments                = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "Creates the infrastructure necessary to support this Azure function:\n- Resource group\n- octopub-products Function\n- Storage Account\n- Consumption-based App Service Plan"
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
  count      = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  runbook_id = "${length(data.octopusdeploy_projects.runbook_azure_function_destroy_infrastructure.projects) != 0 ? null : octopusdeploy_runbook.runbook_azure_function_destroy_infrastructure[0].id}"

  step {
    condition           = "Success"
    name                = "Validate Setup"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Validate Setup"
      notes                              = "This step detects any default values that must be updated before the runbook can be executed."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptBody" = "# Define variables\n$errorCollection = @()\n\ntry\n{\n  Write-Host \"Checking to see if Project variables have been configured ...\"\n  if (\"#{Project.Octopus.Api.Key}\" -eq \"CHANGE ME\")\n  {\n    $errorCollection += @(\"The project variable Project.Octopus.Api.Key has not been configured.\")\n    throw \"The Api Key has not been configured, unable to proceed with checks!\"\n  }\n\n  Set-OctopusVariable -Name IsValid -Value $true\n}\ncatch\n{\n  Write-Warning \"Fatal error occurred:\"\n  Write-Warning \"$($_.Exception.Message)\"\n\n  Set-OctopusVariable -Name IsValid -Value $false\n}\n"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
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
    condition            = "Variable"
    condition_expression = "#{if Octopus.Action[Validate Setup].Output.IsValid == \"True\"}true#{/if}"
    name                 = "Deregister target"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Deregister target"
      notes                              = "Deregisters the Azure Function App as a Target."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "$appServiceName = \"#{Project.Azure.Function.Octopub.Products.Name}\"\n$apiKey = \"#{Project.Octopus.Api.Key}\"\n$spaceId = \"#{Octopus.Space.Id}\"\n$headers = @{\"X-Octopus-ApiKey\"=$apiKey}\n\nif ([String]::IsNullOrWhitespace(\"#{Octopus.Web.ServerUri}\"))\n{\n  $octopusUrl = \"#{Octopus.Web.BaseUrl}\"\n}\nelse\n{\n  $octopusUrl = \"#{Octopus.Web.ServerUri}\"\n}\n\n$uriBuilder = New-Object System.UriBuilder(\"$octopusUrl/api/$spaceId/machines\")\n$query = [System.Web.HttpUtility]::ParseQueryString(\"\")\n$query[\"name\"] = $appServiceName\n$uriBuilder.Query = $query.ToString()\n$uri = $uriBuilder.ToString()\n\n$octopubTarget = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers\n\nforeach ($target in $octopubTarget.Items)\n{\n  Write-Host \"Deregistering\" + $target.Name\n  $uri = \"$octopusUrl/api/$spaceId/machines/$($target.Id)\"\n  Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers\n}"
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
    condition            = "Variable"
    condition_expression = "#{if Octopus.Action[Validate Setup].Output.IsValid == \"True\"}true#{/if}"
    name                 = "Destroy resource group"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Destroy resource group"
      notes                              = "This step uses the Azure CLI to delete a resource group."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = $OctopusParameters['Project.Azure.ResourceGroup.Name']\n\n$groupExists = az group exists --name $resourceGroupName\n\nif($groupExists -eq $true) {\n\tWrite-Host \"Deleting Resource Group: $resourceGroupName\"\n    az group delete --name $resourceGroupName --yes \n\tWrite-Highlight \"Deleted Resource Group: $resourceGroupName\"\n}\nelse {\n\tWrite-Highlight \"Resource Group: $resourceGroupName doesn't exist.\"\n}"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
        image   = "octopusdeploylabs/azure-workertools"
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

data "octopusdeploy_projects" "runbook_azure_function_destroy_infrastructure" {
  ids          = null
  partial_name = "Azure Function"
  skip         = 0
  take         = 1
}
variable "runbook_azure_function_destroy_infrastructure_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Destroy Infrastructure"
  default     = "Destroy Infrastructure"
}
resource "octopusdeploy_runbook" "runbook_azure_function_destroy_infrastructure" {
  count                       = "${length(data.octopusdeploy_projects.runbook_azure_function_destroy_infrastructure.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_azure_function_destroy_infrastructure_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? data.octopusdeploy_projects.project_azure_function.projects[0].id : octopusdeploy_project.project_azure_function[0].id}"
  environment_scope           = "Specified"
  environments                = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
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

variable "project_azure_function_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Azure Function"
  default     = "Azure Function"
}
variable "project_azure_function_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Azure Function"
  default     = ""
}
variable "project_azure_function_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Azure Function"
  default     = ""
}
variable "project_azure_function_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Azure Function"
  default     = "Demo deploying an Azure Function."
}
variable "project_azure_function_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_azure_function" {
  ids          = null
  partial_name = "${var.project_azure_function_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_azure_function" {
  count                                = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_azure_function_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_security.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_security.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_security[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_azure.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_azure.project_groups[0].id : octopusdeploy_project_group.project_group_azure[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_azure_function_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
  }
  description = "${var.project_azure_function_description_prefix}${var.project_azure_function_description}${var.project_azure_function_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


