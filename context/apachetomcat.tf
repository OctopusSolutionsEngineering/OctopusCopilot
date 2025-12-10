provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.6.0" }
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

data "octopusdeploy_project_groups" "project_group_tomcat" {
  ids          = null
  partial_name = "${var.project_group_tomcat_name}"
  skip         = 0
  take         = 1
}
variable "project_group_tomcat_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Tomcat"
}
resource "octopusdeploy_project_group" "project_group_tomcat" {
  count = "${length(data.octopusdeploy_project_groups.project_group_tomcat.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_tomcat_name}"
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
  description = ""

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
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
    name                                  = "Security"
    is_optional_phase                     = false
    minimum_environments_before_promotion = 0
  }

  release_retention_policy {
    quantity_to_keep    = 0
    should_keep_forever = true
    unit                = "Items"
  }

  tentacle_retention_policy {
    quantity_to_keep    = 0
    should_keep_forever = true
    unit                = "Items"
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

data "octopusdeploy_channels" "channel_octopub_default" {
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

resource "octopusdeploy_process" "process_octopub" {
  count      = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? data.octopusdeploy_projects.project_octopub.projects[0].id : octopusdeploy_project.project_octopub[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_octopub_approve_production_deployment" {
  count                 = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  name                  = "Approve Production Deployment"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process.process_octopub[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  excluded_environments = null
  notes                 = "This step pauses the deployment and waits for approval before continuing"
  package_requirement   = "LetOctopusDecide"
  slug                  = "approve-production-deployment"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the deployment?"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_octopub_octopus___check_targets_available" {
  count                 = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check Targets Available"
  process_id            = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process.process_octopub[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_targets_available[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_targets_available.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_targets_available[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step checks that deployment targets are present, and if not, displays a link to the documentation.\n"
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-targets-available"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "CheckTargets.Octopus.Role" = "Tomcat.Web"
        "CheckTargets.Message" = "You must add a [Tentacle](https://octopus.com/docs/infrastructure/deployment-targets/tentacle) with the target tag `Tomcat.Web`."
        "CheckTargets.Octopus.Api.Key" = "#{Project.Octopus.Api.Key}"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_octopub_octopus___check_smtp_server_configured" {
  count                 = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check SMTP Server Configured"
  process_id            = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process.process_octopub[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step checks that the SMTP server is configured, and if not, provides a link to the documentation."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-smtp-server-configured"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
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

variable "project_octopub_step_deploy_to_tomcat_via_manager_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy to Tomcat via Manager in project Octopub"
  default     = "com.octopus:java-frontend"
}
variable "action_b5db3976a6058b846e2ef726ee139fcf26756a43d95da3aed7f951beadf6377a_sensitive_value" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "Sensitive value for property Tomcat.Deploy.Password"
  default     = "Change Me!"
}
resource "octopusdeploy_process_step" "process_step_octopub_deploy_to_tomcat_via_manager" {
  count                 = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  name                  = "Deploy to Tomcat via Manager"
  type                  = "Octopus.TomcatDeploy"
  process_id            = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process.process_octopub[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Deploys a WAR file to Tomcat via the manager."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_octopub_step_deploy_to_tomcat_via_manager_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-to-tomcat-via-manager"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{Octopus.Action[Octopus - Check Targets Available].Output.SetupValid}"
        "Octopus.Action.TargetRoles" = "Tomcat.Web"
      }
  execution_properties  = {
        "Tomcat.Deploy.Enabled" = "True"
        "Octopus.Action.EnabledFeatures" = ",Octopus.Features.TomcatDeployManager"
        "Tomcat.Deploy.Controller" = "http://localhost:8080/manager"
        "Tomcat.Deploy.User" = "admin"
        "Tomcat.Deploy.Name" = "octopub"
        "Tomcat.Deploy.Password" = "${var.action_b5db3976a6058b846e2ef726ee139fcf26756a43d95da3aed7f951beadf6377a_sensitive_value}"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_octopub_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  process_id            = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process.process_octopub[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Scans the SBOM for security vulnerabilities."
  package_requirement   = "LetOctopusDecide"
  slug                  = "scan-for-vulnerabilities"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
      }
  parameters            = {
        "Sbom.Package" = jsonencode({
        "PackageId" = "com.octopus:octopub-frontend-sbom"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
                })
      }
}

resource "octopusdeploy_process_step" "process_step_octopub_deployment_success_notification" {
  count                 = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  name                  = "Deployment Success Notification"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process.process_octopub[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
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

resource "octopusdeploy_process_steps_order" "process_step_order_octopub" {
  count      = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process.process_octopub[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process_step.process_step_octopub_approve_production_deployment[0].id}", "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_octopub_octopus___check_targets_available[0].id}", "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_octopub_octopus___check_smtp_server_configured[0].id}", "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process_step.process_step_octopub_deploy_to_tomcat_via_manager[0].id}", "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_octopub_scan_for_vulnerabilities[0].id}", "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? null : octopusdeploy_process_step.process_step_octopub_deployment_success_notification[0].id}"]
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

resource "octopusdeploy_variable" "octopub_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_octopub.projects) == 0 ?octopusdeploy_project.project_octopub[0].id : data.octopusdeploy_projects.project_octopub.projects[0].id}"
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

resource "octopusdeploy_variable" "octopub_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_octopub.projects) == 0 ?octopusdeploy_project.project_octopub[0].id : data.octopusdeploy_projects.project_octopub.projects[0].id}"
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

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_octopub_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = ""
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? data.octopusdeploy_projects.project_octopub.projects[0].id : octopusdeploy_project.project_octopub[0].id}"
  tenant_ids  = []

  once_daily_schedule {
    start_time   = "2025-11-04T09:00:00"
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

variable "project_octopub_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Octopub"
  default     = "Octopub"
}
variable "project_octopub_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Octopub"
  default     = ""
}
variable "project_octopub_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Octopub"
  default     = ""
}
variable "project_octopub_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Octopub"
  default     = "Deploys a WAR file to a Tomcat server.\n\nRecreate this project with the prompt:\n\n`Create a Tomcat project called \"My Tomcat App\"`"
}
variable "project_octopub_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_octopub" {
  ids          = null
  partial_name = "${var.project_octopub_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_octopub" {
  count                                = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_octopub_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_tomcat.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_tomcat.project_groups[0].id : octopusdeploy_project_group.project_group_tomcat[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_octopub_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_octopub_description_prefix}${var.project_octopub_description}${var.project_octopub_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_octopub" {
  count      = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_octopub.projects) != 0 ? data.octopusdeploy_projects.project_octopub.projects[0].id : octopusdeploy_project.project_octopub[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


