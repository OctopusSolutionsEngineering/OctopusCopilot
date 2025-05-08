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

data "octopusdeploy_tag_sets" "tagset_tag_set" {
  ids          = null
  partial_name = "Tag Set"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_tag_set" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? 0 : 1}"
  name        = "Tag Set"
  description = "An example of a tenant tag set"
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_tag_set_tag_tag" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? 0 : 1}"
  name        = "tag"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets[0].id : octopusdeploy_tag_set.tagset_tag_set[0].id}"
  color       = "#333333"
  description = "An example of a tag"
}

resource "octopusdeploy_tag" "tagset_tag_set_tag_tag2" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? 0 : 1}"
  name        = "tag2"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_tag_set.tag_sets[0].id : octopusdeploy_tag_set.tagset_tag_set[0].id}"
  color       = "#C5AEEE"
  description = "Another example of a tag"
}

data "octopusdeploy_tag_sets" "tagset_cities" {
  ids          = null
  partial_name = "Cities"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_cities" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1}"
  name        = "Cities"
  description = "An example tag set that captures cities"
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_cities_tag_sydney" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1}"
  name        = "Sydney"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#333333"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_london" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1}"
  name        = "London"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#87BFEC"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_washington" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1}"
  name        = "Washington"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#5ECD9E"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_madrid" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1}"
  name        = "Madrid"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#FFA461"
  description = ""
}

resource "octopusdeploy_tag" "tagset_cities_tag_wellington" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? 0 : 1}"
  name        = "Wellington"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_cities.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_cities.tag_sets[0].id : octopusdeploy_tag_set.tagset_cities[0].id}"
  color       = "#C5AEEE"
  description = ""
}

data "octopusdeploy_tag_sets" "tagset_business_units" {
  ids          = null
  partial_name = "Business Units"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_business_units" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? 0 : 1}"
  name        = "Business Units"
  description = "An example tag set that defined business units"
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_business_units_tag_billing" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? 0 : 1}"
  name        = "Billing"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#333333"
  description = ""
}

resource "octopusdeploy_tag" "tagset_business_units_tag_insurance" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? 0 : 1}"
  name        = "Insurance"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#87BFEC"
  description = ""
}

resource "octopusdeploy_tag" "tagset_business_units_tag_engineering" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? 0 : 1}"
  name        = "Engineering"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#C5AEEE"
  description = ""
}

resource "octopusdeploy_tag" "tagset_business_units_tag_hr" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? 0 : 1}"
  name        = "HR"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_business_units.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_business_units.tag_sets[0].id : octopusdeploy_tag_set.tagset_business_units[0].id}"
  color       = "#FFA461"
  description = ""
}

data "octopusdeploy_tag_sets" "tagset_regions" {
  ids          = null
  partial_name = "Regions"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_tag_set" "tagset_regions" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? 0 : 1}"
  name        = "Regions"
  description = "A sample tag set that captures geographical regions"
  lifecycle {
    prevent_destroy = true
  }
}

resource "octopusdeploy_tag" "tagset_regions_tag_us" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? 0 : 1}"
  name        = "US"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#333333"
  description = ""
}

resource "octopusdeploy_tag" "tagset_regions_tag_europe" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? 0 : 1}"
  name        = "Europe"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#5ECD9E"
  description = ""
}

resource "octopusdeploy_tag" "tagset_regions_tag_asia" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? 0 : 1}"
  name        = "Asia"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#FF9F9F"
  description = ""
}

resource "octopusdeploy_tag" "tagset_regions_tag_anz" {
  count       = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? 0 : 1}"
  name        = "ANZ"
  tag_set_id  = "${length(data.octopusdeploy_tag_sets.tagset_regions.tag_sets) != 0 ? data.octopusdeploy_tag_sets.tagset_regions.tag_sets[0].id : octopusdeploy_tag_set.tagset_regions[0].id}"
  color       = "#C5AEEE"
  description = ""
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

data "octopusdeploy_worker_pools" "workerpool_hosted_windows" {
  ids          = null
  partial_name = "Hosted Windows"
  skip         = 0
  take         = 1
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

data "octopusdeploy_accounts" "account_aws" {
  ids          = null
  partial_name = "AWS"
  skip         = 0
  take         = 1
  account_type = "AmazonWebServicesOidcAccount"
}
resource "octopusdeploy_aws_openid_connect_account" "account_aws" {
  count                             = "${length(data.octopusdeploy_accounts.account_aws.accounts) != 0 ? 0 : 1}"
  name                              = "AWS"
  description                       = "This is an example of an unscoped OIDC AWS account available to all environments."
  role_arn                          = "arn:aws:iam::123456789012:role/S3Access"
  account_test_subject_keys         = []
  environments                      = []
  execution_subject_keys            = []
  health_subject_keys               = []
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

data "octopusdeploy_accounts" "account_azure_service_principal" {
  ids          = null
  partial_name = "Azure Service Principal"
  skip         = 0
  take         = 1
  account_type = "AzureServicePrincipal"
}
resource "octopusdeploy_azure_service_principal" "account_azure_service_principal" {
  count                             = "${length(data.octopusdeploy_accounts.account_azure_service_principal.accounts) != 0 ? 0 : 1}"
  name                              = "Azure Service Principal"
  description                       = "An example Azure service principal account"
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  application_id                    = "b0676d9e-8d3e-457d-844a-ab77deda4916"
  password                          = "${var.account_azure_service_principal}"
  subscription_id                   = "7dae5466-90fb-4bf7-b0ee-7194033a1fde"
  tenant_id                         = "b8fc95ef-da51-4d9e-9921-714292b30e20"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_azure_service_principal" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Azure secret associated with the account Azure Service Principal"
  default     = "Change Me!"
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

data "octopusdeploy_accounts" "account_octopussamples_azure_account" {
  ids          = null
  partial_name = "OctopusSamples Azure Account"
  skip         = 0
  take         = 1
  account_type = "AzureServicePrincipal"
}
resource "octopusdeploy_azure_service_principal" "account_octopussamples_azure_account" {
  count                             = "${length(data.octopusdeploy_accounts.account_octopussamples_azure_account.accounts) != 0 ? 0 : 1}"
  name                              = "OctopusSamples Azure Account"
  description                       = "This account was added to give the Octopus Samples projects an account to work with.  It is initially set with dummy values and will need to be configured."
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  application_id                    = "00000000-0000-0000-0000-000000000000"
  password                          = "${var.account_octopussamples_azure_account}"
  subscription_id                   = "00000000-0000-0000-0000-000000000000"
  tenant_id                         = "00000000-0000-0000-0000-000000000000"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_octopussamples_azure_account" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Azure secret associated with the account OctopusSamples Azure Account"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_shawnazure" {
  ids          = null
  partial_name = "ShawnAzure"
  skip         = 0
  take         = 1
  account_type = "AzureServicePrincipal"
}
resource "octopusdeploy_azure_service_principal" "account_shawnazure" {
  count                             = "${length(data.octopusdeploy_accounts.account_shawnazure.accounts) != 0 ? 0 : 1}"
  name                              = "ShawnAzure"
  description                       = ""
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  application_id                    = "631408da-9bd5-4cf2-b4b6-8bd0506db582"
  password                          = "${var.account_shawnazure}"
  subscription_id                   = "c5e7ce05-3887-4caa-aef6-948a93e56498"
  tenant_id                         = "18eb006b-c3c8-4a72-93cd-fe4b293f82ee"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}
variable "account_shawnazure" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The Azure secret associated with the account ShawnAzure"
  default     = "Change Me!"
}

data "octopusdeploy_accounts" "account_ssh_key_pair" {
  ids          = null
  partial_name = "SSH Key Pair"
  skip         = 0
  take         = 1
  account_type = "SshKeyPair"
}
resource "octopusdeploy_ssh_key_account" "account_ssh_key_pair" {
  count                             = "${length(data.octopusdeploy_accounts.account_ssh_key_pair.accounts) != 0 ? 0 : 1}"
  name                              = "SSH Key Pair"
  description                       = "An example of a SSH Key Pair account scoped to the Test environemtn"
  environments                      = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  private_key_file                  = "${var.account_ssh_key_pair_cert}"
  username                          = "username"
  private_key_passphrase            = "${var.account_ssh_key_pair}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [private_key_passphrase, private_key_file]
    prevent_destroy = true
  }
}
variable "account_ssh_key_pair" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password associated with the certificate for account SSH Key Pair"
  default     = "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUJGd0FBQUFkemMyZ3RjbgpOaEFBQUFBd0VBQVFBQUFRRUF5c25PVXhjN0tJK2pIRUc5RVEwQXFCMllGRWE5ZnpZakZOY1pqY1dwcjJQRkRza25oOUpTCm1NVjVuZ2VrbTRyNHJVQU5tU2dQMW1ZTGo5TFR0NUVZa0N3OUdyQ0paNitlQTkzTEowbEZUamFkWEJuQnNmbmZGTlFWYkcKZ2p3U1o4SWdWQ2oySXE0S1hGZm0vbG1ycEZQK2Jqa2V4dUxwcEh5dko2ZmxZVjZFMG13YVlneVNHTWdLYy9ubXJaMTY0WApKMStJL1M5NkwzRWdOT0hNZmo4QjM5eEhZQ0ZUTzZEQ0pLQ3B0ZUdRa0gwTURHam84d3VoUlF6c0IzVExsdXN6ZG0xNmRZCk16WXZBSWR3emZ3bzh1ajFBSFFOendDYkIwRmR6bnFNOEpLV2ZrQzdFeVVrZUl4UXZmLzJGd1ZyS0xEZC95ak5PUmNoa3EKb2owNncySXFad0FBQThpS0tqT3dpaW96c0FBQUFBZHpjMmd0Y25OaEFBQUJBUURLeWM1VEZ6c29qNk1jUWIwUkRRQ29IWgpnVVJyMS9OaU1VMXhtTnhhbXZZOFVPeVNlSDBsS1l4WG1lQjZTYml2aXRRQTJaS0EvV1pndVAwdE8za1JpUUxEMGFzSWxuCnI1NEQzY3NuU1VWT05wMWNHY0d4K2Q4VTFCVnNhQ1BCSm53aUJVS1BZaXJncGNWK2IrV2F1a1UvNXVPUjdHNHVta2ZLOG4KcCtWaFhvVFNiQnBpREpJWXlBcHorZWF0blhyaGNuWDRqOUwzb3ZjU0EwNGN4K1B3SGYzRWRnSVZNN29NSWtvS20xNFpDUQpmUXdNYU9qekM2RkZET3dIZE11VzZ6TjJiWHAxZ3pOaThBaDNETi9Dank2UFVBZEEzUEFKc0hRVjNPZW96d2twWitRTHNUCkpTUjRqRkM5Ly9ZWEJXc29zTjMvS00wNUZ5R1NxaVBUckRZaXBuQUFBQUF3RUFBUUFBQVFFQXdRZzRqbitlb0kyYUJsdk4KVFYzRE1rUjViMU9uTG1DcUpEeGM1c2N4THZNWnNXbHBaN0NkVHk4ckJYTGhEZTdMcUo5QVVub0FHV1lwdTA1RW1vaFRpVwptVEFNVHJCdmYwd2xsdCtJZVdvVXo3bmFBbThQT1psb29MbXBYRzh5VmZKRU05aUo4NWtYNDY4SkF6VDRYZ1JXUFRYQ1JpCi9abCtuWUVUZVE4WTYzWlJhTVE3SUNmK2FRRWxRenBYb21idkxYM1RaNmNzTHh5Z3Eza01aSXNJU0lUcEk3Y0tsQVJ0Rm4KcWxKRitCL2JlUEJkZ3hIRVpqZDhDV0NIR1ZRUDh3Z3B0d0Rrak9NTzh2b2N4YVpOT0hZZnBwSlBCTkVjMEVKbmduN1BXSgorMVZSTWZKUW5SemVubmE3VHdSUSsrclZmdkVaRmhqamdSUk85RitrMUZvSWdRQUFBSUVBbFFybXRiV2V0d3RlWlZLLys4CklCUDZkcy9MSWtPb3pXRS9Wckx6cElBeHEvV1lFTW1QK24wK1dXdWRHNWpPaTFlZEJSYVFnU0owdTRxcE5JMXFGYTRISFYKY2oxL3pzenZ4RUtSRElhQkJGaU81Y3QvRVQvUTdwanozTnJaZVdtK0dlUUJKQ0diTEhSTlQ0M1ZpWVlLVG82ZGlGVTJteApHWENlLzFRY2NqNjVZQUFBQ0JBUHZodmgzb2Q1MmY4SFVWWGoxeDNlL1ZFenJPeVloTi9UQzNMbWhHYnRtdHZ0L0J2SUhxCndxWFpTT0lWWkZiRnVKSCtORHNWZFFIN29yUW1VcGJxRllDd0IxNUZNRGw0NVhLRm0xYjFyS1c1emVQK3d0M1hyM1p0cWsKRkdlaUlRMklSZklBQjZneElvNTZGemdMUmx6QnB0bzhkTlhjMXhtWVgyU2Rhb3ZwSkRBQUFBZ1FET0dwVE9oOEFRMFoxUwpzUm9vVS9YRTRkYWtrSU5vMDdHNGI3M01maG9xbkV1T01LM0ZRVStRRWUwYWpvdWs5UU1QNWJzZU1CYnJNZVNNUjBRWVBCClQ4Z0Z2S2VISWN6ZUtJTjNPRkRaRUF4TEZNMG9LbjR2bmdHTUFtTXUva2QwNm1PZnJUNDRmUUh1ajdGNWx1QVJHejRwYUwKLzRCTUVkMnFTRnFBYzZ6L0RRQUFBQTF0WVhSMGFFQk5ZWFIwYUdWM0FRSURCQT09Ci0tLS0tRU5EIE9QRU5TU0ggUFJJVkFURSBLRVktLS0tLQo="
}
variable "account_ssh_key_pair_cert" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate file for account SSH Key Pair"
  default     = "LS0tLS1CRUdJTiBPUEVOU1NIIFBSSVZBVEUgS0VZLS0tLS0KYjNCbGJuTnphQzFyWlhrdGRqRUFBQUFBQkc1dmJtVUFBQUFFYm05dVpRQUFBQUFBQUFBQkFBQUJGd0FBQUFkemMyZ3RjbgpOaEFBQUFBd0VBQVFBQUFRRUF5c25PVXhjN0tJK2pIRUc5RVEwQXFCMllGRWE5ZnpZakZOY1pqY1dwcjJQRkRza25oOUpTCm1NVjVuZ2VrbTRyNHJVQU5tU2dQMW1ZTGo5TFR0NUVZa0N3OUdyQ0paNitlQTkzTEowbEZUamFkWEJuQnNmbmZGTlFWYkcKZ2p3U1o4SWdWQ2oySXE0S1hGZm0vbG1ycEZQK2Jqa2V4dUxwcEh5dko2ZmxZVjZFMG13YVlneVNHTWdLYy9ubXJaMTY0WApKMStJL1M5NkwzRWdOT0hNZmo4QjM5eEhZQ0ZUTzZEQ0pLQ3B0ZUdRa0gwTURHam84d3VoUlF6c0IzVExsdXN6ZG0xNmRZCk16WXZBSWR3emZ3bzh1ajFBSFFOendDYkIwRmR6bnFNOEpLV2ZrQzdFeVVrZUl4UXZmLzJGd1ZyS0xEZC95ak5PUmNoa3EKb2owNncySXFad0FBQThpS0tqT3dpaW96c0FBQUFBZHpjMmd0Y25OaEFBQUJBUURLeWM1VEZ6c29qNk1jUWIwUkRRQ29IWgpnVVJyMS9OaU1VMXhtTnhhbXZZOFVPeVNlSDBsS1l4WG1lQjZTYml2aXRRQTJaS0EvV1pndVAwdE8za1JpUUxEMGFzSWxuCnI1NEQzY3NuU1VWT05wMWNHY0d4K2Q4VTFCVnNhQ1BCSm53aUJVS1BZaXJncGNWK2IrV2F1a1UvNXVPUjdHNHVta2ZLOG4KcCtWaFhvVFNiQnBpREpJWXlBcHorZWF0blhyaGNuWDRqOUwzb3ZjU0EwNGN4K1B3SGYzRWRnSVZNN29NSWtvS20xNFpDUQpmUXdNYU9qekM2RkZET3dIZE11VzZ6TjJiWHAxZ3pOaThBaDNETi9Dank2UFVBZEEzUEFKc0hRVjNPZW96d2twWitRTHNUCkpTUjRqRkM5Ly9ZWEJXc29zTjMvS00wNUZ5R1NxaVBUckRZaXBuQUFBQUF3RUFBUUFBQVFFQXdRZzRqbitlb0kyYUJsdk4KVFYzRE1rUjViMU9uTG1DcUpEeGM1c2N4THZNWnNXbHBaN0NkVHk4ckJYTGhEZTdMcUo5QVVub0FHV1lwdTA1RW1vaFRpVwptVEFNVHJCdmYwd2xsdCtJZVdvVXo3bmFBbThQT1psb29MbXBYRzh5VmZKRU05aUo4NWtYNDY4SkF6VDRYZ1JXUFRYQ1JpCi9abCtuWUVUZVE4WTYzWlJhTVE3SUNmK2FRRWxRenBYb21idkxYM1RaNmNzTHh5Z3Eza01aSXNJU0lUcEk3Y0tsQVJ0Rm4KcWxKRitCL2JlUEJkZ3hIRVpqZDhDV0NIR1ZRUDh3Z3B0d0Rrak9NTzh2b2N4YVpOT0hZZnBwSlBCTkVjMEVKbmduN1BXSgorMVZSTWZKUW5SemVubmE3VHdSUSsrclZmdkVaRmhqamdSUk85RitrMUZvSWdRQUFBSUVBbFFybXRiV2V0d3RlWlZLLys4CklCUDZkcy9MSWtPb3pXRS9Wckx6cElBeHEvV1lFTW1QK24wK1dXdWRHNWpPaTFlZEJSYVFnU0owdTRxcE5JMXFGYTRISFYKY2oxL3pzenZ4RUtSRElhQkJGaU81Y3QvRVQvUTdwanozTnJaZVdtK0dlUUJKQ0diTEhSTlQ0M1ZpWVlLVG82ZGlGVTJteApHWENlLzFRY2NqNjVZQUFBQ0JBUHZodmgzb2Q1MmY4SFVWWGoxeDNlL1ZFenJPeVloTi9UQzNMbWhHYnRtdHZ0L0J2SUhxCndxWFpTT0lWWkZiRnVKSCtORHNWZFFIN29yUW1VcGJxRllDd0IxNUZNRGw0NVhLRm0xYjFyS1c1emVQK3d0M1hyM1p0cWsKRkdlaUlRMklSZklBQjZneElvNTZGemdMUmx6QnB0bzhkTlhjMXhtWVgyU2Rhb3ZwSkRBQUFBZ1FET0dwVE9oOEFRMFoxUwpzUm9vVS9YRTRkYWtrSU5vMDdHNGI3M01maG9xbkV1T01LM0ZRVStRRWUwYWpvdWs5UU1QNWJzZU1CYnJNZVNNUjBRWVBCClQ4Z0Z2S2VISWN6ZUtJTjNPRkRaRUF4TEZNMG9LbjR2bmdHTUFtTXUva2QwNm1PZnJUNDRmUUh1ajdGNWx1QVJHejRwYUwKLzRCTUVkMnFTRnFBYzZ6L0RRQUFBQTF0WVhSMGFFQk5ZWFIwYUdWM0FRSURCQT09Ci0tLS0tRU5EIE9QRU5TU0ggUFJJVkFURSBLRVktLS0tLQo="
}

data "octopusdeploy_accounts" "account_token" {
  ids          = null
  partial_name = "Token"
  skip         = 0
  take         = 1
  account_type = "Token"
}
resource "octopusdeploy_token_account" "account_token" {
  count                             = "${length(data.octopusdeploy_accounts.account_token.accounts) != 0 ? 0 : 1}"
  name                              = "Token"
  description                       = "An example of an unscoped Token account"
  environments                      = []
  tenant_tags                       = []
  tenants                           = []
  tenanted_deployment_participation = "Untenanted"
  token                             = "${var.account_token}"
  depends_on                        = []
  lifecycle {
    ignore_changes  = [token]
    prevent_destroy = true
  }
}
variable "account_token" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The token associated with the account Token"
  default     = "Change Me!"
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

data "octopusdeploy_feeds" "feed_octopus_server_releases__built_in_" {
  feed_type    = "OctopusProject"
  ids          = null
  partial_name = ""
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a feed called \"Octopus Server Releases (built-in)\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.feeds) != 0
    }
  }
}

data "octopusdeploy_feeds" "feed_docker_hub" {
  feed_type    = "Docker"
  ids          = null
  partial_name = "Docker Hub"
  skip         = 0
  take         = 1
}
variable "feed_docker_hub_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Docker Hub"
  default     = "Change Me!"
}
resource "octopusdeploy_docker_container_registry" "feed_docker_hub" {
  count                                = "${length(data.octopusdeploy_feeds.feed_docker_hub.feeds) != 0 ? 0 : 1}"
  name                                 = "Docker Hub"
  password                             = "${var.feed_docker_hub_password}"
  registry_path                        = ""
  username                             = "mcasperson"
  api_version                          = ""
  feed_uri                             = "https://index.docker.io"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_nuget" {
  feed_type    = "NuGet"
  ids          = null
  partial_name = "Nuget"
  skip         = 0
  take         = 1
}
variable "feed_nuget_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Nuget"
  default     = "Change Me!"
}
resource "octopusdeploy_nuget_feed" "feed_nuget" {
  count                                = "${length(data.octopusdeploy_feeds.feed_nuget.feeds) != 0 ? 0 : 1}"
  name                                 = "Nuget"
  feed_uri                             = "https://nuget.example.org"
  username                             = "username"
  password                             = "${var.feed_nuget_password}"
  is_enhanced_mode                     = false
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_artifactory_feed" {
  feed_type    = "ArtifactoryGeneric"
  ids          = null
  partial_name = "Artifactory Feed"
  skip         = 0
  take         = 1
}
variable "feed_artifactory_feed_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Artifactory Feed"
  default     = "Change Me!"
}
resource "octopusdeploy_artifactory_generic_feed" "feed_artifactory_feed" {
  count      = "${length(data.octopusdeploy_feeds.feed_artifactory_feed.feeds) != 0 ? 0 : 1}"
  feed_uri   = "https://example.jfrog.io"
  name       = "Artifactory Feed"
  password   = "${var.feed_artifactory_feed_password}"
  username   = "username"
  repository = "repositoryname"
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_aws_ecr" {
  feed_type    = "AwsElasticContainerRegistry"
  ids          = null
  partial_name = "AWS ECR"
  skip         = 0
  take         = 1
}
variable "feed_aws_ecr_secretkey" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret key used by the feed AWS ECR"
  default     = "Change Me!"
}
resource "octopusdeploy_aws_elastic_container_registry" "feed_aws_ecr" {
  count                                = "${length(data.octopusdeploy_feeds.feed_aws_ecr.feeds) != 0 ? 0 : 1}"
  name                                 = "AWS ECR"
  access_key                           = "ASIAY34FZKBNKMUTVV7A"
  secret_key                           = "${var.feed_aws_ecr_secretkey}"
  region                               = "ap-southeast-2"
  package_acquisition_location_options = ["ExecutionTarget", "NotAcquired"]
  lifecycle {
    ignore_changes  = [secret_key]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_github_repository_feed" {
  feed_type    = "GitHub"
  ids          = null
  partial_name = "GitHub Repository Feed"
  skip         = 0
  take         = 1
}
variable "feed_github_repository_feed_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed GitHub Repository Feed"
  default     = "Change Me!"
}
resource "octopusdeploy_github_repository_feed" "feed_github_repository_feed" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_repository_feed.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Repository Feed"
  password                             = "${var.feed_github_repository_feed_password}"
  feed_uri                             = "https://api.github.com"
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  username                             = "x-access-token"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
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

data "octopusdeploy_feeds" "feed_maven" {
  feed_type    = "Maven"
  ids          = null
  partial_name = "Maven"
  skip         = 0
  take         = 1
}
variable "feed_maven_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed Maven"
  default     = "Change Me!"
}
resource "octopusdeploy_maven_feed" "feed_maven" {
  count                                = "${length(data.octopusdeploy_feeds.feed_maven.feeds) != 0 ? 0 : 1}"
  name                                 = "Maven"
  feed_uri                             = "https://repo.maven.apache.org/maven2/"
  username                             = "username"
  password                             = "${var.feed_maven_password}"
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_github_repository_feed_with_token" {
  feed_type    = "GitHub"
  ids          = null
  partial_name = "GitHub Repository Feed with Token"
  skip         = 0
  take         = 1
}
variable "feed_github_repository_feed_with_token_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The password used by the feed GitHub Repository Feed with Token"
  default     = "Change Me!"
}
resource "octopusdeploy_github_repository_feed" "feed_github_repository_feed_with_token" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_repository_feed_with_token.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Repository Feed with Token"
  password                             = "${var.feed_github_repository_feed_with_token_password}"
  feed_uri                             = "https://api.github.com"
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
  }
}

data "octopusdeploy_feeds" "feed_github_repository_feed_with_anonymous_access" {
  feed_type    = "GitHub"
  ids          = null
  partial_name = "GitHub Repository Feed with Anonymous Access"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_github_repository_feed" "feed_github_repository_feed_with_anonymous_access" {
  count                                = "${length(data.octopusdeploy_feeds.feed_github_repository_feed_with_anonymous_access.feeds) != 0 ? 0 : 1}"
  name                                 = "GitHub Repository Feed with Anonymous Access"
  feed_uri                             = "https://api.github.com"
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  lifecycle {
    ignore_changes  = [password]
    prevent_destroy = true
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

data "octopusdeploy_feeds" "feed_octopussamples_github_nuget_feed" {
  feed_type    = "NuGet"
  ids          = null
  partial_name = "OctopusSamples GitHub NuGet Feed"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_nuget_feed" "feed_octopussamples_github_nuget_feed" {
  count                                = "${length(data.octopusdeploy_feeds.feed_octopussamples_github_nuget_feed.feeds) != 0 ? 0 : 1}"
  name                                 = "OctopusSamples GitHub NuGet Feed"
  feed_uri                             = "https://nuget.pkg.github.com/OctopusSamples/index.json"
  is_enhanced_mode                     = false
  package_acquisition_location_options = ["Server", "ExecutionTarget"]
  download_attempts                    = 5
  download_retry_backoff_seconds       = 10
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

data "octopusdeploy_tenants" "tenant_tenant" {
  ids          = null
  partial_name = "Tenant"
  skip         = 0
  take         = 1
  project_id   = ""
  tags         = null
}
resource "octopusdeploy_tenant" "tenant_tenant" {
  count       = "${length(data.octopusdeploy_tenants.tenant_tenant.tenants) != 0 ? 0 : 1}"
  name        = "Tenant"
  description = "An example of a tenant"
  tenant_tags = ["Tag Set/tag"]
  depends_on  = [octopusdeploy_tag_set.tagset_tag_set,octopusdeploy_tag.tagset_tag_set_tag_tag]
  lifecycle {
    prevent_destroy = true
  }
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

data "octopusdeploy_certificates" "certificate_development_certificate" {
  ids          = null
  partial_name = "Development Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_development_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_development_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Development Certificate"
  password                          = "${var.certificate_development_certificate_password}"
  certificate_data                  = "${var.certificate_development_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_development_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Development Certificate"
  default     = "Password01!"
}
variable "certificate_development_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Development Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_test_certificate" {
  ids          = null
  partial_name = "Test Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_test_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_test_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Test Certificate"
  password                          = "${var.certificate_test_certificate_password}"
  certificate_data                  = "${var.certificate_test_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_test_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Test Certificate"
  default     = "Password01!"
}
variable "certificate_test_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Test Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_production_certificate" {
  ids          = null
  partial_name = "Production Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_production_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_production_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Production Certificate"
  password                          = "${var.certificate_production_certificate_password}"
  certificate_data                  = "${var.certificate_production_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_production_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Production Certificate"
  default     = "Password01!"
}
variable "certificate_production_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Production Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_unscoped_certificate" {
  ids          = null
  partial_name = "Unscoped Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_unscoped_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_unscoped_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Unscoped Certificate"
  password                          = "${var.certificate_unscoped_certificate_password}"
  certificate_data                  = "${var.certificate_unscoped_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []
  depends_on                        = []
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_unscoped_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Unscoped Certificate"
  default     = "Password01!"
}
variable "certificate_unscoped_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Unscoped Certificate"
  default     = "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"
}

data "octopusdeploy_certificates" "certificate_self_signed_certificate" {
  ids          = null
  partial_name = "Self SIgned Certificate"
  skip         = 0
  take         = 1
}
resource "octopusdeploy_certificate" "certificate_self_signed_certificate" {
  count                             = "${length(data.octopusdeploy_certificates.certificate_self_signed_certificate.certificates) != 0 ? 0 : 1}"
  name                              = "Self SIgned Certificate"
  password                          = "${var.certificate_self_signed_certificate_password}"
  certificate_data                  = "${var.certificate_self_signed_certificate_data}"
  archived                          = ""
  environments                      = []
  notes                             = ""
  tenant_tags                       = ["Cities/London", "Cities/Sydney", "Cities/Washington"]
  tenanted_deployment_participation = "TenantedOrUntenanted"
  tenants                           = []
  depends_on                        = [octopusdeploy_tag_set.tagset_cities,octopusdeploy_tag.tagset_cities_tag_sydney,octopusdeploy_tag.tagset_cities_tag_london,octopusdeploy_tag.tagset_cities_tag_washington]
  lifecycle {
    ignore_changes  = [password, certificate_data]
    prevent_destroy = true
  }
}
variable "certificate_self_signed_certificate_password" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The password used by the certificate Self SIgned Certificate"
  default     = "Password01!"
}
variable "certificate_self_signed_certificate_data" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The certificate data used by the certificate Self SIgned Certificate"
  default     = "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"
}

data "octopusdeploy_deployment_targets" "target_listening_tentacle" {
  ids                  = null
  partial_name         = "Listening Tentacle"
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
resource "octopusdeploy_listening_tentacle_deployment_target" "target_listening_tentacle" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_listening_tentacle.deployment_targets) != 0 ? 0 : 1}"
  environments                      = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
  name                              = "Listening Tentacle"
  roles                             = ["windows-server"]
  tentacle_url                      = "https://windows.server.internal:10933/"
  thumbprint                        = "56489134F675B8E18C4CF0C85719716D3CAD3FAA"
  is_disabled                       = false
  is_in_process                     = false
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  tentacle_version_details {
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_arn_aws_eks_ap_southeast_2_381713788115_cluster_pfbdemo" {
  ids                  = null
  partial_name         = "arn:aws:eks:ap-southeast-2:381713788115:cluster/pfbdemo"
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
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_arn_aws_eks_ap_southeast_2_381713788115_cluster_pfbdemo" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_arn_aws_eks_ap_southeast_2_381713788115_cluster_pfbdemo.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = "https://BEBB2E615CA6ECBF48A94074A3D5D834.gr7.ap-southeast-2.eks.amazonaws.com"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}"]
  name                              = "arn:aws:eks:ap-southeast-2:381713788115:cluster/pfbdemo"
  roles                             = ["Kubernetes"]
  default_worker_pool_id            = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = true
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = "Feeds-5473"
    image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
  }

  aws_account_authentication {
    account_id        = "${length(data.octopusdeploy_accounts.account_aws_oidc.accounts) != 0 ? data.octopusdeploy_accounts.account_aws_oidc.accounts[0].id : octopusdeploy_aws_openid_connect_account.account_aws_oidc[0].id}"
    cluster_name      = "pfbdemo"
    assume_role       = false
    use_instance_role = false
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_eks" {
  ids                  = null
  partial_name         = "EKS"
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
resource "octopusdeploy_kubernetes_cluster_deployment_target" "target_eks" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_eks.deployment_targets) != 0 ? 0 : 1}"
  cluster_url                       = "https://BEBB2E615CA6ECBF48A94074A3D5D834.gr7.ap-southeast-2.eks.amazonaws.com"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  name                              = "EKS"
  roles                             = ["Kubernetes"]
  default_worker_pool_id            = "${length(data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools) != 0 ? data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id : data.octopusdeploy_worker_pools.workerpool_default_worker_pool.worker_pools[0].id}"
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  skip_tls_verification             = true
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  endpoint {
    communication_style = "Kubernetes"
  }

  container {
    feed_id = "Feeds-5473"
    image   = "ghcr.io/octopusdeploylabs/k8s-workertools"
  }

  aws_account_authentication {
    account_id        = "${length(data.octopusdeploy_accounts.account_aws_oidc.accounts) != 0 ? data.octopusdeploy_accounts.account_aws_oidc.accounts[0].id : octopusdeploy_aws_openid_connect_account.account_aws_oidc[0].id}"
    cluster_name      = "pfbdemo"
    assume_role       = false
    use_instance_role = false
  }
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

data "octopusdeploy_deployment_targets" "target_ssh_target" {
  ids                  = null
  partial_name         = "SSH Target"
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
resource "octopusdeploy_ssh_connection_deployment_target" "target_ssh_target" {
  count                 = "${length(data.octopusdeploy_deployment_targets.target_ssh_target.deployment_targets) != 0 ? 0 : 1}"
  account_id            = "${length(data.octopusdeploy_accounts.account_ssh_key_pair.accounts) != 0 ? data.octopusdeploy_accounts.account_ssh_key_pair.accounts[0].id : octopusdeploy_ssh_key_account.account_ssh_key_pair[0].id}"
  environments          = ["${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}"]
  fingerprint           = "SHA256:jnEWLbt6i5om5xN3MbJeZvZlC9zo34dx1/u9oUF+yxM"
  host                  = "linux.server.internal"
  name                  = "SSH Target"
  roles                 = ["linux-server"]
  dot_net_core_platform = "linux-x64"
  machine_policy_id     = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  tenant_tags           = []
  lifecycle {
    prevent_destroy = true
  }
  depends_on = []
}

resource "octopusdeploy_variable" "variables_example_variable_set_database_password_1" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "development.database.internal"
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

resource "octopusdeploy_variable" "variables_example_variable_set_database_password_2" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "test.database.internal"
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

resource "octopusdeploy_variable" "variables_example_variable_set_database_password_3" {
  count        = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? 0 : 1}"
  owner_id     = "${length(data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets) != 0 ? data.octopusdeploy_library_variable_sets.library_variable_set_variables_example_variable_set.library_variable_sets[0].id : octopusdeploy_library_variable_set.library_variable_set_variables_example_variable_set[0].id}"
  value        = "production.database.internal"
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

data "octopusdeploy_project_groups" "project_group_aws" {
  ids          = null
  partial_name = "${var.project_group_aws_name}"
  skip         = 0
  take         = 1
}
variable "project_group_aws_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "AWS"
}
resource "octopusdeploy_project_group" "project_group_aws" {
  count = "${length(data.octopusdeploy_project_groups.project_group_aws.project_groups) != 0 ? 0 : 1}"
  name  = "${var.project_group_aws_name}"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_project_groups" "project_group_azure" {
  ids          = null
  partial_name = "${var.project_group_azure_name}"
  skip         = 0
  take         = 1
}
variable "project_group_azure_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Azure"
}
resource "octopusdeploy_project_group" "project_group_azure" {
  count       = "${length(data.octopusdeploy_project_groups.project_group_azure.project_groups) != 0 ? 0 : 1}"
  name        = "${var.project_group_azure_name}"
  description = ""
  lifecycle {
    prevent_destroy = true
  }
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

data "octopusdeploy_machine_policies" "deploymentfreeze_xmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Xmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_xmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_xmas.machine_policies) != 0 ? 0 : 1}"
  name  = "Xmas"
  start = "2024-12-24T14:00:00.000+00:00"
  end   = "2025-12-26T16:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_machine_policies" "deploymentfreeze_xmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Xmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_xmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_xmas.machine_policies) != 0 ? 0 : 1}"
  name  = "Xmas"
  start = "2024-12-24T14:00:00.000+00:00"
  end   = "2025-12-26T16:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
  }
}

data "octopusdeploy_machine_policies" "deploymentfreeze_xmas" {
  ids             = null
  environment_ids = null
  project_ids     = null
  tenant_ids      = null
  partial_name    = "Xmas"
  skip            = 0
  take            = 1
}
resource "octopusdeploy_deployment_freeze" "deploymentfreeze_xmas" {
  count = "${length(data.octopusdeploy_deployment_freezes.deploymentfreeze_xmas.machine_policies) != 0 ? 0 : 1}"
  name  = "Xmas"
  start = "2024-12-24T14:00:00.000+00:00"
  end   = "2025-12-26T16:00:00.000+00:00"
  lifecycle {
    prevent_destroy = true
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

data "octopusdeploy_deployment_targets" "target_offline_package_drop" {
  ids                  = null
  partial_name         = "Offline Package Drop"
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
resource "octopusdeploy_offline_package_drop_deployment_target" "target_offline_package_drop" {
  count                             = "${length(data.octopusdeploy_deployment_targets.target_offline_package_drop.deployment_targets) != 0 ? 0 : 1}"
  applications_directory            = "C:\\Applications"
  working_directory                 = "C:\\Octopus"
  environments                      = ["${length(data.octopusdeploy_environments.environment_development.environments) != 0 ? data.octopusdeploy_environments.environment_development.environments[0].id : octopusdeploy_environment.environment_development[0].id}", "${length(data.octopusdeploy_environments.environment_test.environments) != 0 ? data.octopusdeploy_environments.environment_test.environments[0].id : octopusdeploy_environment.environment_test[0].id}", "${length(data.octopusdeploy_environments.environment_production.environments) != 0 ? data.octopusdeploy_environments.environment_production.environments[0].id : octopusdeploy_environment.environment_production[0].id}"]
  name                              = "Offline Package Drop"
  roles                             = ["offline-web-server"]
  health_status                     = "Healthy"
  is_disabled                       = false
  machine_policy_id                 = "${data.octopusdeploy_machine_policies.default_machine_policy.machine_policies[0].id}"
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = ["Tag Set/tag"]
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  lifecycle {
    prevent_destroy = true
  }
  depends_on = [octopusdeploy_tag_set.tagset_tag_set,octopusdeploy_tag.tagset_tag_set_tag_tag]
}

data "octopusdeploy_machine_proxies" "machine_proxy_machine_proxy" {
  ids          = null
  partial_name = "${var.machine_proxy_machine_proxy_name}"
  skip         = 0
  take         = 1
}
variable "machine_proxy_machine_proxy_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the machine proxy to lookup"
  default     = "Machine Proxy"
}
resource "octopusdeploy_machine_proxy" "machine_proxy_machine_proxy" {
  count    = "${length(data.octopusdeploy_machine_proxies.machine_proxy_machine_proxy.machine_proxies) != 0 ? 0 : 1}"
  name     = "${var.machine_proxy_machine_proxy_name}"
  host     = "192.168.1.4"
  password = "${var.machine_proxy_machine_proxy_password}"
  username = "username"
  port     = 80
  lifecycle {
    prevent_destroy = true
  }
}
variable "machine_proxy_machine_proxy_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the machine proxy \"Machine Proxy\""
  default     = "Change Me!"
}


