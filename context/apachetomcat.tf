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
  count       = "${length(data.octopusdeploy_project_groups.project_group_aws.project_groups) != 0 ? 0 : 1}"
  name        = "${var.project_group_aws_name}"
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
    quantity_to_keep = 5
    unit             = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep = 5
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
  api_version                          = ""
  feed_uri                             = "https://ghcrfacade-a6awccayfpcpg4cg.eastus-01.azurewebsites.net"
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

resource "octopusdeploy_process" "process_aws_lambda" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
  depends_on = []
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
  notes                 = "This step pauses the deployment and waits for approval before continuing."
  package_requirement   = "LetOctopusDecide"
  slug                  = "approve-production-deployment"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate setup].Output.AwsLambdaConfigured == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "Octopus.Action.Manual.Instructions" = "Do you approve the production deployment?"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_aws_lambda_octopus___check_smtp_server_configured" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check SMTP Server Configured"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Confirms that the SMTP server has been configured."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-smtp-server-configured"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "SmtpCheck.Octopus.Api.Key" = "#{Project.Octopus.Api.Key}"
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_attempt_login" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Attempt Login"
  type                  = "Octopus.AwsRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step runs an AWS CLI command to get the current user. It will only succeed if the AWS account is correctly configured. We can use the success or failure of this step to determine if the AWS account is correctly configured."
  package_requirement   = "LetOctopusDecide"
  slug                  = "attempt-login"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "aws sts get-caller-identity"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_validate_setup" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Validate Setup"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Always"
  environments          = null
  excluded_environments = null
  notes                 = "This step validates that the required variables have been defined."
  package_requirement   = "LetOctopusDecide"
  slug                  = "validate-setup"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "$errors = @()\n\nif (\"#{Octopus.Step[Attempt Login].Status.Code}\" -ne \"Succeeded\") {\n    $errors += \"The previous step failed, which indicates the AWS Account is not valid.\", \n               \"We recommend using an [AWS OIDC Account](https://octopus.com/docs/infrastructure/accounts/aws#configuring-aws-oidc-account) type to authenticate with AWS.\"\n}\n\nif ([string]::IsNullOrWhitespace(\"#{Project.AWS.Region}\")) {\n    $errors += \"The project variable Project.AWS.Region has not been configured.\",\n               \"See the [AWS documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/create-function.html#options) for details on region.\"\n}\n\nif ([string]::IsNullOrWhitespace(\"#{Project.AWS.Lambda.FunctionName}\")) {\n    $errors += \"The project variable Project.AWS.Lambda.FunctionName has not been configured.\",\n               \"See the [AWS documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/create-function.html#options) for details on function name.\"\n}\n\nif ([string]::IsNullOrWhitespace(\"#{Project.AWS.Lambda.S3.BucketName}\")) {\n    $errors += \"The project variable Project.AWS.Lambda.S3.BucketName has not been configured.\",\n               \"See the [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-function-zip.html#configuration-function-update) for details on storing your function code in an S3 bucket.\"\n}\n\nif ($errors.Count -gt 0) {\n    Write-Highlight ($errors -join \"`n\")\n    Set-OctopusVariable -name \"AwsLambdaConfigured\" -value \"False\"\n} else {\n    Write-Host \"All AWS checks succeeded!\"\n    Set-OctopusVariable -name \"AwsLambdaConfigured\" -value \"True\"\n}"
        "OctopusUseBundledTooling" = "False"
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
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Upload the Lambda application packages to the specified S3 bucket."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_aws_lambda_step_upload_lambda_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "upload-lambda"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Aws.S3.TargetMode" = "EntirePackage"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
        "bucketKeyPrefix" = ""
        "cannedAcl" = "private"
        "bucketKey" = "#{Project.AWS.Lambda.S3.FileName}"
        "metadata" = []
        "storageClass" = "STANDARD"
        "structuredVariableSubstitutionPatterns" = ""
        "tags" = []
        "variableSubstitutionPatterns" = ""
        "autoFocus" = "true"
        "bucketKeyBehaviour" = "Custom"
                })
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.S3.BucketName" = "#{Project.AWS.Lambda.S3.BucketName}"
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
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Stacks deploying Lambda versions must have unique names to ensure a new version is created each time. This step deploys a uniquely named [AWS SAM tooling](https://aws.amazon.com/serverless/sam/) stack, creating a version of the Lambda uploaded in the last step."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_aws_lambda_step_deploy_lambda_sam_template_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-lambda-sam-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Aws.CloudFormationStackName" = "#{Octopus.Space.Name | Replace \"[^A-Za-z0-9]\" \"-\"}-OctopubProductsSAMLambda-#{Octopus.Deployment.Id | Replace -}-#{Octopus.Environment.Name}"
        "Octopus.Action.Package.JsonConfigurationVariablesTargets" = "sam.jvm.yaml"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.IamCapabilities" = jsonencode([
        "CAPABILITY_AUTO_EXPAND",
        "CAPABILITY_IAM",
        "CAPABILITY_NAMED_IAM",
        ])
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
        "key" = "OctopusDeploymentId"
        "value" = "#{if Octopus.Deployment.Id}#{Octopus.Deployment.Id}#{/if}#{unless Octopus.Deployment.Id}none#{/unless}"
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
        "value" = "#{Octopus.Environment.Name}"
        "key" = "Environment"
                },
        {
        "key" = "DeploymentProject"
        "value" = "#{Octopus.Project.Name}"
                },
        ])
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.TemplateSource" = "Package"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Aws.CloudFormationTemplate" = "sam.jvm.yaml"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.EnabledFeatures" = "Octopus.Features.JsonConfigurationVariables"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_aws_lambda_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Scans the SBOM file embedded in the application package for known vulnerabilities."
  package_requirement   = "LetOctopusDecide"
  slug                  = "scan-for-vulnerabilities"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "Sbom.Package" = jsonencode({
        "PackageId" = "com.octopus:products-microservice-lambda-jvm"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
                })
      }
}

resource "octopusdeploy_process_step" "process_step_aws_lambda_deployment_success_notification" {
  count                 = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  name                  = "Deployment Success Notification"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = null
  notes                 = "Send an email when the deployment is completed successfully."
  package_requirement   = "LetOctopusDecide"
  slug                  = "deployment-success-notification"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{Octopus.Action[Octopus - Check SMTP Server Configured].Output.SmtpConfigured}"
      }
  execution_properties  = {
        "Octopus.Action.Email.Subject" = "Deployment for #{Octopus.Project.Name} completed successfully!"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Email.To" = "admin@example.org"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_aws_lambda" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process.process_aws_lambda[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_approve_production_deployment[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_aws_lambda_octopus___check_smtp_server_configured[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_attempt_login[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_validate_setup[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_upload_lambda[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_deploy_lambda_sam_template[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_aws_lambda_scan_for_vulnerabilities[0].id}", "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? null : octopusdeploy_process_step.process_step_aws_lambda_deployment_success_notification[0].id}"]
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
  role_arn                          = "arn:aws:iam::000000000000:role/RoleName"
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

resource "octopusdeploy_variable" "aws_lambda_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  name            = "Project.Octopus.Api.Key"
  type            = "Sensitive"
  description     = ""
  is_sensitive    = true
  sensitive_value = "Change Me!"
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

resource "octopusdeploy_variable" "aws_lambda_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
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
  default     = "This project provides an example AWS Lambda deployment using an AWS OIDC Account, and SBOM scanning to an AWS Lambda function.\n\nRecreate this project with the prompt:\n\n`Create an AWS Lambda project called \"AWS Lambda App\".`"
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
    target_roles                    = []
  }
  description = "${var.project_aws_lambda_description_prefix}${var.project_aws_lambda_description}${var.project_aws_lambda_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_aws_lambda" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


