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

data "octopusdeploy_project_groups" "project_group_argo_cd" {
  ids          = null
  partial_name = "${var.project_group_argo_cd_name}"
  skip         = 0
  take         = 1
}
variable "project_group_argo_cd_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Argo CD"
}
resource "octopusdeploy_project_group" "project_group_argo_cd" {
  count = "${length(data.octopusdeploy_project_groups.project_group_argo_cd.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_argo_cd_name}"
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

data "octopusdeploy_channels" "channel_argo_cd_octopub_manifest_default" {
  ids          = []
  partial_name = "Default"
  project_id   = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id : octopusdeploy_project.project_argo_cd_octopub_manifest[0].id}"
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

data "octopusdeploy_git_credentials" "gitcredential_mock" {
  name = "Mock"
  skip = 0
  take = 1
}
resource "octopusdeploy_git_credential" "gitcredential_mock" {
  count                   = "${length(data.octopusdeploy_git_credentials.gitcredential_mock.git_credentials) != 0 ? 0 : 1}"
  name                    = "Mock"
  type                    = "UsernamePassword"
  username                = "blah"
  password                = "${var.gitcredential_mock_sensitive_value}"
  repository_restrictions = { allowed_repositories = ["https://mockgit.octopus.com/*"], enabled = true }
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "gitcredential_mock_sensitive_value" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"Mock\""
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

resource "octopusdeploy_process" "process_argo_cd_octopub_manifest" {
  count      = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id : octopusdeploy_project.project_argo_cd_octopub_manifest[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_argo_cd_octopub_manifest_approve_production_deployment" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  name                  = "Approve Production Deployment"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_octopub_manifest[0].id}"
  channels              = null
  condition             = "Success"
  environments          = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  excluded_environments = null
  notes                 = "This step pauses the deployment and waits for approval before continuing."
  package_requirement   = "LetOctopusDecide"
  slug                  = "manual-intervention-required"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the deployment?"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_argo_cd_octopub_manifest_octopus___check_smtp_server_configured" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check SMTP Server Configured"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_octopub_manifest[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_smtp_server_configured.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_smtp_server_configured[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step checks that deployment targets are present, and if not, displays a link to the documentation."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-smtp-server-configured"
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
        "SmtpCheck.Octopus.Api.Key" = "#{Project.Octopus.Api.Key}"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_argo_cd_octopub_manifest_octopus___check_for_argo_cd_instances" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  name                  = "Octopus - Check for Argo CD Instances"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_octopub_manifest[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_for_argo_cd_instances[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template != null ? data.octopusdeploy_step_template.steptemplate_octopus___check_for_argo_cd_instances.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_octopus___check_for_argo_cd_instances[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "This step checks that Argo CD Instances are present, and if not, displays a link to the documentation."
  package_requirement   = "LetOctopusDecide"
  slug                  = "octopus-check-for-argo-cd-instances"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
      }
  parameters            = {
        "Template.Octopus.API.Key" = "#{Project.Octopus.Api.Key}"
      }
}

resource "octopusdeploy_process_step" "process_step_argo_cd_octopub_manifest_update_argo_cd_application_manifests" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  name                  = "Update Argo CD Application Manifests"
  type                  = "Octopus.ArgoCDUpdateManifests"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_octopub_manifest[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "${length(data.octopusdeploy_git_credentials.gitcredential_mock.git_credentials) != 0 ? data.octopusdeploy_git_credentials.gitcredential_mock.git_credentials[0].id : octopusdeploy_git_credential.gitcredential_mock[0].id}", git_credential_type = "Library", github_connection_id = "", repository_uri = "https://mockgit.octopus.com/repo/argocd" } }
  notes                 = "The projects is configured to use the sample application hosted at https://mockgit.octopus.com/repo/argocd in the `octopub-manifest` directory.\n\nThe repo requires credentials, but accepts any username and password, for example:\n\ngit clone https://somerandomusername@mockgit.octopus.com/repo/argocd\n\nAdd this sample application with this command:\n\nargocd repo add https://mockgitserver.orangegrass-c0938ea8.westus2.azurecontainerapps.io/repo/argocd --username \"somerandomusername\" --password \"whatever\"\n\nargocd app create octopub-manifest \\\n    --repo https://mockgit.octopus.com/repo/argocd \\\n    --path octopub-manifest \\\n    --dest-server https://kubernetes.default.svc \\\n    --dest-namespace octopub"
  package_requirement   = "LetOctopusDecide"
  slug                  = "update-argo-cd-application-manifests"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.ArgoCD.CommitMessageDescription" = "Project: #{Octopus.Project.Slug}\nEnvironment: #{Octopus.Environment.Slug}#{if Octopus.Deployment.Tenant.Slug }\nTenant: #{Octopus.Deployment.Tenant.Slug}#{/if}"
        "Octopus.Action.ArgoCD.StepVerification.Method" = "CommitCreated"
        "Octopus.Action.ArgoCD.CommitMessageSummary" = "Updated Manifests with Release: #{Octopus.Release.Number}"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.ArgoCD.StepVerification.Timeout" = "180"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.ArgoCD.Sync.Mode" = "AllEnvironments"
        "Octopus.Action.ArgoCD.InputPath" = "octopub-manifest/template/octopub.yml"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.ArgoCD.CommitMethod" = "DirectCommit"
      }
}

resource "octopusdeploy_process_templated_step" "process_step_argo_cd_octopub_manifest_scan_for_vulnerabilities" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  name                  = "Scan for Vulnerabilities"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_octopub_manifest[0].id}"
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

resource "octopusdeploy_process_step" "process_step_argo_cd_octopub_manifest_send_an_email__deployment_failed_" {
  count                 = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  name                  = "Send an Email (Deployment Failed)"
  type                  = "Octopus.Email"
  process_id            = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_octopub_manifest[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
  notes                 = "Send an email when the deployment has failed."
  package_requirement   = "LetOctopusDecide"
  slug                  = "send-an-email"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{if Octopus.Deployment.Error}#{if Octopus.Action[Octopus - Check SMTP Server Configured].Output.SmtpConfigured == \"True\"}true#{/if}#{/if}"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Email.To" = "admin@example.org"
        "Octopus.Action.Email.Subject" = "Deployment failed!"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_argo_cd_octopub_manifest" {
  count      = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process.process_argo_cd_octopub_manifest[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process_step.process_step_argo_cd_octopub_manifest_approve_production_deployment[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_argo_cd_octopub_manifest_octopus___check_smtp_server_configured[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_argo_cd_octopub_manifest_octopus___check_for_argo_cd_instances[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process_step.process_step_argo_cd_octopub_manifest_update_argo_cd_application_manifests[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_argo_cd_octopub_manifest_scan_for_vulnerabilities[0].id}", "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? null : octopusdeploy_process_step.process_step_argo_cd_octopub_manifest_send_an_email__deployment_failed_[0].id}"]
}

resource "octopusdeploy_variable" "argo_cd_octopub_manifest_project_frontend_theme_1" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) == 0 ?octopusdeploy_project.project_argo_cd_octopub_manifest[0].id : data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id}"
  value        = "pink"
  name         = "Project.Frontend.Theme"
  type         = "String"
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

resource "octopusdeploy_variable" "argo_cd_octopub_manifest_project_frontend_theme_2" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) == 0 ?octopusdeploy_project.project_argo_cd_octopub_manifest[0].id : data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id}"
  value        = "blue"
  name         = "Project.Frontend.Theme"
  type         = "String"
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

resource "octopusdeploy_variable" "argo_cd_octopub_manifest_project_frontend_theme_3" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) == 0 ?octopusdeploy_project.project_argo_cd_octopub_manifest[0].id : data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id}"
  value        = "green"
  name         = "Project.Frontend.Theme"
  type         = "String"
  description  = ""
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

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_variable" "argo_cd_octopub_manifest_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) == 0 ?octopusdeploy_project.project_argo_cd_octopub_manifest[0].id : data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id}"
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

resource "octopusdeploy_variable" "argo_cd_octopub_manifest_project_octopus_api_key_1" {
  count           = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) == 0 ?octopusdeploy_project.project_argo_cd_octopub_manifest[0].id : data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id}"
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

variable "project_argo_cd_octopub_manifest_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Argo CD Octopub Manifest"
  default     = "Argo CD Octopub Manifest"
}
variable "project_argo_cd_octopub_manifest_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Argo CD Octopub Manifest"
  default     = ""
}
variable "project_argo_cd_octopub_manifest_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Argo CD Octopub Manifest"
  default     = ""
}
variable "project_argo_cd_octopub_manifest_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Argo CD Octopub Manifest"
  default     = "Demonstrates the `Update Argo CD Application Manifests` step by updating the values tag for the deployment of a sample Helm chart.\n\nThis step assumes that the sample application from the Git repo https://mockgit.octopus.com/repo/argocd and directory `octopub-manifest` has been deployed to the Argo CD instance, for example:\n\nargocd repo add https://mockgit.octopus.com/repo/argocd --username \"anyusernameisaccepted\" --password \"anypasswordisaccepted\"\n\n argocd app create octopub-manifest \\\n        --repo https://mockgit.octopus.com/repo/argocd \\\n        --path octopub-manifest \\\n        --dest-server https://kubernetes.default.svc \\\n        --dest-namespace octopub"
}
variable "project_argo_cd_octopub_manifest_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_argo_cd_octopub_manifest" {
  ids          = null
  partial_name = "${var.project_argo_cd_octopub_manifest_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_argo_cd_octopub_manifest" {
  count                                = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_argo_cd_octopub_manifest_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_devsecops.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_devsecops[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_argo_cd.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_argo_cd.project_groups[0].id : octopusdeploy_project_group.project_group_argo_cd[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_argo_cd_octopub_manifest_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_argo_cd_octopub_manifest_description_prefix}${var.project_argo_cd_octopub_manifest_description}${var.project_argo_cd_octopub_manifest_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_argo_cd_octopub_manifest" {
  count      = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects) != 0 ? data.octopusdeploy_projects.project_argo_cd_octopub_manifest.projects[0].id : octopusdeploy_project.project_argo_cd_octopub_manifest[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


