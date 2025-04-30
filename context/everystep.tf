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

variable "project_group_default_project_group_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Default Project Group"
}
data "octopusdeploy_project_groups" "project_group_default_project_group" {
  ids          = null
  partial_name = "${var.project_group_default_project_group_name}"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a project group called $${var.project_group_default_project_group_name}. This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.project_groups) != 0
    }
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

data "octopusdeploy_channels" "channel_every_step_project_default" {
  ids          = []
  partial_name = "Default"
  skip         = 0
  take         = 1
}

data "octopusdeploy_accounts" "account_azure" {
  ids          = null
  partial_name = "Azure"
  skip         = 0
  take         = 1
  account_type = "AzureOidc"
}
resource "octopusdeploy_azure_openid_connect" "account_azure" {
  count                             = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? 0 : 1}"
  name                              = "Azure"
  description                       = "An example of an unscoped Azure OIDC account available to all environments"
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  subscription_id                   = "11111111-1111-1111-1111-111111111111"
  azure_environment                 = ""
  tenant_id                         = "11111111-1111-1111-1111-111111111111"
  application_id                    = "11111111-1111-1111-1111-111111111111"
  audience                          = "api://AzureADTokenExchange"
  account_test_subject_keys         = ["space"]
  execution_subject_keys            = ["space"]
  health_subject_keys               = ["space"]
  depends_on                        = []
  lifecycle {
    ignore_changes  = []
    prevent_destroy = true
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

data "octopusdeploy_feeds" "feed_github_container_registry" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "GitHub Container Registry"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_docker_container_registry" "feed_github_container_registry" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Container Registry"
  registry_path                        = ""
  api_version                          = "v2"
  feed_uri                             = "https://ghcr.io"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_helm" {
  feed_type    = "Helm"
  ids          = null
  partial_name = "Helm"
  skip         = 0
  take         = 1
}
variable "feed_helm_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Helm"
  default     = "Change Me!"
}
resource "octopusdeploy_helm_feed" "feed_helm" {
  count                                = "${length(data.octopusdeploy_feeds.feed_helm.feeds) != 0 ? 0 : 1}"
  name                                 = "Helm"
  password                             = "${var.feed_helm_password}"
  feed_uri                             = "https://charts.helm.sh/stable"
  username                             = "username"
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

data "octopusdeploy_worker_pools" "workerpool_hosted_windows" {
  ids          = null
  partial_name = "Hosted Windows"
  skip         = 0
  take         = 1
}

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

data "octopusdeploy_git_credentials" "gitcredential_github" {
  name = "GitHub"
  skip = 0
  take = 1
}
resource "octopusdeploy_git_credential" "gitcredential_github" {
  count    = "${length(data.octopusdeploy_git_credentials.gitcredential_github.git_credentials) != 0 ? 0 : 1}"
  name     = "GitHub"
  type     = "UsernamePassword"
  username = "x-access-token"
  password = "${var.gitcredential_github_sensitive_value}"
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "gitcredential_github_sensitive_value" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"GitHub\""
  default     = "Change Me!"
}

variable "project_every_step_project_step_deploy_to_iis_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy to IIS in project Every Step Project"
  default     = "webapp"
}
variable "project_every_step_project_step_deploy_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Package in project Every Step Project"
  default     = "mypackage"
}
variable "project_every_step_project_step_deploy_a_windows_service_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Windows Service in project Every Step Project"
  default     = "myservice"
}
variable "project_every_step_project_step_deploy_an_azure_web_app__web_deploy__packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy an Azure Web App (Web Deploy) in project Every Step Project"
  default     = "MyAzureWebApp"
}
variable "project_every_step_project_step_upload_a_package_to_an_aws_s3_bucket_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Upload a package to an AWS S3 bucket in project Every Step Project"
  default     = "MyAWSPackage"
}
variable "project_every_step_project_step_deploy_java_archive_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Java Archive in project Every Step Project"
  default     = "MyJavaApp"
}
variable "project_every_step_project_step_deploy_a_helm_chart_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Helm Chart in project Every Step Project"
  default     = "MyHelmApp"
}
resource "octopusdeploy_deployment_process" "deployment_process_every_step_project" {
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"

  step {
    condition           = "Success"
    name                = "Run a Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Run a Script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hello World!\""
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
    name                = "Run an Azure Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Run an Azure Script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hello World!\""
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/azure-workertools"
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
    name                = "Run an AWS CLI Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsRunScript"
      name                               = "Run an AWS CLI Script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.Region" = "us-east-1"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
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
    name                = "Run gcloud in a Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.GoogleCloudScripting"
      name                               = "Run gcloud in a Script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.GoogleCloud.Region" = "australia-southeast1"
        "Octopus.Action.Script.Syntax" = "Bash"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.GoogleCloud.Zone" = "australia-southeast1-a"
        "Octopus.Action.GoogleCloud.Project" = "ProjectID"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/gcp-workertools"
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
    name                = "Deploy an Azure Resource Manager template"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureResourceGroup"
      name                               = "Deploy an Azure Resource Manager template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      properties                         = {
        "Octopus.Action.Azure.ResourceGroupDeploymentMode" = "Incremental"
        "Octopus.Action.Azure.TemplateSource" = "Inline"
        "Octopus.Action.Azure.ResourceGroupTemplateParameters" = jsonencode({        })
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "Octopus.Action.Azure.ResourceGroupName" = "my-resource-group"
        "Octopus.Action.Azure.ResourceGroupTemplate" = jsonencode({
        "resources" = []
        "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        "contentVersion" = "1.0.0.0"
                })
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
    condition           = "Success"
    name                = "Run a kubectl script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.KubernetesRunScript"
      name                               = "Run a kubectl script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "Write-Host \"Hello World\""
        "Octopus.Action.KubernetesContainers.Namespace" = "mynamespace"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Deploy to IIS"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.IIS"
      name                               = "Deploy to IIS"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.IISWebSite.WebRootType" = "packageRoot"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.IISWebSite.EnableWindowsAuthentication" = "True"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.StartWebSite" = "True"
        "Octopus.Action.IISWebSite.EnableBasicAuthentication" = "False"
        "Octopus.Action.IISWebSite.Bindings" = jsonencode([
        {
        "requireSni" = "False"
        "enabled" = "True"
        "protocol" = "http"
        "port" = "80"
        "host" = ""
        "thumbprint" = null
        "certificateVariable" = null
                },
        ])
        "Octopus.Action.IISWebSite.EnableAnonymousAuthentication" = "False"
        "Octopus.Action.IISWebSite.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.IISWebSite.WebSiteName" = "webapp"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.IISWebSite.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.StartApplicationPool" = "True"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.IISWebSite.ApplicationPoolName" = "apppool"
        "Octopus.Action.IISWebSite.CreateOrUpdateWebSite" = "True"
        "Octopus.Action.IISWebSite.DeploymentType" = "webSite"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_to_iis_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.IISWebSite", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.ConfigurationVariables"]
    }

    properties   = {}
    target_roles = ["windows-server"]
  }
  step {
    condition           = "Success"
    name                = "Deploy a Package"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TentaclePackage"
      name                               = "Deploy a Package"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_a_package_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.ConfigurationVariables"]
    }

    properties   = {}
    target_roles = ["windows-server"]
  }
  step {
    condition           = "Success"
    name                = "Deploy a Windows Service"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.WindowsService"
      name                               = "Deploy a Windows Service"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.WindowsService.CreateOrUpdateService" = "True"
        "Octopus.Action.WindowsService.StartMode" = "auto"
        "Octopus.Action.WindowsService.ExecutablePath" = "myapp.exe"
        "Octopus.Action.WindowsService.DesiredStatus" = "Default"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.WindowsService.Description" = "This is a sample deployment of a Windows service"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.WindowsService.ServiceAccount" = "LocalSystem"
        "Octopus.Action.WindowsService.ServiceName" = "My Service"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.WindowsService.DisplayName" = "My sample Windows service"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_a_windows_service_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.WindowsService", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.ConfigurationVariables"]
    }

    properties   = {}
    target_roles = ["windows-server"]
  }
  step {
    condition           = "Success"
    name                = "Deploy an Azure Web App (Web Deploy)"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureWebApp"
      name                               = "Deploy an Azure Web App (Web Deploy)"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.UseChecksum" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/azure-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_an_azure_web_app__web_deploy__packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = ["AzureWebApp"]
  }
  step {
    condition           = "Success"
    name                = "Upload a package to an AWS S3 bucket"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsUploadS3"
      name                               = "Upload a package to an AWS S3 bucket"
      condition                          = "Success"
      run_on_server                      = false
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.Region" = "ap-southeast-2"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
        "bucketKey" = "mybucket"
        "bucketKeyPrefix" = ""
        "storageClass" = "STANDARD"
        "cannedAcl" = "private"
        "variableSubstitutionPatterns" = ""
        "bucketKeyBehaviour" = "Custom"
        "structuredVariableSubstitutionPatterns" = ""
        "metadata" = []
        "tags" = []
                })
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Aws.S3.TargetMode" = "EntirePackage"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.S3.BucketName" = "my-s3-bucket"
        "Octopus.Action.RunOnServer" = "false"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_upload_a_package_to_an_aws_s3_bucket_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Deploy Java Archive"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.JavaArchive"
      name                               = "Deploy Java Archive"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Package.UseCustomInstallationDirectory" = "False"
        "Octopus.Action.Package.CustomInstallationDirectoryShouldBePurgedBeforeDeployment" = "False"
        "Octopus.Action.JavaArchive.DeployExploded" = "False"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Package.JavaArchiveCompression" = "True"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_java_archive_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["JavaAppServer"]
  }
  step {
    condition           = "Success"
    name                = "Deploy a Helm Chart"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.HelmChartUpgrade"
      name                               = "Deploy a Helm Chart"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Script.ScriptSource" = "Package"
        "Octopus.Action.Helm.ResetValues" = "True"
        "Octopus.Action.Helm.Namespace" = "mycustomnamespace"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_a_helm_chart_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_helm.feeds) != 0 ? data.octopusdeploy_feeds.feed_helm.feeds[0].id : octopusdeploy_helm_feed.feed_helm[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Deploy Kubernetes YAML"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.KubernetesDeployRawYaml"
      name                               = "Deploy Kubernetes YAML"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.14.2\n        ports:\n        - containerPort: 80"
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Deploy with Kustomize"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Kubernetes.Kustomize"
      name                               = "Deploy with Kustomize"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      properties                         = {
        "Octopus.Action.SubstituteInFiles.TargetFiles" = " **/*.env"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.Kubernetes.Kustomize.OverlayPath" = "overlays/#{Octopus.Environment.Name}"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []
      features                           = []

      git_dependency {
        repository_uri      = "https://github.com/OctopusSamples/OctoPetShop.git"
        default_branch      = "main"
        git_credential_type = "Library"
        git_credential_id   = "${length(data.octopusdeploy_git_credentials.gitcredential_github.git_credentials) != 0 ? data.octopusdeploy_git_credentials.gitcredential_github.git_credentials[0].id : octopusdeploy_git_credential.gitcredential_github[0].id}"
      }
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Apply a Terraform template"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformApply"
      name                               = "Apply a Terraform template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
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
    name                = "Destroy Terraform resources"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformDestroy"
      name                               = "Destroy Terraform resources"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
                })
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
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
    name                = "Plan to apply a Terraform template"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformPlan"
      name                               = "Plan to apply a Terraform template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
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
    name                = "Plan a Terraform destroy"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformPlanDestroy"
      name                               = "Plan a Terraform destroy"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
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
    condition_expression = "#{Step.Run}"
    name                 = "Deploy an AWS CloudFormation template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsRunCloudFormation"
      name                               = "Deploy an AWS CloudFormation template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.CloudFormationTemplate" = "AWSTemplateFormatVersion: '2010-09-09'\nDescription: 'CloudFormation exports'\n \nConditions:\n  HasNot: !Equals [ 'true', 'false' ]\n \n# dummy (null) resource, never created\nResources:\n  NullResource:\n    Type: 'Custom::NullResource'\n    Condition: HasNot\n \nOutputs:\n  ExportsStackName:\n    Value: !Ref 'AWS::StackName'\n    Export:\n      Name: !Sub 'ExportsStackName-$${AWS::StackName}'"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.TemplateSource" = "Inline"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.Region" = "us-east-2"
        "Octopus.Action.Aws.CloudFormationTemplateParameters" = jsonencode([])
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.CloudFormationStackName" = "mystackname"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
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
    condition           = "Always"
    name                = "Apply an AWS CloudFormation Change Set"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsApplyCloudFormationChangeSet"
      name                               = "Apply an AWS CloudFormation Change Set"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.CloudFormation.ChangeSet.Arn" = "mychangeset"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.CloudFormationStackName" = "mystack"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.Region" = "ap-southeast-1"
        "OctopusUseBundledTooling" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
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
    condition           = "Failure"
    name                = "Delete an AWS CloudFormation stack"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsDeleteCloudFormation"
      name                               = "Delete an AWS CloudFormation stack"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.Region" = "us-east-2"
        "Octopus.Action.Aws.CloudFormationStackName" = "my-stack-name"
        "OctopusUseBundledTooling" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
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

data "octopusdeploy_accounts" "account_aws_oidc" {
  ids          = null
  partial_name = "AWS OIDC"
  skip         = 0
  take         = 1
  account_type = "AmazonWebServicesOidcAccount"
}
resource "octopusdeploy_aws_openid_connect_account" "account_aws_oidc" {
  count                             = "${length(data.octopusdeploy_accounts.account_aws_oidc.accounts) != 0 ? 0 : 1}"
  name                              = "AWS OIDC"
  description                       = "An AWS OIDC account. See https://octopus.com/docs/infrastructure/accounts/aws for more information."
  role_arn                          = "arn:aws:iam::381713788115:role/OIDCAdminAccess"
  account_test_subject_keys         = ["space"]
  environments                      = []
  execution_subject_keys            = ["space"]
  health_subject_keys               = ["space"]
  session_duration                  = 3600
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  depends_on                        = []
  lifecycle {
    ignore_changes  = []
    prevent_destroy = true
  }
}

resource "octopusdeploy_variable" "every_step_project_account_aws_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_aws_oidc.accounts) != 0 ? data.octopusdeploy_accounts.account_aws_oidc.accounts[0].id : octopusdeploy_aws_openid_connect_account.account_aws_oidc[0].id}"
  name         = "Account.AWS"
  type         = "AmazonWebServicesAccount"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "variable_99b08078ba47238c5e4abfae90c644746cdea2cdeb685fbf8010dbf63ecd3563_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Step.Run"
  default     = "True"
}
resource "octopusdeploy_variable" "every_step_project_step_run_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${var.variable_99b08078ba47238c5e4abfae90c644746cdea2cdeb685fbf8010dbf63ecd3563_value}"
  name         = "Step.Run"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "project_every_step_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Every Step Project"
  default     = "Every Step Project"
}
variable "project_every_step_project_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Every Step Project"
  default     = ""
}
variable "project_every_step_project_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Every Step Project"
  default     = ""
}
variable "project_every_step_project_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Every Step Project"
  default     = ""
}
variable "project_every_step_project_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_every_step_project" {
  ids          = null
  partial_name = "${var.project_every_step_project_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_every_step_project" {
  count                                = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_every_step_project_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_every_step_project_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
  }
  description = "${var.project_every_step_project_description_prefix}${var.project_every_step_project_description}${var.project_every_step_project_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


