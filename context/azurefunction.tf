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

data "octopusdeploy_worker_pools" "workerpool_default_worker_pool" {
  ids          = null
  partial_name = "Default Worker Pool"
  skip         = 0
  take         = 1
}

data "octopusdeploy_worker_pools" "workerpool_default_worker_pool" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_process" "process_azure_function" {
  count      = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? data.octopusdeploy_projects.project_azure_function.projects[0].id : octopusdeploy_project.project_azure_function[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_azure_function_validate_setup" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Validate setup"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step detects any default values that must be updated before a deployment to Azure can be performed."
  package_requirement   = "LetOctopusDecide"
  slug                  = "verify-setup"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id : data.octopusdeploy_worker_pools.Default Worker Pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptParameters" = "-Role \"Octopub-Products-Function\" -CheckForTargets $true"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/Azure/ValidateSetup.ps1"
      }
}

resource "octopusdeploy_process_step" "process_step_azure_function_check_smtp_configuration" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Check SMTP configuration"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step checks to see if SMTP has been configured.  It sets an output variable that can be used in subsequent steps that send email."
  package_requirement   = "LetOctopusDecide"
  slug                  = "check-smtp-configuration"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id : data.octopusdeploy_worker_pools.Default Worker Pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/CheckSMTPConfigured.ps1"
      }
}

variable "project_azure_function_step_deploy_products_microservice_azurefunction_jvm_azure_function___staging_slot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy products-microservice-azurefunction-jvm Azure Function - Staging Slot in project Azure Function"
  default     = "com.octopus:products-microservice-azurefunction-jvm"
}
resource "octopusdeploy_process_step" "process_step_azure_function_deploy_products_microservice_azurefunction_jvm_azure_function___staging_slot" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Deploy products-microservice-azurefunction-jvm Azure Function - Staging Slot"
  type                  = "Octopus.AzureAppService"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step deploys the web app to the staging slot."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_azure_function_step_deploy_products_microservice_azurefunction_jvm_azure_function___staging_slot_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-products-microservice-azurefunction-jvm-azure-function-staging-slot"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id : data.octopusdeploy_worker_pools.Default Worker Pool.worker_pools[0].id}"
  properties            = {
        "Octopus.Action.TargetRoles" = "Octopub-Products-Function"
      }
  execution_properties  = {
        "Octopus.Action.EnabledFeatures" = "Octopus.Features.JsonConfigurationVariables,Octopus.Features.ConfigurationTransforms,Octopus.Features.SubstituteInFiles"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.DeploymentSlot" = "staging"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.DeploymentType" = "Package"
      }
}

resource "octopusdeploy_process_step" "process_step_azure_function_smoke_test" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Smoke test"
  type                  = "Octopus.AzurePowerShell"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Variable"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", image = "octopusdeploylabs/azure-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  package_requirement   = "LetOctopusDecide"
  slug                  = "smoke-test"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id : data.octopusdeploy_worker_pools.Default Worker Pool.worker_pools[0].id}"
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate Setup].Output.SetupValid == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = \"#{Project.Azure.ResourceGroup.Name}\"\n$functionName = \"#{Project.Azure.Function.Octopub.Products.Name}\"\n\n# Get list of deployment slots\n$deploymentSlots = (az functionapp deployment slot list --resource-group $resourceGroupName --name $functionName | ConvertFrom-JSON)\n\n# Check to see if anything was returned\nif ($null -ne $deploymentSlots -and $null -ne ($deploymentSlots | Where-Object {$_.Name -eq \"staging\"}))\n{\n  # Assing the hostname of the deployment slot\n  $testUrl = ($deploymentSlots | Where-Object {$_.Name -eq \"staging\"}).defaultHostName\n}\nelse\n{\n  # No deployments slots are available, use the function app instead\n  $testUrl = (az functionapp show --resource-group $resourceGroupName --name $functionName | ConvertFrom-JSON).defaultHostName\n}\n\ntry\n{\n  # Make a web request  \n  $response = Invoke-WebRequest -Uri \"https://$testUrl\"\n\n  # Check for a 200 response\n  if ($response.StatusCode -ne 200)\n  {\n    # Throw an error\n    throw $response.StatusCode\n  }\n  else\n  {\n    Write-Host \"Smoke test succeeded!\"\n  }\n}\ncatch\n{\n  Write-Warning \"An error occurred: $($_.Exception.Message)\"\n}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
}

resource "octopusdeploy_process_step" "process_step_azure_function_manual_approval" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Manual approval"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  excluded_environments = null
  notes                 = "A production deployment must be approved before deploying to the production Web App slot."
  package_requirement   = "LetOctopusDecide"
  slug                  = "manual-approval"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Manual.Instructions" = "Please review the Staging slot for the function apps"
        "Octopus.Action.Manual.ResponsibleTeamIds" = "teams-managers"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
      }
}

resource "octopusdeploy_process_step" "process_step_azure_function_swap_deployment_slots" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Swap deployment slots"
  type                  = "Octopus.AzurePowerShell"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Variable"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", image = "octopusdeploylabs/azure-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step swaps the staging and production deployment slots.  This allows for blue/green style deployments."
  package_requirement   = "LetOctopusDecide"
  slug                  = "swap-deployment-slots"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id : data.octopusdeploy_worker_pools.Default Worker Pool.worker_pools[0].id}"
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate Setup].Output.SetupValid == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Azure.AccountId" = "#{Project.Azure.Account}"
        "Octopus.Action.Script.ScriptBody" = "# Get variables\n$resourceGroupName = $OctopusParameters[\"Project.Azure.ResourceGroup.Name\"]\n$functionAppName = $OctopusParameters[\"Project.Azure.Function.Octopub.Products.Name\"]\n\n# Swap the staging and production slots\nWrite-Host \"Swapping Staging and Production slots...\"\naz functionapp deployment slot swap --slot \"Staging\" --target-slot \"Production\" --resource-group $resourceGroupName --name $functionAppName\nWrite-Host \"Swap complete!\""
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
}

variable "project_azure_function_step_scan_for_vulnerabilities_package_products_microservice_azurefunction_jvm_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named products-microservice-azurefunction-jvm from step Scan for Vulnerabilities in project Azure Function"
  default     = "com.octopus:products-microservice-azurefunction-jvm"
}
resource "octopusdeploy_process_step" "process_step_azure_function_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step extracts the Docker image, finds any bom.json files, and scans them for vulnerabilities using Trivy. \n\nThis step is expected to be run with each deployment to ensure vulnerabilities are discovered as early as possible. \n\nIt is also run daily via a project trigger that reruns the deployment in the Security environment. This allows unknown vulnerabilities to be discovered after a production deployment."
  package_requirement   = "LetOctopusDecide"
  packages              = { products-microservice-azurefunction-jvm = { acquisition_location = "ExecutionTarget", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_azure_function_step_scan_for_vulnerabilities_package_products_microservice_azurefunction_jvm_packageid}", properties = { Extract = "True", Purpose = "", SelectionMode = "immediate" } } }
  slug                  = "scan-for-vulnerabilities"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id : data.octopusdeploy_worker_pools.Default Worker Pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/DirectorySbomScan.ps1"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
      }
}

resource "octopusdeploy_process_step" "process_step_azure_function_send_deployment_failure_notification" {
  count                 = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  name                  = "Send deployment failure notification"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step sends an email notification that the deployment has failed.  It includes the error details.  This step only runs when `Octopus.Error` has a value and the output variable `Octopus.Action[Check SMTP configuration].Output.SmtpConfigured` is set to true."
  package_requirement   = "LetOctopusDecide"
  slug                  = "send-deployment-failure-notification"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{if Octopus.Deployment.Error}#{if Octopus.Action[Check SMTP configuration].Output.SmtpConfigured == \"True\"}true#{/if}#{/if}"
      }
  execution_properties  = {
        "Octopus.Action.Email.Subject" = "#{Octopus.Project.Name} failed to deploy to #{Octopus.Environment.Name}!"
        "Octopus.Action.Email.To" = "#{Octopus.Deployment.CreatedBy.EmailAddress}"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Email.Body" = "#{Octopus.Project.Name} release version #{Octopus.Release.Number} has failed deployed to #{Octopus.Environment.Name}\n\n#{Octopus.Deployment.Error}:\n#{Octopus.Deployment.ErrorDetail}"
        "Octopus.Action.Email.Priority" = "High"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_azure_function" {
  count      = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process.process_azure_function[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_validate_setup[0].id}", "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_check_smtp_configuration[0].id}", "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_deploy_products_microservice_azurefunction_jvm_azure_function___staging_slot[0].id}", "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_smoke_test[0].id}", "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_manual_approval[0].id}", "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_swap_deployment_slots[0].id}", "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_scan_for_vulnerabilities[0].id}", "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? null : octopusdeploy_process_step.process_step_azure_function_send_deployment_failure_notification[0].id}"]
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
  description                       = "This account was added to give the Octopus Samples projects an account to work with.  It is initially set with dummy values and will need to be configured. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AzureServicePrincipal\"."
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

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_azure_function_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = "Performs a daily security scan of the production deployment"
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? data.octopusdeploy_projects.project_azure_function.projects[0].id : octopusdeploy_project.project_azure_function[0].id}"
  tenant_ids  = []

  once_daily_schedule {
    start_time   = "2025-06-22T09:00:00"
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
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_azure.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_azure.project_groups[0].id : octopusdeploy_project_group.project_group_azure[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_azure_function_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_azure_function_description_prefix}${var.project_azure_function_description}${var.project_azure_function_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_azure_function" {
  count      = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_azure_function.projects) != 0 ? data.octopusdeploy_projects.project_azure_function.projects[0].id : octopusdeploy_project.project_azure_function[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


