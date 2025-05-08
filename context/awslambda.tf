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

variable "project_aws_lambda_step_deploy_aws_lambda_function_package_products_microservice_lambda_jvm_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named products-microservice-lambda-jvm from step Deploy AWS Lambda function in project AWS Lambda"
  default     = "com.octopus:products-microservice-lambda-jvm"
}
variable "project_aws_lambda_step_scan_for_vulnerabilities_package_products_microservice_lambda_jvm_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named products-microservice-lambda-jvm from step Scan for Vulnerabilities in project AWS Lambda"
  default     = "com.octopus:products-microservice-lambda-jvm"
}
resource "octopusdeploy_deployment_process" "deployment_process_aws_lambda" {
  count      = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? data.octopusdeploy_projects.project_aws_lambda.projects[0].id : octopusdeploy_project.project_aws_lambda[0].id}"

  step {
    condition           = "Success"
    name                = "Validate setup"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Validate setup"
      notes                              = "This step detects any default values that must be updated before a deployment to AWS can be performed."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptBody" = "# Define variables\n$errorCollection = @()\n\ntry\n{\n  $awsConfigured = $true\n\n  # Ensure AWS account is configured\n  Write-Output \"Verifying AWS Account has been configured ...\"\n\n  # Check the AWS Account properties\n  if (\"#{Project.AWS.Account.RoleArn}\" -ieq \"CHANGE ME\")\n  {\n    # Add to error messages\n    $errorCollection += @(\"The AWS Account Role Arn has not been configured.\")\n    $awsConfigured = $false\n  }\n\n  if (-not $awsConfigured) {\n    $errorCollection += @(\"We recommend using an [AWS OIDC Account](https://octopus.com/docs/infrastructure/accounts/aws#configuring-aws-oidc-account) type to authenticate with AWS.\")\n  }\n\n  Write-Output \"Checking to see if Project variables have been configured ...\"\n\n  if ([string]::IsNullOrWhitespace(\"#{Project.AWS.Region}\"))\n  {\n    $errorCollection += @(\n      \"The project variable Project.AWS.Region has not been configured.\",\n      \"See the [AWS documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/create-function.html#options) for details on region.\"\n    )\n  }\n\n  if ([string]::IsNullOrWhitespace(\"#{Project.AWS.Lambda.FunctionName}\"))\n  {\n    $errorCollection += @(\n      \"The project variable Project.AWS.Lambda.FunctionName has not been configured.\",\n      \"See the [AWS documentation](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/lambda/create-function.html#options) for details on function name.\"\n    )\n  }\n\n  if ([string]::IsNullOrWhitespace(\"#{Project.AWS.Lambda.FunctionRole}\"))\n  {\n    $errorCollection += @(\n      \"The project variable Project.AWS.Lambda.FunctionRole (ARN) has not been configured.\",\n      \"See the [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html) for details on Lambda function permissions using an execution role.\"\n    )\n  }\n\n}\ncatch\n{\n  Write-Verbose \"Fatal error occurred:\"\n  Write-Verbose \"$($_.Exception.Message)\"\n}\nfinally\n{\n  # Check to see if any errors were recorded\n  if ($errorCollection.Count -gt 0)\n  {\n    # Display the messages\n    Write-Highlight \"$($errorCollection -join \"`n\")\"\n\n    # Set output variable to skip Lambda deployment using variable run condition\n    Set-OctopusVariable -name \"AwsLambdaConfigured\" -value \"False\"\n\n  }\n  else\n  {\n    Write-Host \"All checks succeeded!\"\n    Set-OctopusVariable -name \"AwsLambdaConfigured\" -value \"True\"\n  }\n}"
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
    name                = "Approve Production Deployment"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Manual"
      name                               = "Approve Production Deployment"
      notes                              = "This manual intervention is used to provide a prompt before a production deployment."
      condition                          = "Success"
      run_on_server                      = false
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties                         = {
        "Octopus.Action.RunOnServer" = "false"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the production deployment?"
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
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Validate setup].Output.AwsLambdaConfigured == \"True\"}true#{/if}#{/unless}"
    name                 = "Deploy AWS Lambda function"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsRunScript"
      name                               = "Deploy AWS Lambda function"
      notes                              = "This step deploys an AWS Lambda function defined in a supplied package."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptFileName" = "octopus/aws-lambda-products-deploy.ps1"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_hub[0].id}"
        image   = "octopuslabs/aws-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      package {
        name                      = "products-microservice-lambda-jvm"
        package_id                = "${var.project_aws_lambda_step_deploy_aws_lambda_function_package_products_microservice_lambda_jvm_packageid}"
        acquisition_location      = "Server"
        extract_during_deployment = false
        feed_id                   = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
        properties                = { Extract = "False", Purpose = "", SelectionMode = "immediate" }
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
  step {
    condition           = "Success"
    name                = "Print Message When no Targets"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Print Message When no Targets"
      notes                              = "This step detects when the previous steps were skipped due to no targets being defined and prints a message with a link to documentation for creating targets."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptBody" = "# The variable to check must be in the format\n# #{Octopus.Step[\u003cname of the step that deploys the lambda\u003e].Status.Code}\nif (\"#{Octopus.Step[Deploy AWS Lambda function].Status.Code}\" -ieq \"Skipped\") {\n  Write-Highlight \"To complete the deployment, you must have the necessary AWS Lambda configuration.\"\n  Write-Highlight \"See details of the [required configuration](https://library.octopus.com/step-templates/9b5ee984-bdd2-49f0-a78a-07e21e60da8a/actiontemplate-aws-deploy-lambda-function).\"\n}"
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
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/DirectorySbomScan.ps1"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      package {
        name                      = "products-microservice-lambda-jvm"
        package_id                = "${var.project_aws_lambda_step_scan_for_vulnerabilities_package_products_microservice_lambda_jvm_packageid}"
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

resource "octopusdeploy_variable" "aws_lambda_project_aws_lambda_functionname_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "#{Octopus.Space.Name | Replace \"[^A-Za-z0-9]\" \"-\" | ToLower}-octopub-products-#{Octopus.Environment.Name | ToLower}"
  name         = "Project.AWS.Lambda.FunctionName"
  type         = "String"
  description  = "The name of the AWS Lambda function to create or update."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "aws_lambda_project_aws_lambda_functionrole_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "arn:aws:iam::381713788115:role/octoai-template-octopub-products-lambda-execution"
  name         = "Project.AWS.Lambda.FunctionRole"
  type         = "String"
  description  = "The Amazon Resource Name (ARN) of the function’s execution role."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "aws_lambda_project_aws_lambda_runtime_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "java17"
  name         = "Project.AWS.Lambda.Runtime"
  type         = "String"
  description  = "The identifier of the functions runtime."
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
  value        = "#{Octopus.Space.Name | Replace \"[^A-Za-z0-9]\" \"-\" | ToLower}-octopub-s3lambda"
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

resource "octopusdeploy_variable" "aws_lambda_project_aws_lambda_functionhandler_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "io.quarkus.amazon.lambda.runtime.QuarkusStreamHandler::handleRequest"
  name         = "Project.AWS.Lambda.FunctionHandler"
  type         = "String"
  description  = "The path to the Handler for the AWS Lambda"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "aws_lambda_project_aws_lambda_memorysize_1" {
  count        = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_aws_lambda.projects) == 0 ?octopusdeploy_project.project_aws_lambda[0].id : data.octopusdeploy_projects.project_aws_lambda.projects[0].id}"
  value        = "256"
  name         = "Project.AWS.Lambda.MemorySize"
  type         = "String"
  description  = "The amount of memory to allocate to the AWS Lambda Function."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_projects" "projecttrigger_aws_lambda_daily_security_scan" {
  ids          = null
  partial_name = "AWS Lambda"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_aws_lambda_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.projecttrigger_aws_lambda_daily_security_scan.projects) != 0 ? 0 : 1}"
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
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_security.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_security.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_security[0].id}"
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


