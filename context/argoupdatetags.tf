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
variable "feed_ghcr_anonymous_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed GHCR Anonymous"
  default     = "Change Me!"
}
resource "octopusdeploy_docker_container_registry" "feed_ghcr_anonymous" {
  count                                = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? 0 : 1}"
  name                                 = "GHCR Anonymous"
  password                             = "${var.feed_ghcr_anonymous_password}"
  registry_path                        = ""
  username                             = "x-access-token"
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

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
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
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the deployment?"
        "Octopus.Action.Manual.ResponsibleTeamIds" = "teams-everyone"
        "Octopus.Action.RunOnServer" = "true"
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
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
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
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
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
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.Script.ScriptBody" = "echo \"Running smoke test...\"\n\necho \".\"\necho \".\"\necho \".\"\necho \".\"\necho \".\"\n\necho \"Smoke test passed!\""
        "OctopusUseBundledTooling" = "False"
      }
}

resource "octopusdeploy_process_step" "process_step_update_image_tags___helm_send_an_email___deployment_successful" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Send an Email - Deployment successful"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Sends an email in the event the deployment failed."
  package_requirement   = "LetOctopusDecide"
  slug                  = "send-an-email-deployment-successful"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Email.To" = "#{Octopus.Deployment.CreatedBy.EmailAddress}"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Email.Subject" = "Deployment to #{Octopus.Environment.Name} for project #{Octopus.Project.Name} deployed successfully!"
        "Octopus.Action.Email.Body" = "Deployment to #{Octopus.Environment.Name} for project #{Octopus.Project.Name}, version #{Octopus.Release.Number} was successfully deployed!"
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
  excluded_environments = null
  notes                 = "Sends an email in the event the deployment failed."
  package_requirement   = "LetOctopusDecide"
  slug                  = "send-an-email-deployment-failed"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{if Octopus.Deployment.Error}#{if Octopus.Action[Octopus - Check SMTP Server Configured].Output.SmtpConfigured == \"True\"}true#{/if}#{/if}"
      }
  execution_properties  = {
        "Octopus.Action.Email.Subject" = "Deployment to #{Octopus.Environment.Name} for project #{Octopus.Project.Name} has failed!"
        "Octopus.Action.Email.Body" = "Deployment to #{Octopus.Environment.Name} for project #{Octopus.Project.Name}, version #{Octopus.Release.Number} has failed!"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Email.To" = "#{Octopus.Deployment.CreatedBy.EmailAddress}"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_scan_for_vulnerabilities_for_octopub_products_microservice" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities for octopub-products-microservice"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].version}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "scan-for-vulnerabilities-for-octopub-products-microservice"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Octopus.Worker.Pool"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "Sbom.Package" = jsonencode({
        "PackageId" = "octopussolutionsengineering/octopub-products-microservice"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
                })
      }
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_scan_for_vulnerabilities_for_octopub_audit_microservice" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities for octopub-audit-microservice"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].version}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "scan-for-vulnerabilities-for-octopub-audit-microservice"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.Octopus.Worker.Pool"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "Sbom.Package" = jsonencode({
        "PackageId" = "octopussolutionsengineering/octopub-audit-microservice"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
                })
      }
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_scan_for_vulnerabilities_for_octopub_frontend" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities for octopub-frontend"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].version}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "scan-for-vulnerabilities-for-octopub-frontend"
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
        "PackageId" = "octopussolutionsengineering/octopub-frontend"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
                })
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_update_image_tags___helm" {
  count      = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_approve_production_deployment[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_octopus___check_smtp_server_configured[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_octopus___check_for_argo_cd_instances[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_update_images[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_smoke_test[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_send_an_email___deployment_successful[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_send_an_email___deployment_failed[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_scan_for_vulnerabilities_for_octopub_products_microservice[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_scan_for_vulnerabilities_for_octopub_audit_microservice[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_scan_for_vulnerabilities_for_octopub_frontend[0].id}"]
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

data "octopusdeploy_feeds" "feed_docker_feed_tf" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "Docker Feed TF"
  skip         = 0
  take         = 1
}
variable "feed_docker_feed_tf_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Docker Feed TF"
  default     = "Change Me!"
}
resource "octopusdeploy_docker_container_registry" "feed_docker_feed_tf" {
  count                                = "${length(data.octopusdeploy_feeds.feed_docker_feed_tf.feeds) != 0 ? 0 : 1}"
  name                                 = "Docker Feed TF"
  password                             = "${var.feed_docker_feed_tf_password}"
  username                             = "octopussolutionsengineering"
  feed_uri                             = "https://index.docker.io"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_step_template" "steptemplate_scan_for_vulnerabilities_copy" {
  name = "Scan for Vulnerabilities Copy"
}
resource "octopusdeploy_step_template" "steptemplate_scan_for_vulnerabilities_copy" {
  count           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities_copy.step_template != null ? 0 : 1}"
  action_type     = "Octopus.Script"
  name            = "Scan for Vulnerabilities Copy"
  description     = "This step extracts the Docker image, finds any bom.json files, and scans them for vulnerabilities using Trivy."
  step_package_id = "Octopus.Script"
  packages        = [{ acquisition_location = "ExecutionTarget", extract_during_deployment = null, feed_id = "", name = "application", package_id = "", properties = { package_parameter_name = "Sbom.Package", purpose = "", selection_mode = "True" } }]
  parameters      = [{ default_sensitive_value = null, default_value = null, display_settings = { "Octopus.ControlType" = "Package" }, help_text = null, id = "38f4f941-14b5-4f39-9a5d-f7b8c9ccb942", label = "Application package containing the SBOM to scan", name = "Sbom.Package" }]
  properties      = { "Octopus.Action.Script.ScriptBody" = "Write-Host \"Pulling Trivy Docker Image\"\nWrite-Host \"##octopus[stdout-verbose]\"\ndocker pull ghcr.io/aquasecurity/trivy\nWrite-Host \"##octopus[stdout-default]\"\n\n$SUCCESS = 0\n\nWrite-Host \"##octopus[stdout-verbose]\"\nGet-ChildItem -Path \".\" | Out-String\nWrite-Host \"##octopus[stdout-default]\"\n\n# Find all bom.json files\n$bomFiles = Get-ChildItem -Path \".\" -Filter \"bom.json\" -Recurse -File\n\nif ($bomFiles.Count -eq 0) {\n    Write-Host \"No bom.json files found in the current directory.\"\n    exit 0\n}\n\nforeach ($file in $bomFiles) {\n    Write-Host \"Scanning $($file.FullName)\"\n\n    # Delete any existing report file\n    if (Test-Path \"$PWD/depscan-bom.json\") {\n        Remove-Item \"$PWD/depscan-bom.json\" -Force\n    }\n\n    # Generate the report, capturing the output\n    try {\n        $OUTPUT = docker run --rm -v \"$($file.FullName):/input/$($file.Name)\" ghcr.io/aquasecurity/trivy sbom -q \"/input/$($file.Name)\"\n        $exitCode = $LASTEXITCODE\n    }\n    catch {\n        $OUTPUT = $_.Exception.Message\n        $exitCode = 1\n    }\n\n    # Run again to generate the JSON output\n    docker run --rm -v \"$${PWD}:/output\" -v \"$($file.FullName):/input/$($file.Name)\" ghcr.io/aquasecurity/trivy sbom -q -f json -o /output/depscan-bom.json \"/input/$($file.Name)\"\n\n    # Octopus Deploy artifact\n    New-OctopusArtifact \"$PWD/depscan-bom.json\"\n\n    # Parse JSON output to count vulnerabilities\n    $jsonContent = Get-Content -Path \"depscan-bom.json\" | ConvertFrom-Json\n    $CRITICAL = ($jsonContent.Results | ForEach-Object { $_.Vulnerabilities } | Where-Object { $_.Severity -eq \"CRITICAL\" }).Count\n    $HIGH = ($jsonContent.Results | ForEach-Object { $_.Vulnerabilities } | Where-Object { $_.Severity -eq \"HIGH\" }).Count\n\n    if (\"#{Octopus.Environment.Name}\" -eq \"Security\") {\n        Write-Highlight \"🟥 $CRITICAL critical vulnerabilities\"\n        Write-Highlight \"🟧 $HIGH high vulnerabilities\"\n    }\n\n    # Set success to 1 if exit code is not zero\n    if ($exitCode -ne 0) {\n        $SUCCESS = 1\n    }\n\n    # Print the output\n    $OUTPUT | ForEach-Object {\n        if ($_.Length -gt 0) {\n            Write-Host $_\n        }\n    }\n}\n\n# Cleanup\nfor ($i = 1; $i -le 10; $i++) {\n    try {\n        if (Test-Path \"bundle\") {\n            Set-ItemProperty -Path \"bundle\" -Name IsReadOnly -Value $false -Recurse -ErrorAction SilentlyContinue\n            Remove-Item -Path \"bundle\" -Recurse -Force -ErrorAction Stop\n            break\n        }\n    }\n    catch {\n        Write-Host \"Attempting to clean up files\"\n        Start-Sleep -Seconds 1\n    }\n}\n\n# Set Octopus variable\nSet-OctopusVariable -Name \"VerificationResult\" -Value $SUCCESS\n\nexit 0", "Octopus.Action.Script.ScriptSource" = "Inline", "Octopus.Action.Script.Syntax" = "PowerShell", OctopusUseBundledTooling = "False" }
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_process" "process_update_image_tags___helm_scan" {
  count      = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? data.octopusdeploy_projects.project_update_image_tags___helm.projects[0].id : octopusdeploy_project.project_update_image_tags___helm[0].id}"
  runbook_id = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_runbook.runbook_update_image_tags___helm_scan[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_scan_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm_scan[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_scan_for_vulnerabilities[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "scan-for-vulnerabilities"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
      }
  parameters            = {
        "Sbom.Package" = jsonencode({
        "PackageId" = "com.octopus:products-microservice-lambda-jvm"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}"
                })
      }
}

variable "project_scan_step_run_a_script_package_octopub_frontend_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named octopub-frontend from step Run a Script in project Scan"
  default     = "octopussamples/octopub-frontend"
}
resource "octopusdeploy_process_step" "process_step_update_image_tags___helm_scan_run_a_script" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm_scan[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  is_disabled           = true
  package_requirement   = "LetOctopusDecide"
  packages              = { octopub-frontend = { acquisition_location = "NotAcquired", feed_id = "${length(data.octopusdeploy_feeds.feed_docker_feed_tf.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_feed_tf.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_feed_tf[0].id}", id = null, package_id = "${var.project_scan_step_run_a_script_package_octopub_frontend_packageid}", properties = { Extract = "False", SelectionMode = "immediate" } } }
  slug                  = "run-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "Write-Host \"Hi\""
        "OctopusUseBundledTooling" = "False"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_update_image_tags___helm_scan_scan_for_vulnerabilities_copy" {
  count                 = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities Copy"
  process_id            = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm_scan[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities_copy.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities_copy.step_template.id : octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities_copy[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities_copy.step_template != null ? data.octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities_copy.step_template.version : octopusdeploy_step_template.steptemplate_scan_for_vulnerabilities_copy[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  is_disabled           = true
  package_requirement   = "LetOctopusDecide"
  slug                  = "scan-for-vulnerabilities-copy"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "Sbom.Package" = jsonencode({
        "PackageId" = "octopussamples/octopub-frontend"
        "FeedId" = "${length(data.octopusdeploy_feeds.feed_docker_feed_tf.feeds) != 0 ? data.octopusdeploy_feeds.feed_docker_feed_tf.feeds[0].id : octopusdeploy_docker_container_registry.feed_docker_feed_tf[0].id}"
                })
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_update_image_tags___helm_scan" {
  count      = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process.process_update_image_tags___helm_scan[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_scan_scan_for_vulnerabilities[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_step.process_step_update_image_tags___helm_scan_run_a_script[0].id}", "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_update_image_tags___helm_scan_scan_for_vulnerabilities_copy[0].id}"]
}

variable "runbook_update_image_tags___helm_scan_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Scan"
  default     = "Scan"
}
resource "octopusdeploy_runbook" "runbook_update_image_tags___helm_scan" {
  count                       = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_update_image_tags___helm_scan_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_update_image_tags___helm.projects) != 0 ? data.octopusdeploy_projects.project_update_image_tags___helm.projects[0].id : octopusdeploy_project.project_update_image_tags___helm[0].id}"
  environment_scope           = "All"
  environments                = []
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = ""
  multi_tenancy_mode          = "Untenanted"

  retention_policy {
    quantity_to_keep = 5
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
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


