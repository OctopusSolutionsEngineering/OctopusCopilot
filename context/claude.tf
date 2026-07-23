provider "octopusdeploy" {
  space_id = "${trimspace(var.octopus_space_id)}"
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeploy/octopusdeploy", version = "1.18.2" }
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

data "octopusdeploy_project_groups" "project_group_claude" {
  ids          = null
  partial_name = "${var.project_group_claude_name}"
  skip         = 0
  take         = 1
}
variable "project_group_claude_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Claude"
}
resource "octopusdeploy_project_group" "project_group_claude" {
  count = "${length(data.octopusdeploy_project_groups.project_group_claude.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_claude_name}"
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
  use_guided_failure           = true

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
    is_enabled = true
  }
  depends_on = [octopusdeploy_environment.environment_development,octopusdeploy_environment.environment_test]
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

  release_retention_with_strategy {
    strategy         = "Count"
    quantity_to_keep = 30
    unit             = "Days"
  }

  tentacle_retention_with_strategy {
    strategy         = "Count"
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

data "octopusdeploy_channels" "channel_claude_default" {
  ids          = []
  partial_name = "Default"
  project_id   = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? data.octopusdeploy_projects.project_claude.projects[0].id : octopusdeploy_project.project_claude[0].id}"
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

resource "octopusdeploy_process" "process_claude" {
  count      = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? data.octopusdeploy_projects.project_claude.projects[0].id : octopusdeploy_project.project_claude[0].id}"
  depends_on = []
}

variable "project_claude_step_list_commits_package_octopub_frontend_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named octopub-frontend from step List Commits in project Claude"
  default     = "com.octopus:octopub-frontend"
}
resource "octopusdeploy_process_step" "process_step_claude_list_commits" {
  count                 = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  name                  = "List Commits"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process.process_claude[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Lists the commits associated with the package being deployed"
  package_requirement   = "LetOctopusDecide"
  packages              = { octopub-frontend = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds) != 0 ? data.octopusdeploy_feeds.feed_octopus_maven_feed.feeds[0].id : octopusdeploy_maven_feed.feed_octopus_maven_feed[0].id}", id = null, package_id = "${var.project_claude_step_list_commits_package_octopub_frontend_packageid}", properties = { Extract = "True", SelectionMode = "immediate" }, version = "20260721.659.1" } }
  slug                  = "list-commits"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptBody" = <<EOT
#{each change in Octopus.Deployment.Changes}
#{each commit in change.Commits}
Write-Highlight "[#{commit.LinkUrl}](#{commit.LinkUrl})"
#{/each}
#{/each}
EOT
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}

resource "octopusdeploy_process_step" "process_step_claude_run_claude_agent" {
  count                 = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  name                  = "Run Claude Agent"
  type                  = "Octopus.Claude"
  process_id            = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process.process_claude[0].id}"
  channels              = null
  condition             = "Success"
  container             = { dockerfile = "FROM python:3.11-slim\n\n# 1. Install prerequisites (including libicu for .NET Calamari compatibility)\nRUN apt-get update && apt-get install -y --no-install-recommends \\\n    curl \\\n    git \\\n    libicu-dev \\\n    ca-certificates \\\n    && rm -rf /var/lib/apt/lists/*\n\n# 2. Install the native Claude Code CLI tool \nRUN curl -fsSL https://claude.ai/install.sh | bash\n\n# 3. Create a global symlink using the exact path from your install log\n# This bypasses the $PATH profile restriction for non-interactive runners\nRUN ln -sf /root/.local/bin/claude /usr/local/bin/claude\n\nWORKDIR /app\nCMD [\"/bin/bash\"]", feed_id = "", git_url = null, image = "" }
  environments          = null
  excluded_environments = null
  notes                 = "Inspects the Git commits and rates the changes in a number of categories."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-claude-agent"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  depends_on            = [octopusdeploy_process_step.process_step_claude_list_commits]
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Claude.Permissions" = jsonencode({
        "deny" = [
        "WebFetch",
        "WebSearch",
        "Bash",
        ]
                })
        "Octopus.Action.Claude.SandboxMode" = "None"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Claude.InjectionCheckEnabled" = "False"
        "Octopus.Action.Claude.OctopusMcpTools" = jsonencode([
        "*",
        ])
        "Octopus.Action.Claude.McpServers" = jsonencode([
        {
        "url" = "https://api.githubcopilot.com/mcp/"
        "headers" = {
        "Authorization" = "#{Project.GitHub.PAT}"
                }
        "env" = {        }
        "allowedTools" = [
        "*",
        ]
        "type" = "http"
        "name" = "GitHub"
                },
        ])
        "Octopus.Action.Claude.Model" = "claude-sonnet-5"
        "Octopus.Action.Claude.Prompt" = <<EOT
Your task is to rate the impact of the Git commits that contribute to the new version of the application being deployed.

The following is the list of Git commits:

#{each change in Octopus.Deployment.Changes}
#{each commit in change.Commits}
#{commit.LinkUrl}
#{/each}
#{/each}

Output a value between 1 and 10 based on the impact of the changes in the following categories:

* Security
* User Interface
* Documentation
* Business Logic
* Performance
* Code dependencies
* Code refactoring

The result must be a plain JSON blob like this:

```
{
  "security": 1,
  "userInterface": 4,
  "documentation": 7,
  "businessLogic": 3,
  "performance": 1,
  "dependencies": 9,
  "refactoring": 5
}
```
EOT
        "Octopus.Action.Claude.Effort" = "medium"
        "Octopus.Action.Claude.ApiKey" = "#{Project.Claude.ApiKey}"
      }
}

resource "octopusdeploy_process_step" "process_step_claude_extract_json" {
  count                 = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  name                  = "Extract JSON"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process.process_claude[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "Extracts the JSON blob from the LLM-generated markdown. Recreate the code in this step exactly."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  depends_on            = [octopusdeploy_process_step.process_step_claude_run_claude_agent]
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = <<EOT
$response =  $OctopusParameters["Octopus.Action[Run Claude Agent].Output.Octopus.Action.Claude.Response"]

if ($response -match "(?s)\{.*\}") {
    $jsonText = $Matches[0].Trim()

    if (Test-Json -Json $jsonText) {
        Write-Highlight "JSON Response:`n$jsonText"

        Set-OctopusVariable -name "JsonResult" -value $jsonText

        $objects = $jsonText | ConvertFrom-Json

        $needApproval = $objects.security -ge 5 -or $objects.businessLogic -ge 5 -or $objects.performance -ge 5

        Write-Highlight "Needs approval: $needApproval"

        Set-OctopusVariable -name "NeedApproval" -value $needApproval

        Write-Highlight "Access `##{Octopus.Action[#{Octopus.Step.Name}].Output.JsonResult}` to get the JSON response"
        Write-Highlight "Access `##{Octopus.Action[#{Octopus.Step.Name}].Output.NeedApproval}` to get the approval flag"
    } else {
        Write-Warning "The markdown block is not valid JSON."
    }
} else {
    Write-Error "No JSON markdown block found in the response."
}


EOT
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_claude_manual_intervention_required" {
  count                 = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  name                  = "Manual Intervention Required"
  type                  = "Octopus.Manual"
  process_id            = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process.process_claude[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = null
  notes                 = "If specific categories were rated as having significant changes, a manual intervention is displayed to approve the deployment."
  package_requirement   = "LetOctopusDecide"
  slug                  = "manual-intervention-required"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  depends_on            = [octopusdeploy_process_step.process_step_claude_extract_json]
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{Octopus.Action[Extract JSON].Output.NeedApproval}"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
        "Octopus.Action.Manual.Instructions" = "Do you approve these changes for deployment?"
      }
}

resource "octopusdeploy_process_step" "process_step_claude_perform_deployment" {
  count                 = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  name                  = "Perform Deployment"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process.process_claude[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "A set performing a mock deployment."
  package_requirement   = "LetOctopusDecide"
  slug                  = "perform-deployment"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_variable  = "Project.WorkerPool"
  depends_on            = [octopusdeploy_process_step.process_step_claude_manual_intervention_required]
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = "echo \"Performing deployment...\""
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_claude" {
  count      = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process.process_claude[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process_step.process_step_claude_list_commits[0].id}", "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process_step.process_step_claude_run_claude_agent[0].id}", "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process_step.process_step_claude_extract_json[0].id}", "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process_step.process_step_claude_manual_intervention_required[0].id}", "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? null : octopusdeploy_process_step.process_step_claude_perform_deployment[0].id}"]
}

resource "octopusdeploy_variable" "claude_project_claude_apikey_1" {
  count           = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_claude.projects) == 0 ?octopusdeploy_project.project_claude[0].id : data.octopusdeploy_projects.project_claude.projects[0].id}"
  name            = "Project.Claude.ApiKey"
  type            = "Sensitive"
  description     = "The Claude API key"
  is_sensitive    = true
  sensitive_value = "Change Me!"
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "claude_project_github_pat_1" {
  count           = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_claude.projects) == 0 ?octopusdeploy_project.project_claude[0].id : data.octopusdeploy_projects.project_claude.projects[0].id}"
  name            = "Project.GitHub.PAT"
  type            = "Sensitive"
  description     = "The GitHub Personal Access Token that is used by the GitHub MCP server."
  is_sensitive    = true
  sensitive_value = "Change Me!"
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "claude_octopusprintvariables_1" {
  count        = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_claude.projects) == 0 ?octopusdeploy_project.project_claude[0].id : data.octopusdeploy_projects.project_claude.projects[0].id}"
  value        = "False"
  name         = "OctopusPrintVariables"
  type         = "String"
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

resource "octopusdeploy_variable" "claude_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_claude.projects) == 0 ?octopusdeploy_project.project_claude[0].id : data.octopusdeploy_projects.project_claude.projects[0].id}"
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

variable "project_claude_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Claude"
  default     = "Claude"
}
variable "project_claude_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Claude"
  default     = ""
}
variable "project_claude_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Claude"
  default     = ""
}
variable "project_claude_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Claude"
  default     = ""
}
variable "project_claude_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_claude" {
  ids          = null
  partial_name = "${var.project_claude_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_claude" {
  count                                = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_claude_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_application[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_claude.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_claude.project_groups[0].id : octopusdeploy_project_group.project_group_claude[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_claude_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_claude_description_prefix}${var.project_claude_description}${var.project_claude_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_claude" {
  count      = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_claude.projects) != 0 ? data.octopusdeploy_projects.project_claude.projects[0].id : octopusdeploy_project.project_claude[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}


