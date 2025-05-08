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

data "octopusdeploy_channels" "channel_kubernetes_web_app_default" {
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

variable "project_kubernetes_web_app_step_deploy_a_kubernetes_web_app_via_yaml_package_octopub_selfcontained_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named octopub-selfcontained from step Deploy a Kubernetes Web App via YAML in project Kubernetes Web App"
  default     = "octopussolutionsengineering/octopub-selfcontained"
}
resource "octopusdeploy_deployment_process" "deployment_process_kubernetes_web_app" {
  count      = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id : octopusdeploy_project.project_kubernetes_web_app[0].id}"

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
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the production deployment?"
        "Octopus.Action.RunOnServer" = "false"
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
    condition           = "Success"
    name                = "Deploy a Kubernetes Web App via YAML"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.KubernetesDeployRawYaml"
      name                               = "Deploy a Kubernetes Web App via YAML"
      notes                              = "This step deploys a Kubernetes Deployment resource defined as raw YAML."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_variable               = "Octopus.Project.WorkerPool"
      properties                         = {
        "Octopus.Action.KubernetesContainers.Namespace" = "#{Octopus.Environment.Name | ToLower}"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
        "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: \"#{Kubernetes.Deployment.Name}\"\n  labels:\n    app: \"#{Kubernetes.Deployment.Name}\"\nspec:\n  replicas: 1\n  selector:\n    matchLabels:\n      app: \"#{Kubernetes.Deployment.Name}\"\n  template:\n    metadata:\n      labels:\n        app: \"#{Kubernetes.Deployment.Name}\"\n    spec:\n      containers:\n      - name: octopub\n        # The image is sourced from the package reference. This allows the package version to be selected\n        # at release creation time.\n        image: \"ghcr.io/#{Octopus.Action.Package[octopub-selfcontained].PackageId}:#{Octopus.Action.Package[octopub-selfcontained].PackageVersion}\"\n        ports:\n        - containerPort: 8080\n        resources:\n          limits:\n            cpu: \"1\"\n            memory: \"512Mi\"\n          requests:\n            cpu: \"0.5\"\n            memory: \"256Mi\"\n        livenessProbe:\n          httpGet:\n            path: /health/products\n            port: 8080\n          initialDelaySeconds: 30\n          periodSeconds: 10\n        readinessProbe:\n          httpGet:\n            path: /health/products\n            port: 8080\n          initialDelaySeconds: 5\n          periodSeconds: 5"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
      }

      environments          = []
      excluded_environments = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
      channels              = []
      tenant_tags           = []

      package {
        name                      = "octopub-selfcontained"
        package_id                = "${var.project_kubernetes_web_app_step_deploy_a_kubernetes_web_app_via_yaml_package_octopub_selfcontained_packageid}"
        acquisition_location      = "NotAcquired"
        extract_during_deployment = false
        feed_id                   = "${length(data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds) != 0 ? data.octopusdeploy_feeds.feed_ghcr_anonymous.feeds[0].id : octopusdeploy_docker_container_registry.feed_ghcr_anonymous[0].id}"
        properties                = { Extract = "False", Purpose = "DockerImageReference", SelectionMode = "immediate" }
      }
      features = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
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
      worker_pool_variable               = "Octopus.Project.WorkerPool"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptBody" = "# The variable to check must be in the format\n# #{Octopus.Step[\u003cname of the step that deploys the web app\u003e].Status.Code}\nif (\"#{Octopus.Step[Deploy a Kubernetes Web App via YAML].Status.Code}\" -eq \"Abandoned\") {\n  Write-Highlight \"To complete the deployment you must have a Kubernetes target with the tag 'Kubernetes'.\"\n  Write-Highlight \"We recommend the [Kubernetes Agent](https://octopus.com/docs/kubernetes/targets/kubernetes-agent).\"\n}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
      environments                       = []
      excluded_environments              = ["${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
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
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_variable               = "Octopus.Project.WorkerPool"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Script.ScriptFileName" = "octopus/DockerImageSbomScan.ps1"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []
      features                           = []

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

resource "octopusdeploy_variable" "kubernetes_web_app_kubernetes_deployment_name_1" {
  count        = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) == 0 ?octopusdeploy_project.project_kubernetes_web_app[0].id : data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id}"
  value        = "octopub"
  name         = "Kubernetes.Deployment.Name"
  type         = "String"
  description  = "This is the name of the Kubernetes deployment. It is exposed as a variable to allow the name to be shared between the deployment process and the runbooks."
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

resource "octopusdeploy_variable" "kubernetes_web_app_octopus_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) == 0 ?octopusdeploy_project.project_kubernetes_web_app[0].id : data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  name         = "Octopus.Project.WorkerPool"
  type         = "WorkerPool"
  description  = "Using a variable to define the worker pool used by steps allows the worker pool to be easily changed in a central location."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "kubernetes_web_app_octopusprintevaluatedvariables_1" {
  count        = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) == 0 ?octopusdeploy_project.project_kubernetes_web_app[0].id : data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id}"
  value        = "False"
  name         = "OctopusPrintEvaluatedVariables"
  type         = "String"
  description  = "Set this variable to true to log the evaluated value of variables available at the beginning of each step in the deployment as Verbose messages. See https://octopus.com/docs/support/debug-problems-with-octopus-variables for more details."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "kubernetes_web_app_octopusprintvariables_1" {
  count        = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) == 0 ?octopusdeploy_project.project_kubernetes_web_app[0].id : data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id}"
  value        = "False"
  name         = "OctopusPrintVariables"
  type         = "String"
  description  = "Set this variable to true to log the variables available at the beginning of each step in the deployment as Verbose messages. See https://octopus.com/docs/support/debug-problems-with-octopus-variables for more details."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "kubernetes_web_app_application_image_1" {
  count        = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) == 0 ?octopusdeploy_project.project_kubernetes_web_app[0].id : data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id}"
  value        = "ghcr.io/#{Octopus.Action[Deploy a Kubernetes Web App via YAML].Package[octopub-selfcontained].PackageId}:#{Octopus.Action[Deploy a Kubernetes Web App via YAML].Package[octopub-selfcontained].PackageVersion}"
  name         = "Application.Image"
  type         = "String"
  description  = "The image name is in the format \"ghcr.io/#{Octopus.Action[<Name of the step applying the Kubernetes deployment resource>].Package[<Name of the referenced package>].PackageId}:#{Octopus.Action[<Name of the step applying the Kubernetes deployment resource>].Package[Name of the referenced package>].PackageVersion}\". This variable allows the packages used by the \"Deploy a Kubernetes Web App via YAML\" step to be referenced in subsequent steps."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_projects" "projecttrigger_kubernetes_web_app_daily_security_scan" {
  ids          = null
  partial_name = "Kubernetes Web App"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_kubernetes_web_app_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.projecttrigger_kubernetes_web_app_daily_security_scan.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = "This trigger reruns the deployment in the Security environment. This means any new vulnerabilities detected after a production deployment will be identified."
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? data.octopusdeploy_projects.project_kubernetes_web_app.projects[0].id : octopusdeploy_project.project_kubernetes_web_app[0].id}"
  tenant_ids  = []

  once_daily_schedule {
    start_time   = "2025-04-26T09:00:00"
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

variable "project_kubernetes_web_app_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Kubernetes Web App"
  default     = "Kubernetes Web App"
}
variable "project_kubernetes_web_app_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Kubernetes Web App"
  default     = ""
}
variable "project_kubernetes_web_app_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Kubernetes Web App"
  default     = ""
}
variable "project_kubernetes_web_app_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Kubernetes Web App"
  default     = "This project provides an example Kubernetes deployment using YAML, Cloud Target Discovery, and SBOM scanning to an AWS EKS Kubernetes cluster."
}
variable "project_kubernetes_web_app_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_kubernetes_web_app" {
  ids          = null
  partial_name = "${var.project_kubernetes_web_app_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_kubernetes_web_app" {
  count                                = "${length(data.octopusdeploy_projects.project_kubernetes_web_app.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_kubernetes_web_app_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_security.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_security.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_security[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_kubernetes.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_kubernetes.project_groups[0].id : octopusdeploy_project_group.project_group_kubernetes[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_kubernetes_web_app_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
  }
  description = "${var.project_kubernetes_web_app_description_prefix}${var.project_kubernetes_web_app_description}${var.project_kubernetes_web_app_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


