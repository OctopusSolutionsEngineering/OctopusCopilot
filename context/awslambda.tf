provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.0.1" }
  }
  required_version = ">= 1.6.0"
}

variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
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

data "octopusdeploy_channels" "channel_aws_lambda_default" {
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

resource "octopusdeploy_process" "process_aws_lambda" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_attempt_login" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Attempt Login"
  type                  = "Octopus.AwsRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}", image = "octopuslabs/aws-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step runs an AWS CLI command to get the current user. It will only succeed if the AWS account is correctly configured. We can use the success or failure of this step to determine if the AWS account is correctly configured."
  package_requirement   = "LetOctopusDecide"
  slug                  = "attempt-login"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.ScriptBody" = "# Get the current AWS user. This will only succeed if the AWS account is valid.\n# If the AWS account is not valid, this step will fail. We can detect the failure and offer next steps.\naws sts get-caller-identity"
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_validate_setup" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Validate setup"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Always"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step detects any default values that must be updated before a deployment to AWS can be performed."
  package_requirement   = "LetOctopusDecide"
  slug                  = "validate-setup"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/aws/ValidateLambdaSetup.ps1"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_check_smtp_configuration" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Check SMTP configuration"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step checks to see if SMTP has been configured.  It sets an output variable that can be used in subsequent steps that send email."
  package_requirement   = "LetOctopusDecide"
  slug                  = "check-smtp-configuration"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/CheckSMTPConfigured.ps1"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_send_deployment_start_notification" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Send deployment start notification"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = null
  notes                 = "This step sends an email notification that the deployment has started.  It only runs when the output variable `Octopus.Action[Check SMTP configuration].Output.SmtpConfigured` is set to true."
  package_requirement   = "LetOctopusDecide"
  slug                  = "send-deployment-start-notification"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Check SMTP configuration].Output.SmtpConfigured == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "Octopus.Action.Email.Body" = "#{Octopus.Project.Name} release version #{Octopus.Release.Number} is deploying to #{Octopus.Environment.Name}"
        "Octopus.Action.Email.Subject" = "#{Octopus.Project.Name} is deploying to #{Octopus.Environment.Name}"
        "Octopus.Action.Email.To" = "#{Octopus.Deployment.CreatedBy.EmailAddress}"
        "Octopus.Action.RunOnServer" = "false"
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_approve_production_deployment" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Approve Production Deployment"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  excluded_environments = null
  notes                 = "This manual intervention is used to provide a prompt before a production deployment."
  package_requirement   = "LetOctopusDecide"
  slug                  = "approve-production-deployment"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate setup].Output.AwsLambdaConfigured == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "Octopus.Action.Manual.Instructions" = "Do you approve the production deployment?"
        "Octopus.Action.RunOnServer" = "false"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
      }
}

variable "project_aws_lambda_step_upload_lambda_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Upload Lambda in project AWS Lambda"
  default     = "com.octopus:products-microservice-lambda-jvm"
}
resource "octopusdeploy_process_step" "process_step_aws_lambda_upload_lambda" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Upload Lambda"
  type                  = "Octopus.AwsUploadS3"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Variable"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}", image = "octopuslabs/aws-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Upload the Lambda application packages to the specified S3 bucket."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_aws_lambda_step_upload_lambda_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "upload-lambda"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate setup].Output.AwsLambdaConfigured == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "Octopus.Action.Aws.S3.TargetMode" = "EntirePackage"
        "Octopus.Action.Aws.S3.BucketName" = "#{Project.AWS.Lambda.S3.BucketName}"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
        "bucketKeyBehaviour" = "Custom"
        "cannedAcl" = "private"
        "variableSubstitutionPatterns" = ""
        "structuredVariableSubstitutionPatterns" = ""
        "tags" = []
        "bucketKey" = "#{Project.AWS.Lambda.S3.FileName}"
        "bucketKeyPrefix" = ""
        "storageClass" = "STANDARD"
        "metadata" = []
        "autoFocus" = "true"
                })
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Aws.AssumeRole" = "False"
      }
}

variable "project_aws_lambda_step_deploy_lambda_sam_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Lambda SAM template in project AWS Lambda"
  default     = "com.octopus:products-microservice-awssam"
}
resource "octopusdeploy_process_step" "process_step_aws_lambda_deploy_lambda_sam_template" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Deploy Lambda SAM template"
  type                  = "Octopus.AwsRunCloudFormation"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Variable"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}", image = "octopuslabs/aws-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Stacks deploying Lambda versions must have unique names to ensure a new version is created each time. This step deploys a uniquely named [AWS SAM tooling](https://aws.amazon.com/serverless/sam/) stack, creating a version of the Lambda uploaded in the last step."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_aws_lambda_step_deploy_lambda_sam_template_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-lambda-sam-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate setup].Output.AwsLambdaConfigured == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "Octopus.Action.EnabledFeatures" = "Octopus.Features.JsonConfigurationVariables"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "Octopus.Action.Aws.CloudFormationStackName" = "#{Octopus.Space.Name | Replace \"[^A-Za-z0-9]\" \"-\"}-OctopubProductsSAMLambda-#{Octopus.Deployment.Id | Replace -}-#{Octopus.Environment.Name}"
        "Octopus.Action.Aws.IamCapabilities" = jsonencode([
        "CAPABILITY_AUTO_EXPAND",
        "CAPABILITY_IAM",
        "CAPABILITY_NAMED_IAM",
        ])
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.CloudFormationTemplate" = "sam.jvm.yaml"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Package.JsonConfigurationVariablesTargets" = "sam.jvm.yaml"
        "Octopus.Action.Aws.TemplateSource" = "Package"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.CloudFormation.Tags" = jsonencode([
        {
        "key" = "OctopusTenantId"
        "value" = "#{if Octopus.Deployment.Tenant.Id}#{Octopus.Deployment.Tenant.Id}#{/if}#{unless Octopus.Deployment.Tenant.Id}untenanted#{/unless}"
                },
        {
        "key" = "OctopusStepId"
        "value" = "#{Octopus.Step.Id}"
                },
        {
        "key" = "OctopusRunbookRunId"
        "value" = "#{if Octopus.RunBookRun.Id}#{Octopus.RunBookRun.Id}#{/if}#{unless Octopus.RunBookRun.Id}none#{/unless}"
                },
        {
        "value" = "#{if Octopus.Deployment.Id}#{Octopus.Deployment.Id}#{/if}#{unless Octopus.Deployment.Id}none#{/unless}"
        "key" = "OctopusDeploymentId"
                },
        {
        "key" = "OctopusProjectId"
        "value" = "#{Octopus.Project.Id}"
                },
        {
        "key" = "OctopusEnvironmentId"
        "value" = "#{Octopus.Environment.Id}"
                },
        {
        "key" = "Environment"
        "value" = "#{Octopus.Environment.Name}"
                },
        {
        "key" = "DeploymentProject"
        "value" = "#{Octopus.Project.Name}"
                },
        ])
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_print_message_when_no_targets" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Print Message When no Targets"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step detects when the previous steps were skipped due to no targets being defined and prints a message with a link to documentation for creating targets."
  package_requirement   = "LetOctopusDecide"
  slug                  = "print-message-when-no-targets"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptBody" = "# The variable to check must be in the format\n# #{Octopus.Step[\u003cname of the step that deploys the lambda\u003e].Status.Code}\nif (\"#{Octopus.Step[Deploy AWS Lambda function].Status.Code}\" -ieq \"Skipped\") {\n  Write-Highlight \"To complete the deployment, you must have the necessary AWS Lambda configuration.\"\n  Write-Highlight \"See details of the [required configuration](https://library.octopus.com/step-templates/9b5ee984-bdd2-49f0-a78a-07e21e60da8a/actiontemplate-aws-deploy-lambda-function).\"\n}"
      }
}

variable "project_aws_lambda_step_scan_for_vulnerabilities_package_products_microservice_lambda_jvm_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named products-microservice-lambda-jvm from step Scan for Vulnerabilities in project AWS Lambda"
  default     = "com.octopus:products-microservice-lambda-jvm"
}
resource "octopusdeploy_process_step" "process_step_aws_lambda_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Always"
  environments          = null
  excluded_environments = null
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step extracts the Docker image, finds any bom.json files, and scans them for vulnerabilities using Trivy. \n\nThis step is expected to be run with each deployment to ensure vulnerabilities are discovered as early as possible. \n\nIt is also run daily via a project trigger that reruns the deployment in the Security environment. This allows unknown vulnerabilities to be discovered after a production deployment."
  package_requirement   = "LetOctopusDecide"
  packages              = { products-microservice-lambda-jvm = { acquisition_location = "ExecutionTarget", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_aws_lambda_step_scan_for_vulnerabilities_package_products_microservice_lambda_jvm_packageid}", properties = { Extract = "True", Purpose = "", SelectionMode = "immediate" } } }
  slug                  = "scan-for-vulnerabilities"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptFileName" = "octopus/DirectorySbomScan.ps1"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GitRepository.Source" = "External"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_aws_lambda" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_attempt_login[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_validate_setup[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_check_smtp_configuration[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_send_deployment_start_notification[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_approve_production_deployment[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_upload_lambda[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_deploy_lambda_sam_template[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_print_message_when_no_targets[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_scan_for_vulnerabilities[0].id}"]
}

resource "octopusdeploy_variable" "aws_lambda_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
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

resource "octopusdeploy_variable" "aws_lambda_project_aws_account_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_aws_oidc.accounts) != 0 ? data.octopusdeploy_accounts.account_aws_oidc.accounts[0].id : octopusdeploy_aws_openid_connect_account.account_aws_oidc[0].id}"
  name         = "Project.AWS.Account"
  type         = "AmazonWebServicesAccount"
  description  = "The Account to use to authenticate to AWS."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "aws_lambda_project_aws_region_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "eu-west-2"
  name         = "Project.AWS.Region"
  type         = "String"
  description  = "The AWS region that will host the AWS Lambda function."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "aws_lambda_project_aws_lambda_s3_bucketname_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "#{Octopus.Space.Name | Replace \"[^A-Za-z0-9]\" \"-\" | ToLower}-octopubs3-#{Octopus.Environment.Name | ToLower}"
  name         = "Project.AWS.Lambda.S3.BucketName"
  type         = "String"
  description  = "The AWS S3 Bucket name to store the Lambda package"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "aws_lambda_project_aws_lambda_s3_filename_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "octopub-products-microservice-lambda-jvm.#{Octopus.Action[Upload Lambda].Package.PackageVersion}.zip"
  name         = "Project.AWS.Lambda.S3.FileName"
  type         = "String"
  description  = "The filename for the AWS Lambda to be uploaded to S3"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "aws_lambda_resources_productsmicroservice_properties_codeuri_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "#{Octopus.Action[Upload Lambda].Output.Package.S3Uri}"
  name         = "Resources:ProductsMicroservice:Properties:CodeUri"
  type         = "String"
  description  = "The path to the AWS lambda function in the specified s3 bucket"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_aws_lambda_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = "This trigger reruns the deployment in the Security environment. This means any new vulnerabilities detected after a production deployment will be identified."
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
  tenant_ids  = []

  once_daily_schedule {
    start_time   = "2025-05-08T09:00:00"
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

resource "octopusdeploy_process" "process_aws_lambda_checkov_sam_static_analysis" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
  runbook_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_runbook.runbook_aws_lambda_checkov_sam_static_analysis[0].id}"
  depends_on = []
}

variable "project_checkov_sam_static_analysis_step_run_checkov_static_analysis_scan_package_products_microservice_awssam_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named products-microservice-awssam from step Run Checkov static analysis scan in project Checkov SAM Static Analysis"
  default     = "com.octopus:products-microservice-awssam"
}
resource "octopusdeploy_process_step" "process_step_aws_lambda_checkov_sam_static_analysis_run_checkov_static_analysis_scan" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Run Checkov static analysis scan"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda_checkov_sam_static_analysis[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "", git_credential_type = "Anonymous", repository_uri = "https://github.com/OctopusSolutionsEngineering/Octopub.git" } }
  notes                 = "This step extracts SAM YAML files and scans them for security and compliance misconfigurations in your SAM CloudFormation template files. \n\nThis step is expected to be run as a routine operations task (a runbook) to ensure any potential issues can be reported."
  package_requirement   = "LetOctopusDecide"
  packages              = { products-microservice-awssam = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_checkov_sam_static_analysis_step_run_checkov_static_analysis_scan_package_products_microservice_awssam_packageid}", properties = { Extract = "True", Purpose = "", SelectionMode = "immediate" } } }
  slug                  = "run-checkov-static-analysis-scan"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptFileName" = "octopus/RunCheckovScan.ps1"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GitRepository.Source" = "External"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_aws_lambda_checkov_sam_static_analysis" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda_checkov_sam_static_analysis[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_checkov_sam_static_analysis_run_checkov_static_analysis_scan[0].id}"]
}

variable "runbook_aws_lambda_checkov_sam_static_analysis_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Checkov SAM Static Analysis"
  default     = "Checkov SAM Static Analysis"
}
resource "octopusdeploy_runbook" "runbook_aws_lambda_checkov_sam_static_analysis" {
  count                       = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_aws_lambda_checkov_sam_static_analysis_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
  environment_scope           = "All"
  environments                = []
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "Uses `checkov`, a static analysis tool to help identify any security and compliance misconfigurations in your SAM CloudFormation template files."
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

variable "project_aws_lambda_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from AWS Lambda"
  default     = "AWS Lambda"
}
variable "project_aws_lambda_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project AWS Lambda"
  default     = ""
}
variable "project_aws_lambda_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project AWS Lambda"
  default     = ""
}
variable "project_aws_lambda_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from AWS Lambda"
  default     = "This project provides an example AWS Lambda deployment using an AWS OIDC Account, and SBOM scanning to an AWS Lambda function."
}
variable "project_aws_lambda_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_aws_lambda" {
  ids          = null
  partial_name = "${var.project_aws_lambda_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_aws_lambda" {
  count                                = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_aws_lambda_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_aws.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_aws.project_groups[0].id : octopusdeploy_project_group.project_group_aws[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_aws_lambda_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
  }
  description = "${var.project_aws_lambda_description_prefix}${var.project_aws_lambda_description}${var.project_aws_lambda_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


