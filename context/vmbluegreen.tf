provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.5.0" }
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

data "octopusdeploy_project_groups" "project_group_blue_green_single_server___environment" {
  ids          = null
  partial_name = "${var.project_group_blue_green_single_server___environment_name}"
  skip         = 0
  take         = 1
}
variable "project_group_blue_green_single_server___environment_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Blue/Green Single Server - Environment"
}
resource "octopusdeploy_project_group" "project_group_blue_green_single_server___environment" {
  count = "${length(data.octopusdeploy_project_groups.project_group_blue_green_single_server___environment.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_blue_green_single_server___environment_name}"
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
  allow_dynamic_infrastructure = false
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
  allow_dynamic_infrastructure = false
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

data "octopusdeploy_environments" "environment_production___blue" {
  ids          = null
  partial_name = "Production - Blue"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_production___blue" {
  count                        = "${length(data.octopusdeploy_environments.environment_production___blue.environments) != 0 ? 0 : 1}"
  name                         = "Production - Blue"
  description                  = ""
  allow_dynamic_infrastructure = false
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

data "octopusdeploy_environments" "environment_production___green" {
  ids          = null
  partial_name = "Production - Green"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_environment" "environment_production___green" {
  count                        = "${length(data.octopusdeploy_environments.environment_production___green.environments) != 0 ? 0 : 1}"
  name                         = "Production - Green"
  description                  = ""
  allow_dynamic_infrastructure = false
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
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_test,octopusdeploy_environment.environment_production___blue]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_lifecycles" "lifecycle_blue_green" {
  ids          = null
  partial_name = "Blue Green"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_blue_green" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_blue_green.lifecycles) != 0 ? 0 : 1}"
  name        = "Blue Green"
  description = ""

  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    name                                  = "Development"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0

    release_retention_policy {
      quantity_to_keep = 5
      unit             = "Days"
    }
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
    name                                  = "Test"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0

    release_retention_policy {
      quantity_to_keep = 5
      unit             = "Days"
    }
  }
  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_production___blue.environments) != 0 ? data.octopusdeploy_environments.environment_production___blue.environments[0].id : octopusdeploy_environment.environment_production___blue[0].id}", "${length(data.octopusdeploy_environments.environment_production___green.environments) != 0 ? data.octopusdeploy_environments.environment_production___green.environments[0].id : octopusdeploy_environment.environment_production___green[0].id}"]
    name                                  = "Production"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0

    release_retention_policy {
      quantity_to_keep = 5
      unit             = "Days"
    }
  }

  release_retention_policy {
    quantity_to_keep = 5
    unit             = "Days"
  }

  tentacle_retention_policy {
    quantity_to_keep = 1
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

data "octopusdeploy_channels" "channel_random_quotes__net_iis_default" {
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
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_test,octopusdeploy_environment.environment_production___blue,octopusdeploy_environment.environment_production___green]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_blue_green_deployment" {
  website = "https://library.octopus.com/step-templates/72db001f-ae7f-4a0f-b952-5f80e2fc4cd2"
}
data "octopusdeploy_step_template" "steptemplate_octopus___check_blue_green_deployment" {
  name = "Octopus - Check Blue Green Deployment"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_blue_green_deployment" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_blue_green_deployment.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_blue_green_deployment.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_octopus___check_blue_green_deployment.step_template != null ? 0 : 1}"
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

resource "octopusdeploy_process" "process_random_quotes__net_iis" {
  count      = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id : octopusdeploy_project.project_random_quotes__net_iis[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_templated_step" "process_step_random_quotes__net_iis_octopus___check_blue_green_deployment" {
  count                 = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check Blue Green Deployment"
  process_id            = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process.process_random_quotes__net_iis[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_blue_green_deployment.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_blue_green_deployment.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_blue_green_deployment[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_blue_green_deployment.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_blue_green_deployment.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_blue_green_deployment[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-blue-green-deployment"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Workerpool.Default"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "BlueGreen.Environment.Blue.Name" = "Production - Blue"
        "BlueGreen.Octopus.Api.Key" = "#{Project.Octopus.Api.Key}"
        "BlueGreen.Environment.Green.Name" = "Production - Green"
      }
}

resource "octopusdeploy_process_step" "process_step_random_quotes__net_iis_approve_production_deployment" {
  count                 = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  name                  = "Approve Production Deployment"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process.process_random_quotes__net_iis[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_production___blue.environments) != 0 ? data.octopusdeploy_environments.environment_production___blue.environments[0].id : octopusdeploy_environment.environment_production___blue[0].id}", "${length(data.octopusdeploy_environments.environment_production___green.environments) != 0 ? data.octopusdeploy_environments.environment_production___green.environments[0].id : octopusdeploy_environment.environment_production___green[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  excluded_environments = null
  notes                 = "This step pauses the deployment and waits for approval before continuing."
  package_requirement   = "LetOctopusDecide"
  slug                  = "approve-production-deployment"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the production deployment?\n\n#{if Octopus.Action[Octopus - Check Blue Green Deployment].Output.SequentialDeploy}WARNING! You appear to be deploying to the #{Octopus.Environment.Name} environment twice. It is expected that blue/green deployments alternate between environments.#{/if}"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_random_quotes__net_iis_octopus___check_targets_available" {
  count                 = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check Targets Available"
  process_id            = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process.process_random_quotes__net_iis[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_targets_available[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_targets_available[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step checks that deployment targets are present, and if not, displays a link to the documentation."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-targets-available"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Workerpool.Default"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "CheckTargets.Octopus.Role" = "randomquotes-iis-website"
        "CheckTargets.Octopus.Api.Key" = "#{Project.Octopus.Api.Key}"
        "CheckTargets.Message" = "See the [documentation](https://octopus.com/docs/infrastructure/deployment-targets) for details on creating targets."
      }
}

resource "octopusdeploy_process_templated_step" "process_step_random_quotes__net_iis_octopus___check_smtp_server_configured" {
  count                 = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check SMTP Server Configured"
  process_id            = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process.process_random_quotes__net_iis[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step checks that the SMTP server is configured, and if not, provides a link to the documentation."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-smtp-server-configured"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Workerpool.Default"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "SmtpCheck.Octopus.Api.Key" = "#{Project.Octopus.Api.Key}"
      }
}

variable "project_random_quotes__net_iis_step_transfer_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Transfer a Package in project Random Quotes .NET IIS"
  default     = "com.octopus:randomquotes-dotnet"
}
resource "octopusdeploy_process_step" "process_step_random_quotes__net_iis_transfer_a_package" {
  count                 = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  name                  = "Transfer a Package"
  type                  = "Octopus.TransferPackage"
  process_id            = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process.process_random_quotes__net_iis[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Transfers a package to the VM."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_random_quotes__net_iis_step_transfer_a_package_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "transfer-a-package"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "randomquotes-web-iis"
      }
  execution_properties  = {
        "Octopus.Action.Package.TransferPath" = "C:\\New folder\\#{Octopus.Action.Package.PackageId}.#{Octopus.Action.Package.PackageVersion}.zip"
      }
}

resource "octopusdeploy_process_step" "process_step_random_quotes__net_iis_send_an_email_on_success" {
  count                 = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  name                  = "Send an Email on Success"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process.process_random_quotes__net_iis[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = null
  notes                 = "Sends an email when the deployment is successful."
  package_requirement   = "LetOctopusDecide"
  slug                  = "send-an-email-on-success"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{Octopus.Action[Octopus - Check SMTP Server Configured].Output.SmtpConfigured}"
      }
  execution_properties  = {
        "Octopus.Action.Email.Subject" = "#{Octopus.Project.Name} succeeded!"
        "Octopus.Action.Email.Body" = "The deployment succeeded."
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Email.To" = "releases@example.org"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_random_quotes__net_iis" {
  count      = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process.process_random_quotes__net_iis[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_random_quotes__net_iis_octopus___check_blue_green_deployment[0].id}", "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process_step.process_step_random_quotes__net_iis_approve_production_deployment[0].id}", "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_random_quotes__net_iis_octopus___check_targets_available[0].id}", "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_random_quotes__net_iis_octopus___check_smtp_server_configured[0].id}", "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process_step.process_step_random_quotes__net_iis_transfer_a_package[0].id}", "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? null : octopusdeploy_process_step.process_step_random_quotes__net_iis_send_an_email_on_success[0].id}"]
}

resource "octopusdeploy_variable" "random_quotes__net_iis_prject_iis_application_pool_1" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "RandomQuotes-Blue"
  name         = "Prject.IIS.Application.Pool"
  type         = "String"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___blue.environments) != 0 ? data.octopusdeploy_environments.environment_production___blue.environments[0].id : octopusdeploy_environment.environment_production___blue[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_prject_iis_application_pool_2" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "RandomQuotes-Green"
  name         = "Prject.IIS.Application.Pool"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___green.environments) != 0 ? data.octopusdeploy_environments.environment_production___green.environments[0].id : octopusdeploy_environment.environment_production___green[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_project_iis_binding_port_1" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "81"
  name         = "Project.IIS.Binding.Port"
  type         = "String"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___blue.environments) != 0 ? data.octopusdeploy_environments.environment_production___blue.environments[0].id : octopusdeploy_environment.environment_production___blue[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_project_iis_binding_port_2" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "82"
  name         = "Project.IIS.Binding.Port"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___green.environments) != 0 ? data.octopusdeploy_environments.environment_production___green.environments[0].id : octopusdeploy_environment.environment_production___green[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_project_iis_website_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "RandomQuotes-Blue"
  name         = "Project.IIS.Website.Name"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___blue.environments) != 0 ? data.octopusdeploy_environments.environment_production___blue.environments[0].id : octopusdeploy_environment.environment_production___blue[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_project_iis_website_name_2" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "RandomQuotes-Green"
  name         = "Project.IIS.Website.Name"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___green.environments) != 0 ? data.octopusdeploy_environments.environment_production___green.environments[0].id : octopusdeploy_environment.environment_production___green[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_project_iis_path_1" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "C:\\inetpub\\wwwroot\\randomquotes-blue"
  name         = "Project.IIS.Path"
  type         = "String"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___blue.environments) != 0 ? data.octopusdeploy_environments.environment_production___blue.environments[0].id : octopusdeploy_environment.environment_production___blue[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_project_iis_path_2" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "C:\\inetpub\\wwwroot\\randomquotes-green"
  name         = "Project.IIS.Path"
  type         = "String"
  description  = ""
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = ["${length(data.octopusdeploy_environments.environment_production___green.environments) != 0 ? data.octopusdeploy_environments.environment_production___green.environments[0].id : octopusdeploy_environment.environment_production___green[0].id}"]
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

resource "octopusdeploy_variable" "random_quotes__net_iis_appsettings_environmentname_1" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "#{Octopus.Environment.Name}"
  name         = "AppSettings:EnvironmentName"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "random_quotes__net_iis_appsettings_appversion_1" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "#{Octopus.Release.Number}"
  name         = "AppSettings:AppVersion"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "random_quotes__net_iis_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
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

resource "octopusdeploy_variable" "random_quotes__net_iis_project_workerpool_default_1" {
  count        = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) == 0 ?octopusdeploy_project.project_random_quotes__net_iis[0].id : data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  name         = "Project.Workerpool.Default"
  type         = "WorkerPool"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "project_random_quotes__net_iis_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Random Quotes .NET IIS"
  default     = "Random Quotes .NET IIS"
}
variable "project_random_quotes__net_iis_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Random Quotes .NET IIS"
  default     = ""
}
variable "project_random_quotes__net_iis_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Random Quotes .NET IIS"
  default     = ""
}
variable "project_random_quotes__net_iis_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Random Quotes .NET IIS"
  default     = "Deploys the .NET version of Random Quotes using the Blue/Green environment pattern to a single server with multiple applications.  [Build definition](https://github.com/OctopusSamples/RandomQuotes).\n\nRecreate this project with the AI Assistant using the prompt:\n\n `Create a VM Blue/Green project called \"My VM Blue Green Project\"`"
}
variable "project_random_quotes__net_iis_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_random_quotes__net_iis" {
  ids          = null
  partial_name = "${var.project_random_quotes__net_iis_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_random_quotes__net_iis" {
  count                                = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_random_quotes__net_iis_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_blue_green.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_blue_green.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_blue_green[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_blue_green_single_server___environment.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_blue_green_single_server___environment.project_groups[0].id : octopusdeploy_project_group.project_group_blue_green_single_server___environment[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_random_quotes__net_iis_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_random_quotes__net_iis_description_prefix}${var.project_random_quotes__net_iis_description}${var.project_random_quotes__net_iis_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_random_quotes__net_iis" {
  count      = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_random_quotes__net_iis.projects) != 0 ? data.octopusdeploy_projects.project_random_quotes__net_iis.projects[0].id : octopusdeploy_project.project_random_quotes__net_iis[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


