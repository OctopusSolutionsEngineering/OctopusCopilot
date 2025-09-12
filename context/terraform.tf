provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.3.8" }
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

data "octopusdeploy_project_groups" "project_group_terraform" {
  ids          = null
  partial_name = "${var.project_group_terraform_name}"
  skip         = 0
  take         = 1
}
variable "project_group_terraform_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Terraform"
}
resource "octopusdeploy_project_group" "project_group_terraform" {
  count = "${length(data.octopusdeploy_project_groups.project_group_terraform.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_terraform_name}"
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

data "octopusdeploy_lifecycles" "lifecycle_application" {
  ids          = null
  partial_name = "Application"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_lifecycle" "lifecycle_application" {
  count       = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? 0 : 1}"
  name        = "Application"
  description = "This is an example lifecycle that automatically deploys to the first environment"

  phase {
    automatic_deployment_targets          = []
    optional_deployment_targets           = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
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

data "octopusdeploy_channels" "channel_terraform_default" {
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

resource "octopusdeploy_process" "process_terraform" {
  count      = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? data.octopusdeploy_projects.project_terraform.projects[0].id : octopusdeploy_project.project_terraform[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_terraform_plan_to_apply_a_terraform_template" {
  count                 = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  name                  = "Plan to apply a Terraform template"
  type                  = "Octopus.TerraformPlan"
  process_id            = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? null : octopusdeploy_process.process_terraform[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/terraform-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step plans the changes made by the Terraform configuration and saves the changes in an output variable."
  package_requirement   = "LetOctopusDecide"
  slug                  = "plan-to-apply-a-terraform-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.Template" = "#{Project.Terraform.Configuration}"
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({        })
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.AdditionalActionParams" = "\"-var=message=#{Terraform.Variable.Message}\""
      }
}

resource "octopusdeploy_process_step" "process_step_terraform_approve_plan" {
  count                 = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  name                  = "Approve Plan"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? null : octopusdeploy_process.process_terraform[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step displays the changes to be applied and asks for the changes to be approved."
  package_requirement   = "LetOctopusDecide"
  slug                  = "approve-plan"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve the planned changes?\n\n#{Octopus.Action[Plan to apply a Terraform template].Output.TerraformPlanOutput}"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_terraform_apply_a_terraform_template" {
  count                 = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  name                  = "Apply a Terraform template"
  type                  = "Octopus.TerraformApply"
  process_id            = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? null : octopusdeploy_process.process_terraform[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/terraform-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step applies the Terraform configuration."
  package_requirement   = "LetOctopusDecide"
  slug                  = "apply-a-terraform-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Terraform.AdditionalActionParams" = "\"-var=message=#{Terraform.Variable.Message}\""
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({        })
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.Template" = "#{Project.Terraform.Configuration}"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_terraform" {
  count      = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? null : octopusdeploy_process.process_terraform[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? null : octopusdeploy_process_step.process_step_terraform_plan_to_apply_a_terraform_template[0].id}", "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? null : octopusdeploy_process_step.process_step_terraform_approve_plan[0].id}", "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? null : octopusdeploy_process_step.process_step_terraform_apply_a_terraform_template[0].id}"]
}

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_variable" "terraform_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_terraform.projects) == 0 ?octopusdeploy_project.project_terraform[0].id : data.octopusdeploy_projects.project_terraform.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : null}"
  name         = "Project.WorkerPool"
  type         = "WorkerPool"
  description  = "The workerpool used by the steps. Defining the workerpool as a variable allows it to be changed in a single location for multiple steps."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "terraform_project_terraform_configuration_1" {
  count        = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_terraform.projects) == 0 ?octopusdeploy_project.project_terraform[0].id : data.octopusdeploy_projects.project_terraform.projects[0].id}"
  value        = "variable \"message\" {\n  type = string\n  default = \"Hello World!\"\n}\n\nresource \"terraform_data\" \"replacement\" {\n  input = var.message\n}\n"
  name         = "Project.Terraform.Configuration"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "terraform_terraform_variable_message_1" {
  count        = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_terraform.projects) == 0 ?octopusdeploy_project.project_terraform[0].id : data.octopusdeploy_projects.project_terraform.projects[0].id}"
  value        = "Hi world!"
  name         = "Terraform.Variable.Message"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "terraform_octopusprintvariables_1" {
  count        = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_terraform.projects) == 0 ?octopusdeploy_project.project_terraform[0].id : data.octopusdeploy_projects.project_terraform.projects[0].id}"
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

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_terraform_daily_security_scan" {
  count       = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Daily Security Scan"
  description = ""
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? data.octopusdeploy_projects.project_terraform.projects[0].id : octopusdeploy_project.project_terraform[0].id}"
  tenant_ids  = []

  once_daily_schedule {
    start_time   = "2025-05-12T09:00:00"
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

variable "project_terraform_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Terraform"
  default     = "Terraform"
}
variable "project_terraform_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Terraform"
  default     = ""
}
variable "project_terraform_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Terraform"
  default     = ""
}
variable "project_terraform_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Terraform"
  default     = "This project runs a script step."
}
variable "project_terraform_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_terraform" {
  ids          = null
  partial_name = "${var.project_terraform_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_terraform" {
  count                                = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_terraform_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_application[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_terraform.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_terraform.project_groups[0].id : octopusdeploy_project_group.project_group_terraform[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_terraform_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_terraform_description_prefix}${var.project_terraform_description}${var.project_terraform_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_terraform" {
  count      = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_terraform.projects) != 0 ? data.octopusdeploy_projects.project_terraform.projects[0].id : octopusdeploy_project.project_terraform[0].id}"
  template   = "#{Octopus.Date.Year}.#{Octopus.Date.Month}.#{Octopus.Date.Day}.i"
}


