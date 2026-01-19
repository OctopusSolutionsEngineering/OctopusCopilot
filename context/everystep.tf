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

variable "project_group_default_project_group_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Default Project Group"
}
data "octopusdeploy_project_groups" "project_group_default_project_group" {
  ids          = null
  partial_name = "${var.project_group_default_project_group_name}"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a project group called $${var.project_group_default_project_group_name}. This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.project_groups) != 0
    }
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

variable "variable_77a383b2349dcc39c966faa9e5ae72da855f6405e711813d52a6b78790fc6512_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Database.Password"
  default     = "development.database.internal"
}
resource "octopusdeploy_variable" "variables_example_variable_set_database_password_1" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "${var.variable_77a383b2349dcc39c966faa9e5ae72da855f6405e711813d52a6b78790fc6512_value}"
  name         = "Database.Password"
  type         = "String"
  description  = "This is an example of a variable scoped to an environment"
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

variable "variable_19c7fb322951c79633fa2f2526f1ff251d34c4d471ecc3586cdf130be1c665b2_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Database.Password"
  default     = "test.database.internal"
}
resource "octopusdeploy_variable" "variables_example_variable_set_database_password_2" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "${var.variable_19c7fb322951c79633fa2f2526f1ff251d34c4d471ecc3586cdf130be1c665b2_value}"
  name         = "Database.Password"
  type         = "String"
  description  = "This is an example of a variable scoped to an environment"
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

variable "variable_c9c5116a122c3d94886131532de205ba0ad9c0b41280a670fca888b7689cd427_value" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable Database.Password"
  default     = "production.database.internal"
}
resource "octopusdeploy_variable" "variables_example_variable_set_database_password_3" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "${var.variable_c9c5116a122c3d94886131532de205ba0ad9c0b41280a670fca888b7689cd427_value}"
  name         = "Database.Password"
  type         = "String"
  description  = "This is an example of a variable scoped to an environment"
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

data "octopusdeploy_library_variable_sets" "library_variable_set_variables_example_variable_set" {
  ids          = null
  partial_name = "Example Variable Set"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_library_variable_set" "library_variable_set_variables_example_variable_set" {
  count       = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  name        = "Example Variable Set"
  description = ""

  template {
    name             = "Common.Variable"
    label            = "A common variable that must be defined for each tenant"
    help_text        = "The help text associated with the variable is defined here."
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "MultiLineText" }
  }
  template {
    name             = "Example.Account.Variable"
    label            = "The account to use"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "AmazonWebServicesAccount" }
  }
  template {
    name             = "Example.Azure.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "AzureAccount" }
  }
  template {
    name             = "Example.Certificate.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Certificate" }
  }
  template {
    name             = "Example.Checkbox.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Checkbox" }
  }
  template {
    name             = "Example.Dropdown.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Select", "Octopus.SelectOptions" = "Option1|This is the displayed text for option 1\nOption2|This is the displayed text for the second option" }
  }
  template {
    name             = "Example.GenericOIDC.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "GenericOidcAccount" }
  }
  template {
    name             = "Example.GCP.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "GoogleCloudAccount" }
  }
  template {
    name             = "Example.Password.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "Sensitive" }
  }
  template {
    name             = "Example.SingleLineTextBox.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "SingleLineText" }
  }
  template {
    name             = "Example.UsernamePassword.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "UsernamePasswordAccount" }
  }
  template {
    name             = "Example.WorkerPool.Variable"
    default_value    = ""
    display_settings = { "Octopus.ControlType" = "WorkerPool" }
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

variable "tenantvariable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_value" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The value of the tenant project variable"
  default     = "A custom value for the Test environment"
}
resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_australian_office" {
  count          = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  environment_id = "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"
  project_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  template_id    = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_project.project_every_step_project[0].template[0].id}"
  tenant_id      = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value          = "${var.tenantvariable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_value}"
  depends_on     = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

variable "tenantvariable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_value" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The value of the tenant project variable"
  default     = "This is the value for the test environment. Note that each tenant variable is a unique and distinct \"octopusdeploy_tenant_project_variable\" resource."
}
resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_australian_office" {
  count          = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  environment_id = "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"
  project_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  template_id    = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_project.project_every_step_project[0].template[1].id}"
  tenant_id      = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value          = "${var.tenantvariable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_value}"
  depends_on     = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

variable "variable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_sensitive_value" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable Australian Office"
  default     = "Change Me!"
}
resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[8].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[8].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "var.variable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_sensitive_value"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[9].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[9].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "single line of text"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[10].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[10].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3005"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[0].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "The value for the Australian Office tenant"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[2].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[2].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3002"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable6_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[3].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[3].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Certificates-461"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable7_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[4].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[4].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "True"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable8_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[7].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[7].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3003"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable9_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[11].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[11].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "WorkerPools-3788"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable10_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[1].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[1].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3001"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable11_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[5].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[5].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Option1"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable12_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[6].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[6].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-21"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
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

data "octopusdeploy_tag_sets" "tagset_cities" {
  ids          = null
  partial_name = "Cities"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_cities" {
  name        = "Cities"
  description = "An example tag set that captures cities"
  count       = length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_cities_tag_sydney" {
  name        = "Sydney"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#333333"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Sydney"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_london" {
  name        = "London"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#87BFEC"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "London"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_washington" {
  name        = "Washington"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#5ECD9E"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Washington"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_madrid" {
  name        = "Madrid"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#FFA461"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Madrid"], [])) != 0 ? 0 : 1
}

resource "octopusdeploy_tag" "tagset_cities_tag_wellington" {
  name        = "Wellington"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#C5AEEE"
  description = ""
  count       = length(try([for item in data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].tags : item if item.name == "Wellington"], [])) != 0 ? 0 : 1
}

data "octopusdeploy_tenants" "tenant_australian_office" {
  ids          = null
  partial_name = "Australian Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_australian_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  name        = "Australian Office"
  description = "An example tenant that represents an Australian office"
  tenant_tags = ["Cities/Sydney"]
  depends_on  = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_sydney]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tenant_project" "tenant_project_australian_office_every_step_project" {
  tenant_id       = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  project_id      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  environment_ids = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}", "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
}

data "octopusdeploy_tenants" "tenant_european_office" {
  ids          = null
  partial_name = "European Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_european_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_european_office.tenants) != 0 ? 0 : 1}"
  name        = "European Office"
  description = "An example tenant that represents the European office"
  tenant_tags = ["Cities/London"]
  depends_on  = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_london]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tenant_project" "tenant_project_european_office_every_step_project" {
  tenant_id       = "${length(data.octopusdeploy_tenants.tenant_european_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_european_office.tenants[0].id : octopusdeploy_tenant.tenant_european_office[0].id}"
  project_id      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  environment_ids = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}", "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
}

data "octopusdeploy_tenants" "tenant_main_office" {
  ids          = null
  partial_name = "Main Office"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_main_office" {
  count       = "${length(data.octopusdeploy_tenants.tenant_main_office.tenants) != 0 ? 0 : 1}"
  name        = "Main Office"
  description = "An example tenant that represents that main US office"
  tenant_tags = ["Cities/Washington"]
  depends_on  = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_washington]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tenant_project" "tenant_project_main_office_every_step_project" {
  tenant_id       = "${length(data.octopusdeploy_tenants.tenant_main_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_main_office.tenants[0].id : octopusdeploy_tenant.tenant_main_office[0].id}"
  project_id      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  environment_ids = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}", "${length(data.octopusdeploy_environments.environment_security.environments) != 0 ? data.octopusdeploy_environments.environment_security.environments[0].id : octopusdeploy_environment.environment_security[0].id}"]
}

data "octopusdeploy_channels" "channel_every_step_project_default" {
  ids          = []
  partial_name = "Default"
  skip         = 0
  take         = 1
}

data "octopusdeploy_projects" "channel_every_step_project_hotfix" {
  ids          = null
  partial_name = "Every Step Project"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_channel" "channel_every_step_project_hotfix" {
  count       = "${length(data.octopusdeploy_projects.channel_every_step_project_hotfix.projects) != 0 ? 0 : 1}"
  name        = "Hotfix"
  description = "This is an example channel with package version rules"
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  is_default  = false

  rule {

    action_package {
      deployment_action = "Deploy a Helm Chart"
    }

    tag           = "^featurebranch$"
    version_range = "[1.0,)"
  }

  tenant_tags = []
  depends_on  = [octopusdeploy_process_steps_order.process_step_order_every_step_project,octopusdeploy_process_steps_order.process_step_order_every_step_project_example_runbook]
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_accounts" "account_azure" {
  ids          = null
  partial_name = "Azure"
  skip         = 0
  take         = 1
  account_type = "AzureOIDC"
}
resource "octopusdeploy_azure_openid_connect" "account_azure" {
  count                             = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? 0 : 1}"
  name                              = "Azure"
  description                       = "An example of an unscoped Azure OIDC account available to all environments. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AzureOidc\"."
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  subscription_id                   = "00000000-0000-0000-0000-000000000000"
  azure_environment                 = ""
  tenant_id                         = "00000000-0000-0000-0000-000000000000"
  application_id                    = "00000000-0000-0000-0000-000000000000"
  audience                          = "api://AzureADTokenExchange"
  account_test_subject_keys         = ["space"]
  execution_subject_keys            = ["space"]
  health_subject_keys               = ["space"]
  depends_on                        = []
  lifecycle {
    ignore_changes  = []
    prevent_destroy = true
  }
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

data "octopusdeploy_feeds" "feed_helm" {
  feed_type    = "Helm"
  ids          = null
  partial_name = "Helm"
  skip         = 0
  take         = 1
}
variable "feed_helm_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Helm"
  default     = "Change Me!"
}
resource "octopusdeploy_helm_feed" "feed_helm" {
  count                                = "${length(data.octopusdeploy_feeds.feed_helm.feeds) != 0 ? 0 : 1}"
  name                                 = "Helm"
  password                             = "${var.feed_helm_password}"
  feed_uri                             = "https://charts.helm.sh/stable"
  username                             = "username"
  package_acquisition_location_options = ["ExecutionTarget", "Server", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_" {
  feed_type    = "OctopusProject"
  ids          = null
  partial_name = "Octopus Server Releases"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"Octopus Server Releases (built-in)\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
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

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
}

data "octopusdeploy_git_credentials" "gitcredential_github" {
  name = "GitHub"
  skip = 0
  take = 1
}
resource "octopusdeploy_git_credential" "gitcredential_github" {
  count    = "${length(data.octopusdeploy_git_credentials.gitcredential_github.git_credentials) != 0 ? 0 : 1}"
  name     = "GitHub"
  type     = "UsernamePassword"
  username = "x-access-token"
  password = "${var.gitcredential_github_sensitive_value}"
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "gitcredential_github_sensitive_value" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"GitHub\""
  default     = "Change Me!"
}

data "octopusdeploy_project_groups" "project_group_orchestrator" {
  ids          = null
  partial_name = "${var.project_group_orchestrator_name}"
  skip         = 0
  take         = 1
}
variable "project_group_orchestrator_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Orchestrator"
}
resource "octopusdeploy_project_group" "project_group_orchestrator" {
  count = "${length(data.octopusdeploy_project_groups.project_group_orchestrator.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_orchestrator_name}"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_channels" "channel_child_project_default" {
  ids          = []
  partial_name = "Default"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_process" "process_child_project" {
  count      = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_child_project_run_a_script" {
  count                 = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process.process_child_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hello world\""
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_child_project" {
  count      = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process.process_child_project[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_child_project_run_a_script[0].id}"]
}

variable "project_child_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Child Project"
  default     = "Child Project"
}
variable "project_child_project_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Child Project"
  default     = ""
}
variable "project_child_project_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Child Project"
  default     = ""
}
variable "project_child_project_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Child Project"
  default     = ""
}
variable "project_child_project_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project Untenanted"
  default     = "Untenanted"
}
data "octopusdeploy_projects" "project_child_project" {
  ids          = null
  partial_name = "${var.project_child_project_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_child_project" {
  count                                = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_child_project_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id : data.octopusdeploy_lifecycles.system_lifecycle_firstlifecycle.lifecycles[0].id}"
  project_group_id                     = "${length(data.octopusdeploy_project_groups.project_group_orchestrator.project_groups) != 0 ? data.octopusdeploy_project_groups.project_group_orchestrator.project_groups[0].id : octopusdeploy_project_group.project_group_orchestrator[0].id}"
  included_library_variable_sets       = []
  tenanted_deployment_participation    = "${var.project_child_project_tenanted}"

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_child_project_description_prefix}${var.project_child_project_description}${var.project_child_project_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_child_project" {
  count      = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}

data "octopusdeploy_community_step_template" "communitysteptemplate_readyroll___deploy_database_package" {
  website = "https://library.octopus.com/step-templates/14e87c33-b34a-429f-be2c-e44d3d631649"
}
data "octopusdeploy_step_template" "steptemplate_readyroll___deploy_database_package" {
  name = "ReadyRoll - Deploy Database Package"
}
resource "octopusdeploy_community_step_template" "communitysteptemplate_readyroll___deploy_database_package" {
  community_action_template_id = "${length(data.octopusdeploy_community_step_template.communitysteptemplate_readyroll___deploy_database_package.steps) != 0 ? data.octopusdeploy_community_step_template.communitysteptemplate_readyroll___deploy_database_package.steps[0].id : null}"
  count                        = "${data.octopusdeploy_step_template.steptemplate_readyroll___deploy_database_package.step_template != null ? 0 : 1}"
}

resource "octopusdeploy_process" "process_every_step_project" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  depends_on = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_sydney,octopusdeploy_tag.tagset_cities_tag_sydney,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_washington,octopusdeploy_tag.tagset_cities_tag_washington,octopusdeploy_tag.tagset_cities_tag_madrid,octopusdeploy_tag.tagset_cities_tag_madrid,octopusdeploy_tag.tagset_cities_tag_wellington,octopusdeploy_tag.tagset_cities_tag_wellington]
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_a_script" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "An example step that runs an inline script. This step is configured to only run for tenants with the London tenant tag. You will be penalized for defining a \"primary_package\" block for a script step with \"Octopus.Action.Script.ScriptSource\" set to \"Inline\"."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = ["Cities/London"]
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hello World!\"\n\nVARIABLE=\"test\"\n\n# Pay attention to how the $ character is escaped when defined in Terraform\necho \"$${VARIABLE}\"\n\n# Pay attention to how the percent character is escaped when defined in Terraform\ncurl -w \"%%{http_code}\" http://example.org"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
}

variable "project_every_step_project_step_run_a_script_from_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Run a Script from a package in project Every Step Project"
  default     = "scripts"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_run_a_script_from_a_package" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script from a package"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "An example step that is configured to run a script from a package. Note how this step defines a primary_package."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_run_a_script_from_a_package_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "run-a-script-from-a-package-1"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = ["Tag Set/tag", "Tag Set/tag2"]
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptFileName" = "MyScript.ps1"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Package"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_an_azure_script" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run an Azure Script"
  type                  = "Octopus.AzurePowerShell"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/azure-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This is an example step that runs an inline script against Azure resources. Note how this step does not defined a primary_package. Note how this step defines the \"Octopus.Action.Azure.AccountId\" property."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-an-azure-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = ["Business Units/Billing", "Business Units/Engineering", "Business Units/HR", "Business Units/Insurance", "Cities/London", "Cities/Madrid", "Cities/Sydney", "Cities/Washington", "Cities/Wellington", "Regions/ANZ", "Regions/Asia", "Regions/Europe", "Regions/US"]
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "Octopus.Action.Script.ScriptBody" = "# Note how dollar signs are escaped with another dollar sign\n$myvariable = \"hi\"\necho \"$myvariable\""
      }
}

variable "project_every_step_project_step_run_an_azure_script_from_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Run an Azure Script from a package in project Every Step Project"
  default     = "AzureScripts"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_run_an_azure_script_from_a_package" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run an Azure Script from a package"
  type                  = "Octopus.AzurePowerShell"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/azure-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This is an example step that runs a script against Azure resources from a package. Note how this step defines a primary_package. Note how this step defines the \"Octopus.Action.Azure.AccountId\" property."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_run_an_azure_script_from_a_package_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "run-an-azure-script-from-a-package"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = ["Business Units/Billing", "Business Units/Engineering", "Business Units/HR", "Business Units/Insurance", "Cities/London", "Cities/Madrid", "Cities/Sydney", "Cities/Washington", "Cities/Wellington", "Regions/ANZ", "Regions/Asia", "Regions/Europe", "Regions/US"]
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptFileName" = "CreaeResourceGroup.ps1"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Package"
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_an_aws_cli_script" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run an AWS CLI Script"
  type                  = "Octopus.AwsRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This is an example script that run against AWS resources. Note the absence of the primary_package block."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-an-aws-cli-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.Region" = "us-east-1"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
      }
}

variable "project_every_step_project_step_run_an_aws_cli_script_from_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Run an AWS CLI Script from package in project Every Step Project"
  default     = "awscript"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_run_an_aws_cli_script_from_package" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run an AWS CLI Script from package"
  type                  = "Octopus.AwsRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This is an example script, sourced from a package, that run against AWS resources. The package is defined in the primary_package."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_run_an_aws_cli_script_from_package_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "run-an-aws-cli-script-from-package"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "Package"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.Region" = "us-east-1"
        "Octopus.Action.Script.ScriptParameters" = "-ResourceName whatever"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptFileName" = "script.ps1"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_gcloud_in_a_script" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run gcloud in a Script"
  type                  = "Octopus.GoogleCloudScripting"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/gcp-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This is a script that runs against Google Cloud Platform (GCP) resources"
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-gcloud-in-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GoogleCloud.Region" = "australia-southeast1"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.GoogleCloud.Project" = "ProjectID"
        "Octopus.Action.GoogleCloud.Zone" = "australia-southeast1-a"
        "Octopus.Action.Script.Syntax" = "Bash"
        "OctopusUseBundledTooling" = "False"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_gcloud_in_a_script_with_an_account" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run gcloud in a Script with an account"
  type                  = "Octopus.GoogleCloudScripting"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/gcp-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This is a script that runs against Google Cloud Platform (GCP) resources using an account."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-gcloud-in-a-script-with-an-account"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.GoogleCloud.Zone" = "australia-southeast1-a"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.GoogleCloudAccount.Variable" = "Example.GCP.Variable"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "False"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.GoogleCloud.Project" = "ProjectID"
        "Octopus.Action.GoogleCloud.Region" = "australia-southeast1"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_an_azure_resource_manager_template" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy an Azure Resource Manager template"
  type                  = "Octopus.AzureResourceGroup"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys an Azure ARM template. Note the \"Octopus.Action.Azure.AccountId\" key in the \"execution_properties\" is required."
  package_requirement   = "LetOctopusDecide"
  slug                  = "deploy-an-azure-resource-manager-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "Octopus.Action.Azure.TemplateSource" = "Inline"
        "Octopus.Action.Azure.ResourceGroupName" = "my-resource-group"
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.ResourceGroupTemplate" = jsonencode({
        "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        "contentVersion" = "1.0.0.0"
        "resources" = []
                })
        "Octopus.Action.Azure.ResourceGroupDeploymentMode" = "Incremental"
        "Octopus.Action.Azure.ResourceGroupTemplateParameters" = jsonencode({        })
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_a_kubectl_script" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a kubectl script"
  type                  = "Octopus.KubernetesRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/k8s-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This runs a custom script using kubectl within the context of a Kubernetes cluster."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-kubectl-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Kubernetes"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "Write-Host \"Hello World\""
        "Octopus.Action.KubernetesContainers.Namespace" = "mynamespace"
      }
}

variable "project_every_step_project_step_deploy_to_iis_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy to IIS in project Every Step Project"
  default     = "webapp"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_to_iis" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy to IIS"
  type                  = "Octopus.IIS"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a Windows IIS application."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_to_iis_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-to-iis"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "windows-server"
      }
  execution_properties  = {
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.IISWebSite.EnableAnonymousAuthentication" = "False"
        "Octopus.Action.IISWebSite.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.ApplicationPoolName" = "apppool"
        "Octopus.Action.IISWebSite.WebRootType" = "packageRoot"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.IISWebSite.StartWebSite" = "True"
        "Octopus.Action.EnabledFeatures" = ",Octopus.Features.IISWebSite,Octopus.Features.ConfigurationTransforms,Octopus.Features.ConfigurationVariables"
        "Octopus.Action.IISWebSite.EnableWindowsAuthentication" = "True"
        "Octopus.Action.IISWebSite.CreateOrUpdateWebSite" = "True"
        "Octopus.Action.IISWebSite.Bindings" = jsonencode([
        {
        "requireSni" = "False"
        "enabled" = "True"
        "protocol" = "http"
        "port" = "80"
        "host" = ""
        "thumbprint" = null
        "certificateVariable" = null
                },
        ])
        "Octopus.Action.IISWebSite.EnableBasicAuthentication" = "False"
        "Octopus.Action.IISWebSite.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.IISWebSite.DeploymentType" = "webSite"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.WebSiteName" = "webapp"
        "Octopus.Action.IISWebSite.StartApplicationPool" = "True"
      }
}

variable "project_every_step_project_step_deploy_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Package in project Every Step Project"
  default     = "mypackage"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_a_package" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Package"
  type                  = "Octopus.TentaclePackage"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step copies a package to server or virtual machine."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_a_package_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-a-package"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "windows-server"
      }
  execution_properties  = {
        "Octopus.Action.EnabledFeatures" = ",Octopus.Features.ConfigurationTransforms,Octopus.Features.ConfigurationVariables"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
      }
}

variable "project_every_step_project_step_deploy_a_windows_service_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Windows Service in project Every Step Project"
  default     = "myservice"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_a_windows_service" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Windows Service"
  type                  = "Octopus.WindowsService"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a windows service."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_a_windows_service_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-a-windows-service"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "windows-server"
      }
  execution_properties  = {
        "Octopus.Action.EnabledFeatures" = ",Octopus.Features.WindowsService,Octopus.Features.ConfigurationTransforms,Octopus.Features.ConfigurationVariables"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.WindowsService.ServiceAccount" = "LocalSystem"
        "Octopus.Action.WindowsService.ExecutablePath" = "myapp.exe"
        "Octopus.Action.WindowsService.StartMode" = "auto"
        "Octopus.Action.WindowsService.Description" = "This is a sample deployment of a Windows service"
        "Octopus.Action.WindowsService.DisplayName" = "My sample Windows service"
        "Octopus.Action.WindowsService.DesiredStatus" = "Default"
        "Octopus.Action.WindowsService.ServiceName" = "My Service"
        "Octopus.Action.WindowsService.CreateOrUpdateService" = "True"
      }
}

variable "project_every_step_project_step_deploy_an_azure_web_app__web_deploy__packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy an Azure Web App (Web Deploy) in project Every Step Project"
  default     = "MyAzureWebApp"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_an_azure_web_app__web_deploy_" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy an Azure Web App (Web Deploy)"
  type                  = "Octopus.AzureWebApp"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/azure-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys an application an an Azure Web App. Note how this step does not define any scripts. Note how this step defined the \"target_roles\" attribute."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_an_azure_web_app__web_deploy__packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-an-azure-web-app-web-deploy"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "AzureWebApp"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.UseChecksum" = "False"
      }
}

variable "project_every_step_project_step_upload_a_package_to_an_aws_s3_bucket_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Upload a package to an AWS S3 bucket in project Every Step Project"
  default     = "MyAWSPackage"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_upload_a_package_to_an_aws_s3_bucket" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Upload a package to an AWS S3 bucket"
  type                  = "Octopus.AwsUploadS3"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step uploads a file to an AWS S3 bucket."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_upload_a_package_to_an_aws_s3_bucket_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "upload-a-package-to-an-aws-s3-bucket"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Aws.Region" = "ap-southeast-2"
        "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
        "cannedAcl" = "private"
        "variableSubstitutionPatterns" = ""
        "structuredVariableSubstitutionPatterns" = ""
        "metadata" = []
        "storageClass" = "STANDARD"
        "tags" = []
        "bucketKey" = "mybucket"
        "bucketKeyBehaviour" = "Custom"
        "bucketKeyPrefix" = ""
                })
        "Octopus.Action.Aws.S3.BucketName" = "my-s3-bucket"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.RunOnServer" = "false"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.S3.TargetMode" = "EntirePackage"
      }
}

variable "project_every_step_project_step_deploy_java_archive_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Java Archive in project Every Step Project"
  default     = "MyJavaApp"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_java_archive" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy Java Archive"
  type                  = "Octopus.JavaArchive"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a Java WAR or JAR file to the filesystem."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_java_archive_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-java-archive"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "JavaAppServer"
      }
  execution_properties  = {
        "Octopus.Action.Package.UseCustomInstallationDirectory" = "False"
        "Octopus.Action.Package.CustomInstallationDirectoryShouldBePurgedBeforeDeployment" = "False"
        "Octopus.Action.JavaArchive.DeployExploded" = "False"
        "Octopus.Action.Package.JavaArchiveCompression" = "True"
        "Octopus.Action.EnabledFeatures" = ",Octopus.Features.SubstituteInFiles"
      }
}

variable "project_every_step_project_step_deploy_a_helm_chart_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Helm Chart in project Every Step Project"
  default     = "MyHelmApp"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_a_helm_chart" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Helm Chart"
  type                  = "Octopus.HelmChartUpgrade"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a Kubernetes Helm chart."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${length(data.octopusdeploy_feeds.feed_helm.feeds) != 0 ? data.octopusdeploy_feeds.feed_helm.feeds[0].id : octopusdeploy_helm_feed.feed_helm[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_a_helm_chart_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-a-helm-chart"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Kubernetes"
      }
  execution_properties  = {
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Script.ScriptSource" = "Package"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Helm.Namespace" = "mycustomnamespace"
        "Octopus.Action.Helm.ResetValues" = "True"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_kubernetes_yaml" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy Kubernetes YAML"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/k8s-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a raw YAML document to a Kubernetes cluster."
  package_requirement   = "LetOctopusDecide"
  slug                  = "deploy-kubernetes-yaml"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Kubernetes"
      }
  execution_properties  = {
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.14.2\n        ports:\n        - containerPort: 80"
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_kubernetes_yaml_with_client_side_apply" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy Kubernetes YAML with client side apply"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/k8s-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys a raw YAML document to a Kubernetes cluster. It enables client side apply for kubectl and disables kubernetes object status verification checks."
  package_requirement   = "LetOctopusDecide"
  slug                  = "deploy-kubernetes-yaml-with-client-side-apply"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Kubernetes"
      }
  execution_properties  = {
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "False"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.KubernetesContainers.DeploymentWait" = "NoWait"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.14.2\n        ports:\n        - containerPort: 80"
      }
}

variable "project_every_step_project_step_deploy_kubernetes_yaml_from_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Kubernetes YAML from a package in project Every Step Project"
  default     = "K8sApplication"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_kubernetes_yaml_from_a_package" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy Kubernetes YAML from a package"
  type                  = "Octopus.KubernetesDeployRawYaml"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/k8s-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step provides an example deploying a Kubernetes YAML file from a package."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_kubernetes_yaml_from_a_package_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-kubernetes-yaml-from-a-package"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Kubernetes"
      }
  execution_properties  = {
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.14.2\n        ports:\n        - containerPort: 80"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Script.ScriptSource" = "Package"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "deployment.yaml"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_with_kustomize" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy with Kustomize"
  type                  = "Octopus.Kubernetes.Kustomize"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  git_dependencies      = { "" = { default_branch = "main", file_path_filters = null, git_credential_id = "${length(data.octopusdeploy_git_credentials.gitcredential_github.git_credentials) != 0 ? data.octopusdeploy_git_credentials.gitcredential_github.git_credentials[0].id : octopusdeploy_git_credential.gitcredential_github[0].id}", git_credential_type = "Library", repository_uri = "https://github.com/OctopusSamples/OctoPetShop.git" } }
  notes                 = "This step deploys a Kustomize resource to a Kubernetes cluster."
  package_requirement   = "LetOctopusDecide"
  slug                  = "deploy-with-kustomize"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "Kubernetes"
      }
  execution_properties  = {
        "Octopus.Action.Kubernetes.Kustomize.OverlayPath" = "overlays/#{Octopus.Environment.Name}"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
        "Octopus.Action.SubstituteInFiles.TargetFiles" = " **/*.env"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_apply_a_terraform_template" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Apply a Terraform template"
  type                  = "Octopus.TerraformApply"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/terraform-workertools" }
  environments          = null
  excluded_environments = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  notes                 = "This step deploys a Terraform configuration file."
  package_requirement   = "LetOctopusDecide"
  slug                  = "apply-a-terraform-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
                })
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_destroy_terraform_resources" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Destroy Terraform resources"
  type                  = "Octopus.TerraformDestroy"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/terraform-workertools" }
  environments          = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  excluded_environments = null
  notes                 = "This step destroys resources created by a Terraform configuration file."
  package_requirement   = "LetOctopusDecide"
  slug                  = "destroy-terraform-resources"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.AzureAccount" = "False"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_plan_to_apply_a_terraform_template" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Plan to apply a Terraform template"
  type                  = "Octopus.TerraformPlan"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/terraform-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step plans the changes that will be implemented by a Terraform configuration file."
  package_requirement   = "LetOctopusDecide"
  slug                  = "plan-to-apply-a-terraform-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.ExecutionTimeout.Minutes" = "5"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_plan_a_terraform_destroy" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Plan a Terraform destroy"
  type                  = "Octopus.TerraformPlanDestroy"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/terraform-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step plans the destruction of resources created by a Terraform configuration file."
  package_requirement   = "LetOctopusDecide"
  slug                  = "plan-a-terraform-destroy"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.AutoRetry.MinimumBackoff" = "15"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.AutoRetry.MaximumCount" = "3"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_an_aws_cloudformation_template" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy an AWS CloudFormation template"
  type                  = "Octopus.AwsRunCloudFormation"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Variable"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys an AWS CloudFormation template. Because this step has the \"condition\" property set to \"Variable\", the \"Octopus.Step.ConditionVariableExpression\" property must be defined."
  package_requirement   = "LetOctopusDecide"
  slug                  = "deploy-an-aws-cloudformation-template"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{Step.Run}"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.CloudFormationStackName" = "mystackname"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.Region" = "us-east-2"
        "Octopus.Action.Aws.TemplateSource" = "Inline"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.CloudFormationTemplate" = "AWSTemplateFormatVersion: '2010-09-09'\nDescription: 'CloudFormation exports'\n \nConditions:\n  HasNot: !Equals [ 'true', 'false' ]\n \n# dummy (null) resource, never created\nResources:\n  NullResource:\n    Type: 'Custom::NullResource'\n    Condition: HasNot\n \nOutputs:\n  ExportsStackName:\n    Value: !Ref 'AWS::StackName'\n    Export:\n      Name: !Sub 'ExportsStackName-$${AWS::StackName}'"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.CloudFormationTemplateParameters" = jsonencode([])
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
      }
}

variable "project_every_step_project_step_deploy_an_aws_cloudformation_template_from_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy an AWS CloudFormation template from package in project Every Step Project"
  default     = "cloudformation"
}
resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_an_aws_cloudformation_template_from_package" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy an AWS CloudFormation template from package"
  type                  = "Octopus.AwsRunCloudFormation"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Variable"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step deploys an AWS CloudFormation template from a package."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "Server", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}", id = null, package_id = "${var.project_every_step_project_step_deploy_an_aws_cloudformation_template_from_package_packageid}", properties = { SelectionMode = "immediate" } }
  slug                  = "deploy-an-aws-cloudformation-template-from-package"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{Step.Run}"
      }
  execution_properties  = {
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.TemplateSource" = "Package"
        "Octopus.Action.Aws.CloudFormationTemplate" = "cloudformation.yaml"
        "Octopus.Action.Package.JsonConfigurationVariablesTargets" = "cloudformation.yaml"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.CloudFormationStackName" = "mystackname"
        "Octopus.Action.Aws.Region" = "us-east-2"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_apply_an_aws_cloudformation_change_set" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Apply an AWS CloudFormation Change Set"
  type                  = "Octopus.AwsApplyCloudFormationChangeSet"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Always"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step applies an AWS CloudFormation Change Set."
  package_requirement   = "LetOctopusDecide"
  slug                  = "apply-an-aws-cloudformation-change-set"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Aws.CloudFormation.ChangeSet.Arn" = "mychangeset"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.CloudFormationStackName" = "mystack"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.Region" = "ap-southeast-1"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_delete_an_aws_cloudformation_stack" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Delete an AWS CloudFormation stack"
  type                  = "Octopus.AwsDeleteCloudFormation"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Failure"
  container             = { feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}", image = "ghcr.io/octopusdeploylabs/aws-workertools" }
  environments          = null
  excluded_environments = null
  notes                 = "This step deletes an AWS CloudFormation stack."
  package_requirement   = "LetOctopusDecide"
  slug                  = "delete-an-aws-cloudformation-stack"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.Region" = "us-east-2"
        "Octopus.Action.Aws.CloudFormationStackName" = "my-stack-name"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.AssumeRole" = "False"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_a_script_on_failure" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script on Failure"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Failure"
  environments          = null
  excluded_environments = null
  notes                 = "This is an example of a step that run when the previous step fails."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script-on-failure"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.Script.ScriptBody" = "echo \"hi\""
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_a_step_with_a_conditionvariableexpression" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "A step with a ConditionVariableExpression"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Variable"
  environments          = null
  excluded_environments = null
  notes                 = "This step uses a condition variable, which is defined in the \"Octopus.Step.ConditionVariableExpression\" property."
  package_requirement   = "LetOctopusDecide"
  slug                  = "a-step-with-a-conditionvariableexpression"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
        "Octopus.Step.ConditionVariableExpression" = "#{RunStep}"
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"hi\""
        "OctopusUseBundledTooling" = "False"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_a_release___deploy_release_if_new_deployment_is_higher" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Release - Deploy release if new deployment is higher"
  type                  = "Octopus.DeployRelease"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step is used to deploy a release of a child project. It will deploy the child project if the selected release is higher than release in the environment."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "NotAcquired", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}", id = null, package_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}", properties = null }
  slug                  = "deploy-a-release"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.DeployRelease.ProjectId" = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.DeployRelease.DeploymentCondition" = "IfNewer"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_a_release___always_deploy" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Release - Always Deploy"
  type                  = "Octopus.DeployRelease"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step is used to deploy a release of a child project. The child project is always deployed."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "NotAcquired", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}", id = null, package_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}", properties = null }
  slug                  = "deploy-a-release-clone-1"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.DeployRelease.ProjectId" = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_deploy_a_release___always_deploy_" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Deploy a Release - Always Deploy "
  type                  = "Octopus.DeployRelease"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step is used to deploy a release of a child project. The child project is always deployed."
  package_requirement   = "LetOctopusDecide"
  primary_package       = { acquisition_location = "NotAcquired", feed_id = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}", id = null, package_id = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}", properties = null }
  slug                  = "deploy-a-release-always-deploy-clone-1"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.DeployRelease.ProjectId" = "${length(data.octopusdeploy_projects.project_child_project.projects) != 0 ? data.octopusdeploy_projects.project_child_project.projects[0].id : octopusdeploy_project.project_child_project[0].id}"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
      }
}

variable "action_42a747be20485d6b5e8a0a491bcf6c5690a9188c88f6ca0c4c1dff9abe22d051_sensitive_value" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "Sensitive value for property DatabasePassword"
  default     = "Change Me!"
}
resource "octopusdeploy_process_templated_step" "process_step_every_step_project_readyroll___deploy_database_package" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "ReadyRoll - Deploy Database Package"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  template_id           = "${data.octopusdeploy_step_template.steptemplate_readyroll___deploy_database_package.step_template != null ? data.octopusdeploy_step_template.steptemplate_readyroll___deploy_database_package.step_template.id : octopusdeploy_community_step_template.communitysteptemplate_readyroll___deploy_database_package[0].id}"
  template_version      = "${data.octopusdeploy_step_template.steptemplate_readyroll___deploy_database_package.step_template != null ? data.octopusdeploy_step_template.steptemplate_readyroll___deploy_database_package.step_template.version : octopusdeploy_community_step_template.communitysteptemplate_readyroll___deploy_database_package[0].version}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This is an example of a community step template."
  package_requirement   = "LetOctopusDecide"
  slug                  = "readyroll-deploy-database-package"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
        "Octopus.Action.TargetRoles" = "TestMe"
      }
  execution_properties  = {
      }
  parameters            = {
        "DatabasePassword" = "${var.action_42a747be20485d6b5e8a0a491bcf6c5690a9188c88f6ca0c4c1dff9abe22d051_sensitive_value}"
        "DatabaseName" = "Database"
        "UseWindowsAuth" = "True"
        "DatabaseUsername" = "Username"
        "PackageName" = jsonencode({
        "FeedId" = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        "PackageId" = "MyPackage"
                })
        "DatabaseServer" = "SQL Server"
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_a_script_for_a_tenant" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script for a tenant"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script-for-a-tenant"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = ["Tag Set/tag"]
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"This step is scoped to a tenant tag\""
      }
}

resource "octopusdeploy_process_step" "process_step_every_step_project_run_an_aws_cli_script_with_retries_enabled" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run an AWS CLI Script with retries enabled"
  type                  = "Octopus.AwsRunScript"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  notes                 = "This step has retries enabled."
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-an-aws-cli-script-with-retries-enabled"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  properties            = {
      }
  execution_properties  = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.Region" = "us-west-2"
        "Octopus.Action.AutoRetry.MinimumBackoff" = "15"
        "Octopus.Action.AutoRetry.MaximumCount" = "3"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptBody" = "echo \"hi\""
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_every_step_project" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_a_script[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_a_script_from_a_package[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_an_azure_script[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_an_azure_script_from_a_package[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_an_aws_cli_script[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_an_aws_cli_script_from_package[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_gcloud_in_a_script[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_gcloud_in_a_script_with_an_account[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_an_azure_resource_manager_template[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_a_kubectl_script[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_to_iis[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_a_package[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_a_windows_service[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_an_azure_web_app__web_deploy_[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_upload_a_package_to_an_aws_s3_bucket[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_java_archive[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_a_helm_chart[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_kubernetes_yaml[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_kubernetes_yaml_with_client_side_apply[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_kubernetes_yaml_from_a_package[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_with_kustomize[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_apply_a_terraform_template[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_destroy_terraform_resources[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_plan_to_apply_a_terraform_template[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_plan_a_terraform_destroy[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_an_aws_cloudformation_template[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_an_aws_cloudformation_template_from_package[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_apply_an_aws_cloudformation_change_set[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_delete_an_aws_cloudformation_stack[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_a_script_on_failure[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_a_step_with_a_conditionvariableexpression[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_a_release___deploy_release_if_new_deployment_is_higher[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_a_release___always_deploy[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_deploy_a_release___always_deploy_[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_templated_step.process_step_every_step_project_readyroll___deploy_database_package[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_a_script_for_a_tenant[0].id}", "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_an_aws_cli_script_with_retries_enabled[0].id}"]
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
  description                       = "An AWS OIDC account. See https://octopus.com/docs/infrastructure/accounts/aws for more information. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"AmazonWebServicesOidcAccount\". Note the \"role_arn\" property is mandatory for accounts of type \"AmazonWebServicesOidcAccount\"."
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

resource "octopusdeploy_variable" "every_step_project_account_aws_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_aws_oidc.accounts) != 0 ? data.octopusdeploy_accounts.account_aws_oidc.accounts[0].id : octopusdeploy_aws_openid_connect_account.account_aws_oidc[0].id}"
  name         = "Account.AWS"
  type         = "AmazonWebServicesAccount"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_step_run_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "True"
  name         = "Step.Run"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_project_sensitive_value_1" {
  count           = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  name            = "Project.Sensitive.Value"
  type            = "Sensitive"
  description     = "This is a sensitive value. It includes the \"sensitive_value\" attribute. It does not include the \"value\" attribute."
  is_sensitive    = true
  sensitive_value = "Change Me!"
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_project_azure_account_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
  name         = "Project.Azure.Account"
  type         = "AzureAccount"
  description  = "This variable points to an Azure account."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_accounts" "account_google_cloud_account" {
  ids          = null
  partial_name = "Google Cloud Account"
  skip         = 0
  take         = 1
  account_type = "GoogleCloudAccount"
}
resource "octopusdeploy_gcp_account" "account_google_cloud_account" {
  count                             = "${length(data.octopusdeploy_accounts.account_google_cloud_account.accounts) != 0 ? 0 : 1}"
  name                              = "Google Cloud Account"
  description                       = "An example of a Google Cloud (GCP) Account scoped to the Development environment Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"GoogleCloudAccount\"."
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  json_key                          = "${var.account_google_cloud_account}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [json_key]
    prevent_destroy = true
  }
}
variable "account_google_cloud_account" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The GCP JSON key associated with the account Google Cloud Account"
  default     = "Change Me!"
}

resource "octopusdeploy_variable" "every_step_project_project_gcp_account_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_google_cloud_account.accounts) != 0 ? data.octopusdeploy_accounts.account_google_cloud_account.accounts[0].id : octopusdeploy_gcp_account.account_google_cloud_account[0].id}"
  name         = "Project.GCP.Account"
  type         = "GoogleCloudAccount"
  description  = "This variable points to a Google Cloud Account."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_accounts" "account_username_password" {
  ids          = null
  partial_name = "Username Password"
  skip         = 0
  take         = 1
  account_type = "UsernamePassword"
}
resource "octopusdeploy_username_password_account" "account_username_password" {
  count                             = "${length(data.octopusdeploy_accounts.account_username_password.accounts) != 0 ? 0 : 1}"
  name                              = "Username Password"
  description                       = "An example of a username password account scoped to the Production environment. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"UsernamePassword\"."
  environments                      = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  username                          = "username"
  password                          = "${var.account_username_password}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_username_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password associated with the account Username Password"
  default     = "Change Me!"
}

resource "octopusdeploy_variable" "every_step_project_project_usernamepassword_account_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_username_password.accounts) != 0 ? data.octopusdeploy_accounts.account_username_password.accounts[0].id : octopusdeploy_username_password_account.account_username_password[0].id}"
  name         = "Project.UsernamePassword.Account"
  type         = "UsernamePasswordAccount"
  description  = "This variable points to a username/password account."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_accounts" "account_generic_oidc" {
  ids          = null
  partial_name = "Generic OIDC"
  skip         = 0
  take         = 1
  account_type = "GenericOidcAccount"
}
resource "octopusdeploy_aws_openid_connect_account" "account_generic_oidc" {
  count                             = "${length(data.octopusdeploy_accounts.account_generic_oidc.accounts) != 0 ? 0 : 1}"
  name                              = "Generic OIDC"
  description                       = "An example of an unscoped generic OIDC account. Note the \"account_type\" in the associated \"octopusdeploy_accounts\" data source is set to \"GenericOidcAccount\"."
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  execution_subject_keys            = ["space"]
  tenanted_deployment_participation = "Untenanted"
  depends_on                        = []
  lifecycle {
    ignore_changes  = []
    prevent_destroy = true
  }
}

resource "octopusdeploy_variable" "every_step_project_project_oidc_account_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_accounts.account_generic_oidc.accounts) != 0 ? data.octopusdeploy_accounts.account_generic_oidc.accounts[0].id : octopusdeploy_aws_openid_connect_account.account_generic_oidc[0].id}"
  name         = "Project.OIDC.Account"
  type         = "GenericOidcAccount"
  description  = "This variable points to a Generic OIDC account."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_worker_pools" "workerpool_worker_pool" {
  ids          = null
  partial_name = "Worker Pool"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_static_worker_pool" "workerpool_worker_pool" {
  count       = "${length(data.octopusdeploy_worker_pools.workerpool_worker_pool.worker_pools) != 0 ? 0 : 1}"
  name        = "Worker Pool"
  description = "An example of a worker pool"
  is_default  = false
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_variable" "every_step_project_project_workerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_worker_pool.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_worker_pool.worker_pools[0].id : octopusdeploy_static_worker_pool.workerpool_worker_pool[0].id}"
  name         = "Project.WorkerPool"
  type         = "WorkerPool"
  description  = "This variable points to a worker pool."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_project_scopedvariable1_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "scoped variable"
  name         = "Project.ScopedVariable1"
  type         = "String"
  description  = "This variable is scoped to an environment"
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

resource "octopusdeploy_variable" "every_step_project_project_scopedvariable3_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "deployment process scoped variable"
  name         = "Project.ScopedVariable3"
  type         = "String"
  description  = "This variable is scoped to the deployment process"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = null
    machines     = null
    roles        = null
    tenant_tags  = null
    processes    = ["${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"]
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_variable_scoped_targettag_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "scoped to target"
  name         = "Variable.Scoped.TargetTag"
  type         = "String"
  description  = "This is an example of a variable scoped to a target tag (or role)"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = null
    machines     = null
    roles        = ["Kubernetes"]
    tenant_tags  = null
    processes    = null
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_scoped_to_step_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "whatever"
  name         = "Scoped.To.Step"
  type         = "String"
  description  = "This is an example of a variable scoped to a step"
  is_sensitive = false

  scope {
    actions      = ["${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_run_a_script[0].id}"]
    channels     = null
    environments = null
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

resource "octopusdeploy_variable" "every_step_project_channel_scoped_variables_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "this is scoped to the hotfix channel"
  name         = "Channel.Scoped.Variables"
  type         = "String"
  description  = "This is an example of a variable scoped to a channel"
  is_sensitive = false

  scope {
    actions      = null
    channels     = ["${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_channel.channel_every_step_project_hotfix[0].id}"]
    environments = null
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

resource "octopusdeploy_variable" "every_step_project_runbook_scoped_variable_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "scoped to a runbook"
  name         = "Runbook Scoped Variable"
  type         = "String"
  description  = "This is an example of a variable scoped to a runbook"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_prompted_variable_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  name         = "Prompted Variable"
  type         = "String"
  description  = "This is an example of a checkbox prompted variable"
  is_sensitive = false

  prompt {
    description = "This is the description"
    label       = "This is the label"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_prompted_variable_textbox_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "The default value"
  name         = "Prompted Variable TextBox"
  type         = "String"
  description  = "This is an example of a single line textbox prompted variable"
  is_sensitive = false

  prompt {
    description = "This is the description"
    label       = "This is the label"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_prompted_variable_multiline_textbox_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "The default value\nover multiple lines"
  name         = "Prompted Variable Multiline TextBox"
  type         = "String"
  description  = "This is an example of a multiline textbox prompted variable"
  is_sensitive = false

  prompt {
    description = "This is the description"
    label       = "This is the label"
    is_required = false

    display_settings {
      control_type = "MultiLineText"
    }
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_prompted_variable_dropdown_list_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "Value1"
  name         = "Prompted Variable Dropdown List"
  type         = "String"
  description  = "This is an example of a dropdown list prompted variable"
  is_sensitive = false

  prompt {
    description = "This is the description"
    label       = "This is the label"
    is_required = false

    display_settings {
      control_type = "Select"

      select_option {
        display_name = "Value1"
        value        = "Display text 1"
      }
      select_option {
        display_name = "Value2"
        value        = "Display text 2"
      }
    }
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_octopusprintevaluatedvariables_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "False"
  name         = "OctopusPrintEvaluatedVariables"
  type         = "String"
  description  = "OctopusPrintEvaluatedVariables is a system variable that enbaled debugging by printing the evaluated value of each variable to the verbose logs. Set the variable to true to enable debugging."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_octopusprintvariables_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "False"
  name         = "OctopusPrintVariables"
  type         = "String"
  description  = "OctopusPrintVariables is a system variable that enables debugging by printing the value of each variable to the verbose logs. Set the value to true to enable debugging."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_runstep_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "true"
  name         = "RunStep"
  type         = "String"
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_project_hostedworkerpool_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  name         = "Project.HostedWorkerPool"
  type         = "WorkerPool"
  description  = "A variable referecing the hosted ubuntu worker pool. Note that the value for this variable first attempts to look up the data source \"data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools\", and if that is empty, then looks up the data source \"data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools\"."
  is_sensitive = false
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_prompted_variable_with_no_label_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  name         = "Prompted variable with no label"
  type         = "String"
  is_sensitive = false

  prompt {
    description = "Note the format of the label field when there is no label"
    label       = ""
    is_required = false
  }
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_project_deployment_target_trigger" "projecttrigger_every_step_project_deployment_target_trigger" {
  count            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name             = "Deployment Target Trigger"
  project_id       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  event_categories = ["MachineAdded", "MachineDeploymentRelatedPropertyWasUpdated", "MachineCleanupFailed"]
  environment_ids  = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  event_groups     = ["Machine", "MachineCritical", "MachineAvailableForDeployment", "MachineUnavailableForDeployment", "MachineHealthChanged"]
  roles            = ["Kubernetes"]
  should_redeploy  = false
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_every_step_project_example_scheduled_trigger" {
  count       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Example Scheduled Trigger"
  description = "This is an example of a scheduled trigger."
  timezone    = "UTC"
  is_disabled = false
  channel_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_channel.channel_every_step_project_hotfix[0].id}"
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  tenant_ids  = ["${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"]

  once_daily_schedule {
    start_time   = "2025-05-03T09:00:00"
    days_of_week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  }

  deploy_latest_release_action {
    source_environment_id      = "${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"
    destination_environment_id = "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"
    should_redeploy            = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_every_step_project_external_feed_trigger" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  name       = "External Feed Trigger"
  channel_id = "Channels-1"

  package {
    deployment_action_slug = "deploy-a-helm-chart"
    package_reference      = ""
  }
  depends_on = [octopusdeploy_process_steps_order.process_step_order_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_git_trigger" "projecttrigger_every_step_project_git_trigger" {
  count       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Git Trigger"
  description = "This is an example of a git trigger"
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  channel_id  = "Channels-1"
  sources     = [{ deployment_action_slug = "deploy-with-kustomize", exclude_file_paths = [], git_dependency_name = "", include_file_paths = [] }]
  depends_on  = [octopusdeploy_process_steps_order.process_step_order_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_every_step_project_scheduled_trigger_with_cron" {
  count       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Scheduled trigger with cron"
  description = "This scheduled trigger provides an example of using a cron expression."
  timezone    = "UTC"
  is_disabled = false
  channel_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_channel.channel_every_step_project_hotfix[0].id}"
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  tenant_ids  = []

  cron_expression_schedule {
    cron_expression = "0 * * * *"
  }

  deploy_latest_release_action {
    source_environment_id      = "${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"
    destination_environment_id = "${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"
    should_redeploy            = true
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_every_step_project_second_external_feed_trigger" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  name       = "Second External Feed Trigger"
  channel_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_channel.channel_every_step_project_hotfix[0].id}"

  package {
    deployment_action_slug = "deploy-a-helm-chart"
    package_reference      = ""
  }
  depends_on = [octopusdeploy_process_steps_order.process_step_order_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_git_trigger" "projecttrigger_every_step_project_second_git_trigger" {
  count       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Second Git Trigger"
  description = ""
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  channel_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_channel.channel_every_step_project_hotfix[0].id}"
  sources     = [{ deployment_action_slug = "deploy-with-kustomize", exclude_file_paths = [], git_dependency_name = "", include_file_paths = ["release/**"] }]
  depends_on  = [octopusdeploy_process_steps_order.process_step_order_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_every_step_project_second_scheduled_trigger" {
  count       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Second Scheduled Trigger"
  description = ""
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  tenant_ids  = ["${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"]

  once_daily_schedule {
    start_time   = "2025-10-20T09:00:00"
    days_of_week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_built_in_trigger" "projecttrigger_every_step_project_built_in_feed_trigger" {
  count                    = "${length(data.octopusdeploy_built_in_trigger.Every Step Project.projects) != 0 ? 0 : 1}"
  space_id                 = "${trimspace(var.octopus_space_id)}"
  channel_id               = "Channels-1"
  project_id               = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  release_creation_package = { deployment_action = "Deploy a Package", package_reference = "" }
  depends_on               = [octopusdeploy_process_steps_order.process_step_order_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_every_step_project_scheduled_trigger" {
  count       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Scheduled Trigger"
  description = "This is an example of a runbook scheduled trigger"
  timezone    = "UTC"
  is_disabled = false
  project_id  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  tenant_ids  = ["${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"]

  once_daily_schedule {
    start_time   = "2025-05-07T09:00:00"
    days_of_week = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  }

  run_runbook_action {
    target_environment_ids = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
    runbook_id             = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_runbook.runbook_every_step_project_example_runbook[0].id}"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_process" "process_every_step_project_example_runbook" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  runbook_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_runbook.runbook_every_step_project_example_runbook[0].id}"
  depends_on = []
}

resource "octopusdeploy_process_step" "process_step_every_step_project_example_runbook_run_a_script" {
  count                 = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                  = "Run a Script"
  type                  = "Octopus.Script"
  process_id            = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project_example_runbook[0].id}"
  channels              = null
  condition             = "Success"
  environments          = null
  excluded_environments = null
  package_requirement   = "LetOctopusDecide"
  slug                  = "run-a-script"
  start_trigger         = "StartAfterPrevious"
  tenant_tags           = null
  worker_pool_id        = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  properties            = {
      }
  execution_properties  = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"This is an example script step\""
        "OctopusUseBundledTooling" = "False"
      }
}

resource "octopusdeploy_process_steps_order" "process_step_order_every_step_project_example_runbook" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  process_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process.process_every_step_project_example_runbook[0].id}"
  steps      = ["${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? null : octopusdeploy_process_step.process_step_every_step_project_example_runbook_run_a_script[0].id}"]
}

variable "runbook_every_step_project_example_runbook_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Example Runbook"
  default     = "Example Runbook"
}
resource "octopusdeploy_runbook" "runbook_every_step_project_example_runbook" {
  count                       = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                        = "${var.runbook_every_step_project_example_runbook_name}"
  project_id                  = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  environment_scope           = "Specified"
  environments                = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "This is an example of a runbook"
  multi_tenancy_mode          = "TenantedOrUntenanted"

  retention_policy {
    should_keep_forever = true
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
}

variable "project_every_step_project_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Every Step Project"
  default     = "Every Step Project"
}
variable "project_every_step_project_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Every Step Project"
  default     = ""
}
variable "project_every_step_project_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Every Step Project"
  default     = ""
}
variable "project_every_step_project_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Every Step Project"
  default     = "This sample project has every step in Octopus assigned to the deployment process. These steps can be used as examples on which to build custom projects. Note how this project has an associated data \"octopusdeploy_projects\" \"project_every_step_project\"."
}
variable "project_every_step_project_tenanted" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The tenanted setting for the project TenantedOrUntenanted"
  default     = "TenantedOrUntenanted"
}
data "octopusdeploy_projects" "project_every_step_project" {
  ids          = null
  partial_name = "${var.project_every_step_project_name}"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project" "project_every_step_project" {
  count                                = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  name                                 = "${var.project_every_step_project_name}"
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  is_discrete_channel_release          = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_application[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
  included_library_variable_sets       = ["${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"]
  tenanted_deployment_participation    = "${var.project_every_step_project_tenanted}"
  release_notes_template               = "Here are the notes for the packages\n#{each package in Octopus.Release.Package}\n- #{package.PackageId} #{package.Version}\n#{each workItem in package.WorkItems}\n    - [#{workItem.Id}](#{workItem.LinkUrl}) - #{workItem.Description}\n#{/each}\n#{/each}"

  template {
    name             = "Example.Tenant.Variable"
    label            = "An example tenant variable required to be defined by all tenants that deploy this project."
    help_text        = "This is where the help text associated with the variable is defined."
    default_value    = "The default value"
    display_settings = { "Octopus.ControlType" = "MultiLineText" }
  }
  template {
    name             = "Another.Tenant.Variable"
    label            = "This is another example of a tenant variable"
    help_text        = "The help text. "
    default_value    = "The default value"
    display_settings = { "Octopus.ControlType" = "MultiLineText" }
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
    target_roles                    = []
  }
  description = "${var.project_every_step_project_description_prefix}${var.project_every_step_project_description}${var.project_every_step_project_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}
resource "octopusdeploy_project_versioning_strategy" "project_every_step_project" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  template   = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
}


