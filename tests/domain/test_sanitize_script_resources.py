import unittest

from domain.sanitizers.terraform import fix_script_source


class SanitizeScriptResourcesTest(unittest.TestCase):
    def test_no_script(self):
        config = 'resource "octopusdeploy_project" "project" {}'
        self.assertEqual(fix_script_source(config), config)

    def test_inline_script(self):
        config = """resource "octopusdeploy_process_step" "process_step_aws_lambda_attempt_login" {
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
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Script.ScriptBody" = "aws sts get-caller-identity"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}"""

        self.assertEqual(fix_script_source(config), config)

    def test_mixed_inline_script(self):
        config = """resource "octopusdeploy_process_step" "process_step_aws_lambda_attempt_login" {
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
  primary_package = {}
  execution_properties  = {
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Script.ScriptBody" = "aws sts get-caller-identity"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptFileName" = "CreaeResourceGroup.ps1"
      }
}"""

        fixed = fix_script_source(config)

        self.assertTrue("primary_package" not in fixed)
        self.assertTrue("Octopus.Action.Script.ScriptFileName" not in fixed)

    def test_mixed_package_script(self):
        config = """resource "octopusdeploy_process_step" "process_step_aws_lambda_attempt_login" {
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
  primary_package = {}
  execution_properties  = {
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Script.ScriptBody" = "aws sts get-caller-identity"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Script.ScriptSource" = "Package"
        "Octopus.Action.Script.ScriptFileName" = "CreaeResourceGroup.ps1"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
}"""

        fixed = fix_script_source(config)

        self.assertTrue("primary_package" in fixed)
        self.assertTrue("Octopus.Action.Script.ScriptBody" not in fixed)
        self.assertTrue("Octopus.Action.Script.Syntax" not in fixed)

    def test_bad_indents_script(self):
        # Note the space before the final closing brace
        config = """resource "octopusdeploy_process_step" "process_step_aws_lambda_attempt_login" {
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
  primary_package = {}
  execution_properties  = {
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Script.ScriptBody" = "aws sts get-caller-identity"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptFileName" = "CreaeResourceGroup.ps1"
      }
   }"""

        self.assertEqual(fix_script_source(config), config)

    def test_bad_indents_script_2(self):
        # Note the space before the resource
        config = """  resource "octopusdeploy_process_step" "process_step_aws_lambda_attempt_login" {
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
  primary_package = {}
  execution_properties  = {
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Script.ScriptBody" = "aws sts get-caller-identity"
        "Octopus.Action.Aws.Region" = "#{Project.AWS.Region}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.AwsAccount.Variable" = "Project.AWS.Account"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptFileName" = "CreaeResourceGroup.ps1"
      }
}"""

        self.assertEqual(fix_script_source(config), config)
