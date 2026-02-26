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

data "octopusdeploy_project_groups" "project_group_update_application_image_tags" {
  ids          = null
  partial_name = "${var.project_group_update_application_image_tags_name}"
  skip         = 0
  take         = 1
}
variable "project_group_update_application_image_tags_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Update Application Image Tags"
}
resource "octopusdeploy_project_group" "project_group_update_application_image_tags" {
  count       = "${length(data.octopusdeploy_project_groups.project_group_update_application_image_tags.project_groups) != 0 ? 0 : 1}"
  name        = "${var.project_group_update_application_image_tags_name}"
  description = "[Argo CD instance link](https://argocd.octopussamples.com/applications)"
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

data "octopusdeploy_channels" "channel_update_image_tags___helm_default" {
  ids          = []
  partial_name = "Default"
  project_id   = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? data.octopusdeploy_projects.project_update_image_tags___helm.projects[0].id : octopusdeploy_project.project_update_image_tags___helm[0].id}"
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
  api_version                          = "v2"
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

data "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_for_argo_cd_instances" {
  website = "https://library.octopus.com/step-templates/7da3a76e-57ca-4542-846a-73c00252206c"
}
data "octopusdeploy_step_template" "steptemplate_octopus___check_for_argo_cd_instances" {
  name = "Octopus - Check for Argo CD Instances"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_octopus___check_for_argo_cd_instances" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_for_argo_cd_instances.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_octopus___check_for_argo_cd_instances.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template != null ? 0 : 1}"
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

resource "octopusdeploy_process" "process_update_image_tags___helm" {
  count      = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? data.octopusdeploy_projects.project_update_image_tags___helm.projects[0].id : octopusdeploy_project.project_update_image_tags___helm[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_update_image_tags___helm_approve_production_deployment" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Approve Production Deployment"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  excluded_environments = null
  notes                 = "This step pauses the deployment and waits for approval before continuing."
  package_requirement   = "LetOctopusDecide"
  slug                  = "approve-production-deployment"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Manual.ResponsibleTeamIds" = "teams-everyone"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the deployment?"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_octopus___check_smtp_server_configured" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check SMTP Server Configured"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Confirms that the SMTP server has been configured."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-smtp-server-configured"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Octopus.Worker.Pool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
      }
  parameters            = {
        "SmtpCheck.Octopus.Api.Key" = "#{Project.Octopus.API.Key}"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_octopus___check_for_argo_cd_instances" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check for Argo CD Instances"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_for_argo_cd_instances[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_for_argo_cd_instances[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Checks to see if an Argo CD instance has been registered to Octopus."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-for-argo-cd-instances"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Octopus.Worker.Pool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "Template.Octopus.API.Key" = "#{Project.Octopus.API.Key}"
      }
}

variable "project_update_image_tags___helm_step_update_images_package_octopub_products_microservice_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named octopub-products-microservice from step Update images in project Update Image Tags - Helm"
  default     = "octopussolutionsengineering/octopub-products-microservice"
}
variable "project_update_image_tags___helm_step_update_images_package_octopub_frontend_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named octopub-frontend from step Update images in project Update Image Tags - Helm"
  default     = "octopussolutionsengineering/octopub-frontend"
}
variable "project_update_image_tags___helm_step_update_images_package_octopub_audit_microservice_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named octopub-audit-microservice from step Update images in project Update Image Tags - Helm"
  default     = "octopussolutionsengineering/octopub-audit-microservice"
}
resource "octopusdeploy_process_step" "process_step_update_image_tags___helm_update_images" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Update images"
  type                  = "Octopus.ArgoCDUpdateImageTags"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Updates the image tag for the referenced images."
  package_requirement   = "LetOctopusDecide"
  packages              = { octopub-audit-microservice = { acquisition_location = "NotAcquired", feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", id = null, package_id = "${var.project_update_image_tags___helm_step_update_images_package_octopub_audit_microservice_packageid}", properties = { Extract = "False", Purpose = "DockerImageReference", SelectionMode = "immediate" } }, octopub-frontend = { acquisition_location = "NotAcquired", feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", id = null, package_id = "${var.project_update_image_tags___helm_step_update_images_package_octopub_frontend_packageid}", properties = { Extract = "False", Purpose = "DockerImageReference", SelectionMode = "immediate" } }, octopub-products-microservice = { acquisition_location = "NotAcquired", feed_id = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}", id = null, package_id = "${var.project_update_image_tags___helm_step_update_images_package_octopub_products_microservice_packageid}", properties = { Extract = "False", Purpose = "DockerImageReference", SelectionMode = "immediate" } } }
  slug                  = "update-images"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Octopus.Worker.Pool"
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Octopus - Check for Argo CD Instances].Output.ArgoPresent == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "Octopus.Action.ArgoCD.CommitMethod" = "PullRequest"
        "Octopus.Action.ArgoCD.CommitMessageDescription" = "If we merge this PR, then the next deployment will be a no-op. \n\n[Release link](#{Octopus.Web.ServerUri}#{Octopus.Web.ReleaseLink})\n[Deployment link](#{Octopus.Web.ServerUri}#{Octopus.Web.DeploymentLink})\n\n"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.ArgoCD.CommitMessageSummary" = "Octopus Deploy updated image versions"
      }
}

resource "octopusdeploy_process_step" "process_step_update_image_tags___helm_smoke_test" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Smoke test"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Runs a smoke test to verify the deployed containers are working properly."
  package_requirement   = "LetOctopusDecide"
  slug                  = "smoke-test"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Octopus.Worker.Pool"
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{if Octopus.Action[Octopus - Check for Argo CD Instances].Output.ArgoPresent == \"True\"}true#{/if}#{/unless}"
      }
  execution_properties  = {
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.Script.ScriptBody" = "echo \"Running smoke test...\"\n\necho \".\"\necho \".\"\necho \".\"\necho \".\"\necho \".\"\n\necho \"Smoke test passed!\""
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}

resource "octopusdeploy_process_step" "process_step_update_image_tags___helm_send_an_email___deployment_failed" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Send an Email - Deployment failed"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Sends an email in the event the deployment failed."
  package_requirement   = "LetOctopusDecide"
  slug                  = "send-an-email-deployment-failed"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{if Octopus.Deployment.Error}#{if Octopus.Action[Octopus - Check SMTP Server Configured].Output.SmtpConfigured == \"True\"}true#{/if}#{/if}"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Email.To" = "#{Octopus.Deployment.CreatedBy.EmailAddress}"
        "Octopus.Action.Email.Subject" = "Deployment to #{Octopus.Environment.Name} for project #{Octopus.Project.Name} has failed!"
        "Octopus.Action.Email.Body" = "Deployment to #{Octopus.Environment.Name} for project #{Octopus.Project.Name}, version #{Octopus.Release.Number} has failed!"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
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
  worker_pool_variable  = "Project.Octopus.Worker.Pool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
      }
  parameters            = {
        "Sbom.Package" = jsonencode({
        "PackageId" = "com.octopus:octopub-sbom"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
                })
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_update_image_tags___helm" {
  count      = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_approve_production_deployment[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_octopus___check_smtp_server_configured[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_octopus___check_for_argo_cd_instances[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_update_images[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_smoke_test[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_send_an_email___deployment_failed[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_scan_for_vulnerabilities[0].id}"]
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

resource "octopusdeploy_variable" "update_image_tags___helm_project_octopus_worker_pool_1" {
  count        = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) == 0 ?octopusdeploy_project.project_update_image_tags___helm[0].id : data.octopusdeploy_projects.project_update_image_tags___helm.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  name         = "Project.Octopus.Worker.Pool"
  type         = "WorkerPool"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "update_image_tags___helm_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) == 0 ?octopusdeploy_project.project_update_image_tags___helm[0].id : data.octopusdeploy_projects.project_update_image_tags___helm.projects[0].id}"
  name            = "Project.Octopus.API.Key"
  type            = "Sensitive"
  description     = "API Key used for making queries to the Octopus API."
  is_sensitive    = true
  sensitive_value = "Change Me!"
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

variable "project_update_image_tags___helm_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Update Image Tags - Helm"
  default     = "Update Image Tags - Helm"
}
variable "project_update_image_tags___helm_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Update Image Tags - Helm"
  default     = ""
}
variable "project_update_image_tags___helm_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Update Image Tags - Helm"
  default     = ""
}
variable "project_update_image_tags___helm_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Update Image Tags - Helm"
  default     = "Recreate the project using the prompt: `Create Argo CD Update Image Tag project called \"My Argo CD Update Image Tag Project\"`\n\n[Argo CD instance link](https://argocd.octopussamples.com/applications)"
}
variable "project_update_image_tags___helm_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_update_image_tags___helm" {
  ids          = null
  partial_name = "${var.project_update_image_tags___helm_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_update_image_tags___helm" {
  count                                = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_update_image_tags___helm_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_update_application_image_tags.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_update_application_image_tags.project_groups[0].id : octopusdeploy_project_group.project_group_update_application_image_tags[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_update_image_tags___helm_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_update_image_tags___helm_description_prefix}${var.project_update_image_tags___helm_description}${var.project_update_image_tags___helm_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_update_image_tags___helm" {
  count      = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? data.octopusdeploy_projects.project_update_image_tags___helm.projects[0].id : octopusdeploy_project.project_update_image_tags___helm[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


