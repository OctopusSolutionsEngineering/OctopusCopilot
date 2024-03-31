resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis" {
  id                                = "Machines-12387"
  environments                      = ["${octopusdeploy_environment.environment_development.id}"]
  name                              = "azure-iis"
  roles                             = ["azure-iss"]
  tentacle_url                      = "poll://4mz9qfd62rypjv59yj2p/"
  is_disabled                       = false
  shell_name                        = "PowerShell"
  shell_version                     = "5.1.17763.4840"
  tenant_tags                       = []
  tenanted_deployment_participation = "Untenanted"
  tenants                           = []

  tentacle_version_details {
  }

  thumbprint = "84D0CA1BBB7436381018A73FE2C385DA0296DE50"
  depends_on = []
}

resource "octopusdeploy_cloud_region_deployment_target" "target_pos_dev_client_1" {
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

resource "octopusdeploy_cloud_region_deployment_target" "target_pos_dev_client_2" {
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

resource "octopusdeploy_cloud_region_deployment_target" "target_pos_dev_server" {
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

resource "octopusdeploy_cloud_region_deployment_target" "target_pos_dev_client_3" {
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

resource "octopusdeploy_cloud_region_deployment_target" "target_dallas_client_5" {
  id                                = "Machines-18486"
  environments                      = [""]
  name                              = "dallas-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_test_client_5" {
  id                                = "Machines-18510"
  environments                      = [""]
  name                              = "pos-test-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_london_client_3" {
  id                                = "Machines-18441"
  environments                      = [""]
  name                              = "london-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_chicago_client_5" {
  id                                = "Machines-18512"
  environments                      = [""]
  name                              = "chicago-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_belfast_client_5" {
  id                                = "Machines-18521"
  environments                      = [""]
  name                              = "belfast-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_dallas_server" {
  id                                = "Machines-18503"
  environments                      = [""]
  name                              = "dallas-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_melbourne_client_5" {
  id                                = "Machines-18506"
  environments                      = [""]
  name                              = "melbourne-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_vancouver_client_3" {
  id                                = "Machines-18458"
  environments                      = [""]
  name                              = "vancouver-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_calgary_client_4" {
  id                                = "Machines-18496"
  environments                      = [""]
  name                              = "calgary-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_edinburgh_client_3" {
  id                                = "Machines-18473"
  environments                      = [""]
  name                              = "edinburgh-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_belfast_client_1" {
  id                                = "Machines-18519"
  environments                      = [""]
  name                              = "belfast-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_toronto_client_1" {
  id                                = "Machines-18457"
  environments                      = [""]
  name                              = "toronto-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_toronto_client_4" {
  id                                = "Machines-18446"
  environments                      = [""]
  name                              = "toronto-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_calgary_server" {
  id                                = "Machines-18494"
  environments                      = [""]
  name                              = "calgary-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_test_client_2" {
  id                                = "Machines-18497"
  environments                      = [""]
  name                              = "pos-test-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_atlanta_client_2" {
  id                                = "Machines-18499"
  environments                      = [""]
  name                              = "atlanta-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_vancouver_client_5" {
  id                                = "Machines-18465"
  environments                      = [""]
  name                              = "vancouver-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_melbourne_client_1" {
  id                                = "Machines-18504"
  environments                      = [""]
  name                              = "melbourne-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_edinburgh_server" {
  id                                = "Machines-18471"
  environments                      = [""]
  name                              = "edinburgh-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_brisbane_client_2" {
  id                                = "Machines-18453"
  environments                      = [""]
  name                              = "brisbane-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_brisbane_client_4" {
  id                                = "Machines-18442"
  environments                      = [""]
  name                              = "brisbane-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_belfast_server" {
  id                                = "Machines-18520"
  environments                      = [""]
  name                              = "belfast-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_chicago_server" {
  id                                = "Machines-18522"
  environments                      = [""]
  name                              = "chicago-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_5" {
  id                                = "Machines-18477"
  environments                      = [""]
  name                              = "sydney-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_calgary_client_2" {
  id                                = "Machines-18493"
  environments                      = [""]
  name                              = "calgary-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_melbourne_client_3" {
  id                                = "Machines-18509"
  environments                      = [""]
  name                              = "melbourne-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_chicago_client_1" {
  id                                = "Machines-18514"
  environments                      = [""]
  name                              = "chicago-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_test_client_4" {
  id                                = "Machines-18479"
  environments                      = [""]
  name                              = "pos-test-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_dallas_client_4" {
  id                                = "Machines-18484"
  environments                      = [""]
  name                              = "dallas-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_brisbane_client_3" {
  id                                = "Machines-18444"
  environments                      = [""]
  name                              = "brisbane-client-3"
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


resource "octopusdeploy_git_credential" "gitcredential_demo_space_creator_app" {
  id       = "GitCredentials-923"
  name     = "Demo Space Creator App"
  type     = "UsernamePassword"
  username = "x-access-token"
  password = "${var.gitcredential_demo_space_creator_app}"
}
variable "gitcredential_demo_space_creator_app" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"Demo Space Creator App\""
}


resource "octopusdeploy_cloud_region_deployment_target" "target_london_client_5" {
  id                                = "Machines-18449"
  environments                      = [""]
  name                              = "london-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_london_server" {
  id                                = "Machines-18463"
  environments                      = [""]
  name                              = "london-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_dallas_client_1" {
  id                                = "Machines-18501"
  environments                      = [""]
  name                              = "dallas-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_3" {
  id                                = "Machines-18491"
  environments                      = [""]
  name                              = "sydney-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_brisbane_client_5" {
  id                                = "Machines-18443"
  environments                      = [""]
  name                              = "brisbane-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_edinburgh_client_1" {
  id                                = "Machines-18474"
  environments                      = [""]
  name                              = "edinburgh-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_test_client_1" {
  id                                = "Machines-18488"
  environments                      = [""]
  name                              = "pos-test-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_toronto_client_2" {
  id                                = "Machines-18455"
  environments                      = [""]
  name                              = "toronto-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_melbourne_client_4" {
  id                                = "Machines-18490"
  environments                      = [""]
  name                              = "melbourne-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_melbourne_server" {
  id                                = "Machines-18511"
  environments                      = [""]
  name                              = "melbourne-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_edinburgh_client_4" {
  id                                = "Machines-18505"
  environments                      = [""]
  name                              = "edinburgh-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_1" {
  id                                = "Machines-18487"
  environments                      = [""]
  name                              = "sydney-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_calgary_client_5" {
  id                                = "Machines-18513"
  environments                      = [""]
  name                              = "calgary-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_toronto_server" {
  id                                = "Machines-18447"
  environments                      = [""]
  name                              = "toronto-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_brisbane_client_1" {
  id                                = "Machines-18452"
  environments                      = [""]
  name                              = "brisbane-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_belfast_client_3" {
  id                                = "Machines-18516"
  environments                      = [""]
  name                              = "belfast-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_test_server" {
  id                                = "Machines-18498"
  environments                      = [""]
  name                              = "pos-test-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_dallas_client_3" {
  id                                = "Machines-18485"
  environments                      = [""]
  name                              = "dallas-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_atlanta_client_3" {
  id                                = "Machines-18481"
  environments                      = [""]
  name                              = "atlanta-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_london_client_4" {
  id                                = "Machines-18448"
  environments                      = [""]
  name                              = "london-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_2" {
  id                                = "Machines-18478"
  environments                      = [""]
  name                              = "sydney-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_atlanta_client_5" {
  id                                = "Machines-18482"
  environments                      = [""]
  name                              = "atlanta-client-5"
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


resource "octopusdeploy_git_credential" "gitcredential_cac" {
  id       = "GitCredentials-221"
  name     = "CaC"
  type     = "UsernamePassword"
  username = "mcasperson"
  password = "${var.gitcredential_cac}"
}
variable "gitcredential_cac" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The secret variable value associated with the git credential \"CaC\""
}


resource "octopusdeploy_cloud_region_deployment_target" "target_vancouver_client_2" {
  id                                = "Machines-18459"
  environments                      = [""]
  name                              = "vancouver-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_vancouver_server" {
  id                                = "Machines-18460"
  environments                      = [""]
  name                              = "vancouver-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_server" {
  id                                = "Machines-18489"
  environments                      = [""]
  name                              = "sydney-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_belfast_client_2" {
  id                                = "Machines-18523"
  environments                      = [""]
  name                              = "belfast-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_vancouver_client_4" {
  id                                = "Machines-18461"
  environments                      = [""]
  name                              = "vancouver-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_melbourne_client_2" {
  id                                = "Machines-18507"
  environments                      = [""]
  name                              = "melbourne-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_toronto_client_3" {
  id                                = "Machines-18445"
  environments                      = [""]
  name                              = "toronto-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_atlanta_client_1" {
  id                                = "Machines-18480"
  environments                      = [""]
  name                              = "atlanta-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_chicago_client_3" {
  id                                = "Machines-18515"
  environments                      = [""]
  name                              = "chicago-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_dev_client_5" {
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_dev_client_4" {
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


resource "octopusdeploy_cloud_region_deployment_target" "target_edinburgh_client_5" {
  id                                = "Machines-18472"
  environments                      = [""]
  name                              = "edinburgh-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_belfast_client_4" {
  id                                = "Machines-18518"
  environments                      = [""]
  name                              = "belfast-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_toronto_client_5" {
  id                                = "Machines-18456"
  environments                      = [""]
  name                              = "toronto-client-5"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_london_client_2" {
  id                                = "Machines-18450"
  environments                      = [""]
  name                              = "london-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_calgary_client_3" {
  id                                = "Machines-18508"
  environments                      = [""]
  name                              = "calgary-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_dallas_client_2" {
  id                                = "Machines-18483"
  environments                      = [""]
  name                              = "dallas-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_atlanta_client_4" {
  id                                = "Machines-18502"
  environments                      = [""]
  name                              = "atlanta-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_chicago_client_2" {
  id                                = "Machines-18524"
  environments                      = [""]
  name                              = "chicago-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_brisbane_server" {
  id                                = "Machines-18454"
  environments                      = [""]
  name                              = "brisbane-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_4" {
  id                                = "Machines-18492"
  environments                      = [""]
  name                              = "sydney-client-4"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_atlanta_server" {
  id                                = "Machines-18500"
  environments                      = [""]
  name                              = "atlanta-server"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_vancouver_client_1" {
  id                                = "Machines-18462"
  environments                      = [""]
  name                              = "vancouver-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_london_client_1" {
  id                                = "Machines-18451"
  environments                      = [""]
  name                              = "london-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_edinburgh_client_2" {
  id                                = "Machines-18475"
  environments                      = [""]
  name                              = "edinburgh-client-2"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_calgary_client_1" {
  id                                = "Machines-18495"
  environments                      = [""]
  name                              = "calgary-client-1"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_pos_test_client_3" {
  id                                = "Machines-18476"
  environments                      = [""]
  name                              = "pos-test-client-3"
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


resource "octopusdeploy_cloud_region_deployment_target" "target_chicago_client_4" {
  id                                = "Machines-18517"
  environments                      = [""]
  name                              = "chicago-client-4"
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


