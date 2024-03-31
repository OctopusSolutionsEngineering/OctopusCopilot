resource "octopusdeploy_target" "target_pos_dev_client_1" {
  id                                = "Machines-18467"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "pos-dev-client-1"
  roles                             = ["pos-client"]
  default_worker_pool_id            = "WorkerPools-1107"
  health_status                     = "Healthy"
  is_disabled                       = false
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  thumbprint                        = ""
  depends_on                        = []
}

resource "octopusdeploy_target" "target_pos_dev_client_2" {
  id                                = "Machines-18469"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "pos-dev-client-2"
  roles                             = ["pos-client"]
  default_worker_pool_id            = "WorkerPools-1107"
  health_status                     = "Healthy"
  is_disabled                       = false
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  thumbprint                        = ""
  depends_on                        = []
}

resource "octopusdeploy_target" "target_pos_dev_server" {
  id                                = "Machines-18468"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "pos-dev-server"
  roles                             = ["pos-server"]
  default_worker_pool_id            = "WorkerPools-1107"
  health_status                     = "Healthy"
  is_disabled                       = false
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  thumbprint                        = ""
  depends_on                        = []
}

resource "octopusdeploy_target" "target_pos_dev_client_3" {
  id                                = "Machines-18464"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "pos-dev-client-3"
  roles                             = ["pos-client"]
  default_worker_pool_id            = "WorkerPools-1107"
  health_status                     = "Healthy"
  is_disabled                       = false
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  thumbprint                        = ""
  depends_on                        = []
}


resource "octopusdeploy_environment" "environment_development" {
  id                           = "Environments-1022"
  name                         = "Development"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = true
  sort_order                   = 0

  jira_extension_settings {
    environment_type = "development"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = true
  }
}

resource "octopusdeploy_target" "target_pos_dev_client_5" {
  id                                = "Machines-18470"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "pos-dev-client-5"
  roles                             = ["pos-client"]
  default_worker_pool_id            = "WorkerPools-1107"
  health_status                     = "Healthy"
  is_disabled                       = false
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  thumbprint                        = ""
  depends_on                        = []
}


resource "octopusdeploy_target" "target_pos_dev_client_4" {
  id                                = "Machines-18466"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "pos-dev-client-4"
  roles                             = ["pos-client"]
  default_worker_pool_id            = "WorkerPools-1107"
  health_status                     = "Healthy"
  is_disabled                       = false
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  thumbprint                        = ""
  depends_on                        = []
}

resource "octopusdeploy_target" "target_azure_iis" {
  id                                = "Machines-12345"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "azure_iis"
  roles                             = ["pos-client"]
  default_worker_pool_id            = "WorkerPools-1107"
  health_status                     = "Healthy"
  is_disabled                       = false
  shell_name                        = "Unknown"
  shell_version                     = "Unknown"
  tenant_tags                       = []
  tenanted_deployment_participation = "Tenanted"
  tenants                           = []
  thumbprint                        = ""
  depends_on                        = []
}