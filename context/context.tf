provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.9.0" }
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

data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_" {
  feed_type    = "OctopusProject"
  ids          = null
  partial_name = "Octopus Server Releases"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"Octopus Server Releases (built-in)\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
  }
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

data "octopusdeploy_feeds" "feed_nuget" {
  feed_type    = "NuGet"
  ids          = null
  partial_name = "Nuget"
  skip         = 0
  take         = 1
}
variable "feed_nuget_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Nuget"
  default     = "Change Me!"
}
resource "octopusdeploy_nuget_feed" "feed_nuget" {
  count                                = "${length(data.octopusdeploy_feeds.feed_nuget.feeds) != 0 ? 0 : 1}"
  name                                 = "Nuget"
  feed_uri                             = "https://nuget.example.org"
  username                             = "username"
  password                             = "${var.feed_nuget_password}"
  is_enhanced_mode                     = false
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_artifactory_feed" {
  feed_type    = "ArtifactoryGeneric"
  ids          = null
  partial_name = "Artifactory Feed"
  skip         = 0
  take         = 1
}
variable "feed_artifactory_feed_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Artifactory Feed"
  default     = "Change Me!"
}
resource "octopusdeploy_artifactory_generic_feed" "feed_artifactory_feed" {
  count      = "${length(data.octopusdeploy_feeds.feed_artifactory_feed.feeds) != 0 ? 0 : 1}"
  feed_uri   = "https://example.jfrog.io"
  name       = "Artifactory Feed"
  password   = "${var.feed_artifactory_feed_password}"
  username   = "username"
  repository = "repositoryname"
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_aws_ecr" {
  feed_type    = "AwsElasticContainerRegistry"
  ids          = null
  partial_name = "AWS ECR"
  skip         = 0
  take         = 1
}
variable "feed_aws_ecr_secretkey" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret key used by the feed AWS ECR"
  default     = "Change Me!"
}
resource "octopusdeploy_aws_elastic_container_registry" "feed_aws_ecr" {
  count                                = "${length(data.octopusdeploy_feeds.feed_aws_ecr.feeds) != 0 ? 0 : 1}"
  name                                 = "AWS ECR"
  access_key                           = "ASIAY34FZKBNKMUTVV7A"
  secret_key                           = "${var.feed_aws_ecr_secretkey}"
  region                               = "ap-southeast-2"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [secret_key]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_github_repository_feed" {
  feed_type    = "GitHub"
  ids          = null
  partial_name = "GitHub Repository Feed"
  skip         = 0
  take         = 1
}
variable "feed_github_repository_feed_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed GitHub Repository Feed"
  default     = "Change Me!"
}
resource "octopusdeploy_github_repository_feed" "feed_github_repository_feed" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_repository_feed.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Repository Feed"
  password                             = "${var.feed_github_repository_feed_password}"
  feed_uri                             = "https://api.github.com"
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  username                             = "x-access-token"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
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
  package_acquisition_location_options = ["ExecutionTarget", "Server", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_maven" {
  feed_type    = "Maven"
  ids          = null
  partial_name = "Maven"
  skip         = 0
  take         = 1
}
variable "feed_maven_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Maven"
  default     = "Change Me!"
}
resource "octopusdeploy_maven_feed" "feed_maven" {
  count                                = "${length(data.octopusdeploy_feeds.feed_maven.feeds) != 0 ? 0 : 1}"
  name                                 = "Maven"
  feed_uri                             = "https://repo.maven.apache.org/maven2/"
  username                             = "username"
  password                             = "${var.feed_maven_password}"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_github_repository_feed_with_token" {
  feed_type    = "GitHub"
  ids          = null
  partial_name = "GitHub Repository Feed with Token"
  skip         = 0
  take         = 1
}
variable "feed_github_repository_feed_with_token_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed GitHub Repository Feed with Token"
  default     = "Change Me!"
}
resource "octopusdeploy_github_repository_feed" "feed_github_repository_feed_with_token" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_repository_feed_with_token.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Repository Feed with Token"
  password                             = "${var.feed_github_repository_feed_with_token_password}"
  feed_uri                             = "https://api.github.com"
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_github_repository_feed_with_anonymous_access" {
  feed_type    = "GitHub"
  ids          = null
  partial_name = "GitHub Repository Feed with Anonymous Access"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_github_repository_feed" "feed_github_repository_feed_with_anonymous_access" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_repository_feed_with_anonymous_access.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Repository Feed with Anonymous Access"
  feed_uri                             = "https://api.github.com"
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
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

data "octopusdeploy_feeds" "feed_octopussamples_github_nuget_feed" {
  feed_type    = "NuGet"
  ids          = null
  partial_name = "OctopusSamples GitHub NuGet Feed"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_nuget_feed" "feed_octopussamples_github_nuget_feed" {
  count                                = "${length(data.octopusdeploy_feeds.feed_octopussamples_github_nuget_feed.feeds) != 0 ? 0 : 1}"
  name                                 = "OctopusSamples GitHub NuGet Feed"
  feed_uri                             = "https://nuget.pkg.github.com/OctopusSamples/index.json"
  is_enhanced_mode                     = false
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
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

data "octopusdeploy_feeds" "feed_s3_feed" {
  feed_type    = "S3"
  ids          = null
  partial_name = "S3 Feed"
  skip         = 0
  take         = 1
}
variable "feed_s3_feed_secretkey" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret key used by the feed S3 Feed"
  default     = "Change Me!"
}
resource "octopusdeploy_s3_feed" "feed_s3_feed" {
  count                   = "${length(data.octopusdeploy_feeds.feed_s3_feed.feeds) != 0 ? 0 : 1}"
  name                    = "S3 Feed"
  use_machine_credentials = false
  access_key              = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  secret_key              = "${var.feed_s3_feed_secretkey}"
  lifecycle {
    ignore_changes  = [secret_key]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_anonymous_docker_feed" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "Anonymous Docker Feed"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_docker_container_registry" "feed_anonymous_docker_feed" {
  count                                = "${length(data.octopusdeploy_feeds.feed_anonymous_docker_feed.feeds) != 0 ? 0 : 1}"
  name                                 = "Anonymous Docker Feed"
  registry_path                        = ""
  api_version                          = ""
  feed_uri                             = "https://index.docker.io"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_project_groups" "project_group_aws" {
  ids          = null
  partial_name = "${var.project_group_aws_name}"
  skip         = 0
  take         = 1
}
variable "project_group_aws_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "AWS"
}
resource "octopusdeploy_project_group" "project_group_aws" {
  count = "${length(data.octopusdeploy_project_groups.project_group_aws.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_aws_name}"
  lifecycle {
    prevent_destroy = true
  }
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

data "octopusdeploy_project_groups" "project_group_kubernetes" {
  ids          = null
  partial_name = "${var.project_group_kubernetes_name}"
  skip         = 0
  take         = 1
}
variable "project_group_kubernetes_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Kubernetes"
}
resource "octopusdeploy_project_group" "project_group_kubernetes" {
  count = "${length(data.octopusdeploy_project_groups.project_group_kubernetes.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_kubernetes_name}"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_project_groups" "project_group_llm" {
  ids          = null
  partial_name = "${var.project_group_llm_name}"
  skip         = 0
  take         = 1
}
variable "project_group_llm_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "LLM"
}
resource "octopusdeploy_project_group" "project_group_llm" {
  count = "${length(data.octopusdeploy_project_groups.project_group_llm.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_llm_name}"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_project_groups" "project_group_orchestrator" {
  ids          = null
  partial_name = "${var.project_group_orchestrator_name}"
  skip         = 0
  take         = 1
}
variable "project_group_orchestrator_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Orchestrator"
}
resource "octopusdeploy_project_group" "project_group_orchestrator" {
  count = "${length(data.octopusdeploy_project_groups.project_group_orchestrator.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_orchestrator_name}"
  lifecycle {
    prevent_destroy = true
  }
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

data "octopusdeploy_project_groups" "project_group_terraform" {
  ids          = null
  partial_name = "${var.project_group_terraform_name}"
  skip         = 0
  take         = 1
}
variable "project_group_terraform_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Terraform"
}
resource "octopusdeploy_project_group" "project_group_terraform" {
  count = "${length(data.octopusdeploy_project_groups.project_group_terraform.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_terraform_name}"
  lifecycle {
    prevent_destroy = true
  }
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

data "octopusdeploy_accounts" "account_a_second_aws_oidc_account" {
  ids          = null
  partial_name = "A second AWS OIDC Account"
  skip         = 0
  take         = 1
  account_type = "AmazonWebServicesOidcAccount"
}
resource "octopusdeploy_aws_openid_connect_account" "account_a_second_aws_oidc_account" {
  count                             = "${length(data.octopusdeploy_accounts.account_a_second_aws_oidc_account.accounts) != 0 ? 0 : 1}"
  name                              = "A second AWS OIDC Account"
  description                       = "This is a second AWS ODIC account. Note that each account has its own separate and distinct \"octopusdeploy_accounts\" data source."
  role_arn                          = "arn:aws:iam::381713788115:role/OIDCAdminAccess"
  account_test_subject_keys         = ["type"]
  environments                      = []
  execution_subject_keys            = ["project"]
  health_subject_keys               = ["account"]
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

data "octopusdeploy_accounts" "account_aws" {
  ids          = null
  partial_name = "AWS"
  skip         = 0
  take         = 1
  account_type = "AmazonWebServicesOidcAccount"
}
resource "octopusdeploy_aws_openid_connect_account" "account_aws" {
  count                             = "${length(data.octopusdeploy_accounts.account_aws.accounts) != 0 ? 0 : 1}"
  name                              = "AWS"
  description                       = "This is an example of an unscoped OIDC AWS account available to all environments. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AmazonWebServicesOidcAccount\"."
  role_arn                          = "arn:aws:iam::123456789012:role/S3Access"
  account_test_subject_keys         = []
  environments                      = []
  execution_subject_keys            = []
  health_subject_keys               = []
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
  description                       = "An AWS OIDC account. See https://octopus.com/docs/infrastructure/accounts/aws for more information. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AmazonWebServicesOidcAccount\". Note the \"role_arn\" property is mandatory for accounts of type \"AmazonWebServicesOidcAccount\"."
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

data "octopusdeploy_accounts" "account_aws_with_keys" {
  ids          = null
  partial_name = "AWS with Keys"
  skip         = 0
  take         = 1
  account_type = "AmazonWebServicesAccount"
}
resource "octopusdeploy_aws_account" "account_aws_with_keys" {
  count                             = "${length(data.octopusdeploy_accounts.account_aws_with_keys.accounts) != 0 ? 0 : 1}"
  name                              = "AWS with Keys"
  description                       = "This is an example AWS account with access and secret keys. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AmazonWebServicesAccount\"."
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  access_key                        = "AKIAIOSFODNN7EXAMPLE"
  secret_key                        = "${var.account_aws_with_keys}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [secret_key]
    prevent_destroy = true
  }
}
variable "account_aws_with_keys" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The AWS secret key associated with the account AWS with Keys"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_azure" {
  ids          = null
  partial_name = "Azure"
  skip         = 0
  take         = 1
  account_type = "AzureOIDC"
}
resource "octopusdeploy_azure_openid_connect" "account_azure" {
  count                             = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? 0 : 1}"
  name                              = "Azure"
  description                       = "An example of an unscoped Azure OIDC account available to all environments. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AzureOidc\"."
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  subscription_id                   = "00000000-0000-0000-0000-000000000000"
  azure_environment                 = ""
  tenant_id                         = "00000000-0000-0000-0000-000000000000"
  application_id                    = "00000000-0000-0000-0000-000000000000"
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

data "octopusdeploy_accounts" "account_azure_service_principal" {
  ids          = null
  partial_name = "Azure Service Principal"
  skip         = 0
  take         = 1
  account_type = "AzureServicePrincipal"
}
resource "octopusdeploy_azure_service_principal" "account_azure_service_principal" {
  count                             = "${length(data.octopusdeploy_accounts.account_azure_service_principal.accounts) != 0 ? 0 : 1}"
  name                              = "Azure Service Principal"
  description                       = "An example Azure service principal account. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AzureServicePrincipal\"."
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  application_id                    = "b0676d9e-8d3e-457d-844a-ab77deda4916"
  password                          = "${var.account_azure_service_principal}"
  subscription_id                   = "7dae5466-90fb-4bf7-b0ee-7194033a1fde"
  tenant_id                         = "b8fc95ef-da51-4d9e-9921-714292b30e20"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_azure_service_principal" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Azure secret associated with the account Azure Service Principal"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_generic_oidc" {
  ids          = null
  partial_name = "Generic OIDC"
  skip         = 0
  take         = 1
  account_type = "GenericOidcAccount"
}
resource "octopusdeploy_aws_openid_connect_account" "account_generic_oidc" {
  count                             = "${length(data.octopusdeploy_accounts.account_generic_oidc.accounts) != 0 ? 0 : 1}"
  name                              = "Generic OIDC"
  description                       = "An example of an unscoped generic OIDC account. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"GenericOidcAccount\"."
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  execution_subject_keys            = ["space"]
  tenanted_deployment_participation = "Untenanted"
  depends_on                        = []
  lifecycle {
    ignore_changes  = []
    prevent_destroy = true
  }
}

data "octopusdeploy_accounts" "account_google_cloud_account" {
  ids          = null
  partial_name = "Google Cloud Account"
  skip         = 0
  take         = 1
  account_type = "GoogleCloudAccount"
}
resource "octopusdeploy_gcp_account" "account_google_cloud_account" {
  count                             = "${length(data.octopusdeploy_accounts.account_google_cloud_account.accounts) != 0 ? 0 : 1}"
  name                              = "Google Cloud Account"
  description                       = "An example of a Google Cloud (GCP) Account scoped to the Development environment Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"GoogleCloudAccount\"."
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  json_key                          = "${var.account_google_cloud_account}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [json_key]
    prevent_destroy = true
  }
}
variable "account_google_cloud_account" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The GCP JSON key associated with the account Google Cloud Account"
  default     = "Change Me!"
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

data "octopusdeploy_accounts" "account_shawnazure" {
  ids          = null
  partial_name = "ShawnAzure"
  skip         = 0
  take         = 1
  account_type = "AzureServicePrincipal"
}
resource "octopusdeploy_azure_service_principal" "account_shawnazure" {
  count                             = "${length(data.octopusdeploy_accounts.account_shawnazure.accounts) != 0 ? 0 : 1}"
  name                              = "ShawnAzure"
  description                       = "Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AzureServicePrincipal\"."
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  application_id                    = "631408da-9bd5-4cf2-b4b6-8bd0506db582"
  password                          = "${var.account_shawnazure}"
  subscription_id                   = "c5e7ce05-3887-4caa-aef6-948a93e56498"
  tenant_id                         = "18eb006b-c3c8-4a72-93cd-fe4b293f82ee"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_shawnazure" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Azure secret associated with the account ShawnAzure"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_ssh_key_pair" {
  ids          = null
  partial_name = "SSH Key Pair"
  skip         = 0
  take         = 1
  account_type = "SshKeyPair"
}
resource "octopusdeploy_ssh_key_account" "account_ssh_key_pair" {
  count                             = "${length(data.octopusdeploy_accounts.account_ssh_key_pair.accounts) != 0 ? 0 : 1}"
  name                              = "SSH Key Pair"
  description                       = "An example of a SSH Key Pair account scoped to the Test environment. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"SshKeyPair\"."
  environments                      = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  private_key_file                  = "${var.account_ssh_key_pair_cert}"
  username                          = "username"
  private_key_passphrase            = "${var.account_ssh_key_pair}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [private_key_passphrase, private_key_file]
    prevent_destroy = true
  }
}
variable "account_ssh_key_pair" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password associated with the certificate for account SSH Key Pair"
  default     = "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUJGd0FBQUFkemMyZ3RjbgpOaEFBQUFBd0VBQVFBQUFRRUF5c25PVXhjN0tJK2pIRUc5RVEwQXFCMllGRWE5ZnpZakZOY1pqY1dwcjJQRkRza25oOUpTCm1NVjVuZ2VrbTRyNHJVQU5tU2dQMW1ZTGo5TFR0NUVZa0N3OUdyQ0paNitlQTkzTEowbEZUamFkWEJuQnNmbmZGTlFWYkcKZ2p3U1o4SWdWQ2oySXE0S1hGZm0vbG1ycEZQK2Jqa2V4dUxwcEh5dko2ZmxZVjZFMG13YVlneVNHTWdLYy9ubXJaMTY0WApKMStJL1M5NkwzRWdOT0hNZmo4QjM5eEhZQ0ZUTzZEQ0pLQ3B0ZUdRa0gwTURHam84d3VoUlF6c0IzVExsdXN6ZG0xNmRZCk16WXZBSWR3emZ3bzh1ajFBSFFOendDYkIwRmR6bnFNOEpLV2ZrQzdFeVVrZUl4UXZmLzJGd1ZyS0xEZC95ak5PUmNoa3EKb2owNncySXFad0FBQThpS0tqT3dpaW96c0FBQUFBZHpjMmd0Y25OaEFBQUJBUURLeWM1VEZ6c29qNk1jUWIwUkRRQ29IWgpnVVJyMS9OaU1VMXhtTnhhbXZZOFVPeVNlSDBsS1l4WG1lQjZTYml2aXRRQTJaS0EvV1pndVAwdE8za1JpUUxEMGFzSWxuCnI1NEQzY3NuU1VWT05wMWNHY0d4K2Q4VTFCVnNhQ1BCSm53aUJVS1BZaXJncGNWK2IrV2F1a1UvNXVPUjdHNHVta2ZLOG4KcCtWaFhvVFNiQnBpREpJWXlBcHorZWF0blhyaGNuWDRqOUwzb3ZjU0EwNGN4K1B3SGYzRWRnSVZNN29NSWtvS20xNFpDUQpmUXdNYU9qekM2RkZET3dIZE11VzZ6TjJiWHAxZ3pOaThBaDNETi9Dank2UFVBZEEzUEFKc0hRVjNPZW96d2twWitRTHNUCkpTUjRqRkM5Ly9ZWEJXc29zTjMvS00wNUZ5R1NxaVBUckRZaXBuQUFBQUF3RUFBUUFBQVFFQXdRZzRqbitlb0kyYUJsdk4KVFYzRE1rUjViMU9uTG1DcUpEeGM1c2N4THZNWnNXbHBaN0NkVHk4ckJYTGhEZTdMcUo5QVVub0FHV1lwdTA1RW1vaFRpVwptVEFNVHJCdmYwd2xsdCtJZVdvVXo3bmFBbThQT1psb29MbXBYRzh5VmZKRU05aUo4NWtYNDY4SkF6VDRYZ1JXUFRYQ1JpCi9abCtuWUVUZVE4WTYzWlJhTVE3SUNmK2FRRWxRenBYb21idkxYM1RaNmNzTHh5Z3Eza01aSXNJU0lUcEk3Y0tsQVJ0Rm4KcWxKRitCL2JlUEJkZ3hIRVpqZDhDV0NIR1ZRUDh3Z3B0d0Rrak9NTzh2b2N4YVpOT0hZZnBwSlBCTkVjMEVKbmduN1BXSgorMVZSTWZKUW5SemVubmE3VHdSUSsrclZmdkVaRmhqamdSUk85RitrMUZvSWdRQUFBSUVBbFFybXRiV2V0d3RlWlZLLys4CklCUDZkcy9MSWtPb3pXRS9Wckx6cElBeHEvV1lFTW1QK24wK1dXdWRHNWpPaTFlZEJSYVFnU0owdTRxcE5JMXFGYTRISFYKY2oxL3pzenZ4RUtSRElhQkJGaU81Y3QvRVQvUTdwanozTnJaZVdtK0dlUUJKQ0diTEhSTlQ0M1ZpWVlLVG82ZGlGVTJteApHWENlLzFRY2NqNjVZQUFBQ0JBUHZodmgzb2Q1MmY4SFVWWGoxeDNlL1ZFenJPeVloTi9UQzNMbWhHYnRtdHZ0L0J2SUhxCndxWFpTT0lWWkZiRnVKSCtORHNWZFFIN29yUW1VcGJxRllDd0IxNUZNRGw0NVhLRm0xYjFyS1c1emVQK3d0M1hyM1p0cWsKRkdlaUlRMklSZklBQjZneElvNTZGemdMUmx6QnB0bzhkTlhjMXhtWVgyU2Rhb3ZwSkRBQUFBZ1FET0dwVE9oOEFRMFoxUwpzUm9vVS9YRTRkYWtrSU5vMDdHNGI3M01maG9xbkV1T01LM0ZRVStRRWUwYWpvdWs5UU1QNWJzZU1CYnJNZVNNUjBRWVBCClQ4Z0Z2S2VISWN6ZUtJTjNPRkRaRUF4TEZNMG9LbjR2bmdHTUFtTXUva2QwNm1PZnJUNDRmUUh1ajdGNWx1QVJHejRwYUwKLzRCTUVkMnFTRnFBYzZ6L0RRQUFBQTF0WVhSMGFFQk5ZWFIwYUdWM0FRSURCQT09Ci0tLS0tRU5EIE9QRU5TU0ggUFJJVkFURSBLRVktLS0tLQo="
}
variable "account_ssh_key_pair_cert" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate file for account SSH Key Pair"
  default     = "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUJGd0FBQUFkemMyZ3RjbgpOaEFBQUFBd0VBQVFBQUFRRUF5c25PVXhjN0tJK2pIRUc5RVEwQXFCMllGRWE5ZnpZakZOY1pqY1dwcjJQRkRza25oOUpTCm1NVjVuZ2VrbTRyNHJVQU5tU2dQMW1ZTGo5TFR0NUVZa0N3OUdyQ0paNitlQTkzTEowbEZUamFkWEJuQnNmbmZGTlFWYkcKZ2p3U1o4SWdWQ2oySXE0S1hGZm0vbG1ycEZQK2Jqa2V4dUxwcEh5dko2ZmxZVjZFMG13YVlneVNHTWdLYy9ubXJaMTY0WApKMStJL1M5NkwzRWdOT0hNZmo4QjM5eEhZQ0ZUTzZEQ0pLQ3B0ZUdRa0gwTURHam84d3VoUlF6c0IzVExsdXN6ZG0xNmRZCk16WXZBSWR3emZ3bzh1ajFBSFFOendDYkIwRmR6bnFNOEpLV2ZrQzdFeVVrZUl4UXZmLzJGd1ZyS0xEZC95ak5PUmNoa3EKb2owNncySXFad0FBQThpS0tqT3dpaW96c0FBQUFBZHpjMmd0Y25OaEFBQUJBUURLeWM1VEZ6c29qNk1jUWIwUkRRQ29IWgpnVVJyMS9OaU1VMXhtTnhhbXZZOFVPeVNlSDBsS1l4WG1lQjZTYml2aXRRQTJaS0EvV1pndVAwdE8za1JpUUxEMGFzSWxuCnI1NEQzY3NuU1VWT05wMWNHY0d4K2Q4VTFCVnNhQ1BCSm53aUJVS1BZaXJncGNWK2IrV2F1a1UvNXVPUjdHNHVta2ZLOG4KcCtWaFhvVFNiQnBpREpJWXlBcHorZWF0blhyaGNuWDRqOUwzb3ZjU0EwNGN4K1B3SGYzRWRnSVZNN29NSWtvS20xNFpDUQpmUXdNYU9qekM2RkZET3dIZE11VzZ6TjJiWHAxZ3pOaThBaDNETi9Dank2UFVBZEEzUEFKc0hRVjNPZW96d2twWitRTHNUCkpTUjRqRkM5Ly9ZWEJXc29zTjMvS00wNUZ5R1NxaVBUckRZaXBuQUFBQUF3RUFBUUFBQVFFQXdRZzRqbitlb0kyYUJsdk4KVFYzRE1rUjViMU9uTG1DcUpEeGM1c2N4THZNWnNXbHBaN0NkVHk4ckJYTGhEZTdMcUo5QVVub0FHV1lwdTA1RW1vaFRpVwptVEFNVHJCdmYwd2xsdCtJZVdvVXo3bmFBbThQT1psb29MbXBYRzh5VmZKRU05aUo4NWtYNDY4SkF6VDRYZ1JXUFRYQ1JpCi9abCtuWUVUZVE4WTYzWlJhTVE3SUNmK2FRRWxRenBYb21idkxYM1RaNmNzTHh5Z3Eza01aSXNJU0lUcEk3Y0tsQVJ0Rm4KcWxKRitCL2JlUEJkZ3hIRVpqZDhDV0NIR1ZRUDh3Z3B0d0Rrak9NTzh2b2N4YVpOT0hZZnBwSlBCTkVjMEVKbmduN1BXSgorMVZSTWZKUW5SemVubmE3VHdSUSsrclZmdkVaRmhqamdSUk85RitrMUZvSWdRQUFBSUVBbFFybXRiV2V0d3RlWlZLLys4CklCUDZkcy9MSWtPb3pXRS9Wckx6cElBeHEvV1lFTW1QK24wK1dXdWRHNWpPaTFlZEJSYVFnU0owdTRxcE5JMXFGYTRISFYKY2oxL3pzenZ4RUtSRElhQkJGaU81Y3QvRVQvUTdwanozTnJaZVdtK0dlUUJKQ0diTEhSTlQ0M1ZpWVlLVG82ZGlGVTJteApHWENlLzFRY2NqNjVZQUFBQ0JBUHZodmgzb2Q1MmY4SFVWWGoxeDNlL1ZFenJPeVloTi9UQzNMbWhHYnRtdHZ0L0J2SUhxCndxWFpTT0lWWkZiRnVKSCtORHNWZFFIN29yUW1VcGJxRllDd0IxNUZNRGw0NVhLRm0xYjFyS1c1emVQK3d0M1hyM1p0cWsKRkdlaUlRMklSZklBQjZneElvNTZGemdMUmx6QnB0bzhkTlhjMXhtWVgyU2Rhb3ZwSkRBQUFBZ1FET0dwVE9oOEFRMFoxUwpzUm9vVS9YRTRkYWtrSU5vMDdHNGI3M01maG9xbkV1T01LM0ZRVStRRWUwYWpvdWs5UU1QNWJzZU1CYnJNZVNNUjBRWVBCClQ4Z0Z2S2VISWN6ZUtJTjNPRkRaRUF4TEZNMG9LbjR2bmdHTUFtTXUva2QwNm1PZnJUNDRmUUh1ajdGNWx1QVJHejRwYUwKLzRCTUVkMnFTRnFBYzZ6L0RRQUFBQTF0WVhSMGFFQk5ZWFIwYUdWM0FRSURCQT09Ci0tLS0tRU5EIE9QRU5TU0ggUFJJVkFURSBLRVktLS0tLQo="
}

data "octopusdeploy_accounts" "account_token" {
  ids          = null
  partial_name = "Token"
  skip         = 0
  take         = 1
  account_type = "Token"
}
resource "octopusdeploy_token_account" "account_token" {
  count                             = "${length(data.octopusdeploy_accounts.account_token.accounts) != 0 ? 0 : 1}"
  name                              = "Token"
  description                       = "An example of an unscoped Token account. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"Token\"."
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  token                             = "${var.account_token}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [token]
    prevent_destroy = true
  }
}
variable "account_token" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The token associated with the account Token"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_token_with_tenants" {
  ids          = null
  partial_name = "Token with tenants"
  skip         = 0
  take         = 1
  account_type = "Token"
}
resource "octopusdeploy_token_account" "account_token_with_tenants" {
  count                             = "${length(data.octopusdeploy_accounts.account_token_with_tenants.accounts) != 0 ? 0 : 1}"
  name                              = "Token with tenants"
  description                       = "This is an example of a token account that supports tenants."
  environments                      = []
  tenant_tags                       = ["Business Units/Engineering", "Cities/Madrid", "Regions/ANZ", "Tag Set/tag"]
  tenants                           = ["${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"]
  tenanted_deployment_participation = "TenantedOrUntenanted"
  token                             = "${var.account_token_with_tenants}"
  depends_on                        = [octopusdeploy_tag_set.tagset_tag_set,octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag_set.tagset_business_units,octopusdeploy_tag_set.tagset_regions,octopusdeploy_tag.tagset_tag_set_tag_tag,octopusdeploy_tag.tagset_cities_tag_madrid,octopusdeploy_tag.tagset_business_units_tag_engineering,octopusdeploy_tag.tagset_regions_tag_anz]
  lifecycle {
    ignore_changes  = [token]
    prevent_destroy = true
  }
}
variable "account_token_with_tenants" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The token associated with the account Token with tenants"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_username_password" {
  ids          = null
  partial_name = "Username Password"
  skip         = 0
  take         = 1
  account_type = "UsernamePassword"
}
resource "octopusdeploy_username_password_account" "account_username_password" {
  count                             = "${length(data.octopusdeploy_accounts.account_username_password.accounts) != 0 ? 0 : 1}"
  name                              = "Username Password"
  description                       = "An example of a username password account scoped to the Production environment. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"UsernamePassword\"."
  environments                      = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  username                          = "username"
  password                          = "${var.account_username_password}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_username_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password associated with the account Username Password"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_worker_account" {
  ids          = null
  partial_name = "Worker Account"
  skip         = 0
  take         = 1
  account_type = "UsernamePassword"
}
resource "octopusdeploy_username_password_account" "account_worker_account" {
  count                             = "${length(data.octopusdeploy_accounts.account_worker_account.accounts) != 0 ? 0 : 1}"
  name                              = "Worker Account"
  description                       = ""
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  username                          = "myusername"
  password                          = "${var.account_worker_account}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_worker_account" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password associated with the account Worker Account"
  default     = "Change Me!"
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

data "octopusdeploy_worker_pools" "workerpool_hosted_windows" {
  ids          = null
  partial_name = "Hosted Windows"
  skip         = 0
  take         = 1
}

data "octopusdeploy_worker_pools" "workerpool_worker_pool" {
  ids          = null
  partial_name = "Worker Pool"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_static_worker_pool" "workerpool_worker_pool" {
  count       = "${length(data.octopusdeploy_worker_pools.workerpool_worker_pool.worker_pools) != 0 ? 0 : 1}"
  name        = "Worker Pool"
  description = "An example of a worker pool"
  is_default  = false
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_worker_pools" "workerpool_linux_workers" {
  ids          = null
  partial_name = "Linux Workers"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_static_worker_pool" "workerpool_linux_workers" {
  count       = "${length(data.octopusdeploy_worker_pools.workerpool_linux_workers.worker_pools) != 0 ? 0 : 1}"
  name        = "Linux Workers"
  description = ""
  is_default  = false
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_certificates" "certificate_development_certificate" {
  ids          = null
  partial_name = "Development Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_development_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_development_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Development Certificate"
  password                          = "${var.certificate_development_certificate_password}"
  certificate_data                  = "${var.certificate_development_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_development_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Development Certificate"
  default     = "Password01!"
}
variable "certificate_development_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Development Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_test_certificate" {
  ids          = null
  partial_name = "Test Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_test_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_test_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Test Certificate"
  password                          = "${var.certificate_test_certificate_password}"
  certificate_data                  = "${var.certificate_test_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_test_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Test Certificate"
  default     = "Password01!"
}
variable "certificate_test_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Test Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_production_certificate" {
  ids          = null
  partial_name = "Production Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_production_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_production_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Production Certificate"
  password                          = "${var.certificate_production_certificate_password}"
  certificate_data                  = "${var.certificate_production_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_production_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Production Certificate"
  default     = "Password01!"
}
variable "certificate_production_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Production Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_unscoped_certificate" {
  ids          = null
  partial_name = "Unscoped Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_unscoped_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_unscoped_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Unscoped Certificate"
  password                          = "${var.certificate_unscoped_certificate_password}"
  certificate_data                  = "${var.certificate_unscoped_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_unscoped_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Unscoped Certificate"
  default     = "Password01!"
}
variable "certificate_unscoped_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Unscoped Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_self_signed_certificate" {
  ids          = null
  partial_name = "Self SIgned Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_self_signed_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_self_signed_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Self SIgned Certificate"
  password                          = "${var.certificate_self_signed_certificate_password}"
  certificate_data                  = "${var.certificate_self_signed_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = ["Cities/London", "Cities/Sydney", "Cities/Washington"]
  tenanted_deployment_participation = "TenantedOrUntenanted"
  tenants                           = []
  depends_on                        = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_sydney,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_washington]
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_self_signed_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Self SIgned Certificate"
  default     = "Password01!"
}
variable "certificate_self_signed_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Self SIgned Certificate"
  default     = "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"
}

data "octopusdeploy_tag_sets" "tagset_tag_set" {
  ids          = null
  partial_name = "Tag Set"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_tag_set" {
  name        = "Tag Set"
  description = "An example of a tenant tag set"
  count       = length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? 0 : 1
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_tag_set_tag_tag" {
  name        = "tag"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets[0].id : octopusdeploy_tag_set.tagset_tag_set[0].id}"
  color       = "#333333"
  description = "An example of a tag"
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets[0].tags : item if item.name == "tag"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_tag_set_tag_tag2" {
  name        = "tag2"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets[0].id : octopusdeploy_tag_set.tagset_tag_set[0].id}"
  color       = "#C5AEEE"
  description = "Another example of a tag"
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets[0].tags : item if item.name == "tag2"], [])) != 0 ? 0 : 1
}

data "octopusdeploy_tag_sets" "tagset_cities" {
  ids          = null
  partial_name = "Cities"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_cities" {
  name        = "Cities"
  description = "An example tag set that captures cities"
  count       = length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_cities_tag_sydney" {
  name        = "Sydney"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#333333"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Sydney"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_london" {
  name        = "London"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#87BFEC"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "London"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_washington" {
  name        = "Washington"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#5ECD9E"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Washington"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_madrid" {
  name        = "Madrid"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#FFA461"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Madrid"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_wellington" {
  name        = "Wellington"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#C5AEEE"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Wellington"], [])) != 0 ? 0 : 1
}

data "octopusdeploy_tag_sets" "tagset_business_units" {
  ids          = null
  partial_name = "Business Units"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_business_units" {
  name        = "Business Units"
  description = "An example tag set that defined business units"
  count       = length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? 0 : 1
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_business_units_tag_billing" {
  name        = "Billing"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#333333"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].tags : item if item.name == "Billing"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_business_units_tag_insurance" {
  name        = "Insurance"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#87BFEC"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].tags : item if item.name == "Insurance"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_business_units_tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#C5AEEE"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].tags : item if item.name == "Engineering"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_business_units_tag_hr" {
  name        = "HR"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#FFA461"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].tags : item if item.name == "HR"], [])) != 0 ? 0 : 1
}

data "octopusdeploy_tag_sets" "tagset_regions" {
  ids          = null
  partial_name = "Regions"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_regions" {
  name        = "Regions"
  description = "A sample tag set that captures geographical regions"
  count       = length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? 0 : 1
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_regions_tag_us" {
  name        = "US"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#333333"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].tags : item if item.name == "US"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_regions_tag_europe" {
  name        = "Europe"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#5ECD9E"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].tags : item if item.name == "Europe"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_regions_tag_asia" {
  name        = "Asia"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#FF9F9F"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].tags : item if item.name == "Asia"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_regions_tag_anz" {
  name        = "ANZ"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#C5AEEE"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].tags : item if item.name == "ANZ"], [])) != 0 ? 0 : 1
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

data "octopusdeploy_lifecycles" "lifecycle_hotfix" {
  ids          = null
  partial_name = "Hotfix"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_hotfix" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_hotfix.lifecycles) != 0 ? 0 : 1}"
  name        = "Hotfix"
  description = "This channel allows deployments directly to production."

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

data "octopusdeploy_machine_policies" "machinepolicy_custom_machone_policy" {
  ids          = null
  partial_name = "Custom Machone Policy"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_machine_policy" "machinepolicy_custom_machone_policy" {
  count                           = "${length(data.octopusdeploy_machine_policies.machinepolicy_custom_machone_policy.machine_policies) != 0 ? 0 : 1}"
  name                            = "Custom Machone Policy"
  connection_connect_timeout      = 60000000000
  connection_retry_count_limit    = 5
  connection_retry_sleep_interval = 1000000000
  connection_retry_time_limit     = 300000000000

  machine_cleanup_policy {
    delete_machines_behavior         = "DoNotDelete"
    delete_machines_elapsed_timespan = 3600000000000
  }

  machine_connectivity_policy {
    machine_connectivity_behavior = "ExpectedToBeOnline"
  }

  machine_health_check_policy {

    bash_health_check_policy {
      run_type    = "InheritFromDefault"
      script_body = ""
    }

    powershell_health_check_policy {
      run_type    = "InheritFromDefault"
      script_body = ""
    }

    health_check_cron_timezone = "UTC"
    health_check_interval      = 0
    health_check_type          = "RunScript"
  }

  machine_update_policy {
    calamari_update_behavior         = "UpdateOnDeployment"
    tentacle_update_account_id       = "Accounts-4341"
    tentacle_update_behavior         = "NeverUpdate"
    kubernetes_agent_update_behavior = "Update"
  }
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_machine_policies" "default_machine_policy" {
  ids          = null
  partial_name = "Default Machine Policy"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a machine policy called \"default_machine_policy\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.machine_policies) != 0
    }
  }
}

data "octopusdeploy_tenants" "tenant_australian_office" {
  ids          = null
  partial_name = "Australian Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_australian_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  name        = "Australian Office"
  description = "An example tenant that represents an Australian office"
  tenant_tags = ["Cities/Sydney"]
  depends_on  = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_sydney]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_tenants" "tenant_european_office" {
  ids          = null
  partial_name = "European Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_european_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_european_office.tenants) != 0 ? 0 : 1}"
  name        = "European Office"
  description = "An example tenant that represents the European office"
  tenant_tags = ["Cities/London"]
  depends_on  = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_london]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_tenants" "tenant_main_office" {
  ids          = null
  partial_name = "Main Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_main_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_main_office.tenants) != 0 ? 0 : 1}"
  name        = "Main Office"
  description = "An example tenant that represents that main US office"
  tenant_tags = ["Cities/Washington"]
  depends_on  = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_washington]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_tenants" "tenant_tenant" {
  ids          = null
  partial_name = "Tenant"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_tenant" {
  count       = "${length(data.octopusdeploy_tenants.tenant_tenant.tenants) != 0 ? 0 : 1}"
  name        = "Tenant"
  description = "An example of a tenant"
  tenant_tags = ["Tag Set/tag"]
  depends_on  = [octopusdeploy_tag_set.tagset_tag_set,octopusdeploy_tag.tagset_tag_set_tag_tag]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_tenants" "tenant_tenant_a" {
  ids          = null
  partial_name = "Tenant A"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_tenant_a" {
  count       = "${length(data.octopusdeploy_tenants.tenant_tenant_a.tenants) != 0 ? 0 : 1}"
  name        = "Tenant A"
  tenant_tags = []
  depends_on  = []
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_tenants" "tenant_tenant_b" {
  ids          = null
  partial_name = "Tenant B"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_tenant_b" {
  count       = "${length(data.octopusdeploy_tenants.tenant_tenant_b.tenants) != 0 ? 0 : 1}"
  name        = "Tenant B"
  tenant_tags = []
  depends_on  = []
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_targets" "target_ssh_target" {
  ids                  = null
  partial_name         = "SSH Target"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_ssh_connection_deployment_target" "target_ssh_target" {
  count                 = "${length(data.octopusdeploy_deployment_targets.target_ssh_target.deployment_targets) != 0 ? 0 : 1}"
  account_id            = "${length(data.octopusdeploy_accounts.account_username_password.accounts) != 0 ? data.octopusdeploy_accounts.account_username_password.accounts[0].id : octopusdeploy_username_password_account.account_username_password[0].id}"
  environments          = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  fingerprint           = "SHA256:U+NO3sOxbAvVCtF1NCN/ZL2+rWJ9bddDQSoGom1TsI8"
  host                  = "10.1.1.1"
  port                  = "22"
  name                  = "SSH Target"
  roles                 = ["Linux"]
  dot_net_core_platform = "linux-x64"
  machine_policy_id     = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  tenant_tags           = []
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_kubernetes_target" {
  ids                  = null
  partial_name         = "Kubernetes Target"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_target" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_kubernetes_target.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = "https://example.org"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  name                              = "Kubernetes Target"
  roles                             = ["Kubernetes"]
  default_worker_pool_id            = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = true
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = "Feeds-5455"
    image   = "octopusdeploy/worker-tools:6.4.0-ubuntu.22.04"
  }

  aws_account_authentication {
    account_id        = "${length(data.octopusdeploy_accounts.account_aws_oidc.accounts) != 0 ? data.octopusdeploy_accounts.account_aws_oidc.accounts[0].id : octopusdeploy_aws_openid_connect_account.account_aws_oidc[0].id}"
    cluster_name      = "mytestcluster"
    assume_role       = false
    use_instance_role = false
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_kubernetes_with_auzre_auth" {
  ids                  = null
  partial_name         = "Kubernetes with Auzre Auth"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_with_auzre_auth" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_kubernetes_with_auzre_auth.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = ""
  environments                      = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  name                              = "Kubernetes with Auzre Auth"
  roles                             = ["MyTargetName"]
  default_worker_pool_id            = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = false
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = "Feeds-5473"
    image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
  }

  azure_service_principal_authentication {
    account_id             = "${length(data.octopusdeploy_accounts.account_azure_service_principal.accounts) != 0 ? data.octopusdeploy_accounts.account_azure_service_principal.accounts[0].id : octopusdeploy_azure_service_principal.account_azure_service_principal[0].id}"
    cluster_name           = "clustername"
    cluster_resource_group = "resourcegroupname"
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_kubernetes_with_certificate_auth" {
  ids                  = null
  partial_name         = "Kubernetes with Certificate Auth"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_with_certificate_auth" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_kubernetes_with_certificate_auth.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = "http://cluster"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  name                              = "Kubernetes with Certificate Auth"
  roles                             = ["MyTargetName"]
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = true
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = ""
    image   = ""
  }

  certificate_authentication {
    client_certificate = "${length(data.octopusdeploy_certificates.certificate_development_certificate.certificates) != 0 ? data.octopusdeploy_certificates.certificate_development_certificate.certificates[0].id : octopusdeploy_certificate.certificate_development_certificate[0].id}"
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_kubernetes_with_google_auth" {
  ids                  = null
  partial_name         = "Kubernetes with Google Auth"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_with_google_auth" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_kubernetes_with_google_auth.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = ""
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  name                              = "Kubernetes with Google Auth"
  roles                             = ["MyTargetName"]
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = false
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = ""
    image   = ""
  }

  gcp_account_authentication {
    account_id                  = "${length(data.octopusdeploy_accounts.account_google_cloud_account.accounts) != 0 ? data.octopusdeploy_accounts.account_google_cloud_account.accounts[0].id : octopusdeploy_gcp_account.account_google_cloud_account[0].id}"
    cluster_name                = "clustername"
    project                     = "projectname"
    impersonate_service_account = false
    region                      = "us-west1-a"
    use_vm_service_account      = false
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_kubernetes_with_pod_service_account_auth" {
  ids                  = null
  partial_name         = "Kubernetes with Pod Service Account Auth"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_with_pod_service_account_auth" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_kubernetes_with_pod_service_account_auth.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = "http://mycluster"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  name                              = "Kubernetes with Pod Service Account Auth"
  roles                             = ["MyTargetName"]
  cluster_certificate_path          = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
  default_worker_pool_id            = "${length(data.octopusdeploy_worker_pools.workerpool_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_worker_pool.worker_pools[0].id : octopusdeploy_static_worker_pool.workerpool_worker_pool[0].id}"
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = false
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = ""
    image   = ""
  }

  pod_authentication {
    token_path = "/var/run/secrets/kubernetes.io/serviceaccount/token"
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_kubernetes_with_token_auth" {
  ids                  = null
  partial_name         = "Kubernetes with Token Auth"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_with_token_auth" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_kubernetes_with_token_auth.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = "http://clusterurl"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  name                              = "Kubernetes with Token Auth"
  roles                             = ["Kubernetes"]
  cluster_certificate               = "${length(data.octopusdeploy_certificates.certificate_development_certificate.certificates) != 0 ? data.octopusdeploy_certificates.certificate_development_certificate.certificates[0].id : octopusdeploy_certificate.certificate_development_certificate[0].id}"
  default_worker_pool_id            = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = false
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = ""
    image   = ""
  }

  authentication {
    account_id = "${length(data.octopusdeploy_accounts.account_token.accounts) != 0 ? data.octopusdeploy_accounts.account_token.accounts[0].id : octopusdeploy_token_account.account_token[0].id}"
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_kubernetes_with_username_and_password_auth" {
  ids                  = null
  partial_name         = "Kubernetes with Username and Password Auth"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_kubernetes_with_username_and_password_auth" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_kubernetes_with_username_and_password_auth.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = "http://10.1.2.3"
  environments                      = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  name                              = "Kubernetes with Username and Password Auth"
  roles                             = ["MyTargetName"]
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = true
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = ""
    image   = ""
  }

  authentication {
    account_id = "${length(data.octopusdeploy_accounts.account_username_password.accounts) != 0 ? data.octopusdeploy_accounts.account_username_password.accounts[0].id : octopusdeploy_username_password_account.account_username_password[0].id}"
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_xmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Xmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_xmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_xmas.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Xmas"
  start = "2024-12-24T14:00:00.000+00:00"
  end   = "2025-12-26T16:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_xmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Xmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_xmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_xmas.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Xmas"
  start = "2024-12-24T14:00:00.000+00:00"
  end   = "2025-12-26T16:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_xmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Xmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_xmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_xmas.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Xmas"
  start = "2024-12-24T14:00:00.000+00:00"
  end   = "2025-12-26T16:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_holidays" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Holidays"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_holidays" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_holidays.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Holidays"
  start = "2026-01-26T00:30:03.000+00:00"
  end   = "2026-01-26T01:00:03.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_cyber_monday" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Cyber Monday"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_cyber_monday" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_cyber_monday.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Cyber Monday"
  start = "2026-11-30T00:00:00.000+00:00"
  end   = "2026-12-02T23:59:59.999+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_targets" "target_cloudregion1" {
  ids                  = null
  partial_name         = "CloudRegion1"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_cloud_region_deployment_target" "target_cloudregion1" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_cloudregion1.deployment_targets) != 0 ? 0 : 1}"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  name                              = "CloudRegion1"
  roles                             = ["TestMe"]
  default_worker_pool_id            = ""
  health_status                     = "Healthy"
  is_disabled                       = false
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  thumbprint                        = ""
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_cyber_monday" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Cyber Monday"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_cyber_monday" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_cyber_monday.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Cyber Monday"
  start = "2026-11-30T00:00:00.000+00:00"
  end   = "2026-12-02T23:59:59.999+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_targets" "target_cloudregion2" {
  ids                  = null
  partial_name         = "CloudRegion2"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_cloud_region_deployment_target" "target_cloudregion2" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_cloudregion2.deployment_targets) != 0 ? 0 : 1}"
  environments                      = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
  name                              = "CloudRegion2"
  roles                             = ["TestMe"]
  default_worker_pool_id            = ""
  health_status                     = "Healthy"
  is_disabled                       = false
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  thumbprint                        = ""
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_christmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Christmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_christmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_christmas.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Christmas"
  start = "2026-12-20T00:00:00.000+00:00"
  end   = "2026-12-27T23:59:59.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_black_friday_freeze" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Black Friday Freeze"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_black_friday_freeze" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_black_friday_freeze.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Black Friday Freeze"
  start = "2026-11-23T00:00:00.000+00:00"
  end   = "2026-11-29T23:59:59.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_christmas_freeze" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Christmas Freeze"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_christmas_freeze" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_christmas_freeze.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Christmas Freeze"
  start = "2026-12-20T00:00:00.000+00:00"
  end   = "2026-12-27T00:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_christmas_freeze" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Christmas Freeze"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_christmas_freeze" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_christmas_freeze.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Christmas Freeze"
  start = "2026-12-20T00:00:00.000+00:00"
  end   = "2026-12-27T23:59:59.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_deployment_freezes" "deploymentfreeze_xmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Xmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_xmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_xmas.deployment_freezes) != 0 ? 0 : 1}"
  name  = "Xmas"
  start = "2024-12-24T14:00:00.000+00:00"
  end   = "2025-12-26T16:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_workers" "worker_linux_worker" {
  ids                  = null
  partial_name         = "Linux Worker"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
}
resource "octopusdeploy_ssh_connection_worker" "worker_linux_worker" {
  count             = "${length(data.octopusdeploy_workers.worker_linux_worker.workers) != 0 ? 0 : 1}"
  name              = "Linux Worker"
  account_id        = "${length(data.octopusdeploy_accounts.account_worker_account.accounts) != 0 ? data.octopusdeploy_accounts.account_worker_account.accounts[0].id : octopusdeploy_username_password_account.account_worker_account[0].id}"
  dotnet_platform   = "linux-x64"
  fingerprint       = "SHA256:U+NO3sOxbAvVCtF1NCN/ZL2+rWJ9bddDQSoGom1TsI8"
  host              = "192.168.1.1"
  port              = 22
  worker_pool_ids   = ["${length(data.octopusdeploy_worker_pools.workerpool_linux_workers.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_linux_workers.worker_pools[0].id : octopusdeploy_static_worker_pool.workerpool_linux_workers[0].id}"]
  machine_policy_id = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_variable" "variables_example_variable_set_database_password_1" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "development.database.internal"
  name         = "Database.Password"
  type         = "String"
  description  = "This is an example of a variable scoped to an environment"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
    processes    = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "variables_example_variable_set_database_password_2" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "test.database.internal"
  name         = "Database.Password"
  type         = "String"
  description  = "This is an example of a variable scoped to an environment"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
    processes    = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "variables_example_variable_set_database_password_3" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "production.database.internal"
  name         = "Database.Password"
  type         = "String"
  description  = "This is an example of a variable scoped to an environment"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
    machines     = null
    roles        = null
    tenant_tags  = null
    processes    = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_library_variable_sets" "library_variable_set_variables_example_variable_set" {
  ids          = null
  partial_name = "Example Variable Set"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_library_variable_set" "library_variable_set_variables_example_variable_set" {
  count       = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  name        = "Example Variable Set"
  description = ""

  template {
    name             = "Common.Variable"
    label            = "A common variable that must be defined for each tenant"
    help_text        = "The help text associated with the variable is defined here."
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "MultiLineText" }
  }
  template {
    name             = "Example.Account.Variable"
    label            = "The account to use"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "AmazonWebServicesAccount" }
  }
  template {
    name             = "Example.Azure.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "AzureAccount" }
  }
  template {
    name             = "Example.Certificate.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Certificate" }
  }
  template {
    name             = "Example.Checkbox.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Checkbox" }
  }
  template {
    name             = "Example.Dropdown.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Select", "Octopus.SelectOptions" = "Option1|This is the displayed text for option 1\nOption2|This is the displayed text for the second option" }
  }
  template {
    name             = "Example.GenericOIDC.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "GenericOidcAccount" }
  }
  template {
    name             = "Example.GCP.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "GoogleCloudAccount" }
  }
  template {
    name             = "Example.Password.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Sensitive" }
  }
  template {
    name             = "Example.SingleLineTextBox.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "SingleLineText" }
  }
  template {
    name             = "Example.UsernamePassword.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "UsernamePasswordAccount" }
  }
  template {
    name             = "Example.WorkerPool.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "WorkerPool" }
  }
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_machine_proxies" "machine_proxy_machine_proxy" {
  ids          = null
  partial_name = "${var.machine_proxy_machine_proxy_name}"
  skip         = 0
  take         = 1
}
variable "machine_proxy_machine_proxy_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the machine proxy to lookup"
  default     = "Machine Proxy"
}
resource "octopusdeploy_machine_proxy" "machine_proxy_machine_proxy" {
  count    = "${length(data.octopusdeploy_machine_proxies.machine_proxy_machine_proxy.machine_proxies) != 0 ? 0 : 1}"
  name     = "${var.machine_proxy_machine_proxy_name}"
  host     = "192.168.1.4"
  password = "${var.machine_proxy_machine_proxy_password}"
  username = "username"
  port     = 80
  lifecycle {
    prevent_destroy = true
  }
}
variable "machine_proxy_machine_proxy_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the machine proxy \"Machine Proxy\""
  default     = "Change Me!"
}

data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_smtp_server_configured" {
  website = "https://library.octopus.com/step-templates/ad8126be-37af-4297-b46e-fce02ba3987a"
}
data "octopusdeploy_step_template" "steptemplate_octopus___check_smtp_server_configured" {
  name = "Octopus - Check SMTP Server Configured"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_smtp_server_configured" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? 0 : 1}"
}

data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_targets_available" {
  website = "https://library.octopus.com/step-templates/81444e7f-d77a-47db-b287-0f1ab5793880"
}
data "octopusdeploy_step_template" "steptemplate_octopus___check_targets_available" {
  name = "Octopus - Check Targets Available"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_targets_available" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_targets_available.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_targets_available.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template != null ? 0 : 1}"
}

data "octopusdeploy_community_step_template" "communitysteptemplate_readyroll___deploy_database_package" {
  website = "https://library.octopus.com/step-templates/14e87c33-b34a-429f-be2c-e44d3d631649"
}
data "octopusdeploy_step_template" "steptemplate_readyroll___deploy_database_package" {
  name = "ReadyRoll - Deploy Database Package"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_readyroll___deploy_database_package" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_readyroll___deploy_database_package.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_readyroll___deploy_database_package.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_readyroll___deploy_database_package.step_template != null ? 0 : 1}"
}

data "octopusdeploy_community_step_template" "communitysteptemplate_scan_for_vulnerabilities" {
  website = "https://library.octopus.com/step-templates/a38bfff8-8dde-4dd6-9fd0-c90bb4709d5a"
}
data "octopusdeploy_step_template" "steptemplate_scan_for_vulnerabilities" {
  name = "Scan for Vulnerabilities"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_scan_for_vulnerabilities" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? 0 : 1}"
}

data "octopusdeploy_step_template" "steptemplate_script_step_template" {
  name = "Script Step Template"
}
resource "octopusdeploy_step_template" "steptemplate_script_step_template" {
  count           = "${data.octopusdeploy_step_template.steptemplate_script_step_template.step_template != null ? 0 : 1}"
  action_type     = "Octopus.Script"
  name            = "Script Step Template"
  description     = "This is an example step template."
  step_package_id = "Octopus.Script"
  packages        = []
  parameters      = [{ default_sensitive_value = null, default_value = "The default value", display_settings = { "Octopus.ControlType" = "SingleLineText" }, help_text = "The help text", id = "45acbfac-af9c-4901-96b5-f426df0ff3c0", label = "An example property", name = "Example.Property" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "MultiLineText" }, help_text = null, id = "bdbb2687-8c13-4346-bc7b-8b99d1a030e8", label = null, name = "Multiline input" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "AmazonWebServicesAccount" }, help_text = null, id = "1ace254d-42e9-4b14-821c-3ca7f40fcb18", label = null, name = "AWS Account" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "AzureAccount" }, help_text = null, id = "b484ca42-a40c-4906-96f7-26b6a8d1bd49", label = null, name = "Azure Account" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "Certificate" }, help_text = null, id = "17bd2090-8d65-41dc-8c01-fef2fbeb4bb9", label = null, name = "Certificate" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "Checkbox" }, help_text = null, id = "6b2bd9a9-dfc4-4a31-b6fe-3c7884849c34", label = null, name = "Checkbox" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "Select" }, help_text = null, id = "a82f84c4-694b-4be4-98e3-63fd1e4bf723", label = null, name = "Drop Down List" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "GenericOidcAccount" }, help_text = null, id = "a110aa3f-502f-4699-9b42-e9ac20e47ac3", label = null, name = "Generic OIDC Account" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "GoogleCloudAccount" }, help_text = null, id = "263d6b01-a42e-4947-8fe5-8832dfc3aa30", label = null, name = "Google Cloud Account" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "Package" }, help_text = null, id = "28b42fde-1dfa-4370-b8fc-ebed6113d519", label = null, name = "Package" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "Sensitive" }, help_text = null, id = "e8faed28-0584-4e0c-9342-03a9b539d448", label = null, name = "Sensitive value" }, { default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "UsernamePasswordAccount" }, help_text = null, id = "6129799d-8b4c-4ac3-90a0-295944f61375", label = null, name = "Username/Password" }]
  properties      = { "Octopus.Action.Script.ScriptBody" = "echo \"hi\"", "Octopus.Action.Script.ScriptSource" = "Inline", "Octopus.Action.Script.Syntax" = "PowerShell" }
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_community_step_template" "communitysteptemplate_slack___send_simple_notification" {
  website = "https://library.octopus.com/step-templates/99e6f203-3061-4018-9e34-4a3a9c3c3179"
}
data "octopusdeploy_step_template" "steptemplate_slack___send_simple_notification" {
  name = "Slack - Send Simple Notification"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_slack___send_simple_notification" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_slack___send_simple_notification.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_slack___send_simple_notification.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_slack___send_simple_notification.step_template != null ? 0 : 1}"
}

resource "octopusdeploy_variable" "variables_octoai_prompts_project_0__prompt_1" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_octoai_prompts.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_octoai_prompts.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_octoai_prompts.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_octoai_prompts[0].id}"
  value        = "Given the project and its steps, report any configuration that does not follow best practice."
  name         = "Project[0].Prompt"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "variables_octoai_prompts_project_0__systemprompt_1" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_octoai_prompts.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_octoai_prompts.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_octoai_prompts.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_octoai_prompts[0].id}"
  value        = "You must compare the configuration of the project and its steps to the following rules. You must only consider resources that are directly referenced by the current project or the current project's steps.\n\nYou will be penalized for referencing feeds, accounts, certificates, library variable sets, and targets that are not directly referenced by the current project or the current project's steps.\n\nContainer images are defined in the `container` block in an `action` block as part of a resource \"octopusdeploy_runbook_process\" or resource \"octopusdeploy_deployment_process\".\n\nYou must start the answer with a traffic light emoji character and score between 0 and 100 based on how compliant the project is with the rules.\n\nIf the score is between 80 and 100, print the \"🟢\" character.\nIf the score is between 50 and 79, print the \"🟡\" character.\nIf the score is below 49, print the \"🔴\" character.\n\n## Rules\n\n### Feeds\n\n* Projects must only reference packages from one or both of the following feeds:\n  * Docker images must come from a feed called `GHCR Anonymous` with the URL https://ghcrfacade-a6awccayfpcpg4cg.eastus-01.azurewebsites.net\n    * This feed is a thin facade over the GHCR Docker API for images in the [OctopusSolutionsEngineering](https://github.com/OctopusSolutionsEngineering) organisation\n    * This allows for unauthenticated tag queries\n    * The facade application is found [here](https://github.com/OctopusSolutionsEngineering/GHCRFacade)\n  * Packages must come from a Maven feed called `Octopus Maven Feed` with the URL http://octopus-sales-public-maven-repo.s3-website-ap-southeast-2.amazonaws.com/snapshot\n  * This feed uses a public S3 bucket to expose an anonymous Maven repo\n\n### Accounts\n\n* Prefer the use of OIDC accounts\n* Use GUIDs of `00000000-0000-0000-0000-000000000000` when creating Azure accounts\n\n### Sensitive values\n\n* Use `CHANGE ME` for all sensitive values.\n  * This is the value that all sensitive values are defaulted to during export\n  * Any scripts checking for default values must assume sensitive values are set to `CHANGE ME`\n\n### Variables\n\n* All variables must have descriptions\n  * The LLM learns from these descriptions and uses them when customising the project\n* Variables should always use the `#{VariableName}` syntax\n  * This is because the LLM gets confused with Powershell variables starting with a $ and Terraform interpolation\n* Project variables should be prefixed with `Project.`\n  * This prevents name collisions with step templates\n\n### Deployment Processes\n\n* The first step in a deployment or runbook process must be a step called `Validate Setup` that detects default or invalid credentials and prints [highlight](https://octopus.com/docs/deployments/custom-scripts/logging-messages-in-scripts#highlight-log-level) messages indicating next steps\n* Deployments must be allowed with no targets\n* If the deployment process relies on targets being present, a step must be included called `Print Message When no Targets` that detects the absence of targets and prints the next steps\n  * Not all platforms have targets i.e. AWS Lambdas, Google Cloud Functions, Azure Container Instances etc\n  * If we don't expect any targets to be present, there is no need to warn about the lack of targets\n* Deployment processes must deploy [Octopub](github.com/OctopusSolutionsEngineering/Octopub) packages if possible:\n  * Octopub has been designed to support multiple platforms including Lambdas, Azure Functions, Google Functions, Docker etc\n  * Octopub embeds SBOMs for security scanning\n* The last step in the deployment process must be called `Scan for Vulnerabilities` with a script that scans the SBOM associated with the deployed application\n* There must be one example of each step in a deployment process\n  * The purpose of the example projects is to create a base that customers can easily modify and extend via prompts\n  * Having a deployment process deploying multiple applications makes it hard for the LLM to know which combination of steps must be used as an example when deploying a single application.\n  * For example, a microservice deployment must include the steps to deploy one microservice\n  * This does not mean a deployment needs to be done in a single step. If multiple steps are required to deploy a single application, that is fine. This is about avoiding template projects with duplicate steps that do the same thing for multiple applications.\n* Complex scripts must be sourced from a public Git repo or a package\n  * LLMs often have trouble recreating complex scripts\n  * Octopub includes sample scripts at https://github.com/OctopusSolutionsEngineering/Octopub/tree/main/octopus\n* Don't use step templates\n  * This is a limitation of the Octopus Terraform provider\n* Prefer Powershell scripts\n  * Python is not an option because AWS and Azure script steps only support Bash and Powershell\n  * Powershell works on all hosted workers\n  * Powershell can work on Linux\n  * Bash will never be well supported on Windows\n* Don't fail a deployment because of predictable errors\n  * We treat the deployment process as a wizard that points customers to the next step\n* All steps must have descriptions\n  * The LLM learns from these descriptions and uses the information when customising the project\n\n\n### Projects\n\n* Set the release versions to `#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i`\n\n### Lifecycles\n\n* The deployment must use a lifecycle called `DevSecOps`\n* The `DevSecOps` lifecycle has the environments:\n  * `Development`\n  * `Test`\n  * `Production`\n  * `Security`\n* The `Development` and `Security` environments automatically deploy new releases\n* Steps related to application deployment are excluded from the `Security` environment\n\n### Workers\n\n* Default to the Hosted Ubuntu worker\n  * It's faster than the Hosted Windows workers\n\n### Container Images\n\n* Prefer the use of the [Octopus Labs container images](https://octopushq.atlassian.net/wiki/spaces/SE/pages/2713224189/Octopus+Labs+container+images) which have the name `<platform>-workertools`:\n  * For example, images called `aws-workertools`, `k8s-workertools`, `azure-workertools`\n  * We can iterate quickly on these images as needed\n\n### Triggers\n\n* The project must trigger a redeployment of the `Security` environment daily\n  * This effectively scans all production deployments every day for new vulnerabilities\n\n### Infrastructure creation and destruction\n\n* Runbooks to create and destroy the infrastructure can be included in a project\n* If not, the deployment process must link to documentation that describes how to create the required infrastructure if there are no targets or invalid credentials\n\n### Config-as-Code\n\n* Example projects can be saved as Config-as-code, but will always be recreated as database projects\n\n### Project Groups\n\n* Create example projects in a project group that describes the platform or cloud to which it is being deployed. Examples are:\n  * `Kubernetes`\n  * `Azure`\n  * `AWS`\n  * `GCP`\n\n### Certificates\n\n* Avoid certificates as they are hard to recreate\n\n### Scripts\n\nSometimes the LLMs get confused about random things in the scripts. We may have to edit scripts to avoid LLM issues in preference over \"clean\" scripts."
  name         = "Project[0].SystemPrompt"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_library_variable_sets" "library_variable_set_variables_octoai_prompts" {
  ids          = null
  partial_name = "OctoAI Prompts"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_library_variable_set" "library_variable_set_variables_octoai_prompts" {
  count       = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_octoai_prompts.library_variable_sets) != 0 ? 0 : 1}"
  name        = "OctoAI Prompts"
  description = "The variables maintained by this library variable set are consumed by the AI integration."
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_library_variable_sets" "library_variable_set_scriptmodule_script_module" {
  ids          = null
  partial_name = "Script module"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_script_module" "library_variable_set_scriptmodule_script_module" {
  count       = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_scriptmodule_script_module.library_variable_sets) != 0 ? 0 : 1}"
  description = ""
  name        = "Script module"

  script {
    body   = "function Say-Hello()\r\n{\r\n    Write-Output \"Hello, Octopus!\"\r\n}\r\n"
    syntax = "PowerShell"
  }
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_library_variable_sets" "library_variable_set_variables_tenant_settings" {
  ids          = null
  partial_name = "Tenant Settings"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_library_variable_set" "library_variable_set_variables_tenant_settings" {
  count       = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_tenant_settings.library_variable_sets) != 0 ? 0 : 1}"
  name        = "Tenant Settings"
  description = ""

  template {
    name             = "TenantNamespace"
    label            = "Tenant Namespace"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "SingleLineText" }
  }
  lifecycle {
    prevent_destroy = true
  }
}


