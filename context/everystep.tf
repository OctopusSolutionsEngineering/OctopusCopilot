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

variable "tenantvariable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_value" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The value of the tenant project variable"
  default     = "A custom value for the Production environment"
}
resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_australian_office" {
  count          = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  environment_id = "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"
  project_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  template_id    = "${octopusdeploy_project.project_every_step_project.template[0].id}"
  tenant_id      = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value          = "${var.tenantvariable_e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855_value}"
  depends_on     = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[8] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[8].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = ""
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[2] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[2].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3002"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[4] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[4].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "True"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[5] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[5].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Option1"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[6] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[6].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-21"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable6_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[9] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[9].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "single line of text"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable7_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[10] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[10].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3005"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable8_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[11] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[11].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "WorkerPools-3788"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable9_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[0] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[0].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "The value for the Australian Office tenant"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable10_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[1] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[1].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3001"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable11_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[3] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[3].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Certificates-461"
  depends_on              = [octopusdeploy_tenant_project.tenant_project_australian_office_every_step_project]
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable12_australian_office" {
  count                   = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? 0 : 1}"
  library_variable_set_id = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  template_id             = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].template[7] : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].template[7].id}"
  tenant_id               = "${length(data.octopusdeploy_tenants.tenant_australian_office.tenants) != 0 ? data.octopusdeploy_tenants.tenant_australian_office.tenants[0].id : octopusdeploy_tenant.tenant_australian_office[0].id}"
  value                   = "Accounts-3003"
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
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag_set" "tagset_cities" {
  name        = "Cities"
  description = "An example tag set that captures cities"
}

resource "octopusdeploy_tag" "tagset_cities_tag_sydney" {
  name        = "Sydney"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cities.id}"
  color       = "#333333"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_london" {
  name        = "London"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cities.id}"
  color       = "#87BFEC"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_washington" {
  name        = "Washington"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cities.id}"
  color       = "#5ECD9E"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_madrid" {
  name        = "Madrid"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cities.id}"
  color       = "#FFA461"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_wellington" {
  name        = "Wellington"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cities.id}"
  color       = "#C5AEEE"
  description = ""
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

data "octopusdeploy_accounts" "account_azure" {
  ids          = null
  partial_name = "Azure"
  skip         = 0
  take         = 1
  account_type = "AzureOidc"
}
resource "octopusdeploy_azure_openid_connect" "account_azure" {
  count                             = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? 0 : 1}"
  name                              = "Azure"
  description                       = "An example of an unscoped Azure OIDC account available to all environments"
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  subscription_id                   = "11111111-1111-1111-1111-111111111111"
  azure_environment                 = ""
  tenant_id                         = "11111111-1111-1111-1111-111111111111"
  application_id                    = "11111111-1111-1111-1111-111111111111"
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

variable "project_every_step_project_step_run_a_script_from_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Run a Script from a package in project Every Step Project"
  default     = "scripts"
}
variable "project_every_step_project_step_run_an_azure_script_from_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Run an Azure Script from a package in project Every Step Project"
  default     = "AzureScripts"
}
variable "project_every_step_project_step_deploy_to_iis_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy to IIS in project Every Step Project"
  default     = "webapp"
}
variable "project_every_step_project_step_deploy_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Package in project Every Step Project"
  default     = "mypackage"
}
variable "project_every_step_project_step_deploy_a_windows_service_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Windows Service in project Every Step Project"
  default     = "myservice"
}
variable "project_every_step_project_step_deploy_an_azure_web_app__web_deploy__packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy an Azure Web App (Web Deploy) in project Every Step Project"
  default     = "MyAzureWebApp"
}
variable "project_every_step_project_step_upload_a_package_to_an_aws_s3_bucket_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Upload a package to an AWS S3 bucket in project Every Step Project"
  default     = "MyAWSPackage"
}
variable "project_every_step_project_step_deploy_java_archive_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Java Archive in project Every Step Project"
  default     = "MyJavaApp"
}
variable "project_every_step_project_step_deploy_a_helm_chart_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy a Helm Chart in project Every Step Project"
  default     = "MyHelmApp"
}
variable "project_every_step_project_step_deploy_kubernetes_yaml_from_a_package_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Kubernetes YAML from a package in project Every Step Project"
  default     = "K8sApplication"
}
resource "octopusdeploy_deployment_process" "deployment_process_every_step_project" {
  count      = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"

  step {
    condition           = "Success"
    name                = "Run a Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Run a Script"
      notes                              = "An example step that runs an inline script. This step is configured to only run for tenants with the London tenant tag. Note how this step does not defined a primary_package."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hello World!\"\n\nVARIABLE=\"test\"\n\n# Pay attention to how the $ character is escaped when defined in Terraform\necho \"$${VARIABLE}\""
        "OctopusUseBundledTooling" = "False"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = ["Cities/London"]
      features                           = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Run a Script from a package"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Run a Script from a package"
      notes                              = "An example step that is configured to run a script from a package. Note how this step defines a primary_package."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptFileName" = "MyScript.ps1"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Package"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = ["Tag Set/tag", "Tag Set/tag2"]

      primary_package {
        package_id           = "${var.project_every_step_project_step_run_a_script_from_a_package_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Run an Azure Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Run an Azure Script"
      notes                              = "This is an example step that runs an inline script against Azure resources. Note how this step does not defined a primary_package. Note how this step defines the \"Octopus.Action.Azure.AccountId\" property."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hello World!\""
        "Octopus.Action.RunOnServer" = "true"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/azure-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = ["Business Units/Billing", "Business Units/Engineering", "Business Units/HR", "Business Units/Insurance", "Cities/London", "Cities/Madrid", "Cities/Sydney", "Cities/Washington", "Cities/Wellington", "Regions/ANZ", "Regions/Asia", "Regions/Europe", "Regions/US"]
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Run an Azure Script from a package"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Run an Azure Script from a package"
      notes                              = "This is an example step that runs a script against Azure resources from a package. Note how this step defines a primary_package. Note how this step defines the \"Octopus.Action.Azure.AccountId\" property."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptFileName" = "CreaeResourceGroup.ps1"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Package"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/azure-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = ["Business Units/Billing", "Business Units/Engineering", "Business Units/HR", "Business Units/Insurance", "Cities/London", "Cities/Madrid", "Cities/Sydney", "Cities/Washington", "Cities/Wellington", "Regions/ANZ", "Regions/Asia", "Regions/Europe", "Regions/US"]

      primary_package {
        package_id           = "${var.project_every_step_project_step_run_an_azure_script_from_a_package_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Run an AWS CLI Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsRunScript"
      name                               = "Run an AWS CLI Script"
      notes                              = "This is an example script that run against AWS resources"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.Region" = "us-east-1"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Run gcloud in a Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.GoogleCloudScripting"
      name                               = "Run gcloud in a Script"
      notes                              = "This is a script that runs against Google Cloud Platform (GCP) resources"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.GoogleCloud.Region" = "australia-southeast1"
        "Octopus.Action.GoogleCloud.Zone" = "australia-southeast1-a"
        "Octopus.Action.GoogleCloud.Project" = "ProjectID"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/gcp-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Run gcloud in a Script with an account"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.GoogleCloudScripting"
      name                               = "Run gcloud in a Script with an account"
      notes                              = "This is a script that runs against Google Cloud Platform (GCP) resources using an account."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "False"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Script.ScriptBody" = "echo \"Hi\""
        "Octopus.Action.GoogleCloudAccount.Variable" = "Example.GCP.Variable"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.GoogleCloud.Project" = "ProjectID"
        "Octopus.Action.GoogleCloud.Region" = "australia-southeast1"
        "Octopus.Action.GoogleCloud.Zone" = "australia-southeast1-a"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/gcp-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Deploy an Azure Resource Manager template"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureResourceGroup"
      name                               = "Deploy an Azure Resource Manager template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      properties                         = {
        "Octopus.Action.Azure.ResourceGroupDeploymentMode" = "Incremental"
        "Octopus.Action.Azure.TemplateSource" = "Inline"
        "Octopus.Action.Azure.ResourceGroupTemplateParameters" = jsonencode({        })
        "Octopus.Action.Azure.AccountId" = "${length(data.octopusdeploy_accounts.account_azure.accounts) != 0 ? data.octopusdeploy_accounts.account_azure.accounts[0].id : octopusdeploy_azure_openid_connect.account_azure[0].id}"
        "Octopus.Action.Azure.ResourceGroupName" = "my-resource-group"
        "Octopus.Action.Azure.ResourceGroupTemplate" = jsonencode({
        "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        "contentVersion" = "1.0.0.0"
        "resources" = []
                })
        "OctopusUseBundledTooling" = "False"
      }
      environments                       = []
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
    name                = "Run a kubectl script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.KubernetesRunScript"
      name                               = "Run a kubectl script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "Write-Host \"Hello World\""
        "Octopus.Action.KubernetesContainers.Namespace" = "mynamespace"
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Deploy to IIS"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.IIS"
      name                               = "Deploy to IIS"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.IISWebSite.DeploymentType" = "webSite"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.IISWebSite.WebSiteName" = "webapp"
        "Octopus.Action.IISWebSite.EnableAnonymousAuthentication" = "False"
        "Octopus.Action.IISWebSite.ApplicationPoolName" = "apppool"
        "Octopus.Action.IISWebSite.Bindings" = jsonencode([
        {
        "enabled" = "True"
        "protocol" = "http"
        "port" = "80"
        "host" = ""
        "thumbprint" = null
        "certificateVariable" = null
        "requireSni" = "False"
                },
        ])
        "Octopus.Action.IISWebSite.CreateOrUpdateWebSite" = "True"
        "Octopus.Action.IISWebSite.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolIdentityType" = "ApplicationPoolIdentity"
        "Octopus.Action.IISWebSite.EnableWindowsAuthentication" = "True"
        "Octopus.Action.IISWebSite.StartApplicationPool" = "True"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.IISWebSite.StartWebSite" = "True"
        "Octopus.Action.IISWebSite.EnableBasicAuthentication" = "False"
        "Octopus.Action.IISWebSite.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.WebRootType" = "packageRoot"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_to_iis_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.IISWebSite", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.ConfigurationVariables"]
    }

    properties   = {}
    target_roles = ["windows-server"]
  }
  step {
    condition           = "Success"
    name                = "Deploy a Package"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TentaclePackage"
      name                               = "Deploy a Package"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_a_package_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.ConfigurationVariables"]
    }

    properties   = {}
    target_roles = ["windows-server"]
  }
  step {
    condition           = "Success"
    name                = "Deploy a Windows Service"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.WindowsService"
      name                               = "Deploy a Windows Service"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.WindowsService.ServiceAccount" = "LocalSystem"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles" = "True"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.WindowsService.ExecutablePath" = "myapp.exe"
        "Octopus.Action.WindowsService.CreateOrUpdateService" = "True"
        "Octopus.Action.WindowsService.ServiceName" = "My Service"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.WindowsService.DisplayName" = "My sample Windows service"
        "Octopus.Action.WindowsService.StartMode" = "auto"
        "Octopus.Action.WindowsService.DesiredStatus" = "Default"
        "Octopus.Action.WindowsService.Description" = "This is a sample deployment of a Windows service"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_a_windows_service_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.WindowsService", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.ConfigurationVariables"]
    }

    properties   = {}
    target_roles = ["windows-server"]
  }
  step {
    condition           = "Success"
    name                = "Deploy an Azure Web App (Web Deploy)"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureWebApp"
      name                               = "Deploy an Azure Web App (Web Deploy)"
      notes                              = "This step deploys an application an an Azure Web App. Note how this step does not define any scripts. Note how this step defined the \"target_roles\" attribute."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.UseChecksum" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/azure-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_an_azure_web_app__web_deploy__packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = ["AzureWebApp"]
  }
  step {
    condition           = "Success"
    name                = "Upload a package to an AWS S3 bucket"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsUploadS3"
      name                               = "Upload a package to an AWS S3 bucket"
      condition                          = "Success"
      run_on_server                      = false
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.S3.TargetMode" = "EntirePackage"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.Region" = "ap-southeast-2"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Aws.S3.PackageOptions" = jsonencode({
        "bucketKeyBehaviour" = "Custom"
        "structuredVariableSubstitutionPatterns" = ""
        "metadata" = []
        "bucketKey" = "mybucket"
        "bucketKeyPrefix" = ""
        "storageClass" = "STANDARD"
        "cannedAcl" = "private"
        "variableSubstitutionPatterns" = ""
        "tags" = []
                })
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.S3.BucketName" = "my-s3-bucket"
        "Octopus.Action.RunOnServer" = "false"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_upload_a_package_to_an_aws_s3_bucket_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Deploy Java Archive"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.JavaArchive"
      name                               = "Deploy Java Archive"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Package.UseCustomInstallationDirectory" = "False"
        "Octopus.Action.Package.CustomInstallationDirectoryShouldBePurgedBeforeDeployment" = "False"
        "Octopus.Action.JavaArchive.DeployExploded" = "False"
        "Octopus.Action.Package.JavaArchiveCompression" = "True"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_java_archive_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["JavaAppServer"]
  }
  step {
    condition           = "Success"
    name                = "Deploy a Helm Chart"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.HelmChartUpgrade"
      name                               = "Deploy a Helm Chart"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Helm.ResetValues" = "True"
        "Octopus.Action.Helm.Namespace" = "mycustomnamespace"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Script.ScriptSource" = "Package"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_a_helm_chart_packageid}"
        acquisition_location = "Server"
        feed_id              = "${length(data.octopusdeploy_feeds.feed_helm.feeds) != 0 ? data.octopusdeploy_feeds.feed_helm.feeds[0].id : octopusdeploy_helm_feed.feed_helm[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Deploy Kubernetes YAML"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.KubernetesDeployRawYaml"
      name                               = "Deploy Kubernetes YAML"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.RunOnServer" = "true"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.14.2\n        ports:\n        - containerPort: 80"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Deploy Kubernetes YAML from a package"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.KubernetesDeployRawYaml"
      name                               = "Deploy Kubernetes YAML from a package"
      notes                              = "This step provides an example deploying a Kubernetes YAML file from a package."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Package"
        "Octopus.Action.KubernetesContainers.CustomResourceYamlFileName" = "deployment.yaml"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.KubernetesContainers.CustomResourceYaml" = "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: nginx-deployment\n  labels:\n    app: nginx\nspec:\n  replicas: 3\n  selector:\n    matchLabels:\n      app: nginx\n  template:\n    metadata:\n      labels:\n        app: nginx\n    spec:\n      containers:\n      - name: nginx\n        image: nginx:1.14.2\n        ports:\n        - containerPort: 80"
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_every_step_project_step_deploy_kubernetes_yaml_from_a_package_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Deploy with Kustomize"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Kubernetes.Kustomize"
      name                               = "Deploy with Kustomize"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      properties                         = {
        "Octopus.Action.Kubernetes.ServerSideApply.ForceConflicts" = "True"
        "Octopus.Action.Kubernetes.Kustomize.OverlayPath" = "overlays/#{Octopus.Environment.Name}"
        "Octopus.Action.SubstituteInFiles.TargetFiles" = " **/*.env"
        "Octopus.Action.Kubernetes.ResourceStatusCheck" = "True"
        "Octopus.Action.Kubernetes.DeploymentTimeout" = "180"
        "Octopus.Action.Script.ScriptSource" = "GitRepository"
        "Octopus.Action.GitRepository.Source" = "External"
        "Octopus.Action.Kubernetes.ServerSideApply.Enabled" = "True"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []
      features                           = []

      git_dependency {
        repository_uri      = "https://github.com/OctopusSamples/OctoPetShop.git"
        default_branch      = "main"
        git_credential_type = "Library"
        git_credential_id   = "${length(data.octopusdeploy_git_credentials.gitcredential_github.git_credentials) != 0 ? data.octopusdeploy_git_credentials.gitcredential_github.git_credentials[0].id : octopusdeploy_git_credential.gitcredential_github[0].id}"
      }
    }

    properties   = {}
    target_roles = ["Kubernetes"]
  }
  step {
    condition           = "Success"
    name                = "Apply a Terraform template"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformApply"
      name                               = "Apply a Terraform template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
                })
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
      }

      environments          = []
      excluded_environments = ["${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Destroy Terraform resources"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformDestroy"
      name                               = "Destroy Terraform resources"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
      }

      environments          = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Plan to apply a Terraform template"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformPlan"
      name                               = "Plan to apply a Terraform template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
                })
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.ExecutionTimeout.Minutes" = "5"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Plan a Terraform destroy"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.TerraformPlanDestroy"
      name                               = "Plan a Terraform destroy"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Terraform.PlanJsonOutput" = "False"
        "Octopus.Action.Terraform.GoogleCloudAccount" = "False"
        "Octopus.Action.Terraform.AzureAccount" = "False"
        "Octopus.Action.Terraform.AllowPluginDownloads" = "True"
        "Octopus.Action.AutoRetry.MaximumCount" = "3"
        "Octopus.Action.Terraform.RunAutomaticFileSubstitution" = "True"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Terraform.Template" = "ariable \"images\" {\n  type = \"map\"\n\n  default = {\n    us-east-1 = \"image-1234\"\n    us-west-2 = \"image-4567\"\n  }\n}\n\nvariable \"test2\" {\n  type    = \"map\"\n  default = {\n    val1 = [\"hi\"]\n  }\n}\n\nvariable \"test3\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = \"hi\"\n    }\n  }\n}\n\nvariable \"test4\" {\n  type    = \"map\"\n  default = {\n    val1 = {\n      val2 = [\"hi\"]\n    }\n  }\n}\n\n# Example of getting an element from a list in a map\noutput \"nestedlist\" {\n  value = \"$${element(var.test2[\"val1\"], 0)}\"\n}\n\n# Example of getting an element from a nested map\noutput \"nestedmap\" {\n  value = \"$${lookup(var.test3[\"val1\"], \"val2\")}\"\n}"
        "Octopus.Action.GoogleCloud.UseVMServiceAccount" = "True"
        "Octopus.Action.Terraform.ManagedAccount" = "None"
        "Octopus.Action.AutoRetry.MinimumBackoff" = "15"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Terraform.TemplateParameters" = jsonencode({
        "test2" = "{\n  val1 = [\n    \"hi\"\n  ]\n}"
        "test3" = "{\n  val1 = {\n    val2 = \"hi\"\n  }\n}"
        "test4" = "{\n  val1 = {\n    val2 = [\n      \"hi\"\n    ]\n  }\n}"
                })
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.GoogleCloud.ImpersonateServiceAccount" = "False"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/terraform-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{Step.Run}"
    name                 = "Deploy an AWS CloudFormation template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsRunCloudFormation"
      name                               = "Deploy an AWS CloudFormation template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.TemplateSource" = "Inline"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.Region" = "us-east-2"
        "Octopus.Action.Aws.CloudFormationTemplate" = "AWSTemplateFormatVersion: '2010-09-09'\nDescription: 'CloudFormation exports'\n \nConditions:\n  HasNot: !Equals [ 'true', 'false' ]\n \n# dummy (null) resource, never created\nResources:\n  NullResource:\n    Type: 'Custom::NullResource'\n    Condition: HasNot\n \nOutputs:\n  ExportsStackName:\n    Value: !Ref 'AWS::StackName'\n    Export:\n      Name: !Sub 'ExportsStackName-$${AWS::StackName}'"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
        "Octopus.Action.Aws.CloudFormationTemplateParameters" = jsonencode([])
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.Aws.CloudFormationStackName" = "mystackname"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Always"
    name                = "Apply an AWS CloudFormation Change Set"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsApplyCloudFormationChangeSet"
      name                               = "Apply an AWS CloudFormation Change Set"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.CloudFormation.ChangeSet.Arn" = "mychangeset"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.Aws.Region" = "ap-southeast-1"
        "Octopus.Action.Aws.CloudFormationStackName" = "mystack"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Failure"
    name                = "Delete an AWS CloudFormation stack"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AwsDeleteCloudFormation"
      name                               = "Delete an AWS CloudFormation stack"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      properties                         = {
        "Octopus.Action.Aws.Region" = "us-east-2"
        "Octopus.Action.Aws.CloudFormationStackName" = "my-stack-name"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Aws.WaitForCompletion" = "True"
        "Octopus.Action.Aws.AssumeRole" = "False"
        "Octopus.Action.AwsAccount.UseInstanceRole" = "False"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.AwsAccount.Variable" = "Account.AWS"
      }

      container {
        feed_id = "${length(data.octopusdeploy_feeds.feed_github_container_registry.feeds) != 0 ? data.octopusdeploy_feeds.feed_github_container_registry.feeds[0].id : octopusdeploy_docker_container_registry.feed_github_container_registry[0].id}"
        image   = "ghcr.io/octopusdeploylabs/aws-workertools"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Failure"
    name                = "Run a Script on Failure"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Run a Script on Failure"
      notes                              = "This is an example of a step that run when the previous step fails."
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
        "Octopus.Action.Script.ScriptBody" = "echo \"hi\""
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.RunOnServer" = "true"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []
      features                           = []
    }

    properties   = {}
    target_roles = []
  }
  depends_on = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_sydney,octopusdeploy_tag.tagset_cities_tag_sydney,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_washington,octopusdeploy_tag.tagset_cities_tag_washington,octopusdeploy_tag.tagset_cities_tag_madrid,octopusdeploy_tag.tagset_cities_tag_madrid,octopusdeploy_tag.tagset_cities_tag_wellington,octopusdeploy_tag.tagset_cities_tag_wellington]
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
  description                       = "An AWS OIDC account. See https://octopus.com/docs/infrastructure/accounts/aws for more information."
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
}
resource "octopusdeploy_gcp_account" "account_google_cloud_account" {
  count                             = "${length(data.octopusdeploy_accounts.account_google_cloud_account.accounts) != 0 ? 0 : 1}"
  name                              = "Google Cloud Account"
  description                       = "An example of a Google Cloud (GCP) Account scoped to the Development environment"
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
  description                       = "An example of a username password account scoped to the Production environment"
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
  description                       = "An example of an unscoped generic OIDC account"
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

data "octopusdeploy_machine_policies" "default_machine_policy" {
  ids          = null
  partial_name = "Default Machine Policy"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a machine policy called \"default_machine_policy\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.machine_policies) != 0
    }
  }
}

data "octopusdeploy_deployment_targets" "target_cloud_region" {
  ids                  = null
  partial_name         = "Cloud Region"
  skip                 = 0
  take                 = 1
  health_statuses      = null
  communication_styles = null
  environments         = null
  roles                = null
  shell_names          = null
  tenant_tags          = null
  tenants              = null
}
resource "octopusdeploy_cloud_region_deployment_target" "target_cloud_region" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_cloud_region.deployment_targets) != 0 ? 0 : 1}"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  name                              = "Cloud Region"
  roles                             = ["us-east-1"]
  default_worker_pool_id            = "WorkerPools-3788"
  health_status                     = "Healthy"
  is_disabled                       = false
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "TenantedOrUntenanted"
  tenants                           = []
  thumbprint                        = ""
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "every_step_project_project_scopedvariable2_1" {
  count        = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_projects.project_every_step_project.projects) == 0 ?octopusdeploy_project.project_every_step_project[0].id : data.octopusdeploy_projects.project_every_step_project.projects[0].id}"
  value        = "target scoped variable"
  name         = "Project.ScopedVariable2"
  type         = "String"
  description  = "This variable is scoped to a target"
  is_sensitive = false

  scope {
    actions      = null
    channels     = null
    environments = null
    machines     = ["${length(data.octopusdeploy_deployment_targets.target_cloud_region.deployment_targets) != 0 ? data.octopusdeploy_deployment_targets.target_cloud_region.deployment_targets[0].id : octopusdeploy_cloud_region_deployment_target.target_cloud_region[0].id}"]
    roles        = null
    tenant_tags  = null
  }
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
  lifecycle {
    ignore_changes  = [sensitive_value]
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_projects" "projecttrigger_every_step_project_example_scheduled_trigger" {
  ids          = null
  partial_name = "Every Step Project"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_project_scheduled_trigger" "projecttrigger_every_step_project_example_scheduled_trigger" {
  count       = "${length(data.octopusdeploy_projects.projecttrigger_every_step_project_example_scheduled_trigger.projects) != 0 ? 0 : 1}"
  space_id    = "${trimspace(var.octopus_space_id)}"
  name        = "Example Scheduled Trigger"
  description = "This is an example of a scheduled trigger."
  timezone    = "UTC"
  is_disabled = false
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

data "octopusdeploy_projects" "projecttrigger_every_step_project_external_feed_trigger" {
  ids          = null
  partial_name = "Every Step Project"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_external_feed_create_release_trigger" "projecttrigger_every_step_project_external_feed_trigger" {
  count      = "${length(data.octopusdeploy_projects.projecttrigger_every_step_project_external_feed_trigger.projects) != 0 ? 0 : 1}"
  space_id   = "${trimspace(var.octopus_space_id)}"
  project_id = "${length(data.octopusdeploy_projects.project_every_step_project.projects) != 0 ? data.octopusdeploy_projects.project_every_step_project.projects[0].id : octopusdeploy_project.project_every_step_project[0].id}"
  name       = "External Feed Trigger"
  channel_id = "Channels-1"

  package {
    deployment_action_slug = "deploy-a-helm-chart"
    package_reference      = ""
  }
  depends_on = [octopusdeploy_deployment_process.deployment_process_every_step_project]
  lifecycle {
    prevent_destroy = true
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
  default     = "This sample project has every step in Octopus assigned to the deployment process. These steps can be used as examples on which to build custom projects."
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
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${length(data.octopusdeploy_lifecycles.lifecycle_application.lifecycles) != 0 ? data.octopusdeploy_lifecycles.lifecycle_application.lifecycles[0].id : octopusdeploy_lifecycle.lifecycle_application[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_default_project_group.project_groups[0].id}"
  included_library_variable_sets       = ["${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"]
  tenanted_deployment_participation    = "${var.project_every_step_project_tenanted}"

  template {
    name             = "Example.Tenant.Variable"
    label            = "An example tenant variable required to be defined by all tenants that deploy this project."
    help_text        = "This is where the help text associated with the variable is defined."
    default_value    = "The default value"
    display_settings = { "Octopus.ControlType" = "MultiLineText" }
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"
  }
  description = "${var.project_every_step_project_description_prefix}${var.project_every_step_project_description}${var.project_every_step_project_description_suffix}"
  lifecycle {
    prevent_destroy = true
  }
}


