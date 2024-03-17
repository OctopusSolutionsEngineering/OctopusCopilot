resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = "rob.pearson@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = "ryanrousseau"
}

variable "octopus_server" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The URL of the Octopus server e.g. https://myinstance.octopus.app."
}
variable "octopus_apikey" {
  type        = string
  nullable    = false
  sensitive   = true
  description = "The API key used to access the Octopus server. See https://octopus.com/docs/octopus-rest-api/how-to-create-an-api-key for details on creating an API key."
}
variable "octopus_space_id" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The ID of the Octopus space to populate."
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_kailen_garcia" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kailen_garcia.id}"
  value                   = "kailen.garcia@octopus.com"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant" "tenant__tenant_template" {
  name        = "_Tenant Template"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws]
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = "octopus"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "mark.harrison@octopus.com"
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_mark_lamprecht" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value          = "True"
}

resource "octopusdeploy_channel" "channel__preview" {
  name        = "Preview"
  description = ""
  project_id  = "${octopusdeploy_project.project_demo_space_creator.id}"
  is_default  = false

  rule {

    action_package {
      deployment_action = "Deploy Space Creator"
    }
    action_package {
      deployment_action = "Deploy OctoFX Template"
    }
    action_package {
      deployment_action = "Deploy Tenants Template"
    }
    action_package {
      deployment_action = "Deploy Kubernetes Template"
    }
    action_package {
      deployment_action = "Deploy ServiceNow Template"
    }
    action_package {
      deployment_action = "Deploy Helm Template"
    }

    tag           = "preview"
    version_range = ""
  }

  tenant_tags = []
  depends_on  = [octopusdeploy_deployment_process.deployment_process_demo_space_creator]
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_mark_h___enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value          = "False"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "rob.pearson@octopus.com"
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "Tony Kelly demo space"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tenant" "tenant_mark_lamprecht" {
  name        = "Mark Lamprecht"
  description = "A tenant for creating a conferences and exhibitions space for demo purposes.\n\nOctopus.ServiceNow.ChangeRequest.Number"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/TAM", "Region/EMEA", "Options/Run Daily Deployments"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_tam, octopusdeploy_tag.tag_emea, octopusdeploy_tag.tag_run_daily_deployments
  ]
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "https://dev157592.service-now.com/"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "Demo space for DevTools partner visit in India"
}

resource "octopusdeploy_tenant" "tenant_multi_tenancycon" {
  name        = "Multi-TenancyCon"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Conference", "Region/NA", "Options/Run Daily Deployments",
    "Options/Shared Access", "Options/Dev and QA Teams"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_conference, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_run_daily_deployments,
    octopusdeploy_tag.tag_shared_access, octopusdeploy_tag.tag_dev_and_qa_teams
  ]
}

variable "project_group_demo_space_creator_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project group to lookup"
  default     = "Demo Space Creator"
}
data "octopusdeploy_project_groups" "project_group_demo_space_creator" {
  ids          = null
  partial_name = "${var.project_group_demo_space_creator_name}"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a project group called $${var.project_group_demo_space_creator_name}. This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.project_groups) != 0
    }
  }
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "Describe the demo space"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "james.chatmas@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "james.chatmas@octopus.com"
}

variable "demo_space_creator_demospacecreator_createtenant_jsmusertoken_1" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable DemoSpaceCreator.CreateTenant.JSMUserToken"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_jsmusertoken_1" {
  owner_id        = "${octopusdeploy_project.project_demo_space_creator.id}"
  name            = "DemoSpaceCreator.CreateTenant.JSMUserToken"
  type            = "Sensitive"
  description     = "The user token of the JSM account to use when creating and checking issues."
  sensitive_value = "${var.demo_space_creator_demospacecreator_createtenant_jsmusertoken_1}"
  is_sensitive    = true

  prompt {
    description = "The user token of the JSM account to use when creating and checking issues."
    label       = "4.3: JSM User Token"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_james_c" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_james_c.id}"
  value          = "OctoPetShop - Lambda"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "False"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_white_rock_global" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value          = "True"
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

variable "project_demo_space_creator_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the project exported from Demo Space Creator"
  default     = "Demo Space Creator"
}
variable "project_demo_space_creator_description_prefix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional prefix to add to the project description for the project Demo Space Creator"
  default     = ""
}
variable "project_demo_space_creator_description_suffix" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "An optional suffix to add to the project description for the project Demo Space Creator"
  default     = ""
}
variable "project_demo_space_creator_description" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The description of the project exported from Demo Space Creator"
  default     = "Deploys everything needed to create or recreate a demo space and populate it with projects."
}
resource "octopusdeploy_project" "project_demo_space_creator" {
  name                                 = "${var.project_demo_space_creator_name}"
  auto_create_release                  = false
  default_guided_failure_mode          = "EnvironmentDefault"
  default_to_skip_if_already_installed = false
  discrete_channel_release             = false
  is_disabled                          = false
  is_version_controlled                = false
  lifecycle_id                         = "${data.octopusdeploy_lifecycles.lifecycle_default_lifecycle.lifecycles[0].id}"
  project_group_id                     = "${data.octopusdeploy_project_groups.project_group_demo_space_creator.project_groups[0].id}"
  included_library_variable_sets       = [
    "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}",
    "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}",
    "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}",
    "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  ]
  tenanted_deployment_participation    = "Tenanted"

  connectivity_policy {
    allow_deployments_to_no_targets = false
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }

  versioning_strategy {
    template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.LastPatch}.#{Octopus.Version.NextRevision}"
  }

  lifecycle {
    ignore_changes = []
  }
  description = "${var.project_demo_space_creator_description_prefix}${var.project_demo_space_creator_description}${var.project_demo_space_creator_description_suffix}"
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "mark.harrison@octopus.com"
}

variable "demo_space_creator_demospacecreator_createtenant_githubpat_1" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable DemoSpaceCreator.CreateTenant.GitHubPAT"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_githubpat_1" {
  owner_id        = "${octopusdeploy_project.project_demo_space_creator.id}"
  name            = "DemoSpaceCreator.CreateTenant.GitHubPAT"
  type            = "Sensitive"
  description     = "A GitHub Personal Access Token to use with for Config as Code.  The PAT needs repo:status, public_repo, and delete_repo scopes."
  sensitive_value = "${var.demo_space_creator_demospacecreator_createtenant_githubpat_1}"
  is_sensitive    = true

  prompt {
    description = "A GitHub Personal Access Token to use with for Config as Code.  The PAT needs repo:status, public_repo, and delete_repo scopes."
    label       = "3.2: GitHub Personal Access Token"
    is_required = false
  }
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "For a K8s demo."
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "harrisonmeister"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_white_rock_global" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value          = "True"
}

variable "demo_space_creator_demospacecreator_createtenant_githubrepositoryname_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.GitHubRepositoryName"
  default     = "demo.octopus.app"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_githubrepositoryname_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_githubrepositoryname_1}"
  name         = "DemoSpaceCreator.CreateTenant.GitHubRepositoryName"
  type         = "String"
  description  = "The name of the repository to store Config as Code files in. **Note**: Demo Space Creator will attempt to delete and recreate this repository. Do not use an existing on that you do not want to lose."
  is_sensitive = false

  prompt {
    description = "The name of the repository to store Config as Code files in. **Note**: Demo Space Creator will attempt to delete and recreate this repository. Do not use an existing on that you do not want to lose."
    label       = "3.3: GitHub Repository Name"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "mark.lamprecht@octopus.com"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "not set"
}

variable "project_demo_space_creator_step_deploy_space_creator_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Space Creator in project Demo Space Creator"
  default     = "Projects-284"
}
variable "project_demo_space_creator_step_deploy_octofx_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy OctoFX Template in project Demo Space Creator"
  default     = "Projects-486"
}
variable "project_demo_space_creator_step_deploy_tenants_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Tenants Template in project Demo Space Creator"
  default     = "Projects-503"
}
variable "project_demo_space_creator_step_deploy_kubernetes_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Kubernetes Template in project Demo Space Creator"
  default     = "Projects-626"
}
variable "project_demo_space_creator_step_deploy_helm_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Helm Template in project Demo Space Creator"
  default     = "Projects-1001"
}
variable "project_demo_space_creator_step_deploy_ecs_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy ECS Template in project Demo Space Creator"
  default     = "Projects-1331"
}
variable "project_demo_space_creator_step_deploy_servicenow_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy ServiceNow Template in project Demo Space Creator"
  default     = "Projects-802"
}
variable "project_demo_space_creator_step_deploy_jsm_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy JSM Template in project Demo Space Creator"
  default     = "Projects-1642"
}
variable "project_demo_space_creator_step_deploy_lambda_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy Lambda in project Demo Space Creator"
  default     = "Projects-2353"
}
variable "project_demo_space_creator_step_deploy_pos_template_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy POS Template in project Demo Space Creator"
  default     = "Projects-2889"
}
resource "octopusdeploy_deployment_process" "deployment_process_demo_space_creator" {
  project_id = "${octopusdeploy_project.project_demo_space_creator.id}"

  step {
    condition           = "Success"
    name                = "Check if current user matches tenant user"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Check if current user matches tenant user"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = true
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "Octopus.Action.RunOnServer"            = "true"
        "Octopus.Action.Script.ScriptSource"    = "Inline"
        "Octopus.Action.Script.Syntax"          = "PowerShell"
        "Octopus.Action.Script.ScriptBody"      = "$currentUser = $OctopusParameters[\"Octopus.Deployment.CreatedBy.EmailAddress\"]\n$tenantUser = $OctopusParameters[\"Tenant.User.Email\"]\n$allowServiceAccounts = $OctopusParameters[\"CheckCurrentUser.AllowServiceAccounts\"]\n$tenant = $OctopusParameters[\"Octopus.Deployment.Tenant.Name\"]\n\n$name = $OctopusParameters[\"Octopus.Deployment.CreatedBy.DisplayName\"]\nWrite-Verbose \"This task was created by $name\"\n\n$serviceAccounts = @(\"Demo Space Manager\", \"System\")\n\nif ($allowServiceAccounts -eq \"True\" -and $serviceAccounts.Contains($name)) {\n  Write-Host \"Allowing $name to start this task against tenant owned by $tenantUser\"\n  Exit 0\n}\n\n$tenantUsers = $tenantUser.Split([Environment]::NewLine)\n\nif (-not $tenantUsers.Contains($currentUser)) {\n  Fail-Step \"$name does not have permission to run tasks for tenant `\"$tenant`\"\"\n}"
        "CheckCurrentUser.AllowServiceAccounts" = "True"
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
    condition_expression = "#{DemoSpaceCreator.Prompts.DestroyExistingSpace}"
    name                 = "Destroy existing space"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Destroy existing space"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "Run.Runbook.Waitforfinish"                       = "True"
        "Run.Runbook.CancelInSeconds"                     = "1800"
        "Run.Runbook.Environment.Name"                    = "#{Octopus.Environment.Name}"
        "Octopus.Action.RunOnServer"                      = "true"
        "Run.Runbook.Machines"                            = "N/A"
        "Run.Runbook.Name"                                = "Delete demo space"
        "Run.Runbook.AutoApproveManualInterventions"      = "No"
        "Run.Runbook.Tenant.Name"                         = "#{Octopus.Deployment.Tenant.Name}"
        "Run.Runbook.UsePublishedSnapShot"                = "True"
        "Octopus.Action.Script.ScriptSource"              = "Inline"
        "Run.Runbook.Base.Url"                            = "#{Octopus.Web.ServerUri}"
        "Run.Runbook.Space.Name"                          = "#{Octopus.Space.Name}"
        "Octopus.Action.Script.Syntax"                    = "PowerShell"
        "Run.Runbook.DateTime"                            = "N/A"
        "Run.Runbook.Project.Name"                        = "Space Manager"
        "Run.Runbook.Api.Key"                             = "#{DemoSpaceCreator.Octopus.APIKey}"
        "Run.Runbook.ManualIntervention.EnvironmentToUse" = "#{Octopus.Environment.Name}"
        "Octopus.Action.Script.ScriptBody"                = "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12\n\n# Octopus Variables\n$octopusSpaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n$parentTaskId = $OctopusParameters[\"Octopus.Task.Id\"]\n$parentReleaseId = $OctopusParameters[\"Octopus.Release.Id\"]\n$parentChannelId = $OctopusParameters[\"Octopus.Release.Channel.Id\"]\n$parentEnvironmentId = $OctopusParameters[\"Octopus.Environment.Id\"]\n$parentRunbookId = $OctopusParameters[\"Octopus.Runbook.Id\"]\n$parentEnvironmentName = $OctopusParameters[\"Octopus.Environment.Name\"]\n$parentReleaseNumber = $OctopusParameters[\"Octopus.Release.Number\"]\n\n# Step Template Parameters\n$runbookRunName = $OctopusParameters[\"Run.Runbook.Name\"]\n$runbookBaseUrl = $OctopusParameters[\"Run.Runbook.Base.Url\"]\n$runbookApiKey = $OctopusParameters[\"Run.Runbook.Api.Key\"]\n$runbookEnvironmentName = $OctopusParameters[\"Run.Runbook.Environment.Name\"]\n$runbookTenantName = $OctopusParameters[\"Run.Runbook.Tenant.Name\"]\n$runbookWaitForFinish = $OctopusParameters[\"Run.Runbook.Waitforfinish\"]\n$runbookUseGuidedFailure = $OctopusParameters[\"Run.Runbook.UseGuidedFailure\"]\n$runbookUsePublishedSnapshot = $OctopusParameters[\"Run.Runbook.UsePublishedSnapShot\"]\n$runbookPromptedVariables = $OctopusParameters[\"Run.Runbook.PromptedVariables\"]\n$runbookCancelInSeconds = $OctopusParameters[\"Run.Runbook.CancelInSeconds\"]\n$runbookProjectName = $OctopusParameters[\"Run.Runbook.Project.Name\"]\n\n$runbookSpaceName = $OctopusParameters[\"Run.Runbook.Space.Name\"]\n$runbookFutureDeploymentDate = $OctopusParameters[\"Run.Runbook.DateTime\"]\n$runbookMachines = $OctopusParameters[\"Run.Runbook.Machines\"]\n$autoApproveRunbookRunManualInterventions = $OctopusParameters[\"Run.Runbook.AutoApproveManualInterventions\"]\n$approvalEnvironmentName = $OctopusParameters[\"Run.Runbook.ManualIntervention.EnvironmentToUse\"]\n\nfunction Write-OctopusVerbose\n{\n    param($message)\n    \n    Write-Verbose $message  \n}\n\nfunction Write-OctopusInformation\n{\n    param($message)\n    \n    Write-Host $message  \n}\n\nfunction Write-OctopusSuccess\n{\n    param($message)\n\n    Write-Highlight $message \n}\n\nfunction Write-OctopusWarning\n{\n    param($message)\n\n    Write-Warning \"$message\" \n}\n\nfunction Write-OctopusCritical\n{\n    param ($message)\n\n    Write-Error \"$message\" \n}\n\nfunction Invoke-OctopusApi\n{\n    param\n    (\n        $octopusUrl,\n        $endPoint,\n        $spaceId,\n        $apiKey,\n        $method,\n        $item     \n    )\n\n    if ([string]::IsNullOrWhiteSpace($SpaceId))\n    {\n        $url = \"$OctopusUrl/api/$EndPoint\"\n    }\n    else\n    {\n        $url = \"$OctopusUrl/api/$spaceId/$EndPoint\"    \n    }  \n\n    try\n    {\n        if ($null -eq $item)\n        {\n            Write-Verbose \"No data to post or put, calling bog standard invoke-restmethod for $url\"\n            return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -ContentType 'application/json; charset=utf-8'\n        }\n\n        $body = $item | ConvertTo-Json -Depth 10\n        Write-Verbose $body\n\n        Write-Host \"Invoking $method $url\"\n        return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -Body $body -ContentType 'application/json; charset=utf-8'\n    }\n    catch\n    {\n        if ($null -ne $_.Exception.Response)\n        {\n            if ($_.Exception.Response.StatusCode -eq 401)\n            {\n                Write-Error \"Unauthorized error returned from $url, please verify API key and try again\"\n            }\n            elseif ($_.Exception.Response.statusCode -eq 403)\n            {\n                Write-Error \"Forbidden error returned from $url, please verify API key and try again\"\n            }\n            else\n            {                \n                Write-Error -Message \"Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )\"\n            }            \n        }\n        else\n        {\n            Write-Verbose $_.Exception\n        }\n    }\n\n    Throw \"There was an error calling the Octopus API please check the log for more details\"\n}\n\nfunction Test-RequiredValues\n{\n\tparam (\n    \t$variableToCheck,\n        $variableName\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($variableToCheck) -eq $true)\n    {\n    \tWrite-OctopusCritical \"$variableName is required.\"\n        return $false\n    }\n    \n    return $true\n}\n\nfunction GetCheckBoxBoolean\n{\n\tparam (\n    \t[string]$Value\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($value) -eq $true)\n    {\n    \treturn $false\n    }\n    \n    return $value -eq \"True\"\n}\n\nfunction Get-FilteredOctopusItem\n{\n    param(\n        $itemList,\n        $itemName\n    )\n\n    if ($itemList.Items.Count -eq 0)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        Exit 1\n    }  \n\n    $item = $itemList.Items | Where-Object { $_.Name -eq $itemName}      \n\n    if ($null -eq $item)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n    \n    if ($item -is [array])\n    {\n    \tWrite-OctopusCritical \"More than one item exists with the name $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n\n    return $item\n}\n\nfunction Get-OctopusItemFromListEndpoint\n{\n    param(\n        $endpoint,\n        $itemNameToFind,\n        $itemType,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $defaultValue\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($itemNameToFind))\n    {\n    \treturn $defaultValue\n    }\n    \n    Write-OctopusInformation \"Attempting to find $itemType with the name of $itemNameToFind\"\n    \n    $itemList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"$($endpoint)?partialName=$([uri]::EscapeDataString($itemNameToFind))\u0026skip=0\u0026take=100\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"    \n    $item = Get-FilteredOctopusItem -itemList $itemList -itemName $itemNameToFind\n\n    Write-OctopusInformation \"Successfully found $itemNameToFind with id of $($item.Id)\"\n\n    return $item\n}\n\nfunction Get-MachineIdsFromMachineNames\n{\n    param (\n        $targetMachines,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    $targetMachineList = $targetMachines -split \",\"\n    $translatedList = @()\n\n    foreach ($machineName in $targetMachineList)\n    {\n        Write-OctopusVerbose \"Translating $machineName to an Id.  First checking to see if it is already an Id.\"\n    \tif ($machineName.Trim() -like \"Machines*\")\n        {\n            Write-OctopusVerbose \"$machineName is already an Id, no need to look that up.\"\n        \t$translatedList += $machineName\n            continue\n        }\n        \n        $machineObject = Get-OctopusItemFromListEndpoint -itemNameToFind $machineName.Trim() -itemType \"Deployment Target\" -endpoint \"machines\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n\n        $translatedList += $machineObject.Id\n    }\n\n    return $translatedList\n}\n\nfunction Get-RunbookSnapshotIdToRun\n{\n    param (\n        $runbookToRun,\n        $runbookUsePublishedSnapshot,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $runbookSnapShotIdToUse = $runbookToRun.PublishedRunbookSnapshotId\n    Write-OctopusInformation \"The last published snapshot for $runbookRunName is $runbookSnapShotIdToUse\"\n\n    if ($null -eq $runbookSnapShotIdToUse -and $runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusCritical \"Use Published Snapshot was set; yet the runbook doesn't have a published snapshot.  Exiting.\"\n        Exit 1\n    }\n\n    if ($runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusInformation \"Use published snapshot set to true, using the published runbook snapshot.\"\n        return $runbookSnapShotIdToUse\n    }\n\n    if ($null -eq $runbookToRun.PublishedRunbookSnapshotId)\n    {\n        Write-OctopusInformation \"There have been no published runbook snapshots, going to create a new snapshot.\"\n        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    $runbookSnapShotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)/runbookRuns/template\" -method \"Get\" -item $null\n\n    if ($runbookSnapShotTemplate.IsRunbookProcessModified -eq $false -and $runbookSnapShotTemplate.IsVariableSetModified -eq $false -and $runbookSnapShotTemplate.IsLibraryVariableSetModified -eq $false)\n    {        \n        Write-OctopusInformation \"The runbook has not been modified since the published snapshot was created.  Checking to see if any of the packages have a new version.\"    \n        $runbookSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)\" -method \"Get\" -item $null\n        $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n        foreach ($package in $runbookSnapShot.SelectedPackages)\n        {\n            foreach ($templatePackage in $snapshotTemplate.Packages)\n            {\n                if ($package.StepName -eq $templatePackage.StepName -and $package.ActionName -eq $templatePackage.ActionName -and $package.PackageReferenceName -eq $templatePackage.PackageReferenceName)\n                {\n                    $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($templatePackage.FeedId)/packages/versions?packageId=$($templatePackage.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n                    if ($packageVersion -ne $package.Version)\n                    {\n                        Write-OctopusInformation \"A newer version of a package was found, going to use that and create a new snapshot.\"\n                        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId                    \n                    }\n                }\n            }\n        }\n\n        Write-OctopusInformation \"No new package versions have been found, using the published snapshot.\"\n        return $runbookToRun.PublishedRunbookSnapshotId\n    }\n    \n    Write-OctopusInformation \"The runbook has been modified since the snapshot was created, creating a new one.\"\n    return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n}\n\nfunction New-RunbookUnpublishedSnapshot\n{\n    param (\n        $runbookToRun,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $octopusProject = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"Get\" -item $null\n    $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n    $runbookPackages = @()\n    foreach ($package in $snapshotTemplate.Packages)\n    {\n        $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($package.FeedId)/packages/versions?packageId=$($package.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n        if ($packageVersion.TotalResults -le 0)\n        {\n            Write-Error \"Unable to find a package version for $($package.PackageId).  This is required to create a new unpublished snapshot.  Exiting.\"\n            exit 1\n        }\n\n        $runbookPackages += @{\n            StepName = $package.StepName\n            ActionName = $package.ActionName\n            Version = $packageVersion.Items[0].Version\n            PackageReferenceName = $package.PackageReferenceName\n        }\n    }\n\n    $runbookSnapShotRequest = @{\n        FrozenProjectVariableSetId = \"variableset-$($runbookToRun.ProjectId)\"\n        FrozenRunbookProcessId = $($runbookToRun.RunbookProcessId)\n        LibraryVariableSetSnapshotIds = @($octopusProject.IncludedLibraryVariableSetIds)\n        Name = $($snapshotTemplate.NextNameIncrement)\n        ProjectId = $($runbookToRun.ProjectId)\n        ProjectVariableSetSnapshotId = \"variableset-$($runbookToRun.ProjectId)\"\n        RunbookId = $($runbookToRun.Id)\n        SelectedPackages = $runbookPackages\n    }\n\n    $newSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots\" -method \"POST\" -item $runbookSnapShotRequest\n\n    return $($newSnapShot.Id)\n}\n\nfunction Get-ProjectSlug\n{\n    param\n    (\n        $runbookToRun,\n        $projectToUse,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    if ($null -ne $projectToUse)\n    {\n        return $projectToUse.Slug\n    }\n\n    $project = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"GET\" -item $null\n\n    return $project.Slug\n}\n\nfunction Get-RunbookFormValues\n{\n    param (\n        $runbookPreview,\n        $runbookPromptedVariables        \n    )\n\n    $runbookFormValues = @{}\n\n    if ([string]::IsNullOrWhiteSpace($runbookPromptedVariables) -eq $true)\n    {\n        return $runbookFormValues\n    }    \n    \n    $promptedValueList = @(($runbookPromptedVariables -Split \"`n\").Trim())\n    Write-OctopusInformation $promptedValueList.Length\n    \n    foreach($element in $runbookPreview.Form.Elements)\n    {\n    \t$nameToSearchFor = $element.Control.Name\n        $uniqueName = $element.Name\n        $isRequired = $element.Control.Required\n        \n        $promptedVariablefound = $false\n        \n        Write-OctopusInformation \"Looking for the prompted variable value for $nameToSearchFor\"\n    \tforeach ($promptedValue in $promptedValueList)\n        {\n        \t$splitValue = $promptedValue -Split \"::\"\n            Write-OctopusInformation \"Comparing $nameToSearchFor with provided prompted variable $($promptedValue[0])\"\n            if ($splitValue.Length -gt 1)\n            {\n            \tif ($nameToSearchFor -eq $splitValue[0])\n                {\n                \tWrite-OctopusInformation \"Found the prompted variable value $nameToSearchFor\"\n                \t$runbookFormValues[$uniqueName] = $splitValue[1]\n                    $promptedVariableFound = $true\n                    break\n                }\n            }\n        }\n        \n        if ($promptedVariableFound -eq $false -and $isRequired -eq $true)\n        {\n        \tWrite-OctopusCritical \"Unable to find a value for the required prompted variable $nameToSearchFor, exiting\"\n            Exit 1\n        }\n    }\n\n    return $runbookFormValues\n}\n\nfunction Invoke-OctopusDeployRunbook\n{\n    param (\n        $runbookBody,\n        $runbookWaitForFinish,\n        $runbookCancelInSeconds,\n        $projectNameForUrl,        \n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentTaskApprovers,\n        $autoApproveRunbookRunManualInterventions,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $approvalEnvironmentName,\n        $parentRunbookId,\n        $parentTaskId\n    )\n\n    $runbookResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -item $runbookBody -method \"POST\" -endPoint \"runbookRuns\"\n\n    $runbookServerTaskId = $runBookResponse.TaskId\n    Write-OctopusInformation \"The task id of the new task is $runbookServerTaskId\"\n\n    $runbookRunId = $runbookResponse.Id\n    Write-OctopusInformation \"The runbook run id is $runbookRunId\"\n\n    Write-OctopusSuccess \"Runbook was successfully invoked, you can access the launched runbook [here]($defaultUrl/app#/$spaceId/projects/$projectNameForUrl/operations/runbooks/$($runbookBody.RunbookId)/snapshots/$($runbookBody.RunbookSnapShotId)/runs/$runbookRunId)\"\n\n    if ($runbookWaitForFinish -eq $false)\n    {\n        Write-OctopusInformation \"The wait for finish setting is set to no, exiting step\"\n        return\n    }\n    \n    if ($null -ne $runbookBody.QueueTime)\n    {\n    \tWrite-OctopusInformation \"The runbook queue time is set.  Exiting step\"\n        return\n    }\n\n    Write-OctopusSuccess \"The setting to wait for completion was set, waiting until task has finished\"\n    $startTime = Get-Date\n    $currentTime = Get-Date\n    $dateDifference = $currentTime - $startTime\n\t\n    $taskStatusUrl = \"tasks/$runbookServerTaskId\"\n    $numberOfWaits = 0    \n    \n    While ($dateDifference.TotalSeconds -lt $runbookCancelInSeconds)\n    {\n        Write-OctopusInformation \"Waiting 5 seconds to check status\"\n        Start-Sleep -Seconds 5\n        $taskStatusResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint $taskStatusUrl -method \"GET\" -item $null\n        $taskStatusResponseState = $taskStatusResponse.State\n\n        if ($taskStatusResponseState -eq \"Success\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of Success\"\n            exit 0            \n        }\n        elseif($taskStatusResponseState -eq \"Failed\" -or $taskStatusResponseState -eq \"Canceled\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of $taskStatusResponseState status, stopping the run/deployment\"\n            exit 1            \n        }\n        elseif($taskStatusResponse.HasPendingInterruptions -eq $true)\n        {\n            if ($autoApproveRunbookRunManualInterventions -eq \"Yes\")\n            {\n                Submit-RunbookRunForAutoApproval -createdRunbookRun $createdRunbookRun -parentTaskApprovers $parentTaskApprovers -defaultUrl $DefaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -parentProjectName $parentProjectName -parentReleaseNumber $parentReleaseNumber -parentEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $parentTaskId\n            }\n            else\n            {\n                if ($numberOfWaits -ge 10)\n                {\n                    Write-OctopusSuccess \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"\n                }\n                else\n                {\n                    Write-OctopusInformation \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"                        \n                }\n            }\n        }\n        \n        $numberOfWaits += 1\n        if ($numberOfWaits -ge 10)\n        {\n        \tWrite-OctopusSuccess \"The task state is currently $taskStatusResponseState\"\n        \t$numberOfWaits = 0\n        }\n        else\n        {\n        \tWrite-OctopusInformation \"The task state is currently $taskStatusResponseState\"\n        }  \n        \n        $startTime = $taskStatusResponse.StartTime\n        if ($startTime -eq $null -or [string]::IsNullOrWhiteSpace($startTime) -eq $true)\n        {        \n        \tWrite-OctopusInformation \"The task is still queued, let's wait a bit longer\"\n        \t$startTime = Get-Date\n        }\n        $startTime = [DateTime]$startTime\n        \n        $currentTime = Get-Date\n        $dateDifference = $currentTime - $startTime        \n    }\n    \n    Write-OctopusSuccess \"The cancel timeout has been reached, cancelling the runbook run\"\n    $cancelResponse = Invoke-RestMethod \"$runbookBaseUrl/api/tasks/$runbookServerTaskId/cancel\" -Headers $header -Method Post\n    Write-OctopusSuccess \"Exiting with an error code of 1 because we reached the timeout\"\n    exit 1\n}\n\nfunction Get-QueueDate\n{\n\tparam ( \n    \t$futureDeploymentDate\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($futureDeploymentDate) -or $futureDeploymentDate -eq \"N/A\")\n    {\n    \treturn $null\n    }\n    \n    [datetime]$outputDate = New-Object DateTime\n    $currentDate = Get-Date\n\n    if ([datetime]::TryParse($futureDeploymentDate, [ref]$outputDate) -eq $false)\n    {\n        Write-OctopusCritical \"The suppplied date $futureDeploymentDate cannot be parsed by DateTime.TryParse.  Please verify format and try again.  Please [refer to Microsoft's Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.datetime.tryparse) on supported formats.\"\n        exit 1\n    }\n    \n    if ($currentDate -gt $outputDate)\n    {\n    \tWrite-OctopusCritical \"The supplied date $futureDeploymentDate is set for the past.  All queued deployments must be in the future.\"\n        exit 1\n    }\n    \n    return $outputDate\n}\n\nfunction Get-QueueExpiryDate\n{\n\tparam (\n    \t$queueDate\n    )\n    \n    if ($null -eq $queueDate)\n    {\n    \treturn $null\n    }\n    \n    return $queueDate.AddHours(1)\n}\n\nfunction Get-RunbookSpecificMachines\n{\n    param (\n        $runbookPreview,\n        $runbookMachines,        \n        $runbookRunName        \n    )\n\n    if ($runbookMachines -eq \"N/A\")\n    {\n        return @()\n    }\n\n    if ([string]::IsNullOrWhiteSpace($runbookMachines) -eq $true)\n    {\n        return @()\n    }\n\n    $translatedList = Get-MachineIdsFromMachineNames -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -targetMachines $runbookMachines\n\n    $filteredList = @()    \n    foreach ($runbookMachine in $translatedList)\n    {    \t\n    \t$runbookMachineId = $runbookMachine.Trim().ToLower()\n    \tWrite-OctopusVerbose \"Checking if $runbookMachineId is set to run on any of the runbook steps\"\n        \n        foreach ($step in $runbookPreview.StepsToExecute)\n        {\n            foreach ($machine in $step.Machines)\n            {\n            \tWrite-OctopusVerbose \"Checking if $runbookMachineId matches $($machine.Id) and it isn't already in the $($filteredList -join \",\")\"\n                if ($runbookMachineId -eq $machine.Id.Trim().ToLower() -and $filteredList -notcontains $machine.Id)\n                {\n                \tWrite-OctopusInformation \"Adding $($machine.Id) to the list\"\n                    $filteredList += $machine.Id\n                }\n            }\n        }\n    }\n\n    if ($filteredList.Length -le 0)\n    {\n        Write-OctopusSuccess \"The current task is targeting specific machines, but the runbook $runBookRunName does not run against any of these machines $runbookMachines. Skipping this run.\"\n        exit 0\n    }\n\n    return $filteredList\n}\n\nfunction Get-ParentTaskApprovers\n{\n    param (\n        $parentTaskId,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n    \n    $approverList = @()\n    if ($null -eq $parentTaskId)\n    {\n    \tWrite-OctopusInformation \"The deployment task id to pull the approvers from is null, return an empty approver list\"\n    \treturn $approverList\n    }\n\n    Write-OctopusInformation \"Getting all the events from the parent project\"\n    $parentEvents = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"events?regardingAny=$parentTaskId\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"\n    \n    foreach ($parentEvent in $parentEvents.Items)\n    {\n        Write-OctopusVerbose \"Checking $($parentEvent.Message) for manual intervention\"\n        if ($parentEvent.Message -like \"Submitted interruption*\")\n        {\n            Write-OctopusVerbose \"The event $($parentEvent.Id) is a manual intervention approval event which was approved by $($parentEvent.Username).\"\n\n            $approverExists = $approverList | Where-Object {$_.Id -eq $parentEvent.UserId}        \n\n            if ($null -eq $approverExists)\n            {\n                $approverInformation = @{\n                    Id = $parentEvent.UserId;\n                    Username = $parentEvent.Username;\n                    Teams = @()\n                }\n\n                $approverInformation.Teams = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"teammembership?userId=$($approverInformation.Id)\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"            \n\n                Write-OctopusVerbose \"Adding $($approverInformation.Id) to the approval list\"\n                $approverList += $approverInformation\n            }        \n        }\n    }\n\n    return $approverList\n}\n\nfunction Get-ApprovalTaskIdFromDeployment\n{\n    param (\n        $parentReleaseId,\n        $approvalEnvironment,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n\n    $releaseDeploymentList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"releases/$parentReleaseId/deployments\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    \n    $lastDeploymentTime = $(Get-Date).AddYears(-50)\n    $approvalTaskId = $null\n    foreach ($deployment in $releaseDeploymentList.Items)\n    {\n        if ($deployment.EnvironmentId -ne $approvalEnvironment.Id)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) deployed to $($deployment.EnvironmentId) which doesn't match $($approvalEnvironment.Id).\"\n            continue\n        }\n        \n        Write-OctopusInformation \"The deployment $($deployment.Id) was deployed to the approval environment $($approvalEnvironment.Id).\"\n\n        $deploymentTask = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $null -endPoint \"tasks/$($deployment.TaskId)\" -apiKey $octopusApiKey -Method \"Get\"\n        if ($deploymentTask.IsCompleted -eq $true -and $deploymentTask.FinishedSuccessfully -eq $false)\n        {\n            Write-Information \"The deployment $($deployment.Id) was deployed to the approval environment, but it encountered a failure, moving onto the next deployment.\"\n            continue\n        }\n\n        if ($deploymentTask.StartTime -gt $lastDeploymentTime)\n        {\n            $approvalTaskId = $deploymentTask.Id\n            $lastDeploymentTime = $deploymentTask.StartTime\n        }\n    }        \n\n    if ($null -eq $approvalTaskId)\n    {\n    \tWrite-OctopusVerbose \"Unable to find a deployment to the environment, determining if it should've happened already.\"\n        $channelInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$parentChannelId\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n        $lifecycle = Get-OctopusLifeCycle -channel $channelInformation -defaultUrl $defaultUrl -spaceId $spaceId -OctopusApiKey $octopusApiKey\n        $lifecyclePhases = Get-LifecyclePhases -lifecycle $lifecycle -defaultUrl $defaultUrl -spaceId $spaceid -OctopusApiKey $octopusApiKey\n        \n        $foundDestinationFirst = $false\n        $foundApprovalFirst = $false\n        \n        foreach ($phase in $lifecyclePhases.Phases)\n        {\n        \tif ($phase.AutomaticDeploymentTargets -contains $parentEnvironmentId -or $phase.OptionalDeploymentTargets -contains $parentEnvironmentId)\n            {\n            \tif ($foundApprovalFirst -eq $false)\n                {\n                \t$foundDestinationFirst = $true\n                }\n            }\n            \n            if ($phase.AutomaticDeploymentTargets -contains $approvalEnvironment.Id -or $phase.OptionalDeploymentTargets -contains $approvalEnvironment.Id)\n            {\n            \tif ($foundDestinationFirst -eq $false)\n                {\n                \t$foundApprovalFirst = $true\n                }\n            }\n        }\n        \n        $messageToLog = \"Unable to find a deployment for the environment $approvalEnvironmentName.  Auto approvals are disabled.\"\n        if ($foundApprovalFirst -eq $true)\n        {\n        \tWrite-OctopusWarning $messageToLog\n        }\n        else\n        {\n        \tWrite-OctopusInformation $messageToLog\n        }\n        \n        return $null\n    }\n\n    return $approvalTaskId\n}\n\nfunction Get-ApprovalTaskIdFromRunbook\n{\n    param (\n        $parentRunbookId,\n        $approvalEnvironment,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n}\n\nfunction Get-ApprovalTaskId\n{\n\tparam (\n    \t$autoApproveRunbookRunManualInterventions,\n        $parentTaskId,\n        $parentReleaseId,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $approvalEnvironmentName,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey        \n    )\n    \n    if ($autoApproveRunbookRunManualInterventions -eq $false)\n    {\n    \tWrite-OctopusInformation \"Auto approvals are disabled, skipping pulling the approval deployment task id\"\n        return $null\n    }\n    \n    if ([string]::IsNullOrWhiteSpace($approvalEnvironmentName) -eq $true)\n    {\n    \tWrite-OctopusInformation \"Approval environment not supplied, using the current environment id for approvals.\"\n        return $parentTaskId\n    }\n    \n    if ($approvalEnvironmentName.ToLower().Trim() -eq $parentEnvironmentName.ToLower().Trim())\n    {\n        Write-OctopusInformation \"The approval environment is the same as the current environment, using the current task id $parentTaskId\"\n        return $parentTaskId\n    }\n    \n    $approvalEnvironment = Get-OctopusItemFromListEndpoint -itemNameToFind $approvalEnvironmentName -itemType \"Environment\" -defaultUrl $DefaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -defaultValue $null -endpoint \"environments\"\n    \n    if ([string]::IsNullOrWhiteSpace($parentReleaseId) -eq $false)\n    {\n        return Get-ApprovalTaskIdFromDeployment -parentReleaseId $parentReleaseId -approvalEnvironment $approvalEnvironment -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    return Get-ApprovalTaskIdFromRunbook -parentRunbookId $parentRunbookId -approvalEnvironment $approvalEnvironment -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n}\n\nfunction Get-OctopusLifecycle\n{\n    param (\n        $channel,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the lifecycle information $($channel.Name)\"\n    if ($null -eq $channel.LifecycleId)\n    {\n        $lifecycleName = \"Default Lifecycle\"\n        $lifecycleList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles?partialName=$([uri]::EscapeDataString($lifecycleName))\u0026skip=0\u0026take=1\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $lifecycle = $lifecycleList.Items[0]\n    }\n    else\n    {\n        $lifecycle = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($channel.LifecycleId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n    }\n\n    Write-Host \"Successfully found the lifecycle $($lifecycle.Name) to use for this channel.\"\n\n    return $lifecycle\n}\n\nfunction Get-LifecyclePhases\n{\n    param (\n        $lifecycle,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the phase in the lifecycle $($lifecycle.Name) with the environment $environmentName to find the previous phase.\"\n    if ($lifecycle.Phases.Count -eq 0)\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has no set phases, calling the preview endpoint.\"\n        $lifecyclePreview = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($lifecycle.Id)/preview\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $phases = $lifecyclePreview.Phases\n    }\n    else\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has set phases, using those.\"\n        $phases = $lifecycle.Phases    \n    }\n\n    Write-OctopusInformation \"Found $($phases.Length) phases in this lifecycle.\"\n    return $phases\n}\n\nfunction Submit-RunbookRunForAutoApproval\n{\n    param (\n        $createdRunbookRun,\n        $parentTaskApprovers,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $parentTaskId        \n    )\n\n    Write-OctopusSuccess \"The task has a pending manual intervention.  Checking parent approvals.\"    \n    $manualInterventionInformation = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions?regarding=$($createdRunbookRun.TaskId)\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    foreach ($manualIntervention in $manualInterventionInformation.Items)\n    {\n        if ($manualIntervention.IsPending -eq $false)\n        {\n            Write-OctopusInformation \"This manual intervention has already been approved.  Proceeding onto the next one.\"\n            continue\n        }\n\n        if ($manualIntervention.CanTakeResponsibility -eq $false)\n        {\n            Write-OctopusSuccess \"The user associated with the API key doesn't have permissions to take responsibility for the manual intervention.\"\n            Write-OctopusSuccess \"If you wish to leverage the auto-approval functionality give the user permissions.\"\n            continue\n        }        \n\n        $automaticApprover = $null\n        Write-OctopusVerbose \"Checking to see if one of the parent project approvers is assigned to one of the manual intervention teams $($manualIntervention.ResponsibleTeamIds)\"\n        foreach ($approver in $parentTaskApprovers)\n        {\n            foreach ($approverTeam in $approver.Teams)\n            {\n                Write-OctopusVerbose \"Checking to see if $($manualIntervention.ResponsibleTeamIds) contains $($approverTeam.TeamId)\"\n                if ($manualIntervention.ResponsibleTeamIds -contains $approverTeam.TeamId)\n                {\n                    $automaticApprover = $approver\n                    break\n                }\n            }\n\n            if ($null -ne $automaticApprover)\n            {\n                break\n            }\n        }\n\n        if ($null -ne $automaticApprover)\n        {\n        \tWrite-OctopusSuccess \"Matching approver found auto-approving.\"\n            if ($manualIntervention.HasResponsibility -eq $false)\n            {\n                Write-OctopusInformation \"Taking over responsibility for this manual intervention.\"\n                $takeResponsiblilityResponse = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/responsible\" -method \"PUT\" -apiKey $octopusApiKey -spaceId $spaceId\n                Write-OctopusVerbose \"Response from taking responsibility $($takeResponsiblilityResponse.Id)\"\n            }\n            \n            if ([string]::IsNullOrWhiteSpace($parentReleaseNumber) -eq $false)\n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName release $parentReleaseNumber to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that deployment $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n            else \n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName runbook run $parentRunbookId to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that runbook run $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n\n            $submitApprovalBody = @{\n                Instructions = $null;\n                Notes = $notes\n                Result = \"Proceed\"\n            }\n            $submitResult = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/submit\" -method \"POST\" -apiKey $octopusApiKey -item $submitApprovalBody -spaceId $spaceId\n            Write-OctopusSuccess \"Successfully auto approved the manual intervention $($submitResult.Id)\"\n        }\n        else\n        {\n            Write-OctopusSuccess \"Couldn't find an approver to auto-approve the child project.  Waiting until timeout or child project is approved.\"    \n        }\n    }\n}\n\n\n$runbookWaitForFinish = GetCheckboxBoolean -Value $runbookWaitForFinish\n$runbookUseGuidedFailure = GetCheckboxBoolean -Value $runbookUseGuidedFailure\n$runbookUsePublishedSnapshot = GetCheckboxBoolean -Value $runbookUsePublishedSnapshot\n$runbookCancelInSeconds = [int]$runbookCancelInSeconds\n\nWrite-OctopusInformation \"Wait for Finish Before Check: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure Before Check: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Use Published Snapshot Before Check: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Runbook Name $runbookRunName\"\nWrite-OctopusInformation \"Runbook Base Url: $runbookBaseUrl\"\nWrite-OctopusInformation \"Runbook Space Name: $runbookSpaceName\"\nWrite-OctopusInformation \"Runbook Environment Name: $runbookEnvironmentName\"\nWrite-OctopusInformation \"Runbook Tenant Name: $runbookTenantName\"\nWrite-OctopusInformation \"Wait for Finish: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Cancel run in seconds: $runbookCancelInSeconds\"\nWrite-OctopusInformation \"Use Published Snapshot: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Auto Approve Runbook Run Manual Interventions: $autoApproveRunbookRunManualInterventions\"\nWrite-OctopusInformation \"Auto Approve environment name to pull approvals from: $approvalEnvironmentName\"\n\nWrite-OctopusInformation \"Octopus runbook run machines: $runbookMachines\"\nWrite-OctopusInformation \"Parent Task Id: $parentTaskId\"\nWrite-OctopusInformation \"Parent Release Id: $parentReleaseId\"\nWrite-OctopusInformation \"Parent Channel Id: $parentChannelId\"\nWrite-OctopusInformation \"Parent Environment Id: $parentEnvironmentId\"\nWrite-OctopusInformation \"Parent Runbook Id: $parentRunbookId\"\nWrite-OctopusInformation \"Parent Environment Name: $parentEnvironmentName\"\nWrite-OctopusInformation \"Parent Release Number: $parentReleaseNumber\"\n\n$verificationPassed = @()\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookRunName -variableName \"Runbook Name\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookBaseUrl -variableName \"Base Url\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookApiKey -variableName \"Api Key\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookEnvironmentName -variableName \"Environment Name\"\n\nif ($verificationPassed -contains $false)\n{\n\tWrite-OctopusInformation \"Required values missing\"\n\tExit 1\n}\n\n$runbookSpace = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookSpaceName -endpoint \"spaces\" -spaceId $null -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl -itemType \"Space\" -defaultValue $octopusSpaceId\n$runbookSpaceId = $runbookSpace.Id\n\n$projectToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookProjectName -endpoint \"projects\" -spaceId $runbookSpaceId -defaultValue $null -itemType \"Project\" -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl\nif ($null -ne $projectToUse)\n{\t    \n    $runbookEndPoint = \"projects/$($projectToUse.Id)/runbooks\"\n}\nelse\n{\n\t$runbookEndPoint = \"runbooks\"\n}\n\n$environmentToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookEnvironmentName -itemType \"Environment\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -defaultValue $null -endpoint \"environments\"\n\n$runbookToRun = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookRunName -itemType \"Runbook\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -endpoint $runbookEndPoint -octopusApiKey $runbookApiKey -defaultValue $null\n\n$runbookSnapShotIdToUse = Get-RunbookSnapshotIdToRun -runbookToRun $runbookToRun -runbookUsePublishedSnapshot $runbookUsePublishedSnapshot -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $octopusSpaceId\n$projectNameForUrl = Get-ProjectSlug -projectToUse $projectToUse -runbookToRun $runbookToRun -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId\n\n$tenantToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookTenantName -itemType \"Tenant\" -defaultValue $null -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -endpoint \"tenants\" -defaultUrl $runbookBaseUrl\nif ($null -ne $tenantToUse)\n{\t\n    $tenantIdToUse = $tenantToUse.Id    \n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)/$($tenantIdToUse)\" -method \"GET\" -item $null\n}\nelse\n{\n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)\" -method \"GET\" -item $null\n}\n\n$childRunbookRunSpecificMachines = Get-RunbookSpecificMachines -runbookPreview $runBookPreview -runbookMachines $runbookMachines -runbookRunName $runbookRunName\n$runbookFormValues = Get-RunbookFormValues -runbookPreview $runBookPreview -runbookPromptedVariables $runbookPromptedVariables\n\n$queueDate = Get-QueueDate -futureDeploymentDate $runbookFutureDeploymentDate\n$queueExpiryDate = Get-QueueExpiryDate -queueDate $queueDate\n\n$runbookBody = @{\n    RunbookId = $($runbookToRun.Id);\n    RunbookSnapShotId = $runbookSnapShotIdToUse;\n    FrozenRunbookProcessId = $null;\n    EnvironmentId = $($environmentToUse.Id);\n    TenantId = $tenantIdToUse;\n    SkipActions = @();\n    QueueTime = $queueDate;\n    QueueTimeExpiry = $queueExpiryDate;\n    FormValues = $runbookFormValues;\n    ForcePackageDownload = $false;\n    ForcePackageRedeployment = $true;\n    UseGuidedFailure = $runbookUseGuidedFailure;\n    SpecificMachineIds = @($childRunbookRunSpecificMachines);\n    ExcludedMachineIds = @()\n}\n\n$approvalTaskId = Get-ApprovalTaskId -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentTaskId $parentTaskId -parentReleaseId $parentReleaseId -parentRunbookId $parentRunbookId -parentEnvironmentName $parentEnvironmentName -approvalEnvironmentName $approvalEnvironmentName -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey\n$parentTaskApprovers = Get-ParentTaskApprovers -parentTaskId $approvalTaskId -spaceId $runbookSpaceId -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey\n\nInvoke-OctopusDeployRunbook -runbookBody $runbookBody -runbookWaitForFinish $runbookWaitForFinish -runbookCancelInSeconds $runbookCancelInSeconds -projectNameForUrl $projectNameForUrl -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId -parentTaskApprovers $parentTaskApprovers -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentProjectName $projectNameForUrl -parentReleaseNumber $parentReleaseNumber -approvalEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $approvalTaskId"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = { "Octopus.Step.ConditionVariableExpression" = "#{DemoSpaceCreator.Prompts.DestroyExistingSpace}" }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateSpace}#{/unless}"
    name                 = "Deploy Space Creator"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy Space Creator"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-284"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_space_creator_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateSpace}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Connect Tenant to Azure Infrastructure"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to Azure Infrastructure"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "Octopus.Action.RunOnServer"                  = "true"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Project.NameOrId"     = "Azure Infrastructure"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
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
    name                = "Add Azure worker to Space"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Add Azure worker to Space"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.RunOnServer"                      = "true"
        "Run.Runbook.DateTime"                            = "N/A"
        "Octopus.Action.Script.ScriptSource"              = "Inline"
        "Run.Runbook.Space.Name"                          = "#{Octopus.Space.Name}"
        "Run.Runbook.Base.Url"                            = "#{Octopus.Web.ServerUri}"
        "Run.Runbook.UsePublishedSnapShot"                = "True"
        "Run.Runbook.CancelInSeconds"                     = "1800"
        "Run.Runbook.Waitforfinish"                       = "True"
        "Run.Runbook.Environment.Name"                    = "#{Octopus.Environment.Name}"
        "Run.Runbook.Project.Name"                        = "Azure Infrastructure"
        "Octopus.Action.Script.ScriptBody"                = "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12\n\n# Octopus Variables\n$octopusSpaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n$parentTaskId = $OctopusParameters[\"Octopus.Task.Id\"]\n$parentReleaseId = $OctopusParameters[\"Octopus.Release.Id\"]\n$parentChannelId = $OctopusParameters[\"Octopus.Release.Channel.Id\"]\n$parentEnvironmentId = $OctopusParameters[\"Octopus.Environment.Id\"]\n$parentRunbookId = $OctopusParameters[\"Octopus.Runbook.Id\"]\n$parentEnvironmentName = $OctopusParameters[\"Octopus.Environment.Name\"]\n$parentReleaseNumber = $OctopusParameters[\"Octopus.Release.Number\"]\n\n# Step Template Parameters\n$runbookRunName = $OctopusParameters[\"Run.Runbook.Name\"]\n$runbookBaseUrl = $OctopusParameters[\"Run.Runbook.Base.Url\"]\n$runbookApiKey = $OctopusParameters[\"Run.Runbook.Api.Key\"]\n$runbookEnvironmentName = $OctopusParameters[\"Run.Runbook.Environment.Name\"]\n$runbookTenantName = $OctopusParameters[\"Run.Runbook.Tenant.Name\"]\n$runbookWaitForFinish = $OctopusParameters[\"Run.Runbook.Waitforfinish\"]\n$runbookUseGuidedFailure = $OctopusParameters[\"Run.Runbook.UseGuidedFailure\"]\n$runbookUsePublishedSnapshot = $OctopusParameters[\"Run.Runbook.UsePublishedSnapShot\"]\n$runbookPromptedVariables = $OctopusParameters[\"Run.Runbook.PromptedVariables\"]\n$runbookCancelInSeconds = $OctopusParameters[\"Run.Runbook.CancelInSeconds\"]\n$runbookProjectName = $OctopusParameters[\"Run.Runbook.Project.Name\"]\n\n$runbookSpaceName = $OctopusParameters[\"Run.Runbook.Space.Name\"]\n$runbookFutureDeploymentDate = $OctopusParameters[\"Run.Runbook.DateTime\"]\n$runbookMachines = $OctopusParameters[\"Run.Runbook.Machines\"]\n$autoApproveRunbookRunManualInterventions = $OctopusParameters[\"Run.Runbook.AutoApproveManualInterventions\"]\n$approvalEnvironmentName = $OctopusParameters[\"Run.Runbook.ManualIntervention.EnvironmentToUse\"]\n\nfunction Write-OctopusVerbose\n{\n    param($message)\n    \n    Write-Verbose $message  \n}\n\nfunction Write-OctopusInformation\n{\n    param($message)\n    \n    Write-Host $message  \n}\n\nfunction Write-OctopusSuccess\n{\n    param($message)\n\n    Write-Highlight $message \n}\n\nfunction Write-OctopusWarning\n{\n    param($message)\n\n    Write-Warning \"$message\" \n}\n\nfunction Write-OctopusCritical\n{\n    param ($message)\n\n    Write-Error \"$message\" \n}\n\nfunction Invoke-OctopusApi\n{\n    param\n    (\n        $octopusUrl,\n        $endPoint,\n        $spaceId,\n        $apiKey,\n        $method,\n        $item     \n    )\n\n    if ([string]::IsNullOrWhiteSpace($SpaceId))\n    {\n        $url = \"$OctopusUrl/api/$EndPoint\"\n    }\n    else\n    {\n        $url = \"$OctopusUrl/api/$spaceId/$EndPoint\"    \n    }  \n\n    try\n    {\n        if ($null -eq $item)\n        {\n            Write-Verbose \"No data to post or put, calling bog standard invoke-restmethod for $url\"\n            return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -ContentType 'application/json; charset=utf-8'\n        }\n\n        $body = $item | ConvertTo-Json -Depth 10\n        Write-Verbose $body\n\n        Write-Host \"Invoking $method $url\"\n        return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -Body $body -ContentType 'application/json; charset=utf-8'\n    }\n    catch\n    {\n        if ($null -ne $_.Exception.Response)\n        {\n            if ($_.Exception.Response.StatusCode -eq 401)\n            {\n                Write-Error \"Unauthorized error returned from $url, please verify API key and try again\"\n            }\n            elseif ($_.Exception.Response.statusCode -eq 403)\n            {\n                Write-Error \"Forbidden error returned from $url, please verify API key and try again\"\n            }\n            else\n            {                \n                Write-Error -Message \"Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )\"\n            }            \n        }\n        else\n        {\n            Write-Verbose $_.Exception\n        }\n    }\n\n    Throw \"There was an error calling the Octopus API please check the log for more details\"\n}\n\nfunction Test-RequiredValues\n{\n\tparam (\n    \t$variableToCheck,\n        $variableName\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($variableToCheck) -eq $true)\n    {\n    \tWrite-OctopusCritical \"$variableName is required.\"\n        return $false\n    }\n    \n    return $true\n}\n\nfunction GetCheckBoxBoolean\n{\n\tparam (\n    \t[string]$Value\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($value) -eq $true)\n    {\n    \treturn $false\n    }\n    \n    return $value -eq \"True\"\n}\n\nfunction Get-FilteredOctopusItem\n{\n    param(\n        $itemList,\n        $itemName\n    )\n\n    if ($itemList.Items.Count -eq 0)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        Exit 1\n    }  \n\n    $item = $itemList.Items | Where-Object { $_.Name -eq $itemName}      \n\n    if ($null -eq $item)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n    \n    if ($item -is [array])\n    {\n    \tWrite-OctopusCritical \"More than one item exists with the name $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n\n    return $item\n}\n\nfunction Get-OctopusItemFromListEndpoint\n{\n    param(\n        $endpoint,\n        $itemNameToFind,\n        $itemType,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $defaultValue\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($itemNameToFind))\n    {\n    \treturn $defaultValue\n    }\n    \n    Write-OctopusInformation \"Attempting to find $itemType with the name of $itemNameToFind\"\n    \n    $itemList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"$($endpoint)?partialName=$([uri]::EscapeDataString($itemNameToFind))\u0026skip=0\u0026take=100\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"    \n    $item = Get-FilteredOctopusItem -itemList $itemList -itemName $itemNameToFind\n\n    Write-OctopusInformation \"Successfully found $itemNameToFind with id of $($item.Id)\"\n\n    return $item\n}\n\nfunction Get-MachineIdsFromMachineNames\n{\n    param (\n        $targetMachines,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    $targetMachineList = $targetMachines -split \",\"\n    $translatedList = @()\n\n    foreach ($machineName in $targetMachineList)\n    {\n        Write-OctopusVerbose \"Translating $machineName to an Id.  First checking to see if it is already an Id.\"\n    \tif ($machineName.Trim() -like \"Machines*\")\n        {\n            Write-OctopusVerbose \"$machineName is already an Id, no need to look that up.\"\n        \t$translatedList += $machineName\n            continue\n        }\n        \n        $machineObject = Get-OctopusItemFromListEndpoint -itemNameToFind $machineName.Trim() -itemType \"Deployment Target\" -endpoint \"machines\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n\n        $translatedList += $machineObject.Id\n    }\n\n    return $translatedList\n}\n\nfunction Get-RunbookSnapshotIdToRun\n{\n    param (\n        $runbookToRun,\n        $runbookUsePublishedSnapshot,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $runbookSnapShotIdToUse = $runbookToRun.PublishedRunbookSnapshotId\n    Write-OctopusInformation \"The last published snapshot for $runbookRunName is $runbookSnapShotIdToUse\"\n\n    if ($null -eq $runbookSnapShotIdToUse -and $runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusCritical \"Use Published Snapshot was set; yet the runbook doesn't have a published snapshot.  Exiting.\"\n        Exit 1\n    }\n\n    if ($runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusInformation \"Use published snapshot set to true, using the published runbook snapshot.\"\n        return $runbookSnapShotIdToUse\n    }\n\n    if ($null -eq $runbookToRun.PublishedRunbookSnapshotId)\n    {\n        Write-OctopusInformation \"There have been no published runbook snapshots, going to create a new snapshot.\"\n        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    $runbookSnapShotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)/runbookRuns/template\" -method \"Get\" -item $null\n\n    if ($runbookSnapShotTemplate.IsRunbookProcessModified -eq $false -and $runbookSnapShotTemplate.IsVariableSetModified -eq $false -and $runbookSnapShotTemplate.IsLibraryVariableSetModified -eq $false)\n    {        \n        Write-OctopusInformation \"The runbook has not been modified since the published snapshot was created.  Checking to see if any of the packages have a new version.\"    \n        $runbookSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)\" -method \"Get\" -item $null\n        $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n        foreach ($package in $runbookSnapShot.SelectedPackages)\n        {\n            foreach ($templatePackage in $snapshotTemplate.Packages)\n            {\n                if ($package.StepName -eq $templatePackage.StepName -and $package.ActionName -eq $templatePackage.ActionName -and $package.PackageReferenceName -eq $templatePackage.PackageReferenceName)\n                {\n                    $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($templatePackage.FeedId)/packages/versions?packageId=$($templatePackage.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n                    if ($packageVersion -ne $package.Version)\n                    {\n                        Write-OctopusInformation \"A newer version of a package was found, going to use that and create a new snapshot.\"\n                        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId                    \n                    }\n                }\n            }\n        }\n\n        Write-OctopusInformation \"No new package versions have been found, using the published snapshot.\"\n        return $runbookToRun.PublishedRunbookSnapshotId\n    }\n    \n    Write-OctopusInformation \"The runbook has been modified since the snapshot was created, creating a new one.\"\n    return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n}\n\nfunction New-RunbookUnpublishedSnapshot\n{\n    param (\n        $runbookToRun,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $octopusProject = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"Get\" -item $null\n    $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n    $runbookPackages = @()\n    foreach ($package in $snapshotTemplate.Packages)\n    {\n        $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($package.FeedId)/packages/versions?packageId=$($package.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n        if ($packageVersion.TotalResults -le 0)\n        {\n            Write-Error \"Unable to find a package version for $($package.PackageId).  This is required to create a new unpublished snapshot.  Exiting.\"\n            exit 1\n        }\n\n        $runbookPackages += @{\n            StepName = $package.StepName\n            ActionName = $package.ActionName\n            Version = $packageVersion.Items[0].Version\n            PackageReferenceName = $package.PackageReferenceName\n        }\n    }\n\n    $runbookSnapShotRequest = @{\n        FrozenProjectVariableSetId = \"variableset-$($runbookToRun.ProjectId)\"\n        FrozenRunbookProcessId = $($runbookToRun.RunbookProcessId)\n        LibraryVariableSetSnapshotIds = @($octopusProject.IncludedLibraryVariableSetIds)\n        Name = $($snapshotTemplate.NextNameIncrement)\n        ProjectId = $($runbookToRun.ProjectId)\n        ProjectVariableSetSnapshotId = \"variableset-$($runbookToRun.ProjectId)\"\n        RunbookId = $($runbookToRun.Id)\n        SelectedPackages = $runbookPackages\n    }\n\n    $newSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots\" -method \"POST\" -item $runbookSnapShotRequest\n\n    return $($newSnapShot.Id)\n}\n\nfunction Get-ProjectSlug\n{\n    param\n    (\n        $runbookToRun,\n        $projectToUse,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    if ($null -ne $projectToUse)\n    {\n        return $projectToUse.Slug\n    }\n\n    $project = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"GET\" -item $null\n\n    return $project.Slug\n}\n\nfunction Get-RunbookFormValues\n{\n    param (\n        $runbookPreview,\n        $runbookPromptedVariables        \n    )\n\n    $runbookFormValues = @{}\n\n    if ([string]::IsNullOrWhiteSpace($runbookPromptedVariables) -eq $true)\n    {\n        return $runbookFormValues\n    }    \n    \n    $promptedValueList = @(($runbookPromptedVariables -Split \"`n\").Trim())\n    Write-OctopusInformation $promptedValueList.Length\n    \n    foreach($element in $runbookPreview.Form.Elements)\n    {\n    \t$nameToSearchFor = $element.Control.Name\n        $uniqueName = $element.Name\n        $isRequired = $element.Control.Required\n        \n        $promptedVariablefound = $false\n        \n        Write-OctopusInformation \"Looking for the prompted variable value for $nameToSearchFor\"\n    \tforeach ($promptedValue in $promptedValueList)\n        {\n        \t$splitValue = $promptedValue -Split \"::\"\n            Write-OctopusInformation \"Comparing $nameToSearchFor with provided prompted variable $($promptedValue[0])\"\n            if ($splitValue.Length -gt 1)\n            {\n            \tif ($nameToSearchFor -eq $splitValue[0])\n                {\n                \tWrite-OctopusInformation \"Found the prompted variable value $nameToSearchFor\"\n                \t$runbookFormValues[$uniqueName] = $splitValue[1]\n                    $promptedVariableFound = $true\n                    break\n                }\n            }\n        }\n        \n        if ($promptedVariableFound -eq $false -and $isRequired -eq $true)\n        {\n        \tWrite-OctopusCritical \"Unable to find a value for the required prompted variable $nameToSearchFor, exiting\"\n            Exit 1\n        }\n    }\n\n    return $runbookFormValues\n}\n\nfunction Invoke-OctopusDeployRunbook\n{\n    param (\n        $runbookBody,\n        $runbookWaitForFinish,\n        $runbookCancelInSeconds,\n        $projectNameForUrl,        \n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentTaskApprovers,\n        $autoApproveRunbookRunManualInterventions,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $approvalEnvironmentName,\n        $parentRunbookId,\n        $parentTaskId\n    )\n\n    $runbookResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -item $runbookBody -method \"POST\" -endPoint \"runbookRuns\"\n\n    $runbookServerTaskId = $runBookResponse.TaskId\n    Write-OctopusInformation \"The task id of the new task is $runbookServerTaskId\"\n\n    $runbookRunId = $runbookResponse.Id\n    Write-OctopusInformation \"The runbook run id is $runbookRunId\"\n\n    Write-OctopusSuccess \"Runbook was successfully invoked, you can access the launched runbook [here]($defaultUrl/app#/$spaceId/projects/$projectNameForUrl/operations/runbooks/$($runbookBody.RunbookId)/snapshots/$($runbookBody.RunbookSnapShotId)/runs/$runbookRunId)\"\n\n    if ($runbookWaitForFinish -eq $false)\n    {\n        Write-OctopusInformation \"The wait for finish setting is set to no, exiting step\"\n        return\n    }\n    \n    if ($null -ne $runbookBody.QueueTime)\n    {\n    \tWrite-OctopusInformation \"The runbook queue time is set.  Exiting step\"\n        return\n    }\n\n    Write-OctopusSuccess \"The setting to wait for completion was set, waiting until task has finished\"\n    $startTime = Get-Date\n    $currentTime = Get-Date\n    $dateDifference = $currentTime - $startTime\n\t\n    $taskStatusUrl = \"tasks/$runbookServerTaskId\"\n    $numberOfWaits = 0    \n    \n    While ($dateDifference.TotalSeconds -lt $runbookCancelInSeconds)\n    {\n        Write-OctopusInformation \"Waiting 5 seconds to check status\"\n        Start-Sleep -Seconds 5\n        $taskStatusResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint $taskStatusUrl -method \"GET\" -item $null\n        $taskStatusResponseState = $taskStatusResponse.State\n\n        if ($taskStatusResponseState -eq \"Success\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of Success\"\n            exit 0            \n        }\n        elseif($taskStatusResponseState -eq \"Failed\" -or $taskStatusResponseState -eq \"Canceled\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of $taskStatusResponseState status, stopping the run/deployment\"\n            exit 1            \n        }\n        elseif($taskStatusResponse.HasPendingInterruptions -eq $true)\n        {\n            if ($autoApproveRunbookRunManualInterventions -eq \"Yes\")\n            {\n                Submit-RunbookRunForAutoApproval -createdRunbookRun $createdRunbookRun -parentTaskApprovers $parentTaskApprovers -defaultUrl $DefaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -parentProjectName $parentProjectName -parentReleaseNumber $parentReleaseNumber -parentEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $parentTaskId\n            }\n            else\n            {\n                if ($numberOfWaits -ge 10)\n                {\n                    Write-OctopusSuccess \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"\n                }\n                else\n                {\n                    Write-OctopusInformation \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"                        \n                }\n            }\n        }\n        \n        $numberOfWaits += 1\n        if ($numberOfWaits -ge 10)\n        {\n        \tWrite-OctopusSuccess \"The task state is currently $taskStatusResponseState\"\n        \t$numberOfWaits = 0\n        }\n        else\n        {\n        \tWrite-OctopusInformation \"The task state is currently $taskStatusResponseState\"\n        }  \n        \n        $startTime = $taskStatusResponse.StartTime\n        if ($startTime -eq $null -or [string]::IsNullOrWhiteSpace($startTime) -eq $true)\n        {        \n        \tWrite-OctopusInformation \"The task is still queued, let's wait a bit longer\"\n        \t$startTime = Get-Date\n        }\n        $startTime = [DateTime]$startTime\n        \n        $currentTime = Get-Date\n        $dateDifference = $currentTime - $startTime        \n    }\n    \n    Write-OctopusSuccess \"The cancel timeout has been reached, cancelling the runbook run\"\n    $cancelResponse = Invoke-RestMethod \"$runbookBaseUrl/api/tasks/$runbookServerTaskId/cancel\" -Headers $header -Method Post\n    Write-OctopusSuccess \"Exiting with an error code of 1 because we reached the timeout\"\n    exit 1\n}\n\nfunction Get-QueueDate\n{\n\tparam ( \n    \t$futureDeploymentDate\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($futureDeploymentDate) -or $futureDeploymentDate -eq \"N/A\")\n    {\n    \treturn $null\n    }\n    \n    [datetime]$outputDate = New-Object DateTime\n    $currentDate = Get-Date\n\n    if ([datetime]::TryParse($futureDeploymentDate, [ref]$outputDate) -eq $false)\n    {\n        Write-OctopusCritical \"The suppplied date $futureDeploymentDate cannot be parsed by DateTime.TryParse.  Please verify format and try again.  Please [refer to Microsoft's Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.datetime.tryparse) on supported formats.\"\n        exit 1\n    }\n    \n    if ($currentDate -gt $outputDate)\n    {\n    \tWrite-OctopusCritical \"The supplied date $futureDeploymentDate is set for the past.  All queued deployments must be in the future.\"\n        exit 1\n    }\n    \n    return $outputDate\n}\n\nfunction Get-QueueExpiryDate\n{\n\tparam (\n    \t$queueDate\n    )\n    \n    if ($null -eq $queueDate)\n    {\n    \treturn $null\n    }\n    \n    return $queueDate.AddHours(1)\n}\n\nfunction Get-RunbookSpecificMachines\n{\n    param (\n        $runbookPreview,\n        $runbookMachines,        \n        $runbookRunName        \n    )\n\n    if ($runbookMachines -eq \"N/A\")\n    {\n        return @()\n    }\n\n    if ([string]::IsNullOrWhiteSpace($runbookMachines) -eq $true)\n    {\n        return @()\n    }\n\n    $translatedList = Get-MachineIdsFromMachineNames -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -targetMachines $runbookMachines\n\n    $filteredList = @()    \n    foreach ($runbookMachine in $translatedList)\n    {    \t\n    \t$runbookMachineId = $runbookMachine.Trim().ToLower()\n    \tWrite-OctopusVerbose \"Checking if $runbookMachineId is set to run on any of the runbook steps\"\n        \n        foreach ($step in $runbookPreview.StepsToExecute)\n        {\n            foreach ($machine in $step.Machines)\n            {\n            \tWrite-OctopusVerbose \"Checking if $runbookMachineId matches $($machine.Id) and it isn't already in the $($filteredList -join \",\")\"\n                if ($runbookMachineId -eq $machine.Id.Trim().ToLower() -and $filteredList -notcontains $machine.Id)\n                {\n                \tWrite-OctopusInformation \"Adding $($machine.Id) to the list\"\n                    $filteredList += $machine.Id\n                }\n            }\n        }\n    }\n\n    if ($filteredList.Length -le 0)\n    {\n        Write-OctopusSuccess \"The current task is targeting specific machines, but the runbook $runBookRunName does not run against any of these machines $runbookMachines. Skipping this run.\"\n        exit 0\n    }\n\n    return $filteredList\n}\n\nfunction Get-ParentTaskApprovers\n{\n    param (\n        $parentTaskId,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n    \n    $approverList = @()\n    if ($null -eq $parentTaskId)\n    {\n    \tWrite-OctopusInformation \"The deployment task id to pull the approvers from is null, return an empty approver list\"\n    \treturn $approverList\n    }\n\n    Write-OctopusInformation \"Getting all the events from the parent project\"\n    $parentEvents = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"events?regardingAny=$parentTaskId\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"\n    \n    foreach ($parentEvent in $parentEvents.Items)\n    {\n        Write-OctopusVerbose \"Checking $($parentEvent.Message) for manual intervention\"\n        if ($parentEvent.Message -like \"Submitted interruption*\")\n        {\n            Write-OctopusVerbose \"The event $($parentEvent.Id) is a manual intervention approval event which was approved by $($parentEvent.Username).\"\n\n            $approverExists = $approverList | Where-Object {$_.Id -eq $parentEvent.UserId}        \n\n            if ($null -eq $approverExists)\n            {\n                $approverInformation = @{\n                    Id = $parentEvent.UserId;\n                    Username = $parentEvent.Username;\n                    Teams = @()\n                }\n\n                $approverInformation.Teams = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"teammembership?userId=$($approverInformation.Id)\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"            \n\n                Write-OctopusVerbose \"Adding $($approverInformation.Id) to the approval list\"\n                $approverList += $approverInformation\n            }        \n        }\n    }\n\n    return $approverList\n}\n\nfunction Get-ApprovalTaskIdFromDeployment\n{\n    param (\n        $parentReleaseId,\n        $approvalEnvironment,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n\n    $releaseDeploymentList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"releases/$parentReleaseId/deployments\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    \n    $lastDeploymentTime = $(Get-Date).AddYears(-50)\n    $approvalTaskId = $null\n    foreach ($deployment in $releaseDeploymentList.Items)\n    {\n        if ($deployment.EnvironmentId -ne $approvalEnvironment.Id)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) deployed to $($deployment.EnvironmentId) which doesn't match $($approvalEnvironment.Id).\"\n            continue\n        }\n        \n        Write-OctopusInformation \"The deployment $($deployment.Id) was deployed to the approval environment $($approvalEnvironment.Id).\"\n\n        $deploymentTask = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $null -endPoint \"tasks/$($deployment.TaskId)\" -apiKey $octopusApiKey -Method \"Get\"\n        if ($deploymentTask.IsCompleted -eq $true -and $deploymentTask.FinishedSuccessfully -eq $false)\n        {\n            Write-Information \"The deployment $($deployment.Id) was deployed to the approval environment, but it encountered a failure, moving onto the next deployment.\"\n            continue\n        }\n\n        if ($deploymentTask.StartTime -gt $lastDeploymentTime)\n        {\n            $approvalTaskId = $deploymentTask.Id\n            $lastDeploymentTime = $deploymentTask.StartTime\n        }\n    }        \n\n    if ($null -eq $approvalTaskId)\n    {\n    \tWrite-OctopusVerbose \"Unable to find a deployment to the environment, determining if it should've happened already.\"\n        $channelInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$parentChannelId\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n        $lifecycle = Get-OctopusLifeCycle -channel $channelInformation -defaultUrl $defaultUrl -spaceId $spaceId -OctopusApiKey $octopusApiKey\n        $lifecyclePhases = Get-LifecyclePhases -lifecycle $lifecycle -defaultUrl $defaultUrl -spaceId $spaceid -OctopusApiKey $octopusApiKey\n        \n        $foundDestinationFirst = $false\n        $foundApprovalFirst = $false\n        \n        foreach ($phase in $lifecyclePhases.Phases)\n        {\n        \tif ($phase.AutomaticDeploymentTargets -contains $parentEnvironmentId -or $phase.OptionalDeploymentTargets -contains $parentEnvironmentId)\n            {\n            \tif ($foundApprovalFirst -eq $false)\n                {\n                \t$foundDestinationFirst = $true\n                }\n            }\n            \n            if ($phase.AutomaticDeploymentTargets -contains $approvalEnvironment.Id -or $phase.OptionalDeploymentTargets -contains $approvalEnvironment.Id)\n            {\n            \tif ($foundDestinationFirst -eq $false)\n                {\n                \t$foundApprovalFirst = $true\n                }\n            }\n        }\n        \n        $messageToLog = \"Unable to find a deployment for the environment $approvalEnvironmentName.  Auto approvals are disabled.\"\n        if ($foundApprovalFirst -eq $true)\n        {\n        \tWrite-OctopusWarning $messageToLog\n        }\n        else\n        {\n        \tWrite-OctopusInformation $messageToLog\n        }\n        \n        return $null\n    }\n\n    return $approvalTaskId\n}\n\nfunction Get-ApprovalTaskIdFromRunbook\n{\n    param (\n        $parentRunbookId,\n        $approvalEnvironment,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n}\n\nfunction Get-ApprovalTaskId\n{\n\tparam (\n    \t$autoApproveRunbookRunManualInterventions,\n        $parentTaskId,\n        $parentReleaseId,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $approvalEnvironmentName,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey        \n    )\n    \n    if ($autoApproveRunbookRunManualInterventions -eq $false)\n    {\n    \tWrite-OctopusInformation \"Auto approvals are disabled, skipping pulling the approval deployment task id\"\n        return $null\n    }\n    \n    if ([string]::IsNullOrWhiteSpace($approvalEnvironmentName) -eq $true)\n    {\n    \tWrite-OctopusInformation \"Approval environment not supplied, using the current environment id for approvals.\"\n        return $parentTaskId\n    }\n    \n    if ($approvalEnvironmentName.ToLower().Trim() -eq $parentEnvironmentName.ToLower().Trim())\n    {\n        Write-OctopusInformation \"The approval environment is the same as the current environment, using the current task id $parentTaskId\"\n        return $parentTaskId\n    }\n    \n    $approvalEnvironment = Get-OctopusItemFromListEndpoint -itemNameToFind $approvalEnvironmentName -itemType \"Environment\" -defaultUrl $DefaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -defaultValue $null -endpoint \"environments\"\n    \n    if ([string]::IsNullOrWhiteSpace($parentReleaseId) -eq $false)\n    {\n        return Get-ApprovalTaskIdFromDeployment -parentReleaseId $parentReleaseId -approvalEnvironment $approvalEnvironment -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    return Get-ApprovalTaskIdFromRunbook -parentRunbookId $parentRunbookId -approvalEnvironment $approvalEnvironment -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n}\n\nfunction Get-OctopusLifecycle\n{\n    param (\n        $channel,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the lifecycle information $($channel.Name)\"\n    if ($null -eq $channel.LifecycleId)\n    {\n        $lifecycleName = \"Default Lifecycle\"\n        $lifecycleList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles?partialName=$([uri]::EscapeDataString($lifecycleName))\u0026skip=0\u0026take=1\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $lifecycle = $lifecycleList.Items[0]\n    }\n    else\n    {\n        $lifecycle = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($channel.LifecycleId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n    }\n\n    Write-Host \"Successfully found the lifecycle $($lifecycle.Name) to use for this channel.\"\n\n    return $lifecycle\n}\n\nfunction Get-LifecyclePhases\n{\n    param (\n        $lifecycle,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the phase in the lifecycle $($lifecycle.Name) with the environment $environmentName to find the previous phase.\"\n    if ($lifecycle.Phases.Count -eq 0)\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has no set phases, calling the preview endpoint.\"\n        $lifecyclePreview = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($lifecycle.Id)/preview\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $phases = $lifecyclePreview.Phases\n    }\n    else\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has set phases, using those.\"\n        $phases = $lifecycle.Phases    \n    }\n\n    Write-OctopusInformation \"Found $($phases.Length) phases in this lifecycle.\"\n    return $phases\n}\n\nfunction Submit-RunbookRunForAutoApproval\n{\n    param (\n        $createdRunbookRun,\n        $parentTaskApprovers,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $parentTaskId        \n    )\n\n    Write-OctopusSuccess \"The task has a pending manual intervention.  Checking parent approvals.\"    \n    $manualInterventionInformation = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions?regarding=$($createdRunbookRun.TaskId)\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    foreach ($manualIntervention in $manualInterventionInformation.Items)\n    {\n        if ($manualIntervention.IsPending -eq $false)\n        {\n            Write-OctopusInformation \"This manual intervention has already been approved.  Proceeding onto the next one.\"\n            continue\n        }\n\n        if ($manualIntervention.CanTakeResponsibility -eq $false)\n        {\n            Write-OctopusSuccess \"The user associated with the API key doesn't have permissions to take responsibility for the manual intervention.\"\n            Write-OctopusSuccess \"If you wish to leverage the auto-approval functionality give the user permissions.\"\n            continue\n        }        \n\n        $automaticApprover = $null\n        Write-OctopusVerbose \"Checking to see if one of the parent project approvers is assigned to one of the manual intervention teams $($manualIntervention.ResponsibleTeamIds)\"\n        foreach ($approver in $parentTaskApprovers)\n        {\n            foreach ($approverTeam in $approver.Teams)\n            {\n                Write-OctopusVerbose \"Checking to see if $($manualIntervention.ResponsibleTeamIds) contains $($approverTeam.TeamId)\"\n                if ($manualIntervention.ResponsibleTeamIds -contains $approverTeam.TeamId)\n                {\n                    $automaticApprover = $approver\n                    break\n                }\n            }\n\n            if ($null -ne $automaticApprover)\n            {\n                break\n            }\n        }\n\n        if ($null -ne $automaticApprover)\n        {\n        \tWrite-OctopusSuccess \"Matching approver found auto-approving.\"\n            if ($manualIntervention.HasResponsibility -eq $false)\n            {\n                Write-OctopusInformation \"Taking over responsibility for this manual intervention.\"\n                $takeResponsiblilityResponse = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/responsible\" -method \"PUT\" -apiKey $octopusApiKey -spaceId $spaceId\n                Write-OctopusVerbose \"Response from taking responsibility $($takeResponsiblilityResponse.Id)\"\n            }\n            \n            if ([string]::IsNullOrWhiteSpace($parentReleaseNumber) -eq $false)\n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName release $parentReleaseNumber to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that deployment $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n            else \n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName runbook run $parentRunbookId to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that runbook run $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n\n            $submitApprovalBody = @{\n                Instructions = $null;\n                Notes = $notes\n                Result = \"Proceed\"\n            }\n            $submitResult = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/submit\" -method \"POST\" -apiKey $octopusApiKey -item $submitApprovalBody -spaceId $spaceId\n            Write-OctopusSuccess \"Successfully auto approved the manual intervention $($submitResult.Id)\"\n        }\n        else\n        {\n            Write-OctopusSuccess \"Couldn't find an approver to auto-approve the child project.  Waiting until timeout or child project is approved.\"    \n        }\n    }\n}\n\n\n$runbookWaitForFinish = GetCheckboxBoolean -Value $runbookWaitForFinish\n$runbookUseGuidedFailure = GetCheckboxBoolean -Value $runbookUseGuidedFailure\n$runbookUsePublishedSnapshot = GetCheckboxBoolean -Value $runbookUsePublishedSnapshot\n$runbookCancelInSeconds = [int]$runbookCancelInSeconds\n\nWrite-OctopusInformation \"Wait for Finish Before Check: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure Before Check: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Use Published Snapshot Before Check: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Runbook Name $runbookRunName\"\nWrite-OctopusInformation \"Runbook Base Url: $runbookBaseUrl\"\nWrite-OctopusInformation \"Runbook Space Name: $runbookSpaceName\"\nWrite-OctopusInformation \"Runbook Environment Name: $runbookEnvironmentName\"\nWrite-OctopusInformation \"Runbook Tenant Name: $runbookTenantName\"\nWrite-OctopusInformation \"Wait for Finish: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Cancel run in seconds: $runbookCancelInSeconds\"\nWrite-OctopusInformation \"Use Published Snapshot: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Auto Approve Runbook Run Manual Interventions: $autoApproveRunbookRunManualInterventions\"\nWrite-OctopusInformation \"Auto Approve environment name to pull approvals from: $approvalEnvironmentName\"\n\nWrite-OctopusInformation \"Octopus runbook run machines: $runbookMachines\"\nWrite-OctopusInformation \"Parent Task Id: $parentTaskId\"\nWrite-OctopusInformation \"Parent Release Id: $parentReleaseId\"\nWrite-OctopusInformation \"Parent Channel Id: $parentChannelId\"\nWrite-OctopusInformation \"Parent Environment Id: $parentEnvironmentId\"\nWrite-OctopusInformation \"Parent Runbook Id: $parentRunbookId\"\nWrite-OctopusInformation \"Parent Environment Name: $parentEnvironmentName\"\nWrite-OctopusInformation \"Parent Release Number: $parentReleaseNumber\"\n\n$verificationPassed = @()\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookRunName -variableName \"Runbook Name\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookBaseUrl -variableName \"Base Url\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookApiKey -variableName \"Api Key\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookEnvironmentName -variableName \"Environment Name\"\n\nif ($verificationPassed -contains $false)\n{\n\tWrite-OctopusInformation \"Required values missing\"\n\tExit 1\n}\n\n$runbookSpace = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookSpaceName -endpoint \"spaces\" -spaceId $null -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl -itemType \"Space\" -defaultValue $octopusSpaceId\n$runbookSpaceId = $runbookSpace.Id\n\n$projectToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookProjectName -endpoint \"projects\" -spaceId $runbookSpaceId -defaultValue $null -itemType \"Project\" -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl\nif ($null -ne $projectToUse)\n{\t    \n    $runbookEndPoint = \"projects/$($projectToUse.Id)/runbooks\"\n}\nelse\n{\n\t$runbookEndPoint = \"runbooks\"\n}\n\n$environmentToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookEnvironmentName -itemType \"Environment\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -defaultValue $null -endpoint \"environments\"\n\n$runbookToRun = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookRunName -itemType \"Runbook\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -endpoint $runbookEndPoint -octopusApiKey $runbookApiKey -defaultValue $null\n\n$runbookSnapShotIdToUse = Get-RunbookSnapshotIdToRun -runbookToRun $runbookToRun -runbookUsePublishedSnapshot $runbookUsePublishedSnapshot -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $octopusSpaceId\n$projectNameForUrl = Get-ProjectSlug -projectToUse $projectToUse -runbookToRun $runbookToRun -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId\n\n$tenantToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookTenantName -itemType \"Tenant\" -defaultValue $null -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -endpoint \"tenants\" -defaultUrl $runbookBaseUrl\nif ($null -ne $tenantToUse)\n{\t\n    $tenantIdToUse = $tenantToUse.Id    \n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)/$($tenantIdToUse)\" -method \"GET\" -item $null\n}\nelse\n{\n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)\" -method \"GET\" -item $null\n}\n\n$childRunbookRunSpecificMachines = Get-RunbookSpecificMachines -runbookPreview $runBookPreview -runbookMachines $runbookMachines -runbookRunName $runbookRunName\n$runbookFormValues = Get-RunbookFormValues -runbookPreview $runBookPreview -runbookPromptedVariables $runbookPromptedVariables\n\n$queueDate = Get-QueueDate -futureDeploymentDate $runbookFutureDeploymentDate\n$queueExpiryDate = Get-QueueExpiryDate -queueDate $queueDate\n\n$runbookBody = @{\n    RunbookId = $($runbookToRun.Id);\n    RunbookSnapShotId = $runbookSnapShotIdToUse;\n    FrozenRunbookProcessId = $null;\n    EnvironmentId = $($environmentToUse.Id);\n    TenantId = $tenantIdToUse;\n    SkipActions = @();\n    QueueTime = $queueDate;\n    QueueTimeExpiry = $queueExpiryDate;\n    FormValues = $runbookFormValues;\n    ForcePackageDownload = $false;\n    ForcePackageRedeployment = $true;\n    UseGuidedFailure = $runbookUseGuidedFailure;\n    SpecificMachineIds = @($childRunbookRunSpecificMachines);\n    ExcludedMachineIds = @()\n}\n\n$approvalTaskId = Get-ApprovalTaskId -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentTaskId $parentTaskId -parentReleaseId $parentReleaseId -parentRunbookId $parentRunbookId -parentEnvironmentName $parentEnvironmentName -approvalEnvironmentName $approvalEnvironmentName -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey\n$parentTaskApprovers = Get-ParentTaskApprovers -parentTaskId $approvalTaskId -spaceId $runbookSpaceId -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey\n\nInvoke-OctopusDeployRunbook -runbookBody $runbookBody -runbookWaitForFinish $runbookWaitForFinish -runbookCancelInSeconds $runbookCancelInSeconds -projectNameForUrl $projectNameForUrl -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId -parentTaskApprovers $parentTaskApprovers -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentProjectName $projectNameForUrl -parentReleaseNumber $parentReleaseNumber -approvalEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $approvalTaskId"
        "Run.Runbook.Api.Key"                             = "#{DemoSpaceCreator.Octopus.APIKey}"
        "Run.Runbook.ManualIntervention.EnvironmentToUse" = "#{Octopus.Environment.Name}"
        "Run.Runbook.AutoApproveManualInterventions"      = "No"
        "Run.Runbook.Machines"                            = "N/A"
        "Run.Runbook.Tenant.Name"                         = "#{Octopus.Deployment.Tenant.Name}"
        "Octopus.Action.Script.Syntax"                    = "PowerShell"
        "Run.Runbook.Name"                                = "Add workers to tenant"
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
    name                = "Connect Tenant to AWS Infrastructure"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to AWS Infrastructure"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "Octopus.Action.RunOnServer"                  = "true"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Project.NameOrId"     = "AWS Infrastructure"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
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
    name                = "Add AWS worker to Space"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Add AWS worker to Space"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_windows.worker_pools[0].id}"
      properties                         = {
        "Run.Runbook.Machines"                            = "N/A"
        "Run.Runbook.Environment.Name"                    = "#{Octopus.Environment.Name}"
        "Run.Runbook.UsePublishedSnapShot"                = "True"
        "Run.Runbook.Tenant.Name"                         = "#{Octopus.Deployment.Tenant.Name}"
        "Run.Runbook.Api.Key"                             = "#{DemoSpaceCreator.Octopus.APIKey}"
        "Octopus.Action.Script.ScriptSource"              = "Inline"
        "Run.Runbook.Project.Name"                        = "AWS Infrastructure"
        "Run.Runbook.Base.Url"                            = "#{Octopus.Web.ServerUri}"
        "Run.Runbook.Space.Name"                          = "#{Octopus.Space.Name}"
        "Run.Runbook.AutoApproveManualInterventions"      = "No"
        "Octopus.Action.Script.ScriptBody"                = "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12\n\n# Octopus Variables\n$octopusSpaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n$parentTaskId = $OctopusParameters[\"Octopus.Task.Id\"]\n$parentReleaseId = $OctopusParameters[\"Octopus.Release.Id\"]\n$parentChannelId = $OctopusParameters[\"Octopus.Release.Channel.Id\"]\n$parentEnvironmentId = $OctopusParameters[\"Octopus.Environment.Id\"]\n$parentRunbookId = $OctopusParameters[\"Octopus.Runbook.Id\"]\n$parentEnvironmentName = $OctopusParameters[\"Octopus.Environment.Name\"]\n$parentReleaseNumber = $OctopusParameters[\"Octopus.Release.Number\"]\n\n# Step Template Parameters\n$runbookRunName = $OctopusParameters[\"Run.Runbook.Name\"]\n$runbookBaseUrl = $OctopusParameters[\"Run.Runbook.Base.Url\"]\n$runbookApiKey = $OctopusParameters[\"Run.Runbook.Api.Key\"]\n$runbookEnvironmentName = $OctopusParameters[\"Run.Runbook.Environment.Name\"]\n$runbookTenantName = $OctopusParameters[\"Run.Runbook.Tenant.Name\"]\n$runbookWaitForFinish = $OctopusParameters[\"Run.Runbook.Waitforfinish\"]\n$runbookUseGuidedFailure = $OctopusParameters[\"Run.Runbook.UseGuidedFailure\"]\n$runbookUsePublishedSnapshot = $OctopusParameters[\"Run.Runbook.UsePublishedSnapShot\"]\n$runbookPromptedVariables = $OctopusParameters[\"Run.Runbook.PromptedVariables\"]\n$runbookCancelInSeconds = $OctopusParameters[\"Run.Runbook.CancelInSeconds\"]\n$runbookProjectName = $OctopusParameters[\"Run.Runbook.Project.Name\"]\n\n$runbookSpaceName = $OctopusParameters[\"Run.Runbook.Space.Name\"]\n$runbookFutureDeploymentDate = $OctopusParameters[\"Run.Runbook.DateTime\"]\n$runbookMachines = $OctopusParameters[\"Run.Runbook.Machines\"]\n$autoApproveRunbookRunManualInterventions = $OctopusParameters[\"Run.Runbook.AutoApproveManualInterventions\"]\n$approvalEnvironmentName = $OctopusParameters[\"Run.Runbook.ManualIntervention.EnvironmentToUse\"]\n\nfunction Write-OctopusVerbose\n{\n    param($message)\n    \n    Write-Verbose $message  \n}\n\nfunction Write-OctopusInformation\n{\n    param($message)\n    \n    Write-Host $message  \n}\n\nfunction Write-OctopusSuccess\n{\n    param($message)\n\n    Write-Highlight $message \n}\n\nfunction Write-OctopusWarning\n{\n    param($message)\n\n    Write-Warning \"$message\" \n}\n\nfunction Write-OctopusCritical\n{\n    param ($message)\n\n    Write-Error \"$message\" \n}\n\nfunction Invoke-OctopusApi\n{\n    param\n    (\n        $octopusUrl,\n        $endPoint,\n        $spaceId,\n        $apiKey,\n        $method,\n        $item     \n    )\n\n    if ([string]::IsNullOrWhiteSpace($SpaceId))\n    {\n        $url = \"$OctopusUrl/api/$EndPoint\"\n    }\n    else\n    {\n        $url = \"$OctopusUrl/api/$spaceId/$EndPoint\"    \n    }  \n\n    try\n    {\n        if ($null -eq $item)\n        {\n            Write-Verbose \"No data to post or put, calling bog standard invoke-restmethod for $url\"\n            return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -ContentType 'application/json; charset=utf-8'\n        }\n\n        $body = $item | ConvertTo-Json -Depth 10\n        Write-Verbose $body\n\n        Write-Host \"Invoking $method $url\"\n        return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -Body $body -ContentType 'application/json; charset=utf-8'\n    }\n    catch\n    {\n        if ($null -ne $_.Exception.Response)\n        {\n            if ($_.Exception.Response.StatusCode -eq 401)\n            {\n                Write-Error \"Unauthorized error returned from $url, please verify API key and try again\"\n            }\n            elseif ($_.Exception.Response.statusCode -eq 403)\n            {\n                Write-Error \"Forbidden error returned from $url, please verify API key and try again\"\n            }\n            else\n            {                \n                Write-Error -Message \"Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )\"\n            }            \n        }\n        else\n        {\n            Write-Verbose $_.Exception\n        }\n    }\n\n    Throw \"There was an error calling the Octopus API please check the log for more details\"\n}\n\nfunction Test-RequiredValues\n{\n\tparam (\n    \t$variableToCheck,\n        $variableName\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($variableToCheck) -eq $true)\n    {\n    \tWrite-OctopusCritical \"$variableName is required.\"\n        return $false\n    }\n    \n    return $true\n}\n\nfunction GetCheckBoxBoolean\n{\n\tparam (\n    \t[string]$Value\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($value) -eq $true)\n    {\n    \treturn $false\n    }\n    \n    return $value -eq \"True\"\n}\n\nfunction Get-FilteredOctopusItem\n{\n    param(\n        $itemList,\n        $itemName\n    )\n\n    if ($itemList.Items.Count -eq 0)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        Exit 1\n    }  \n\n    $item = $itemList.Items | Where-Object { $_.Name -eq $itemName}      \n\n    if ($null -eq $item)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n    \n    if ($item -is [array])\n    {\n    \tWrite-OctopusCritical \"More than one item exists with the name $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n\n    return $item\n}\n\nfunction Get-OctopusItemFromListEndpoint\n{\n    param(\n        $endpoint,\n        $itemNameToFind,\n        $itemType,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $defaultValue\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($itemNameToFind))\n    {\n    \treturn $defaultValue\n    }\n    \n    Write-OctopusInformation \"Attempting to find $itemType with the name of $itemNameToFind\"\n    \n    $itemList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"$($endpoint)?partialName=$([uri]::EscapeDataString($itemNameToFind))\u0026skip=0\u0026take=100\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"    \n    $item = Get-FilteredOctopusItem -itemList $itemList -itemName $itemNameToFind\n\n    Write-OctopusInformation \"Successfully found $itemNameToFind with id of $($item.Id)\"\n\n    return $item\n}\n\nfunction Get-MachineIdsFromMachineNames\n{\n    param (\n        $targetMachines,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    $targetMachineList = $targetMachines -split \",\"\n    $translatedList = @()\n\n    foreach ($machineName in $targetMachineList)\n    {\n        Write-OctopusVerbose \"Translating $machineName to an Id.  First checking to see if it is already an Id.\"\n    \tif ($machineName.Trim() -like \"Machines*\")\n        {\n            Write-OctopusVerbose \"$machineName is already an Id, no need to look that up.\"\n        \t$translatedList += $machineName\n            continue\n        }\n        \n        $machineObject = Get-OctopusItemFromListEndpoint -itemNameToFind $machineName.Trim() -itemType \"Deployment Target\" -endpoint \"machines\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n\n        $translatedList += $machineObject.Id\n    }\n\n    return $translatedList\n}\n\nfunction Get-RunbookSnapshotIdToRun\n{\n    param (\n        $runbookToRun,\n        $runbookUsePublishedSnapshot,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $runbookSnapShotIdToUse = $runbookToRun.PublishedRunbookSnapshotId\n    Write-OctopusInformation \"The last published snapshot for $runbookRunName is $runbookSnapShotIdToUse\"\n\n    if ($null -eq $runbookSnapShotIdToUse -and $runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusCritical \"Use Published Snapshot was set; yet the runbook doesn't have a published snapshot.  Exiting.\"\n        Exit 1\n    }\n\n    if ($runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusInformation \"Use published snapshot set to true, using the published runbook snapshot.\"\n        return $runbookSnapShotIdToUse\n    }\n\n    if ($null -eq $runbookToRun.PublishedRunbookSnapshotId)\n    {\n        Write-OctopusInformation \"There have been no published runbook snapshots, going to create a new snapshot.\"\n        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    $runbookSnapShotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)/runbookRuns/template\" -method \"Get\" -item $null\n\n    if ($runbookSnapShotTemplate.IsRunbookProcessModified -eq $false -and $runbookSnapShotTemplate.IsVariableSetModified -eq $false -and $runbookSnapShotTemplate.IsLibraryVariableSetModified -eq $false)\n    {        \n        Write-OctopusInformation \"The runbook has not been modified since the published snapshot was created.  Checking to see if any of the packages have a new version.\"    \n        $runbookSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)\" -method \"Get\" -item $null\n        $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n        foreach ($package in $runbookSnapShot.SelectedPackages)\n        {\n            foreach ($templatePackage in $snapshotTemplate.Packages)\n            {\n                if ($package.StepName -eq $templatePackage.StepName -and $package.ActionName -eq $templatePackage.ActionName -and $package.PackageReferenceName -eq $templatePackage.PackageReferenceName)\n                {\n                    $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($templatePackage.FeedId)/packages/versions?packageId=$($templatePackage.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n                    if ($packageVersion -ne $package.Version)\n                    {\n                        Write-OctopusInformation \"A newer version of a package was found, going to use that and create a new snapshot.\"\n                        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId                    \n                    }\n                }\n            }\n        }\n\n        Write-OctopusInformation \"No new package versions have been found, using the published snapshot.\"\n        return $runbookToRun.PublishedRunbookSnapshotId\n    }\n    \n    Write-OctopusInformation \"The runbook has been modified since the snapshot was created, creating a new one.\"\n    return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n}\n\nfunction New-RunbookUnpublishedSnapshot\n{\n    param (\n        $runbookToRun,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $octopusProject = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"Get\" -item $null\n    $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n    $runbookPackages = @()\n    foreach ($package in $snapshotTemplate.Packages)\n    {\n        $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($package.FeedId)/packages/versions?packageId=$($package.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n        if ($packageVersion.TotalResults -le 0)\n        {\n            Write-Error \"Unable to find a package version for $($package.PackageId).  This is required to create a new unpublished snapshot.  Exiting.\"\n            exit 1\n        }\n\n        $runbookPackages += @{\n            StepName = $package.StepName\n            ActionName = $package.ActionName\n            Version = $packageVersion.Items[0].Version\n            PackageReferenceName = $package.PackageReferenceName\n        }\n    }\n\n    $runbookSnapShotRequest = @{\n        FrozenProjectVariableSetId = \"variableset-$($runbookToRun.ProjectId)\"\n        FrozenRunbookProcessId = $($runbookToRun.RunbookProcessId)\n        LibraryVariableSetSnapshotIds = @($octopusProject.IncludedLibraryVariableSetIds)\n        Name = $($snapshotTemplate.NextNameIncrement)\n        ProjectId = $($runbookToRun.ProjectId)\n        ProjectVariableSetSnapshotId = \"variableset-$($runbookToRun.ProjectId)\"\n        RunbookId = $($runbookToRun.Id)\n        SelectedPackages = $runbookPackages\n    }\n\n    $newSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots\" -method \"POST\" -item $runbookSnapShotRequest\n\n    return $($newSnapShot.Id)\n}\n\nfunction Get-ProjectSlug\n{\n    param\n    (\n        $runbookToRun,\n        $projectToUse,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    if ($null -ne $projectToUse)\n    {\n        return $projectToUse.Slug\n    }\n\n    $project = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"GET\" -item $null\n\n    return $project.Slug\n}\n\nfunction Get-RunbookFormValues\n{\n    param (\n        $runbookPreview,\n        $runbookPromptedVariables        \n    )\n\n    $runbookFormValues = @{}\n\n    if ([string]::IsNullOrWhiteSpace($runbookPromptedVariables) -eq $true)\n    {\n        return $runbookFormValues\n    }    \n    \n    $promptedValueList = @(($runbookPromptedVariables -Split \"`n\").Trim())\n    Write-OctopusInformation $promptedValueList.Length\n    \n    foreach($element in $runbookPreview.Form.Elements)\n    {\n    \t$nameToSearchFor = $element.Control.Name\n        $uniqueName = $element.Name\n        $isRequired = $element.Control.Required\n        \n        $promptedVariablefound = $false\n        \n        Write-OctopusInformation \"Looking for the prompted variable value for $nameToSearchFor\"\n    \tforeach ($promptedValue in $promptedValueList)\n        {\n        \t$splitValue = $promptedValue -Split \"::\"\n            Write-OctopusInformation \"Comparing $nameToSearchFor with provided prompted variable $($promptedValue[0])\"\n            if ($splitValue.Length -gt 1)\n            {\n            \tif ($nameToSearchFor -eq $splitValue[0])\n                {\n                \tWrite-OctopusInformation \"Found the prompted variable value $nameToSearchFor\"\n                \t$runbookFormValues[$uniqueName] = $splitValue[1]\n                    $promptedVariableFound = $true\n                    break\n                }\n            }\n        }\n        \n        if ($promptedVariableFound -eq $false -and $isRequired -eq $true)\n        {\n        \tWrite-OctopusCritical \"Unable to find a value for the required prompted variable $nameToSearchFor, exiting\"\n            Exit 1\n        }\n    }\n\n    return $runbookFormValues\n}\n\nfunction Invoke-OctopusDeployRunbook\n{\n    param (\n        $runbookBody,\n        $runbookWaitForFinish,\n        $runbookCancelInSeconds,\n        $projectNameForUrl,        \n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentTaskApprovers,\n        $autoApproveRunbookRunManualInterventions,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $approvalEnvironmentName,\n        $parentRunbookId,\n        $parentTaskId\n    )\n\n    $runbookResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -item $runbookBody -method \"POST\" -endPoint \"runbookRuns\"\n\n    $runbookServerTaskId = $runBookResponse.TaskId\n    Write-OctopusInformation \"The task id of the new task is $runbookServerTaskId\"\n\n    $runbookRunId = $runbookResponse.Id\n    Write-OctopusInformation \"The runbook run id is $runbookRunId\"\n\n    Write-OctopusSuccess \"Runbook was successfully invoked, you can access the launched runbook [here]($defaultUrl/app#/$spaceId/projects/$projectNameForUrl/operations/runbooks/$($runbookBody.RunbookId)/snapshots/$($runbookBody.RunbookSnapShotId)/runs/$runbookRunId)\"\n\n    if ($runbookWaitForFinish -eq $false)\n    {\n        Write-OctopusInformation \"The wait for finish setting is set to no, exiting step\"\n        return\n    }\n    \n    if ($null -ne $runbookBody.QueueTime)\n    {\n    \tWrite-OctopusInformation \"The runbook queue time is set.  Exiting step\"\n        return\n    }\n\n    Write-OctopusSuccess \"The setting to wait for completion was set, waiting until task has finished\"\n    $startTime = Get-Date\n    $currentTime = Get-Date\n    $dateDifference = $currentTime - $startTime\n\t\n    $taskStatusUrl = \"tasks/$runbookServerTaskId\"\n    $numberOfWaits = 0    \n    \n    While ($dateDifference.TotalSeconds -lt $runbookCancelInSeconds)\n    {\n        Write-OctopusInformation \"Waiting 5 seconds to check status\"\n        Start-Sleep -Seconds 5\n        $taskStatusResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint $taskStatusUrl -method \"GET\" -item $null\n        $taskStatusResponseState = $taskStatusResponse.State\n\n        if ($taskStatusResponseState -eq \"Success\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of Success\"\n            exit 0            \n        }\n        elseif($taskStatusResponseState -eq \"Failed\" -or $taskStatusResponseState -eq \"Canceled\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of $taskStatusResponseState status, stopping the run/deployment\"\n            exit 1            \n        }\n        elseif($taskStatusResponse.HasPendingInterruptions -eq $true)\n        {\n            if ($autoApproveRunbookRunManualInterventions -eq \"Yes\")\n            {\n                Submit-RunbookRunForAutoApproval -createdRunbookRun $createdRunbookRun -parentTaskApprovers $parentTaskApprovers -defaultUrl $DefaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -parentProjectName $parentProjectName -parentReleaseNumber $parentReleaseNumber -parentEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $parentTaskId\n            }\n            else\n            {\n                if ($numberOfWaits -ge 10)\n                {\n                    Write-OctopusSuccess \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"\n                }\n                else\n                {\n                    Write-OctopusInformation \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"                        \n                }\n            }\n        }\n        \n        $numberOfWaits += 1\n        if ($numberOfWaits -ge 10)\n        {\n        \tWrite-OctopusSuccess \"The task state is currently $taskStatusResponseState\"\n        \t$numberOfWaits = 0\n        }\n        else\n        {\n        \tWrite-OctopusInformation \"The task state is currently $taskStatusResponseState\"\n        }  \n        \n        $startTime = $taskStatusResponse.StartTime\n        if ($startTime -eq $null -or [string]::IsNullOrWhiteSpace($startTime) -eq $true)\n        {        \n        \tWrite-OctopusInformation \"The task is still queued, let's wait a bit longer\"\n        \t$startTime = Get-Date\n        }\n        $startTime = [DateTime]$startTime\n        \n        $currentTime = Get-Date\n        $dateDifference = $currentTime - $startTime        \n    }\n    \n    Write-OctopusSuccess \"The cancel timeout has been reached, cancelling the runbook run\"\n    $cancelResponse = Invoke-RestMethod \"$runbookBaseUrl/api/tasks/$runbookServerTaskId/cancel\" -Headers $header -Method Post\n    Write-OctopusSuccess \"Exiting with an error code of 1 because we reached the timeout\"\n    exit 1\n}\n\nfunction Get-QueueDate\n{\n\tparam ( \n    \t$futureDeploymentDate\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($futureDeploymentDate) -or $futureDeploymentDate -eq \"N/A\")\n    {\n    \treturn $null\n    }\n    \n    [datetime]$outputDate = New-Object DateTime\n    $currentDate = Get-Date\n\n    if ([datetime]::TryParse($futureDeploymentDate, [ref]$outputDate) -eq $false)\n    {\n        Write-OctopusCritical \"The suppplied date $futureDeploymentDate cannot be parsed by DateTime.TryParse.  Please verify format and try again.  Please [refer to Microsoft's Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.datetime.tryparse) on supported formats.\"\n        exit 1\n    }\n    \n    if ($currentDate -gt $outputDate)\n    {\n    \tWrite-OctopusCritical \"The supplied date $futureDeploymentDate is set for the past.  All queued deployments must be in the future.\"\n        exit 1\n    }\n    \n    return $outputDate\n}\n\nfunction Get-QueueExpiryDate\n{\n\tparam (\n    \t$queueDate\n    )\n    \n    if ($null -eq $queueDate)\n    {\n    \treturn $null\n    }\n    \n    return $queueDate.AddHours(1)\n}\n\nfunction Get-RunbookSpecificMachines\n{\n    param (\n        $runbookPreview,\n        $runbookMachines,        \n        $runbookRunName        \n    )\n\n    if ($runbookMachines -eq \"N/A\")\n    {\n        return @()\n    }\n\n    if ([string]::IsNullOrWhiteSpace($runbookMachines) -eq $true)\n    {\n        return @()\n    }\n\n    $translatedList = Get-MachineIdsFromMachineNames -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -targetMachines $runbookMachines\n\n    $filteredList = @()    \n    foreach ($runbookMachine in $translatedList)\n    {    \t\n    \t$runbookMachineId = $runbookMachine.Trim().ToLower()\n    \tWrite-OctopusVerbose \"Checking if $runbookMachineId is set to run on any of the runbook steps\"\n        \n        foreach ($step in $runbookPreview.StepsToExecute)\n        {\n            foreach ($machine in $step.Machines)\n            {\n            \tWrite-OctopusVerbose \"Checking if $runbookMachineId matches $($machine.Id) and it isn't already in the $($filteredList -join \",\")\"\n                if ($runbookMachineId -eq $machine.Id.Trim().ToLower() -and $filteredList -notcontains $machine.Id)\n                {\n                \tWrite-OctopusInformation \"Adding $($machine.Id) to the list\"\n                    $filteredList += $machine.Id\n                }\n            }\n        }\n    }\n\n    if ($filteredList.Length -le 0)\n    {\n        Write-OctopusSuccess \"The current task is targeting specific machines, but the runbook $runBookRunName does not run against any of these machines $runbookMachines. Skipping this run.\"\n        exit 0\n    }\n\n    return $filteredList\n}\n\nfunction Get-ParentTaskApprovers\n{\n    param (\n        $parentTaskId,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n    \n    $approverList = @()\n    if ($null -eq $parentTaskId)\n    {\n    \tWrite-OctopusInformation \"The deployment task id to pull the approvers from is null, return an empty approver list\"\n    \treturn $approverList\n    }\n\n    Write-OctopusInformation \"Getting all the events from the parent project\"\n    $parentEvents = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"events?regardingAny=$parentTaskId\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"\n    \n    foreach ($parentEvent in $parentEvents.Items)\n    {\n        Write-OctopusVerbose \"Checking $($parentEvent.Message) for manual intervention\"\n        if ($parentEvent.Message -like \"Submitted interruption*\")\n        {\n            Write-OctopusVerbose \"The event $($parentEvent.Id) is a manual intervention approval event which was approved by $($parentEvent.Username).\"\n\n            $approverExists = $approverList | Where-Object {$_.Id -eq $parentEvent.UserId}        \n\n            if ($null -eq $approverExists)\n            {\n                $approverInformation = @{\n                    Id = $parentEvent.UserId;\n                    Username = $parentEvent.Username;\n                    Teams = @()\n                }\n\n                $approverInformation.Teams = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"teammembership?userId=$($approverInformation.Id)\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"            \n\n                Write-OctopusVerbose \"Adding $($approverInformation.Id) to the approval list\"\n                $approverList += $approverInformation\n            }        \n        }\n    }\n\n    return $approverList\n}\n\nfunction Get-ApprovalTaskIdFromDeployment\n{\n    param (\n        $parentReleaseId,\n        $approvalEnvironment,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n\n    $releaseDeploymentList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"releases/$parentReleaseId/deployments\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    \n    $lastDeploymentTime = $(Get-Date).AddYears(-50)\n    $approvalTaskId = $null\n    foreach ($deployment in $releaseDeploymentList.Items)\n    {\n        if ($deployment.EnvironmentId -ne $approvalEnvironment.Id)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) deployed to $($deployment.EnvironmentId) which doesn't match $($approvalEnvironment.Id).\"\n            continue\n        }\n        \n        Write-OctopusInformation \"The deployment $($deployment.Id) was deployed to the approval environment $($approvalEnvironment.Id).\"\n\n        $deploymentTask = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $null -endPoint \"tasks/$($deployment.TaskId)\" -apiKey $octopusApiKey -Method \"Get\"\n        if ($deploymentTask.IsCompleted -eq $true -and $deploymentTask.FinishedSuccessfully -eq $false)\n        {\n            Write-Information \"The deployment $($deployment.Id) was deployed to the approval environment, but it encountered a failure, moving onto the next deployment.\"\n            continue\n        }\n\n        if ($deploymentTask.StartTime -gt $lastDeploymentTime)\n        {\n            $approvalTaskId = $deploymentTask.Id\n            $lastDeploymentTime = $deploymentTask.StartTime\n        }\n    }        \n\n    if ($null -eq $approvalTaskId)\n    {\n    \tWrite-OctopusVerbose \"Unable to find a deployment to the environment, determining if it should've happened already.\"\n        $channelInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$parentChannelId\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n        $lifecycle = Get-OctopusLifeCycle -channel $channelInformation -defaultUrl $defaultUrl -spaceId $spaceId -OctopusApiKey $octopusApiKey\n        $lifecyclePhases = Get-LifecyclePhases -lifecycle $lifecycle -defaultUrl $defaultUrl -spaceId $spaceid -OctopusApiKey $octopusApiKey\n        \n        $foundDestinationFirst = $false\n        $foundApprovalFirst = $false\n        \n        foreach ($phase in $lifecyclePhases.Phases)\n        {\n        \tif ($phase.AutomaticDeploymentTargets -contains $parentEnvironmentId -or $phase.OptionalDeploymentTargets -contains $parentEnvironmentId)\n            {\n            \tif ($foundApprovalFirst -eq $false)\n                {\n                \t$foundDestinationFirst = $true\n                }\n            }\n            \n            if ($phase.AutomaticDeploymentTargets -contains $approvalEnvironment.Id -or $phase.OptionalDeploymentTargets -contains $approvalEnvironment.Id)\n            {\n            \tif ($foundDestinationFirst -eq $false)\n                {\n                \t$foundApprovalFirst = $true\n                }\n            }\n        }\n        \n        $messageToLog = \"Unable to find a deployment for the environment $approvalEnvironmentName.  Auto approvals are disabled.\"\n        if ($foundApprovalFirst -eq $true)\n        {\n        \tWrite-OctopusWarning $messageToLog\n        }\n        else\n        {\n        \tWrite-OctopusInformation $messageToLog\n        }\n        \n        return $null\n    }\n\n    return $approvalTaskId\n}\n\nfunction Get-ApprovalTaskIdFromRunbook\n{\n    param (\n        $parentRunbookId,\n        $approvalEnvironment,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n}\n\nfunction Get-ApprovalTaskId\n{\n\tparam (\n    \t$autoApproveRunbookRunManualInterventions,\n        $parentTaskId,\n        $parentReleaseId,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $approvalEnvironmentName,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey        \n    )\n    \n    if ($autoApproveRunbookRunManualInterventions -eq $false)\n    {\n    \tWrite-OctopusInformation \"Auto approvals are disabled, skipping pulling the approval deployment task id\"\n        return $null\n    }\n    \n    if ([string]::IsNullOrWhiteSpace($approvalEnvironmentName) -eq $true)\n    {\n    \tWrite-OctopusInformation \"Approval environment not supplied, using the current environment id for approvals.\"\n        return $parentTaskId\n    }\n    \n    if ($approvalEnvironmentName.ToLower().Trim() -eq $parentEnvironmentName.ToLower().Trim())\n    {\n        Write-OctopusInformation \"The approval environment is the same as the current environment, using the current task id $parentTaskId\"\n        return $parentTaskId\n    }\n    \n    $approvalEnvironment = Get-OctopusItemFromListEndpoint -itemNameToFind $approvalEnvironmentName -itemType \"Environment\" -defaultUrl $DefaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -defaultValue $null -endpoint \"environments\"\n    \n    if ([string]::IsNullOrWhiteSpace($parentReleaseId) -eq $false)\n    {\n        return Get-ApprovalTaskIdFromDeployment -parentReleaseId $parentReleaseId -approvalEnvironment $approvalEnvironment -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    return Get-ApprovalTaskIdFromRunbook -parentRunbookId $parentRunbookId -approvalEnvironment $approvalEnvironment -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n}\n\nfunction Get-OctopusLifecycle\n{\n    param (\n        $channel,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the lifecycle information $($channel.Name)\"\n    if ($null -eq $channel.LifecycleId)\n    {\n        $lifecycleName = \"Default Lifecycle\"\n        $lifecycleList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles?partialName=$([uri]::EscapeDataString($lifecycleName))\u0026skip=0\u0026take=1\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $lifecycle = $lifecycleList.Items[0]\n    }\n    else\n    {\n        $lifecycle = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($channel.LifecycleId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n    }\n\n    Write-Host \"Successfully found the lifecycle $($lifecycle.Name) to use for this channel.\"\n\n    return $lifecycle\n}\n\nfunction Get-LifecyclePhases\n{\n    param (\n        $lifecycle,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the phase in the lifecycle $($lifecycle.Name) with the environment $environmentName to find the previous phase.\"\n    if ($lifecycle.Phases.Count -eq 0)\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has no set phases, calling the preview endpoint.\"\n        $lifecyclePreview = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($lifecycle.Id)/preview\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $phases = $lifecyclePreview.Phases\n    }\n    else\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has set phases, using those.\"\n        $phases = $lifecycle.Phases    \n    }\n\n    Write-OctopusInformation \"Found $($phases.Length) phases in this lifecycle.\"\n    return $phases\n}\n\nfunction Submit-RunbookRunForAutoApproval\n{\n    param (\n        $createdRunbookRun,\n        $parentTaskApprovers,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $parentTaskId        \n    )\n\n    Write-OctopusSuccess \"The task has a pending manual intervention.  Checking parent approvals.\"    \n    $manualInterventionInformation = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions?regarding=$($createdRunbookRun.TaskId)\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    foreach ($manualIntervention in $manualInterventionInformation.Items)\n    {\n        if ($manualIntervention.IsPending -eq $false)\n        {\n            Write-OctopusInformation \"This manual intervention has already been approved.  Proceeding onto the next one.\"\n            continue\n        }\n\n        if ($manualIntervention.CanTakeResponsibility -eq $false)\n        {\n            Write-OctopusSuccess \"The user associated with the API key doesn't have permissions to take responsibility for the manual intervention.\"\n            Write-OctopusSuccess \"If you wish to leverage the auto-approval functionality give the user permissions.\"\n            continue\n        }        \n\n        $automaticApprover = $null\n        Write-OctopusVerbose \"Checking to see if one of the parent project approvers is assigned to one of the manual intervention teams $($manualIntervention.ResponsibleTeamIds)\"\n        foreach ($approver in $parentTaskApprovers)\n        {\n            foreach ($approverTeam in $approver.Teams)\n            {\n                Write-OctopusVerbose \"Checking to see if $($manualIntervention.ResponsibleTeamIds) contains $($approverTeam.TeamId)\"\n                if ($manualIntervention.ResponsibleTeamIds -contains $approverTeam.TeamId)\n                {\n                    $automaticApprover = $approver\n                    break\n                }\n            }\n\n            if ($null -ne $automaticApprover)\n            {\n                break\n            }\n        }\n\n        if ($null -ne $automaticApprover)\n        {\n        \tWrite-OctopusSuccess \"Matching approver found auto-approving.\"\n            if ($manualIntervention.HasResponsibility -eq $false)\n            {\n                Write-OctopusInformation \"Taking over responsibility for this manual intervention.\"\n                $takeResponsiblilityResponse = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/responsible\" -method \"PUT\" -apiKey $octopusApiKey -spaceId $spaceId\n                Write-OctopusVerbose \"Response from taking responsibility $($takeResponsiblilityResponse.Id)\"\n            }\n            \n            if ([string]::IsNullOrWhiteSpace($parentReleaseNumber) -eq $false)\n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName release $parentReleaseNumber to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that deployment $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n            else \n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName runbook run $parentRunbookId to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that runbook run $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n\n            $submitApprovalBody = @{\n                Instructions = $null;\n                Notes = $notes\n                Result = \"Proceed\"\n            }\n            $submitResult = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/submit\" -method \"POST\" -apiKey $octopusApiKey -item $submitApprovalBody -spaceId $spaceId\n            Write-OctopusSuccess \"Successfully auto approved the manual intervention $($submitResult.Id)\"\n        }\n        else\n        {\n            Write-OctopusSuccess \"Couldn't find an approver to auto-approve the child project.  Waiting until timeout or child project is approved.\"    \n        }\n    }\n}\n\n\n$runbookWaitForFinish = GetCheckboxBoolean -Value $runbookWaitForFinish\n$runbookUseGuidedFailure = GetCheckboxBoolean -Value $runbookUseGuidedFailure\n$runbookUsePublishedSnapshot = GetCheckboxBoolean -Value $runbookUsePublishedSnapshot\n$runbookCancelInSeconds = [int]$runbookCancelInSeconds\n\nWrite-OctopusInformation \"Wait for Finish Before Check: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure Before Check: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Use Published Snapshot Before Check: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Runbook Name $runbookRunName\"\nWrite-OctopusInformation \"Runbook Base Url: $runbookBaseUrl\"\nWrite-OctopusInformation \"Runbook Space Name: $runbookSpaceName\"\nWrite-OctopusInformation \"Runbook Environment Name: $runbookEnvironmentName\"\nWrite-OctopusInformation \"Runbook Tenant Name: $runbookTenantName\"\nWrite-OctopusInformation \"Wait for Finish: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Cancel run in seconds: $runbookCancelInSeconds\"\nWrite-OctopusInformation \"Use Published Snapshot: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Auto Approve Runbook Run Manual Interventions: $autoApproveRunbookRunManualInterventions\"\nWrite-OctopusInformation \"Auto Approve environment name to pull approvals from: $approvalEnvironmentName\"\n\nWrite-OctopusInformation \"Octopus runbook run machines: $runbookMachines\"\nWrite-OctopusInformation \"Parent Task Id: $parentTaskId\"\nWrite-OctopusInformation \"Parent Release Id: $parentReleaseId\"\nWrite-OctopusInformation \"Parent Channel Id: $parentChannelId\"\nWrite-OctopusInformation \"Parent Environment Id: $parentEnvironmentId\"\nWrite-OctopusInformation \"Parent Runbook Id: $parentRunbookId\"\nWrite-OctopusInformation \"Parent Environment Name: $parentEnvironmentName\"\nWrite-OctopusInformation \"Parent Release Number: $parentReleaseNumber\"\n\n$verificationPassed = @()\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookRunName -variableName \"Runbook Name\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookBaseUrl -variableName \"Base Url\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookApiKey -variableName \"Api Key\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookEnvironmentName -variableName \"Environment Name\"\n\nif ($verificationPassed -contains $false)\n{\n\tWrite-OctopusInformation \"Required values missing\"\n\tExit 1\n}\n\n$runbookSpace = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookSpaceName -endpoint \"spaces\" -spaceId $null -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl -itemType \"Space\" -defaultValue $octopusSpaceId\n$runbookSpaceId = $runbookSpace.Id\n\n$projectToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookProjectName -endpoint \"projects\" -spaceId $runbookSpaceId -defaultValue $null -itemType \"Project\" -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl\nif ($null -ne $projectToUse)\n{\t    \n    $runbookEndPoint = \"projects/$($projectToUse.Id)/runbooks\"\n}\nelse\n{\n\t$runbookEndPoint = \"runbooks\"\n}\n\n$environmentToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookEnvironmentName -itemType \"Environment\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -defaultValue $null -endpoint \"environments\"\n\n$runbookToRun = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookRunName -itemType \"Runbook\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -endpoint $runbookEndPoint -octopusApiKey $runbookApiKey -defaultValue $null\n\n$runbookSnapShotIdToUse = Get-RunbookSnapshotIdToRun -runbookToRun $runbookToRun -runbookUsePublishedSnapshot $runbookUsePublishedSnapshot -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $octopusSpaceId\n$projectNameForUrl = Get-ProjectSlug -projectToUse $projectToUse -runbookToRun $runbookToRun -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId\n\n$tenantToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookTenantName -itemType \"Tenant\" -defaultValue $null -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -endpoint \"tenants\" -defaultUrl $runbookBaseUrl\nif ($null -ne $tenantToUse)\n{\t\n    $tenantIdToUse = $tenantToUse.Id    \n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)/$($tenantIdToUse)\" -method \"GET\" -item $null\n}\nelse\n{\n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)\" -method \"GET\" -item $null\n}\n\n$childRunbookRunSpecificMachines = Get-RunbookSpecificMachines -runbookPreview $runBookPreview -runbookMachines $runbookMachines -runbookRunName $runbookRunName\n$runbookFormValues = Get-RunbookFormValues -runbookPreview $runBookPreview -runbookPromptedVariables $runbookPromptedVariables\n\n$queueDate = Get-QueueDate -futureDeploymentDate $runbookFutureDeploymentDate\n$queueExpiryDate = Get-QueueExpiryDate -queueDate $queueDate\n\n$runbookBody = @{\n    RunbookId = $($runbookToRun.Id);\n    RunbookSnapShotId = $runbookSnapShotIdToUse;\n    FrozenRunbookProcessId = $null;\n    EnvironmentId = $($environmentToUse.Id);\n    TenantId = $tenantIdToUse;\n    SkipActions = @();\n    QueueTime = $queueDate;\n    QueueTimeExpiry = $queueExpiryDate;\n    FormValues = $runbookFormValues;\n    ForcePackageDownload = $false;\n    ForcePackageRedeployment = $true;\n    UseGuidedFailure = $runbookUseGuidedFailure;\n    SpecificMachineIds = @($childRunbookRunSpecificMachines);\n    ExcludedMachineIds = @()\n}\n\n$approvalTaskId = Get-ApprovalTaskId -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentTaskId $parentTaskId -parentReleaseId $parentReleaseId -parentRunbookId $parentRunbookId -parentEnvironmentName $parentEnvironmentName -approvalEnvironmentName $approvalEnvironmentName -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey\n$parentTaskApprovers = Get-ParentTaskApprovers -parentTaskId $approvalTaskId -spaceId $runbookSpaceId -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey\n\nInvoke-OctopusDeployRunbook -runbookBody $runbookBody -runbookWaitForFinish $runbookWaitForFinish -runbookCancelInSeconds $runbookCancelInSeconds -projectNameForUrl $projectNameForUrl -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId -parentTaskApprovers $parentTaskApprovers -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentProjectName $projectNameForUrl -parentReleaseNumber $parentReleaseNumber -approvalEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $approvalTaskId"
        "Run.Runbook.Waitforfinish"                       = "True"
        "Octopus.Action.Script.Syntax"                    = "PowerShell"
        "Run.Runbook.CancelInSeconds"                     = "1800"
        "Run.Runbook.Name"                                = "Add workers to tenant"
        "Run.Runbook.ManualIntervention.EnvironmentToUse" = "#{Octopus.Environment.Name}"
        "Run.Runbook.DateTime"                            = "N/A"
        "Octopus.Action.RunOnServer"                      = "true"
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
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateOctoFXDemo}#{/unless}"
    name                 = "Connect Tenant to OctoFX Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to OctoFX Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "ConnectTenantToProject.Project.NameOrId"     = "OctoFX Template"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "Octopus.Action.RunOnServer"                  = "true"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateOctoFXDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateOctoFXDemo}#{/unless}"
    name                 = "Deploy OctoFX Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy OctoFX Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-486"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_octofx_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateOctoFXDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateTenantsDemo}#{/unless}"
    name                 = "Connect Tenant to Tenants Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to Tenants Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "ConnectTenantToProject.Project.NameOrId"     = "Tenants Template"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "Octopus.Action.RunOnServer"                  = "true"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateTenantsDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateTenantsDemo}#{/unless}"
    name                 = "Deploy Tenants Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy Tenants Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-503"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_tenants_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateTenantsDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateKubernetesDemo}#{/unless}"
    name                 = "Connect Tenant to Kubernetes Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to Kubernetes Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "ConnectTenantToProject.Project.NameOrId"     = "Kubernetes Template"
        "Octopus.Action.RunOnServer"                  = "true"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateKubernetesDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateKubernetesDemo}#{/unless}"
    name                 = "Deploy Kubernetes Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy Kubernetes Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-626"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_kubernetes_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateKubernetesDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateHelmDemo}#{/unless}"
    name                 = "Connect Tenant to Helm Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to Helm Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "Octopus.Action.RunOnServer"                  = "true"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Project.NameOrId"     = "Helm Template"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateHelmDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateHelmDemo}#{/unless}"
    name                 = "Deploy Helm Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy Helm Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-1001"
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_helm_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateHelmDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateECSDemo}#{/unless}"
    name                 = "Connect Tenant to ECS Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to ECS Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "Octopus.Action.RunOnServer"                  = "true"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "ConnectTenantToProject.Project.NameOrId"     = "ECS Template"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateECSDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateECSDemo}#{/unless}"
    name                 = "Deploy ECS Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy ECS Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-1331"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_ecs_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateECSDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateServiceNowDemo}#{/unless}"
    name                 = "Connect Tenant to ServiceNow Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to ServiceNow Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Project.NameOrId"     = "ServiceNow Template"
        "Octopus.Action.RunOnServer"                  = "true"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateServiceNowDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateServiceNowDemo}#{/unless}"
    name                 = "Deploy ServiceNow Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy ServiceNow Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-802"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_servicenow_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateServiceNowDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateJSMDemo}#{/unless}"
    name                 = "Connect Tenant to JSM Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to JSM Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "Octopus.Action.RunOnServer"                  = "true"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "ConnectTenantToProject.Project.NameOrId"     = "JSM Template"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateJSMDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateJSMDemo}#{/unless}"
    name                 = "Deploy JSM Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy JSM Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-1642"
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_jsm_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateJSMDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateLambdaDemo}#{/unless}"
    name                 = "Connect Tenant to Lambda"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to Lambda"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
        "Octopus.Action.RunOnServer"                  = "true"
        "ConnectTenantToProject.Project.NameOrId"     = "Lambda Template"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateLambdaDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateLambdaDemo}#{/unless}"
    name                 = "Deploy Lambda"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy Lambda"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-2353"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_lambda_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreateLambdaDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreatePOSDemo}#{/unless}"
    name                 = "Connect Tenant to POS Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Connect Tenant to POS Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "ConnectTenantToProject.Project.NameOrId"     = "Point of Sale Template"
        "ConnectTenantToProject.Environment.NameOrId" = "#{Octopus.Environment.Id}"
        "Octopus.Action.RunOnServer"                  = "true"
        "Octopus.Action.Script.ScriptSource"          = "Inline"
        "ConnectTenantToProject.Tenant.NameOrId"      = "#{Octopus.Deployment.Tenant.Id}"
        "Octopus.Action.Script.ScriptBody"            = "$ErrorActionPreference = \"Stop\";\n\n$octopusURL = $OctopusParameters[\"ConnectTenantToProject.Octopus.ServerUri\"]\n$octopusAPIKey = $OctopusParameters[\"ConnectTenantToProject.Octopus.ApiKey\"]\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$spaceId = $OctopusParameters[\"ConnectTenantToProject.Space.NameOrId\"]\n$tenantId = $OctopusParameters[\"ConnectTenantToProject.Tenant.NameOrId\"]\n$projectId = $OctopusParameters[\"ConnectTenantToProject.Project.NameOrId\"]\n$environmentId = $OctopusParameters[\"ConnectTenantToProject.Environment.NameOrId\"]\n\n# Get Space\nif ($spaceId -notmatch 'Spaces-\\d+') {\n  Write-Verbose \"Searching for space '$spaceId'\"\n  $spacesSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/spaces?partialName=$spaceId\" -Headers $header)\n  $space = $spacesSearch.Items | Select-Object -First 1\n  $spaceId = $space.Id\n}\n\n# Get Tenant\nif ($tenantId -notmatch 'Tenants-\\d+') {\n  Write-Verbose \"Searching for tenant '$tenantId'\"\n  $tenantsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants?name=$tenantId\" -Headers $header)\n  $tenant = $tenantsSearch.Items | Select-Object -First 1\n  $tenantId = $tenant.Id\n} else {\n  $tenant = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header)\n}\n\n# Get Project\nif ($projectId -notmatch 'Projects-\\d+') {\n  Write-Verbose \"Searching for project '$projectId'\"\n  $projectsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/projects?partialName=$projectId\" -Headers $header)\n  $project = $projectsSearch.Items | Select-Object -First 1\n  $projectId = $project.Id\n}\n\n# Get Environment\nif ($environmentId -notmatch 'Environments-\\d+') {\n  Write-Verbose \"Searching for environment '$environmentId'\"\n  $environmentsSearch = (Invoke-RestMethod -Method Get -Uri \"$octopusURL/api/$spaceId/environments?partialName=$environmentId\" -Headers $header)\n  $environment = $environmentsSearch.Items | Select-Object -First 1\n  $environmentId = $environment.Id\n}\n\nif ($tenant.ProjectEnvironments.$projectId -eq $null) {\n\t$tenant.ProjectEnvironments | Add-Member -Name $projectId -Value @($environmentId) -MemberType NoteProperty\n}\n\n$json = $tenant | ConvertTo-Json -Depth 10\nWrite-Verbose $json\n\nInvoke-RestMethod -Method Put -Uri \"$octopusURL/api/$spaceId/tenants/$tenantId\" -Headers $header -Body $json | Out-Null"
        "ConnectTenantToProject.Space.NameOrId"       = "#{Octopus.Space.Id}"
        "ConnectTenantToProject.Octopus.ApiKey"       = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ConnectTenantToProject.Octopus.ServerUri"    = "#{Octopus.Web.ServerUri}"
        "Octopus.Action.Script.Syntax"                = "PowerShell"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreatePOSDemo}#{/unless}"
    }
    target_roles = []
  }
  step {
    condition            = "Variable"
    condition_expression = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreatePOSDemo}#{/unless}"
    name                 = "Deploy POS Template"
    package_requirement  = "LetOctopusDecide"
    start_trigger        = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.DeployRelease"
      name                               = "Deploy POS Template"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.DeployRelease.DeploymentCondition" = "Always"
        "Octopus.Action.DeployRelease.ProjectId"           = "Projects-2889"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_demo_space_creator_step_deploy_pos_template_packageid}"
        acquisition_location = "NotAcquired"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server_releases__built_in_.feeds[0].id}"
        properties           = {}
      }

      features = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.Prompts.CreatePOSDemo}#{/unless}"
    }
    target_roles = []
  }
  depends_on = []
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "Robert van Haaren demo space"
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "not set"
}

variable "demo_space_creator_demospacecreator_createtenant_snowclientsecret_1" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable DemoSpaceCreator.CreateTenant.SNOWClientSecret"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_snowclientsecret_1" {
  owner_id        = "${octopusdeploy_project.project_demo_space_creator.id}"
  name            = "DemoSpaceCreator.CreateTenant.SNOWClientSecret"
  type            = "Sensitive"
  description     = "The client secret to use when connecting to the ServiceNow instance."
  sensitive_value = "${var.demo_space_creator_demospacecreator_createtenant_snowclientsecret_1}"
  is_sensitive    = true

  prompt {
    description = "The client secret to use when connecting to the ServiceNow instance."
    label       = "5.3: ServiceNow Client Secret"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
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

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

data "octopusdeploy_library_variable_sets" "library_variable_set_servicenow" {
  ids          = null
  partial_name = "ServiceNow"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a library variable set called \"ServiceNow\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.library_variable_sets) != 0
    }
  }
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "adamoctoclose"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "itsm"
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant" "tenant_tony_kelly" {
  name        = "Tony Kelly"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Product", "State/Created"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_product,
    octopusdeploy_tag.tag_created, octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role,
    octopusdeploy_tag_set.tagset_state
  ]
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_canary" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_canary.id}"
  value                   = "Canary deployment example space"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "OctoPetShop - Lambda"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "https://dev225540.service-now.com"
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_mark_lamprecht" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value          = "True"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "False"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "admin"
}

variable "demo_space_creator_demospacecreator_createtenant_snowserviceaccountuserpassword_1" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable DemoSpaceCreator.CreateTenant.SNOWServiceAccountUserPassword"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_snowserviceaccountuserpassword_1" {
  owner_id        = "${octopusdeploy_project.project_demo_space_creator.id}"
  name            = "DemoSpaceCreator.CreateTenant.SNOWServiceAccountUserPassword"
  type            = "Sensitive"
  description     = "The service account user password to use when connecting to the ServiceNow instance."
  sensitive_value = "${var.demo_space_creator_demospacecreator_createtenant_snowserviceaccountuserpassword_1}"
  is_sensitive    = true

  prompt {
    description = "The service account user password to use when connecting to the ServiceNow instance."
    label       = "5.5: ServiceNow Service Account User Password"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "octopus-enterprise"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "Describe the demo space"
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

variable "demo_space_creator_demospacecreator_prompts_createhelmdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateHelmDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createhelmdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createhelmdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateHelmDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "06.  Create Helm Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "https://dev112958.service-now.com/"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_james_c" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_james_c.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = ""
}

resource "octopusdeploy_tenant" "tenant_k8s_demo___mark_l" {
  name        = "K8s demo - Mark L"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer
  ]
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = "https://dev121719.service-now.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_james_c" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_james_c.id}"
  value                   = "james.chatmas@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = ""
}

variable "demo_space_creator_demospacecreator_createtenant_githubusername_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.GitHubUsername"
  default     = "not set"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_githubusername_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_githubusername_1}"
  name         = "DemoSpaceCreator.CreateTenant.GitHubUsername"
  type         = "String"
  description  = "The GitHub username to use when configuring projects with Config as Code."
  is_sensitive = false

  prompt {
    description = "The GitHub username to use when configuring projects with Config as Code."
    label       = "3.1: GitHub Username"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

variable "demo_space_creator_demospacecreator_createtenant_clonedtenantid_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.ClonedTenantId"
  default     = "#{Octopus.Action[Clone template tenant].Output.TenantId}"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_clonedtenantid_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_clonedtenantid_1}"
  name         = "DemoSpaceCreator.CreateTenant.ClonedTenantId"
  type         = "String"
  is_sensitive = false
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_ryan_s_sandbox" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value                   = "ryan.rousseau@octopus.com\nmatthew.casperson@octopus.com"
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = "mcasperson"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "itsm"
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "ITSM sample space"
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

variable "demo_space_creator_demospacecreator_prompts_createposdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreatePOSDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createposdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createposdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreatePOSDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "11. Create POS Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_chris_fraser" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_chris_fraser.id}"
  value                   = "Chris' demo space"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mike_nguyen" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mike_nguyen.id}"
  value                   = "mike.nguyen@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = "adamoctoclose"
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

terraform {

  required_providers {
    octopusdeploy = { source = "OctopusDeployLabs/octopusdeploy", version = "0.14.9" }
  }
  required_version = ">= 1.6.0"
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "Adam Close Demo Space"
}

resource "octopusdeploy_tenant" "tenant_github_universe_test" {
  name        = "GitHub Universe Test"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer
  ]
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "Adam close"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_shawn_sesna" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_shawn_sesna.id}"
  value                   = "PetClinic"
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "JChatmasOctopus"
}

resource "octopusdeploy_tenant" "tenant_robert_van_haaren" {
  name        = "Robert van Haaren"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Product", "State/Created"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_product, octopusdeploy_tag.tag_created
  ]
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_insights" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_insights.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "octopus"
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = ""
}

variable "demo_space_creator_demospacecreator_prompts_createlambdademo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateLambdaDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createlambdademo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createlambdademo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateLambdaDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "10. Create Lambda Demo?"
    is_required = true

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "False"
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "False"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

variable "demo_space_creator_demospacecreator_createtenant_jsmbaseurl_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.JSMBaseUrl"
  default     = "not set"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_jsmbaseurl_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_jsmbaseurl_1}"
  name         = "DemoSpaceCreator.CreateTenant.JSMBaseUrl"
  type         = "String"
  description  = "The URL used to access the JSM instance."
  is_sensitive = false

  prompt {
    description = "The URL used to access the JSM instance."
    label       = "4.1: JSM Base Url"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_iis_and_sql" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_iis_and_sql.id}"
  value                   = "Demo Space for IIS and SQL deployments"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

variable "demo_space_creator_demospacecreator_prompts_createjsmdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateJSMDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createjsmdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createjsmdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateJSMDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "09. Create JSM Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "https://stormer.atlassian.net"
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "ITSM sample space"
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "Describe the demo space"
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "james.chatmas@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_james_c" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_james_c.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_shawn_sesna" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_shawn_sesna.id}"
  value                   = "https://shawnsesna.atlassian.net/"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "tony.kelly@octopus.com"
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

variable "demo_space_creator_demospacecreator_createtenant_deployeverything_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.DeployEverything"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_deployeverything_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_deployeverything_1}"
  name         = "DemoSpaceCreator.CreateTenant.DeployEverything"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.1: Create space and deploy templates right now?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

variable "demo_space_creator_demospacecreator_createtenant_spacedescription_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.SpaceDescription"
  default     = "Describe the demo space"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_spacedescription_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_spacedescription_1}"
  name         = "DemoSpaceCreator.CreateTenant.SpaceDescription"
  type         = "String"
  description  = "The description to use when creating the space."
  is_sensitive = false

  prompt {
    description = "The description to use when creating the space."
    label       = "1.3: Space Description"
    is_required = true

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant" "tenant_mark_h___enterprise" {
  name        = "Mark H - Enterprise"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created",
    "Options/Run Daily Deployments", "Options/Dev and QA Teams", "Options/Shared Access", "Region/EMEA",
    "Active Projects/OctoFX Template", "Active Projects/Tenants Template", "Active Projects/Kubernetes Template",
    "Active Projects/ECS Template", "Active Projects/ServiceNow Template", "Active Projects/Lambda Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_emea, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_shared_access,
    octopusdeploy_tag.tag_dev_and_qa_teams, octopusdeploy_tag.tag_ecs_template,
    octopusdeploy_tag.tag_kubernetes_template, octopusdeploy_tag.tag_lambda_template,
    octopusdeploy_tag.tag_octofx_template, octopusdeploy_tag.tag_servicenow_template,
    octopusdeploy_tag.tag_tenants_template
  ]
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "OctoPetShop - Lambda"
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_mark_lamprecht" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value          = "False"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "OctoFX"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "Redgate Summit Space"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = ""
}

resource "octopusdeploy_tenant" "tenant_rob_pearson" {
  name        = "Rob Pearson"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "Region/APAC", "State/Created",
    "Options/Run Daily Deployments", "Options/Do Not Delete"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer,
    octopusdeploy_tag.tag_apac, octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_run_daily_deployments,
    octopusdeploy_tag.tag_do_not_delete, octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role,
    octopusdeploy_tag_set.tagset_region, octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options
  ]
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

variable "demo_space_creator_demospacecreator_createtenant_createhelmdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateHelmDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createhelmdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createhelmdemo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateHelmDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.5: Create Helm Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "Marketing demo space"
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant" "tenant_tenant_design" {
  name        = "Tenant Design"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer,
    octopusdeploy_tag.tag_created
  ]
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant" "tenant_redgate_summit" {
  name        = "Redgate Summit"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created", "Region/NA",
    "Options/Do Not Delete", "Options/Run Daily Deployments", "Options/Dev and QA Teams",
    "Active Projects/Lambda Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_do_not_delete,
    octopusdeploy_tag.tag_dev_and_qa_teams, octopusdeploy_tag.tag_lambda_template
  ]
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

variable "demo_space_creator_demospacecreator_createtenant_createjsmdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateJSMDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createjsmdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createjsmdemo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateJSMDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.8: Create JSM Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "#{Tenant.User.Name}'s Demo Space"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "False"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

variable "demo_space_creator_demospacecreator_prompts_createtenantsdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateTenantsDemo"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createtenantsdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createtenantsdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateTenantsDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "04. Create Tenants Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "octocrock"
}

resource "octopusdeploy_tenant" "tenant_canary" {
  name        = "Canary"
  description = "Canary deployment example space"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "State/Created", "Region/NA", "Role/Feature", "Options/Do Not Delete",
    "Options/Shared Access"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_feature, octopusdeploy_tag.tag_na,
    octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_do_not_delete, octopusdeploy_tag.tag_shared_access,
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options
  ]
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant" "tenant_meghan_mattingly" {
  name        = "Meghan Mattingly"
  description = "Trying "
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Account Executive", "State/Created"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_account_executive,
    octopusdeploy_tag.tag_created
  ]
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "markocto"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "mark.harrison@octopus.com"
}

data "octopusdeploy_library_variable_sets" "library_variable_set_jira_service_management" {
  ids          = null
  partial_name = "Jira Service Management"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a library variable set called \"Jira Service Management\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.library_variable_sets) != 0
    }
  }
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "Mark H's Enterprise space"
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "mark.lamprecht"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "demo.kubeconeu.octopus.app"
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

variable "demo_space_creator_demospacecreator_exporttask_spaceid_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.ExportTask.SpaceId"
  default     = "Spaces-178"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_exporttask_spaceid_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_exporttask_spaceid_1}"
  name         = "DemoSpaceCreator.ExportTask.SpaceId"
  type         = "String"
  is_sensitive = false
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_ryan_s_sandbox" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value                   = "For testing demo space creator"
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_ryan_s_sandbox" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "octopus.SNOW"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "https://dev190932.service-now.com/"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_kubecon" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_kubecon.id}"
  value          = "True"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mike_nguyen" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mike_nguyen.id}"
  value                   = "Mike Nguyen's demo space"
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "ea19ae94ead211109ea84047dc17d4dc"
}

variable "runbook_demo_space_creator_quick_delete_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Quick delete"
  default     = "Quick delete"
}
resource "octopusdeploy_runbook" "runbook_demo_space_creator_quick_delete" {
  name                        = "${var.runbook_demo_space_creator_quick_delete_name}"
  project_id                  = "${octopusdeploy_project.project_demo_space_creator.id}"
  environment_scope           = "All"
  environments                = []
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "**Action**: Delete a demo tenant and space.\n\n**Affects**: Everyone."
  multi_tenancy_mode          = "Tenanted"

  retention_policy {
    quantity_to_keep    = 100
    should_keep_forever = false
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "james.chatmas@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = "https://dev213984.service-now.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

variable "demo_space_creator_demospacecreator_createtenant_tenantrole_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.TenantRole"
  default     = "Role/Solutions Engineer"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_tenantrole_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_tenantrole_1}"
  name         = "DemoSpaceCreator.CreateTenant.TenantRole"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "1.4: Tenant Role"
    is_required = false

    display_settings {
      control_type = "Select"

      select_option {
        display_name = "Role/Account Executive"
        value        = "Account Executive"
      }
      select_option {
        display_name = "Role/Conference"
        value        = "Conference"
      }
      select_option {
        display_name = "Role/CSM"
        value        = "CSM"
      }
      select_option {
        display_name = "Role/Engineering"
        value        = "Engineering"
      }
      select_option {
        display_name = "Role/Feature"
        value        = "Feature"
      }
      select_option {
        display_name = "Role/Product"
        value        = "Product"
      }
      select_option {
        display_name = "Role/SDR"
        value        = "SDR"
      }
      select_option {
        display_name = "Role/Solutions Engineer"
        value        = "Solutions Engineer"
      }
      select_option {
        display_name = "Role/TAM"
        value        = "TAM"
      }
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "James' demo space"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant" "tenant_white_rock_global" {
  name        = "White Rock Global"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "Region/NA", "State/Created",
    "Options/Do Not Delete", "Options/Run Daily Deployments", "Options/Dev and QA Teams"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_na,
    octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_do_not_delete,
    octopusdeploy_tag.tag_dev_and_qa_teams
  ]
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "not set"
}

variable "demo_space_creator_demospacecreator_createtenant_useremail_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.UserEmail"
  default     = "#{Octopus.Deployment.CreatedBy.EmailAddress}"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_useremail_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_useremail_1}"
  name         = "DemoSpaceCreator.CreateTenant.UserEmail"
  type         = "String"
  description  = "The email address of this tenant's owner(s).  This can be multiple email addresses (one per line). Each address must be a valid email address mapped to a user account."
  is_sensitive = false

  prompt {
    description = "The email address of this tenant's owner(s).  This can be multiple email addresses (one per line). Each address must be a valid email address mapped to a user account."
    label       = "1.2: User Email"
    is_required = true

    display_settings {
      control_type = "MultiLineText"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "robert.vanhaaren@octopus.com"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "adam.close@octopus.com"
}

variable "demo_space_creator_demospacecreator_createtenant_tenantname_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.TenantName"
  default     = ""
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_tenantname_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_tenantname_1}"
  name         = "DemoSpaceCreator.CreateTenant.TenantName"
  type         = "String"
  description  = "This is also the space name."
  is_sensitive = false

  prompt {
    description = "This is also the space name. Max length of 20 characters."
    label       = "1.1: Tenant Name"
    is_required = true

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "df9fbcaa71cfb1107e1dc0a03e2bd395"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "adamclose.demo.octopus.app"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "adamoctoclose"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = ""
}

variable "demo_space_creator_demospacecreator_prompts_destroyexistingspace_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.DestroyExistingSpace"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_destroyexistingspace_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_destroyexistingspace_1}"
  name         = "DemoSpaceCreator.Prompts.DestroyExistingSpace"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "01. Destroy Existing Space?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = "https://dev94442.service-now.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_james_c" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_james_c.id}"
  value                   = "octopus.SNOW"
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = "578fb8cdd2e021107189a94f2b3192f9"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_insights" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_insights.id}"
  value                   = "Demo Space for Enterprise Insights"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

variable "demo_space_creator_demospacecreator_createtenant_createservicenowdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateServiceNowDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createservicenowdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createservicenowdemo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateServiceNowDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.7: Create ServiceNow Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "False"
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "Describe the demo space"
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "robpearson"
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant" "tenant_retail_tech" {
  name        = "Retail Tech"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created",
    "Active Projects/OctoFX Template", "Active Projects/Kubernetes Template", "Active Projects/Point of Sale Template",
    "Active Projects/Tenants Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_kubernetes_template,
    octopusdeploy_tag.tag_octofx_template, octopusdeploy_tag.tag_tenants_template,
    octopusdeploy_tag.tag_point_of_sale_template
  ]
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant" "tenant_enterprise" {
  name        = "Enterprise"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created", "Region/NA",
    "Options/Do Not Delete", "Options/Run Daily Deployments", "Options/Dev and QA Teams",
    "Active Projects/Lambda Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_do_not_delete,
    octopusdeploy_tag.tag_dev_and_qa_teams, octopusdeploy_tag.tag_lambda_template
  ]
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_mark_lamprecht" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value          = "True"
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "adam.close@octopus.com"
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "retailtech.demo.octopus.app"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "JChatmasOctopus"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = "robpearson"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "https://markharrison.atlassian.net/"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tenant" "tenant_chris_fraser" {
  name        = "Chris Fraser"
  description = "Demo Playpit"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/TAM", "State/Created", "Active Projects/OctoFX Template",
    "Active Projects/Tenants Template", "Active Projects/Kubernetes Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_tam, octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_kubernetes_template,
    octopusdeploy_tag.tag_octofx_template, octopusdeploy_tag.tag_tenants_template
  ]
}

resource "octopusdeploy_tenant" "tenant_support_debrief" {
  name        = "Support Debrief"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer
  ]
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

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_runbook_process" "runbook_process_demo_space_creator_quick_delete" {
  runbook_id = "${octopusdeploy_runbook.runbook_demo_space_creator_quick_delete.id}"

  step {
    condition           = "Success"
    name                = "Destroy existing space"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Destroy existing space"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "Run.Runbook.DateTime"                            = "N/A"
        "Octopus.Action.Script.ScriptBody"                = "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12\n\n# Octopus Variables\n$octopusSpaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n$parentTaskId = $OctopusParameters[\"Octopus.Task.Id\"]\n$parentReleaseId = $OctopusParameters[\"Octopus.Release.Id\"]\n$parentChannelId = $OctopusParameters[\"Octopus.Release.Channel.Id\"]\n$parentEnvironmentId = $OctopusParameters[\"Octopus.Environment.Id\"]\n$parentRunbookId = $OctopusParameters[\"Octopus.Runbook.Id\"]\n$parentEnvironmentName = $OctopusParameters[\"Octopus.Environment.Name\"]\n$parentReleaseNumber = $OctopusParameters[\"Octopus.Release.Number\"]\n\n# Step Template Parameters\n$runbookRunName = $OctopusParameters[\"Run.Runbook.Name\"]\n$runbookBaseUrl = $OctopusParameters[\"Run.Runbook.Base.Url\"]\n$runbookApiKey = $OctopusParameters[\"Run.Runbook.Api.Key\"]\n$runbookEnvironmentName = $OctopusParameters[\"Run.Runbook.Environment.Name\"]\n$runbookTenantName = $OctopusParameters[\"Run.Runbook.Tenant.Name\"]\n$runbookWaitForFinish = $OctopusParameters[\"Run.Runbook.Waitforfinish\"]\n$runbookUseGuidedFailure = $OctopusParameters[\"Run.Runbook.UseGuidedFailure\"]\n$runbookUsePublishedSnapshot = $OctopusParameters[\"Run.Runbook.UsePublishedSnapShot\"]\n$runbookPromptedVariables = $OctopusParameters[\"Run.Runbook.PromptedVariables\"]\n$runbookCancelInSeconds = $OctopusParameters[\"Run.Runbook.CancelInSeconds\"]\n$runbookProjectName = $OctopusParameters[\"Run.Runbook.Project.Name\"]\n\n$runbookSpaceName = $OctopusParameters[\"Run.Runbook.Space.Name\"]\n$runbookFutureDeploymentDate = $OctopusParameters[\"Run.Runbook.DateTime\"]\n$runbookMachines = $OctopusParameters[\"Run.Runbook.Machines\"]\n$autoApproveRunbookRunManualInterventions = $OctopusParameters[\"Run.Runbook.AutoApproveManualInterventions\"]\n$approvalEnvironmentName = $OctopusParameters[\"Run.Runbook.ManualIntervention.EnvironmentToUse\"]\n\nfunction Write-OctopusVerbose\n{\n    param($message)\n    \n    Write-Verbose $message  \n}\n\nfunction Write-OctopusInformation\n{\n    param($message)\n    \n    Write-Host $message  \n}\n\nfunction Write-OctopusSuccess\n{\n    param($message)\n\n    Write-Highlight $message \n}\n\nfunction Write-OctopusWarning\n{\n    param($message)\n\n    Write-Warning \"$message\" \n}\n\nfunction Write-OctopusCritical\n{\n    param ($message)\n\n    Write-Error \"$message\" \n}\n\nfunction Invoke-OctopusApi\n{\n    param\n    (\n        $octopusUrl,\n        $endPoint,\n        $spaceId,\n        $apiKey,\n        $method,\n        $item     \n    )\n\n    if ([string]::IsNullOrWhiteSpace($SpaceId))\n    {\n        $url = \"$OctopusUrl/api/$EndPoint\"\n    }\n    else\n    {\n        $url = \"$OctopusUrl/api/$spaceId/$EndPoint\"    \n    }  \n\n    try\n    {\n        if ($null -eq $item)\n        {\n            Write-Verbose \"No data to post or put, calling bog standard invoke-restmethod for $url\"\n            return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -ContentType 'application/json; charset=utf-8'\n        }\n\n        $body = $item | ConvertTo-Json -Depth 10\n        Write-Verbose $body\n\n        Write-Host \"Invoking $method $url\"\n        return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -Body $body -ContentType 'application/json; charset=utf-8'\n    }\n    catch\n    {\n        if ($null -ne $_.Exception.Response)\n        {\n            if ($_.Exception.Response.StatusCode -eq 401)\n            {\n                Write-Error \"Unauthorized error returned from $url, please verify API key and try again\"\n            }\n            elseif ($_.Exception.Response.statusCode -eq 403)\n            {\n                Write-Error \"Forbidden error returned from $url, please verify API key and try again\"\n            }\n            else\n            {                \n                Write-Error -Message \"Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )\"\n            }            \n        }\n        else\n        {\n            Write-Verbose $_.Exception\n        }\n    }\n\n    Throw \"There was an error calling the Octopus API please check the log for more details\"\n}\n\nfunction Test-RequiredValues\n{\n\tparam (\n    \t$variableToCheck,\n        $variableName\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($variableToCheck) -eq $true)\n    {\n    \tWrite-OctopusCritical \"$variableName is required.\"\n        return $false\n    }\n    \n    return $true\n}\n\nfunction GetCheckBoxBoolean\n{\n\tparam (\n    \t[string]$Value\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($value) -eq $true)\n    {\n    \treturn $false\n    }\n    \n    return $value -eq \"True\"\n}\n\nfunction Get-FilteredOctopusItem\n{\n    param(\n        $itemList,\n        $itemName\n    )\n\n    if ($itemList.Items.Count -eq 0)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        Exit 1\n    }  \n\n    $item = $itemList.Items | Where-Object { $_.Name -eq $itemName}      \n\n    if ($null -eq $item)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n    \n    if ($item -is [array])\n    {\n    \tWrite-OctopusCritical \"More than one item exists with the name $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n\n    return $item\n}\n\nfunction Get-OctopusItemFromListEndpoint\n{\n    param(\n        $endpoint,\n        $itemNameToFind,\n        $itemType,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $defaultValue\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($itemNameToFind))\n    {\n    \treturn $defaultValue\n    }\n    \n    Write-OctopusInformation \"Attempting to find $itemType with the name of $itemNameToFind\"\n    \n    $itemList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"$($endpoint)?partialName=$([uri]::EscapeDataString($itemNameToFind))\u0026skip=0\u0026take=100\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"    \n    $item = Get-FilteredOctopusItem -itemList $itemList -itemName $itemNameToFind\n\n    Write-OctopusInformation \"Successfully found $itemNameToFind with id of $($item.Id)\"\n\n    return $item\n}\n\nfunction Get-MachineIdsFromMachineNames\n{\n    param (\n        $targetMachines,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    $targetMachineList = $targetMachines -split \",\"\n    $translatedList = @()\n\n    foreach ($machineName in $targetMachineList)\n    {\n        Write-OctopusVerbose \"Translating $machineName to an Id.  First checking to see if it is already an Id.\"\n    \tif ($machineName.Trim() -like \"Machines*\")\n        {\n            Write-OctopusVerbose \"$machineName is already an Id, no need to look that up.\"\n        \t$translatedList += $machineName\n            continue\n        }\n        \n        $machineObject = Get-OctopusItemFromListEndpoint -itemNameToFind $machineName.Trim() -itemType \"Deployment Target\" -endpoint \"machines\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n\n        $translatedList += $machineObject.Id\n    }\n\n    return $translatedList\n}\n\nfunction Get-RunbookSnapshotIdToRun\n{\n    param (\n        $runbookToRun,\n        $runbookUsePublishedSnapshot,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $runbookSnapShotIdToUse = $runbookToRun.PublishedRunbookSnapshotId\n    Write-OctopusInformation \"The last published snapshot for $runbookRunName is $runbookSnapShotIdToUse\"\n\n    if ($null -eq $runbookSnapShotIdToUse -and $runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusCritical \"Use Published Snapshot was set; yet the runbook doesn't have a published snapshot.  Exiting.\"\n        Exit 1\n    }\n\n    if ($runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusInformation \"Use published snapshot set to true, using the published runbook snapshot.\"\n        return $runbookSnapShotIdToUse\n    }\n\n    if ($null -eq $runbookToRun.PublishedRunbookSnapshotId)\n    {\n        Write-OctopusInformation \"There have been no published runbook snapshots, going to create a new snapshot.\"\n        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    $runbookSnapShotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)/runbookRuns/template\" -method \"Get\" -item $null\n\n    if ($runbookSnapShotTemplate.IsRunbookProcessModified -eq $false -and $runbookSnapShotTemplate.IsVariableSetModified -eq $false -and $runbookSnapShotTemplate.IsLibraryVariableSetModified -eq $false)\n    {        \n        Write-OctopusInformation \"The runbook has not been modified since the published snapshot was created.  Checking to see if any of the packages have a new version.\"    \n        $runbookSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)\" -method \"Get\" -item $null\n        $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n        foreach ($package in $runbookSnapShot.SelectedPackages)\n        {\n            foreach ($templatePackage in $snapshotTemplate.Packages)\n            {\n                if ($package.StepName -eq $templatePackage.StepName -and $package.ActionName -eq $templatePackage.ActionName -and $package.PackageReferenceName -eq $templatePackage.PackageReferenceName)\n                {\n                    $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($templatePackage.FeedId)/packages/versions?packageId=$($templatePackage.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n                    if ($packageVersion -ne $package.Version)\n                    {\n                        Write-OctopusInformation \"A newer version of a package was found, going to use that and create a new snapshot.\"\n                        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId                    \n                    }\n                }\n            }\n        }\n\n        Write-OctopusInformation \"No new package versions have been found, using the published snapshot.\"\n        return $runbookToRun.PublishedRunbookSnapshotId\n    }\n    \n    Write-OctopusInformation \"The runbook has been modified since the snapshot was created, creating a new one.\"\n    return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n}\n\nfunction New-RunbookUnpublishedSnapshot\n{\n    param (\n        $runbookToRun,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $octopusProject = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"Get\" -item $null\n    $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n    $runbookPackages = @()\n    foreach ($package in $snapshotTemplate.Packages)\n    {\n        $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($package.FeedId)/packages/versions?packageId=$($package.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n        if ($packageVersion.TotalResults -le 0)\n        {\n            Write-Error \"Unable to find a package version for $($package.PackageId).  This is required to create a new unpublished snapshot.  Exiting.\"\n            exit 1\n        }\n\n        $runbookPackages += @{\n            StepName = $package.StepName\n            ActionName = $package.ActionName\n            Version = $packageVersion.Items[0].Version\n            PackageReferenceName = $package.PackageReferenceName\n        }\n    }\n\n    $runbookSnapShotRequest = @{\n        FrozenProjectVariableSetId = \"variableset-$($runbookToRun.ProjectId)\"\n        FrozenRunbookProcessId = $($runbookToRun.RunbookProcessId)\n        LibraryVariableSetSnapshotIds = @($octopusProject.IncludedLibraryVariableSetIds)\n        Name = $($snapshotTemplate.NextNameIncrement)\n        ProjectId = $($runbookToRun.ProjectId)\n        ProjectVariableSetSnapshotId = \"variableset-$($runbookToRun.ProjectId)\"\n        RunbookId = $($runbookToRun.Id)\n        SelectedPackages = $runbookPackages\n    }\n\n    $newSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots\" -method \"POST\" -item $runbookSnapShotRequest\n\n    return $($newSnapShot.Id)\n}\n\nfunction Get-ProjectSlug\n{\n    param\n    (\n        $runbookToRun,\n        $projectToUse,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    if ($null -ne $projectToUse)\n    {\n        return $projectToUse.Slug\n    }\n\n    $project = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"GET\" -item $null\n\n    return $project.Slug\n}\n\nfunction Get-RunbookFormValues\n{\n    param (\n        $runbookPreview,\n        $runbookPromptedVariables        \n    )\n\n    $runbookFormValues = @{}\n\n    if ([string]::IsNullOrWhiteSpace($runbookPromptedVariables) -eq $true)\n    {\n        return $runbookFormValues\n    }    \n    \n    $promptedValueList = @(($runbookPromptedVariables -Split \"`n\").Trim())\n    Write-OctopusInformation $promptedValueList.Length\n    \n    foreach($element in $runbookPreview.Form.Elements)\n    {\n    \t$nameToSearchFor = $element.Control.Name\n        $uniqueName = $element.Name\n        $isRequired = $element.Control.Required\n        \n        $promptedVariablefound = $false\n        \n        Write-OctopusInformation \"Looking for the prompted variable value for $nameToSearchFor\"\n    \tforeach ($promptedValue in $promptedValueList)\n        {\n        \t$splitValue = $promptedValue -Split \"::\"\n            Write-OctopusInformation \"Comparing $nameToSearchFor with provided prompted variable $($promptedValue[0])\"\n            if ($splitValue.Length -gt 1)\n            {\n            \tif ($nameToSearchFor -eq $splitValue[0])\n                {\n                \tWrite-OctopusInformation \"Found the prompted variable value $nameToSearchFor\"\n                \t$runbookFormValues[$uniqueName] = $splitValue[1]\n                    $promptedVariableFound = $true\n                    break\n                }\n            }\n        }\n        \n        if ($promptedVariableFound -eq $false -and $isRequired -eq $true)\n        {\n        \tWrite-OctopusCritical \"Unable to find a value for the required prompted variable $nameToSearchFor, exiting\"\n            Exit 1\n        }\n    }\n\n    return $runbookFormValues\n}\n\nfunction Invoke-OctopusDeployRunbook\n{\n    param (\n        $runbookBody,\n        $runbookWaitForFinish,\n        $runbookCancelInSeconds,\n        $projectNameForUrl,        \n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentTaskApprovers,\n        $autoApproveRunbookRunManualInterventions,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $approvalEnvironmentName,\n        $parentRunbookId,\n        $parentTaskId\n    )\n\n    $runbookResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -item $runbookBody -method \"POST\" -endPoint \"runbookRuns\"\n\n    $runbookServerTaskId = $runBookResponse.TaskId\n    Write-OctopusInformation \"The task id of the new task is $runbookServerTaskId\"\n\n    $runbookRunId = $runbookResponse.Id\n    Write-OctopusInformation \"The runbook run id is $runbookRunId\"\n\n    Write-OctopusSuccess \"Runbook was successfully invoked, you can access the launched runbook [here]($defaultUrl/app#/$spaceId/projects/$projectNameForUrl/operations/runbooks/$($runbookBody.RunbookId)/snapshots/$($runbookBody.RunbookSnapShotId)/runs/$runbookRunId)\"\n\n    if ($runbookWaitForFinish -eq $false)\n    {\n        Write-OctopusInformation \"The wait for finish setting is set to no, exiting step\"\n        return\n    }\n    \n    if ($null -ne $runbookBody.QueueTime)\n    {\n    \tWrite-OctopusInformation \"The runbook queue time is set.  Exiting step\"\n        return\n    }\n\n    Write-OctopusSuccess \"The setting to wait for completion was set, waiting until task has finished\"\n    $startTime = Get-Date\n    $currentTime = Get-Date\n    $dateDifference = $currentTime - $startTime\n\t\n    $taskStatusUrl = \"tasks/$runbookServerTaskId\"\n    $numberOfWaits = 0    \n    \n    While ($dateDifference.TotalSeconds -lt $runbookCancelInSeconds)\n    {\n        Write-OctopusInformation \"Waiting 5 seconds to check status\"\n        Start-Sleep -Seconds 5\n        $taskStatusResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint $taskStatusUrl -method \"GET\" -item $null\n        $taskStatusResponseState = $taskStatusResponse.State\n\n        if ($taskStatusResponseState -eq \"Success\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of Success\"\n            exit 0            \n        }\n        elseif($taskStatusResponseState -eq \"Failed\" -or $taskStatusResponseState -eq \"Canceled\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of $taskStatusResponseState status, stopping the run/deployment\"\n            exit 1            \n        }\n        elseif($taskStatusResponse.HasPendingInterruptions -eq $true)\n        {\n            if ($autoApproveRunbookRunManualInterventions -eq \"Yes\")\n            {\n                Submit-RunbookRunForAutoApproval -createdRunbookRun $createdRunbookRun -parentTaskApprovers $parentTaskApprovers -defaultUrl $DefaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -parentProjectName $parentProjectName -parentReleaseNumber $parentReleaseNumber -parentEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $parentTaskId\n            }\n            else\n            {\n                if ($numberOfWaits -ge 10)\n                {\n                    Write-OctopusSuccess \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"\n                }\n                else\n                {\n                    Write-OctopusInformation \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"                        \n                }\n            }\n        }\n        \n        $numberOfWaits += 1\n        if ($numberOfWaits -ge 10)\n        {\n        \tWrite-OctopusSuccess \"The task state is currently $taskStatusResponseState\"\n        \t$numberOfWaits = 0\n        }\n        else\n        {\n        \tWrite-OctopusInformation \"The task state is currently $taskStatusResponseState\"\n        }  \n        \n        $startTime = $taskStatusResponse.StartTime\n        if ($startTime -eq $null -or [string]::IsNullOrWhiteSpace($startTime) -eq $true)\n        {        \n        \tWrite-OctopusInformation \"The task is still queued, let's wait a bit longer\"\n        \t$startTime = Get-Date\n        }\n        $startTime = [DateTime]$startTime\n        \n        $currentTime = Get-Date\n        $dateDifference = $currentTime - $startTime        \n    }\n    \n    Write-OctopusSuccess \"The cancel timeout has been reached, cancelling the runbook run\"\n    $cancelResponse = Invoke-RestMethod \"$runbookBaseUrl/api/tasks/$runbookServerTaskId/cancel\" -Headers $header -Method Post\n    Write-OctopusSuccess \"Exiting with an error code of 1 because we reached the timeout\"\n    exit 1\n}\n\nfunction Get-QueueDate\n{\n\tparam ( \n    \t$futureDeploymentDate\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($futureDeploymentDate) -or $futureDeploymentDate -eq \"N/A\")\n    {\n    \treturn $null\n    }\n    \n    [datetime]$outputDate = New-Object DateTime\n    $currentDate = Get-Date\n\n    if ([datetime]::TryParse($futureDeploymentDate, [ref]$outputDate) -eq $false)\n    {\n        Write-OctopusCritical \"The suppplied date $futureDeploymentDate cannot be parsed by DateTime.TryParse.  Please verify format and try again.  Please [refer to Microsoft's Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.datetime.tryparse) on supported formats.\"\n        exit 1\n    }\n    \n    if ($currentDate -gt $outputDate)\n    {\n    \tWrite-OctopusCritical \"The supplied date $futureDeploymentDate is set for the past.  All queued deployments must be in the future.\"\n        exit 1\n    }\n    \n    return $outputDate\n}\n\nfunction Get-QueueExpiryDate\n{\n\tparam (\n    \t$queueDate\n    )\n    \n    if ($null -eq $queueDate)\n    {\n    \treturn $null\n    }\n    \n    return $queueDate.AddHours(1)\n}\n\nfunction Get-RunbookSpecificMachines\n{\n    param (\n        $runbookPreview,\n        $runbookMachines,        \n        $runbookRunName        \n    )\n\n    if ($runbookMachines -eq \"N/A\")\n    {\n        return @()\n    }\n\n    if ([string]::IsNullOrWhiteSpace($runbookMachines) -eq $true)\n    {\n        return @()\n    }\n\n    $translatedList = Get-MachineIdsFromMachineNames -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -targetMachines $runbookMachines\n\n    $filteredList = @()    \n    foreach ($runbookMachine in $translatedList)\n    {    \t\n    \t$runbookMachineId = $runbookMachine.Trim().ToLower()\n    \tWrite-OctopusVerbose \"Checking if $runbookMachineId is set to run on any of the runbook steps\"\n        \n        foreach ($step in $runbookPreview.StepsToExecute)\n        {\n            foreach ($machine in $step.Machines)\n            {\n            \tWrite-OctopusVerbose \"Checking if $runbookMachineId matches $($machine.Id) and it isn't already in the $($filteredList -join \",\")\"\n                if ($runbookMachineId -eq $machine.Id.Trim().ToLower() -and $filteredList -notcontains $machine.Id)\n                {\n                \tWrite-OctopusInformation \"Adding $($machine.Id) to the list\"\n                    $filteredList += $machine.Id\n                }\n            }\n        }\n    }\n\n    if ($filteredList.Length -le 0)\n    {\n        Write-OctopusSuccess \"The current task is targeting specific machines, but the runbook $runBookRunName does not run against any of these machines $runbookMachines. Skipping this run.\"\n        exit 0\n    }\n\n    return $filteredList\n}\n\nfunction Get-ParentTaskApprovers\n{\n    param (\n        $parentTaskId,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n    \n    $approverList = @()\n    if ($null -eq $parentTaskId)\n    {\n    \tWrite-OctopusInformation \"The deployment task id to pull the approvers from is null, return an empty approver list\"\n    \treturn $approverList\n    }\n\n    Write-OctopusInformation \"Getting all the events from the parent project\"\n    $parentEvents = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"events?regardingAny=$parentTaskId\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"\n    \n    foreach ($parentEvent in $parentEvents.Items)\n    {\n        Write-OctopusVerbose \"Checking $($parentEvent.Message) for manual intervention\"\n        if ($parentEvent.Message -like \"Submitted interruption*\")\n        {\n            Write-OctopusVerbose \"The event $($parentEvent.Id) is a manual intervention approval event which was approved by $($parentEvent.Username).\"\n\n            $approverExists = $approverList | Where-Object {$_.Id -eq $parentEvent.UserId}        \n\n            if ($null -eq $approverExists)\n            {\n                $approverInformation = @{\n                    Id = $parentEvent.UserId;\n                    Username = $parentEvent.Username;\n                    Teams = @()\n                }\n\n                $approverInformation.Teams = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"teammembership?userId=$($approverInformation.Id)\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"            \n\n                Write-OctopusVerbose \"Adding $($approverInformation.Id) to the approval list\"\n                $approverList += $approverInformation\n            }        \n        }\n    }\n\n    return $approverList\n}\n\nfunction Get-ApprovalTaskIdFromDeployment\n{\n    param (\n        $parentReleaseId,\n        $approvalEnvironment,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n\n    $releaseDeploymentList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"releases/$parentReleaseId/deployments\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    \n    $lastDeploymentTime = $(Get-Date).AddYears(-50)\n    $approvalTaskId = $null\n    foreach ($deployment in $releaseDeploymentList.Items)\n    {\n        if ($deployment.EnvironmentId -ne $approvalEnvironment.Id)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) deployed to $($deployment.EnvironmentId) which doesn't match $($approvalEnvironment.Id).\"\n            continue\n        }\n        \n        Write-OctopusInformation \"The deployment $($deployment.Id) was deployed to the approval environment $($approvalEnvironment.Id).\"\n\n        $deploymentTask = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $null -endPoint \"tasks/$($deployment.TaskId)\" -apiKey $octopusApiKey -Method \"Get\"\n        if ($deploymentTask.IsCompleted -eq $true -and $deploymentTask.FinishedSuccessfully -eq $false)\n        {\n            Write-Information \"The deployment $($deployment.Id) was deployed to the approval environment, but it encountered a failure, moving onto the next deployment.\"\n            continue\n        }\n\n        if ($deploymentTask.StartTime -gt $lastDeploymentTime)\n        {\n            $approvalTaskId = $deploymentTask.Id\n            $lastDeploymentTime = $deploymentTask.StartTime\n        }\n    }        \n\n    if ($null -eq $approvalTaskId)\n    {\n    \tWrite-OctopusVerbose \"Unable to find a deployment to the environment, determining if it should've happened already.\"\n        $channelInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$parentChannelId\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n        $lifecycle = Get-OctopusLifeCycle -channel $channelInformation -defaultUrl $defaultUrl -spaceId $spaceId -OctopusApiKey $octopusApiKey\n        $lifecyclePhases = Get-LifecyclePhases -lifecycle $lifecycle -defaultUrl $defaultUrl -spaceId $spaceid -OctopusApiKey $octopusApiKey\n        \n        $foundDestinationFirst = $false\n        $foundApprovalFirst = $false\n        \n        foreach ($phase in $lifecyclePhases.Phases)\n        {\n        \tif ($phase.AutomaticDeploymentTargets -contains $parentEnvironmentId -or $phase.OptionalDeploymentTargets -contains $parentEnvironmentId)\n            {\n            \tif ($foundApprovalFirst -eq $false)\n                {\n                \t$foundDestinationFirst = $true\n                }\n            }\n            \n            if ($phase.AutomaticDeploymentTargets -contains $approvalEnvironment.Id -or $phase.OptionalDeploymentTargets -contains $approvalEnvironment.Id)\n            {\n            \tif ($foundDestinationFirst -eq $false)\n                {\n                \t$foundApprovalFirst = $true\n                }\n            }\n        }\n        \n        $messageToLog = \"Unable to find a deployment for the environment $approvalEnvironmentName.  Auto approvals are disabled.\"\n        if ($foundApprovalFirst -eq $true)\n        {\n        \tWrite-OctopusWarning $messageToLog\n        }\n        else\n        {\n        \tWrite-OctopusInformation $messageToLog\n        }\n        \n        return $null\n    }\n\n    return $approvalTaskId\n}\n\nfunction Get-ApprovalTaskIdFromRunbook\n{\n    param (\n        $parentRunbookId,\n        $approvalEnvironment,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n}\n\nfunction Get-ApprovalTaskId\n{\n\tparam (\n    \t$autoApproveRunbookRunManualInterventions,\n        $parentTaskId,\n        $parentReleaseId,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $approvalEnvironmentName,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey        \n    )\n    \n    if ($autoApproveRunbookRunManualInterventions -eq $false)\n    {\n    \tWrite-OctopusInformation \"Auto approvals are disabled, skipping pulling the approval deployment task id\"\n        return $null\n    }\n    \n    if ([string]::IsNullOrWhiteSpace($approvalEnvironmentName) -eq $true)\n    {\n    \tWrite-OctopusInformation \"Approval environment not supplied, using the current environment id for approvals.\"\n        return $parentTaskId\n    }\n    \n    if ($approvalEnvironmentName.ToLower().Trim() -eq $parentEnvironmentName.ToLower().Trim())\n    {\n        Write-OctopusInformation \"The approval environment is the same as the current environment, using the current task id $parentTaskId\"\n        return $parentTaskId\n    }\n    \n    $approvalEnvironment = Get-OctopusItemFromListEndpoint -itemNameToFind $approvalEnvironmentName -itemType \"Environment\" -defaultUrl $DefaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -defaultValue $null -endpoint \"environments\"\n    \n    if ([string]::IsNullOrWhiteSpace($parentReleaseId) -eq $false)\n    {\n        return Get-ApprovalTaskIdFromDeployment -parentReleaseId $parentReleaseId -approvalEnvironment $approvalEnvironment -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    return Get-ApprovalTaskIdFromRunbook -parentRunbookId $parentRunbookId -approvalEnvironment $approvalEnvironment -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n}\n\nfunction Get-OctopusLifecycle\n{\n    param (\n        $channel,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the lifecycle information $($channel.Name)\"\n    if ($null -eq $channel.LifecycleId)\n    {\n        $lifecycleName = \"Default Lifecycle\"\n        $lifecycleList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles?partialName=$([uri]::EscapeDataString($lifecycleName))\u0026skip=0\u0026take=1\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $lifecycle = $lifecycleList.Items[0]\n    }\n    else\n    {\n        $lifecycle = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($channel.LifecycleId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n    }\n\n    Write-Host \"Successfully found the lifecycle $($lifecycle.Name) to use for this channel.\"\n\n    return $lifecycle\n}\n\nfunction Get-LifecyclePhases\n{\n    param (\n        $lifecycle,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the phase in the lifecycle $($lifecycle.Name) with the environment $environmentName to find the previous phase.\"\n    if ($lifecycle.Phases.Count -eq 0)\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has no set phases, calling the preview endpoint.\"\n        $lifecyclePreview = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($lifecycle.Id)/preview\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $phases = $lifecyclePreview.Phases\n    }\n    else\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has set phases, using those.\"\n        $phases = $lifecycle.Phases    \n    }\n\n    Write-OctopusInformation \"Found $($phases.Length) phases in this lifecycle.\"\n    return $phases\n}\n\nfunction Submit-RunbookRunForAutoApproval\n{\n    param (\n        $createdRunbookRun,\n        $parentTaskApprovers,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $parentTaskId        \n    )\n\n    Write-OctopusSuccess \"The task has a pending manual intervention.  Checking parent approvals.\"    \n    $manualInterventionInformation = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions?regarding=$($createdRunbookRun.TaskId)\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    foreach ($manualIntervention in $manualInterventionInformation.Items)\n    {\n        if ($manualIntervention.IsPending -eq $false)\n        {\n            Write-OctopusInformation \"This manual intervention has already been approved.  Proceeding onto the next one.\"\n            continue\n        }\n\n        if ($manualIntervention.CanTakeResponsibility -eq $false)\n        {\n            Write-OctopusSuccess \"The user associated with the API key doesn't have permissions to take responsibility for the manual intervention.\"\n            Write-OctopusSuccess \"If you wish to leverage the auto-approval functionality give the user permissions.\"\n            continue\n        }        \n\n        $automaticApprover = $null\n        Write-OctopusVerbose \"Checking to see if one of the parent project approvers is assigned to one of the manual intervention teams $($manualIntervention.ResponsibleTeamIds)\"\n        foreach ($approver in $parentTaskApprovers)\n        {\n            foreach ($approverTeam in $approver.Teams)\n            {\n                Write-OctopusVerbose \"Checking to see if $($manualIntervention.ResponsibleTeamIds) contains $($approverTeam.TeamId)\"\n                if ($manualIntervention.ResponsibleTeamIds -contains $approverTeam.TeamId)\n                {\n                    $automaticApprover = $approver\n                    break\n                }\n            }\n\n            if ($null -ne $automaticApprover)\n            {\n                break\n            }\n        }\n\n        if ($null -ne $automaticApprover)\n        {\n        \tWrite-OctopusSuccess \"Matching approver found auto-approving.\"\n            if ($manualIntervention.HasResponsibility -eq $false)\n            {\n                Write-OctopusInformation \"Taking over responsibility for this manual intervention.\"\n                $takeResponsiblilityResponse = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/responsible\" -method \"PUT\" -apiKey $octopusApiKey -spaceId $spaceId\n                Write-OctopusVerbose \"Response from taking responsibility $($takeResponsiblilityResponse.Id)\"\n            }\n            \n            if ([string]::IsNullOrWhiteSpace($parentReleaseNumber) -eq $false)\n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName release $parentReleaseNumber to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that deployment $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n            else \n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName runbook run $parentRunbookId to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that runbook run $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n\n            $submitApprovalBody = @{\n                Instructions = $null;\n                Notes = $notes\n                Result = \"Proceed\"\n            }\n            $submitResult = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/submit\" -method \"POST\" -apiKey $octopusApiKey -item $submitApprovalBody -spaceId $spaceId\n            Write-OctopusSuccess \"Successfully auto approved the manual intervention $($submitResult.Id)\"\n        }\n        else\n        {\n            Write-OctopusSuccess \"Couldn't find an approver to auto-approve the child project.  Waiting until timeout or child project is approved.\"    \n        }\n    }\n}\n\n\n$runbookWaitForFinish = GetCheckboxBoolean -Value $runbookWaitForFinish\n$runbookUseGuidedFailure = GetCheckboxBoolean -Value $runbookUseGuidedFailure\n$runbookUsePublishedSnapshot = GetCheckboxBoolean -Value $runbookUsePublishedSnapshot\n$runbookCancelInSeconds = [int]$runbookCancelInSeconds\n\nWrite-OctopusInformation \"Wait for Finish Before Check: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure Before Check: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Use Published Snapshot Before Check: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Runbook Name $runbookRunName\"\nWrite-OctopusInformation \"Runbook Base Url: $runbookBaseUrl\"\nWrite-OctopusInformation \"Runbook Space Name: $runbookSpaceName\"\nWrite-OctopusInformation \"Runbook Environment Name: $runbookEnvironmentName\"\nWrite-OctopusInformation \"Runbook Tenant Name: $runbookTenantName\"\nWrite-OctopusInformation \"Wait for Finish: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Cancel run in seconds: $runbookCancelInSeconds\"\nWrite-OctopusInformation \"Use Published Snapshot: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Auto Approve Runbook Run Manual Interventions: $autoApproveRunbookRunManualInterventions\"\nWrite-OctopusInformation \"Auto Approve environment name to pull approvals from: $approvalEnvironmentName\"\n\nWrite-OctopusInformation \"Octopus runbook run machines: $runbookMachines\"\nWrite-OctopusInformation \"Parent Task Id: $parentTaskId\"\nWrite-OctopusInformation \"Parent Release Id: $parentReleaseId\"\nWrite-OctopusInformation \"Parent Channel Id: $parentChannelId\"\nWrite-OctopusInformation \"Parent Environment Id: $parentEnvironmentId\"\nWrite-OctopusInformation \"Parent Runbook Id: $parentRunbookId\"\nWrite-OctopusInformation \"Parent Environment Name: $parentEnvironmentName\"\nWrite-OctopusInformation \"Parent Release Number: $parentReleaseNumber\"\n\n$verificationPassed = @()\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookRunName -variableName \"Runbook Name\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookBaseUrl -variableName \"Base Url\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookApiKey -variableName \"Api Key\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookEnvironmentName -variableName \"Environment Name\"\n\nif ($verificationPassed -contains $false)\n{\n\tWrite-OctopusInformation \"Required values missing\"\n\tExit 1\n}\n\n$runbookSpace = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookSpaceName -endpoint \"spaces\" -spaceId $null -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl -itemType \"Space\" -defaultValue $octopusSpaceId\n$runbookSpaceId = $runbookSpace.Id\n\n$projectToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookProjectName -endpoint \"projects\" -spaceId $runbookSpaceId -defaultValue $null -itemType \"Project\" -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl\nif ($null -ne $projectToUse)\n{\t    \n    $runbookEndPoint = \"projects/$($projectToUse.Id)/runbooks\"\n}\nelse\n{\n\t$runbookEndPoint = \"runbooks\"\n}\n\n$environmentToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookEnvironmentName -itemType \"Environment\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -defaultValue $null -endpoint \"environments\"\n\n$runbookToRun = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookRunName -itemType \"Runbook\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -endpoint $runbookEndPoint -octopusApiKey $runbookApiKey -defaultValue $null\n\n$runbookSnapShotIdToUse = Get-RunbookSnapshotIdToRun -runbookToRun $runbookToRun -runbookUsePublishedSnapshot $runbookUsePublishedSnapshot -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $octopusSpaceId\n$projectNameForUrl = Get-ProjectSlug -projectToUse $projectToUse -runbookToRun $runbookToRun -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId\n\n$tenantToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookTenantName -itemType \"Tenant\" -defaultValue $null -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -endpoint \"tenants\" -defaultUrl $runbookBaseUrl\nif ($null -ne $tenantToUse)\n{\t\n    $tenantIdToUse = $tenantToUse.Id    \n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)/$($tenantIdToUse)\" -method \"GET\" -item $null\n}\nelse\n{\n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)\" -method \"GET\" -item $null\n}\n\n$childRunbookRunSpecificMachines = Get-RunbookSpecificMachines -runbookPreview $runBookPreview -runbookMachines $runbookMachines -runbookRunName $runbookRunName\n$runbookFormValues = Get-RunbookFormValues -runbookPreview $runBookPreview -runbookPromptedVariables $runbookPromptedVariables\n\n$queueDate = Get-QueueDate -futureDeploymentDate $runbookFutureDeploymentDate\n$queueExpiryDate = Get-QueueExpiryDate -queueDate $queueDate\n\n$runbookBody = @{\n    RunbookId = $($runbookToRun.Id);\n    RunbookSnapShotId = $runbookSnapShotIdToUse;\n    FrozenRunbookProcessId = $null;\n    EnvironmentId = $($environmentToUse.Id);\n    TenantId = $tenantIdToUse;\n    SkipActions = @();\n    QueueTime = $queueDate;\n    QueueTimeExpiry = $queueExpiryDate;\n    FormValues = $runbookFormValues;\n    ForcePackageDownload = $false;\n    ForcePackageRedeployment = $true;\n    UseGuidedFailure = $runbookUseGuidedFailure;\n    SpecificMachineIds = @($childRunbookRunSpecificMachines);\n    ExcludedMachineIds = @()\n}\n\n$approvalTaskId = Get-ApprovalTaskId -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentTaskId $parentTaskId -parentReleaseId $parentReleaseId -parentRunbookId $parentRunbookId -parentEnvironmentName $parentEnvironmentName -approvalEnvironmentName $approvalEnvironmentName -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey\n$parentTaskApprovers = Get-ParentTaskApprovers -parentTaskId $approvalTaskId -spaceId $runbookSpaceId -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey\n\nInvoke-OctopusDeployRunbook -runbookBody $runbookBody -runbookWaitForFinish $runbookWaitForFinish -runbookCancelInSeconds $runbookCancelInSeconds -projectNameForUrl $projectNameForUrl -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId -parentTaskApprovers $parentTaskApprovers -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentProjectName $projectNameForUrl -parentReleaseNumber $parentReleaseNumber -approvalEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $approvalTaskId"
        "Run.Runbook.ManualIntervention.EnvironmentToUse" = "#{Octopus.Environment.Name}"
        "Run.Runbook.Space.Name"                          = "#{Octopus.Space.Name}"
        "Run.Runbook.UsePublishedSnapShot"                = "True"
        "Run.Runbook.CancelInSeconds"                     = "1800"
        "Octopus.Action.RunOnServer"                      = "true"
        "Octopus.Action.Script.Syntax"                    = "PowerShell"
        "Run.Runbook.Machines"                            = "N/A"
        "Run.Runbook.Api.Key"                             = "#{DemoSpaceCreator.Octopus.APIKey}"
        "Run.Runbook.Project.Name"                        = "Space Manager"
        "Run.Runbook.Name"                                = "Delete demo space"
        "Run.Runbook.Waitforfinish"                       = "True"
        "Run.Runbook.AutoApproveManualInterventions"      = "No"
        "Run.Runbook.Base.Url"                            = "#{Octopus.Web.ServerUri}"
        "Run.Runbook.Tenant.Name"                         = "#{Octopus.Deployment.Tenant.Name}"
        "Octopus.Action.Script.ScriptSource"              = "Inline"
        "Run.Runbook.Environment.Name"                    = "#{Octopus.Environment.Name}"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = ["State/Created"]
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  step {
    condition           = "Success"
    name                = "Delete tenant"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Delete tenant"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "Octopus.Action.Script.ScriptBody"                = "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12\n\n# Octopus Variables\n$octopusSpaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n$parentTaskId = $OctopusParameters[\"Octopus.Task.Id\"]\n$parentReleaseId = $OctopusParameters[\"Octopus.Release.Id\"]\n$parentChannelId = $OctopusParameters[\"Octopus.Release.Channel.Id\"]\n$parentEnvironmentId = $OctopusParameters[\"Octopus.Environment.Id\"]\n$parentRunbookId = $OctopusParameters[\"Octopus.Runbook.Id\"]\n$parentEnvironmentName = $OctopusParameters[\"Octopus.Environment.Name\"]\n$parentReleaseNumber = $OctopusParameters[\"Octopus.Release.Number\"]\n\n# Step Template Parameters\n$runbookRunName = $OctopusParameters[\"Run.Runbook.Name\"]\n$runbookBaseUrl = $OctopusParameters[\"Run.Runbook.Base.Url\"]\n$runbookApiKey = $OctopusParameters[\"Run.Runbook.Api.Key\"]\n$runbookEnvironmentName = $OctopusParameters[\"Run.Runbook.Environment.Name\"]\n$runbookTenantName = $OctopusParameters[\"Run.Runbook.Tenant.Name\"]\n$runbookWaitForFinish = $OctopusParameters[\"Run.Runbook.Waitforfinish\"]\n$runbookUseGuidedFailure = $OctopusParameters[\"Run.Runbook.UseGuidedFailure\"]\n$runbookUsePublishedSnapshot = $OctopusParameters[\"Run.Runbook.UsePublishedSnapShot\"]\n$runbookPromptedVariables = $OctopusParameters[\"Run.Runbook.PromptedVariables\"]\n$runbookCancelInSeconds = $OctopusParameters[\"Run.Runbook.CancelInSeconds\"]\n$runbookProjectName = $OctopusParameters[\"Run.Runbook.Project.Name\"]\n\n$runbookSpaceName = $OctopusParameters[\"Run.Runbook.Space.Name\"]\n$runbookFutureDeploymentDate = $OctopusParameters[\"Run.Runbook.DateTime\"]\n$runbookMachines = $OctopusParameters[\"Run.Runbook.Machines\"]\n$autoApproveRunbookRunManualInterventions = $OctopusParameters[\"Run.Runbook.AutoApproveManualInterventions\"]\n$approvalEnvironmentName = $OctopusParameters[\"Run.Runbook.ManualIntervention.EnvironmentToUse\"]\n\nfunction Write-OctopusVerbose\n{\n    param($message)\n    \n    Write-Verbose $message  \n}\n\nfunction Write-OctopusInformation\n{\n    param($message)\n    \n    Write-Host $message  \n}\n\nfunction Write-OctopusSuccess\n{\n    param($message)\n\n    Write-Highlight $message \n}\n\nfunction Write-OctopusWarning\n{\n    param($message)\n\n    Write-Warning \"$message\" \n}\n\nfunction Write-OctopusCritical\n{\n    param ($message)\n\n    Write-Error \"$message\" \n}\n\nfunction Invoke-OctopusApi\n{\n    param\n    (\n        $octopusUrl,\n        $endPoint,\n        $spaceId,\n        $apiKey,\n        $method,\n        $item     \n    )\n\n    if ([string]::IsNullOrWhiteSpace($SpaceId))\n    {\n        $url = \"$OctopusUrl/api/$EndPoint\"\n    }\n    else\n    {\n        $url = \"$OctopusUrl/api/$spaceId/$EndPoint\"    \n    }  \n\n    try\n    {\n        if ($null -eq $item)\n        {\n            Write-Verbose \"No data to post or put, calling bog standard invoke-restmethod for $url\"\n            return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -ContentType 'application/json; charset=utf-8'\n        }\n\n        $body = $item | ConvertTo-Json -Depth 10\n        Write-Verbose $body\n\n        Write-Host \"Invoking $method $url\"\n        return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -Body $body -ContentType 'application/json; charset=utf-8'\n    }\n    catch\n    {\n        if ($null -ne $_.Exception.Response)\n        {\n            if ($_.Exception.Response.StatusCode -eq 401)\n            {\n                Write-Error \"Unauthorized error returned from $url, please verify API key and try again\"\n            }\n            elseif ($_.Exception.Response.statusCode -eq 403)\n            {\n                Write-Error \"Forbidden error returned from $url, please verify API key and try again\"\n            }\n            else\n            {                \n                Write-Error -Message \"Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )\"\n            }            \n        }\n        else\n        {\n            Write-Verbose $_.Exception\n        }\n    }\n\n    Throw \"There was an error calling the Octopus API please check the log for more details\"\n}\n\nfunction Test-RequiredValues\n{\n\tparam (\n    \t$variableToCheck,\n        $variableName\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($variableToCheck) -eq $true)\n    {\n    \tWrite-OctopusCritical \"$variableName is required.\"\n        return $false\n    }\n    \n    return $true\n}\n\nfunction GetCheckBoxBoolean\n{\n\tparam (\n    \t[string]$Value\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($value) -eq $true)\n    {\n    \treturn $false\n    }\n    \n    return $value -eq \"True\"\n}\n\nfunction Get-FilteredOctopusItem\n{\n    param(\n        $itemList,\n        $itemName\n    )\n\n    if ($itemList.Items.Count -eq 0)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        Exit 1\n    }  \n\n    $item = $itemList.Items | Where-Object { $_.Name -eq $itemName}      \n\n    if ($null -eq $item)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n    \n    if ($item -is [array])\n    {\n    \tWrite-OctopusCritical \"More than one item exists with the name $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n\n    return $item\n}\n\nfunction Get-OctopusItemFromListEndpoint\n{\n    param(\n        $endpoint,\n        $itemNameToFind,\n        $itemType,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $defaultValue\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($itemNameToFind))\n    {\n    \treturn $defaultValue\n    }\n    \n    Write-OctopusInformation \"Attempting to find $itemType with the name of $itemNameToFind\"\n    \n    $itemList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"$($endpoint)?partialName=$([uri]::EscapeDataString($itemNameToFind))\u0026skip=0\u0026take=100\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"    \n    $item = Get-FilteredOctopusItem -itemList $itemList -itemName $itemNameToFind\n\n    Write-OctopusInformation \"Successfully found $itemNameToFind with id of $($item.Id)\"\n\n    return $item\n}\n\nfunction Get-MachineIdsFromMachineNames\n{\n    param (\n        $targetMachines,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    $targetMachineList = $targetMachines -split \",\"\n    $translatedList = @()\n\n    foreach ($machineName in $targetMachineList)\n    {\n        Write-OctopusVerbose \"Translating $machineName to an Id.  First checking to see if it is already an Id.\"\n    \tif ($machineName.Trim() -like \"Machines*\")\n        {\n            Write-OctopusVerbose \"$machineName is already an Id, no need to look that up.\"\n        \t$translatedList += $machineName\n            continue\n        }\n        \n        $machineObject = Get-OctopusItemFromListEndpoint -itemNameToFind $machineName.Trim() -itemType \"Deployment Target\" -endpoint \"machines\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n\n        $translatedList += $machineObject.Id\n    }\n\n    return $translatedList\n}\n\nfunction Get-RunbookSnapshotIdToRun\n{\n    param (\n        $runbookToRun,\n        $runbookUsePublishedSnapshot,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $runbookSnapShotIdToUse = $runbookToRun.PublishedRunbookSnapshotId\n    Write-OctopusInformation \"The last published snapshot for $runbookRunName is $runbookSnapShotIdToUse\"\n\n    if ($null -eq $runbookSnapShotIdToUse -and $runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusCritical \"Use Published Snapshot was set; yet the runbook doesn't have a published snapshot.  Exiting.\"\n        Exit 1\n    }\n\n    if ($runbookUsePublishedSnapshot -eq $true)\n    {\n        Write-OctopusInformation \"Use published snapshot set to true, using the published runbook snapshot.\"\n        return $runbookSnapShotIdToUse\n    }\n\n    if ($null -eq $runbookToRun.PublishedRunbookSnapshotId)\n    {\n        Write-OctopusInformation \"There have been no published runbook snapshots, going to create a new snapshot.\"\n        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    $runbookSnapShotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)/runbookRuns/template\" -method \"Get\" -item $null\n\n    if ($runbookSnapShotTemplate.IsRunbookProcessModified -eq $false -and $runbookSnapShotTemplate.IsVariableSetModified -eq $false -and $runbookSnapShotTemplate.IsLibraryVariableSetModified -eq $false)\n    {        \n        Write-OctopusInformation \"The runbook has not been modified since the published snapshot was created.  Checking to see if any of the packages have a new version.\"    \n        $runbookSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots/$($runbookToRun.PublishedRunbookSnapshotId)\" -method \"Get\" -item $null\n        $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n        foreach ($package in $runbookSnapShot.SelectedPackages)\n        {\n            foreach ($templatePackage in $snapshotTemplate.Packages)\n            {\n                if ($package.StepName -eq $templatePackage.StepName -and $package.ActionName -eq $templatePackage.ActionName -and $package.PackageReferenceName -eq $templatePackage.PackageReferenceName)\n                {\n                    $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($templatePackage.FeedId)/packages/versions?packageId=$($templatePackage.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n                    if ($packageVersion -ne $package.Version)\n                    {\n                        Write-OctopusInformation \"A newer version of a package was found, going to use that and create a new snapshot.\"\n                        return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId                    \n                    }\n                }\n            }\n        }\n\n        Write-OctopusInformation \"No new package versions have been found, using the published snapshot.\"\n        return $runbookToRun.PublishedRunbookSnapshotId\n    }\n    \n    Write-OctopusInformation \"The runbook has been modified since the snapshot was created, creating a new one.\"\n    return New-RunbookUnpublishedSnapshot -runbookToRun $runbookToRun -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n}\n\nfunction New-RunbookUnpublishedSnapshot\n{\n    param (\n        $runbookToRun,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId\n    )\n\n    $octopusProject = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"Get\" -item $null\n    $snapshotTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbooks/$($runbookToRun.Id)/runbookSnapShotTemplate\" -method \"Get\" -item $null\n\n    $runbookPackages = @()\n    foreach ($package in $snapshotTemplate.Packages)\n    {\n        $packageVersion = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"feeds/$($package.FeedId)/packages/versions?packageId=$($package.PackageId)\u0026take=1\" -method \"Get\" -item $null\n\n        if ($packageVersion.TotalResults -le 0)\n        {\n            Write-Error \"Unable to find a package version for $($package.PackageId).  This is required to create a new unpublished snapshot.  Exiting.\"\n            exit 1\n        }\n\n        $runbookPackages += @{\n            StepName = $package.StepName\n            ActionName = $package.ActionName\n            Version = $packageVersion.Items[0].Version\n            PackageReferenceName = $package.PackageReferenceName\n        }\n    }\n\n    $runbookSnapShotRequest = @{\n        FrozenProjectVariableSetId = \"variableset-$($runbookToRun.ProjectId)\"\n        FrozenRunbookProcessId = $($runbookToRun.RunbookProcessId)\n        LibraryVariableSetSnapshotIds = @($octopusProject.IncludedLibraryVariableSetIds)\n        Name = $($snapshotTemplate.NextNameIncrement)\n        ProjectId = $($runbookToRun.ProjectId)\n        ProjectVariableSetSnapshotId = \"variableset-$($runbookToRun.ProjectId)\"\n        RunbookId = $($runbookToRun.Id)\n        SelectedPackages = $runbookPackages\n    }\n\n    $newSnapShot = Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -endPoint \"runbookSnapshots\" -method \"POST\" -item $runbookSnapShotRequest\n\n    return $($newSnapShot.Id)\n}\n\nfunction Get-ProjectSlug\n{\n    param\n    (\n        $runbookToRun,\n        $projectToUse,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    if ($null -ne $projectToUse)\n    {\n        return $projectToUse.Slug\n    }\n\n    $project = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint \"projects/$($runbookToRun.ProjectId)\" -method \"GET\" -item $null\n\n    return $project.Slug\n}\n\nfunction Get-RunbookFormValues\n{\n    param (\n        $runbookPreview,\n        $runbookPromptedVariables        \n    )\n\n    $runbookFormValues = @{}\n\n    if ([string]::IsNullOrWhiteSpace($runbookPromptedVariables) -eq $true)\n    {\n        return $runbookFormValues\n    }    \n    \n    $promptedValueList = @(($runbookPromptedVariables -Split \"`n\").Trim())\n    Write-OctopusInformation $promptedValueList.Length\n    \n    foreach($element in $runbookPreview.Form.Elements)\n    {\n    \t$nameToSearchFor = $element.Control.Name\n        $uniqueName = $element.Name\n        $isRequired = $element.Control.Required\n        \n        $promptedVariablefound = $false\n        \n        Write-OctopusInformation \"Looking for the prompted variable value for $nameToSearchFor\"\n    \tforeach ($promptedValue in $promptedValueList)\n        {\n        \t$splitValue = $promptedValue -Split \"::\"\n            Write-OctopusInformation \"Comparing $nameToSearchFor with provided prompted variable $($promptedValue[0])\"\n            if ($splitValue.Length -gt 1)\n            {\n            \tif ($nameToSearchFor -eq $splitValue[0])\n                {\n                \tWrite-OctopusInformation \"Found the prompted variable value $nameToSearchFor\"\n                \t$runbookFormValues[$uniqueName] = $splitValue[1]\n                    $promptedVariableFound = $true\n                    break\n                }\n            }\n        }\n        \n        if ($promptedVariableFound -eq $false -and $isRequired -eq $true)\n        {\n        \tWrite-OctopusCritical \"Unable to find a value for the required prompted variable $nameToSearchFor, exiting\"\n            Exit 1\n        }\n    }\n\n    return $runbookFormValues\n}\n\nfunction Invoke-OctopusDeployRunbook\n{\n    param (\n        $runbookBody,\n        $runbookWaitForFinish,\n        $runbookCancelInSeconds,\n        $projectNameForUrl,        \n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentTaskApprovers,\n        $autoApproveRunbookRunManualInterventions,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $approvalEnvironmentName,\n        $parentRunbookId,\n        $parentTaskId\n    )\n\n    $runbookResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -item $runbookBody -method \"POST\" -endPoint \"runbookRuns\"\n\n    $runbookServerTaskId = $runBookResponse.TaskId\n    Write-OctopusInformation \"The task id of the new task is $runbookServerTaskId\"\n\n    $runbookRunId = $runbookResponse.Id\n    Write-OctopusInformation \"The runbook run id is $runbookRunId\"\n\n    Write-OctopusSuccess \"Runbook was successfully invoked, you can access the launched runbook [here]($defaultUrl/app#/$spaceId/projects/$projectNameForUrl/operations/runbooks/$($runbookBody.RunbookId)/snapshots/$($runbookBody.RunbookSnapShotId)/runs/$runbookRunId)\"\n\n    if ($runbookWaitForFinish -eq $false)\n    {\n        Write-OctopusInformation \"The wait for finish setting is set to no, exiting step\"\n        return\n    }\n    \n    if ($null -ne $runbookBody.QueueTime)\n    {\n    \tWrite-OctopusInformation \"The runbook queue time is set.  Exiting step\"\n        return\n    }\n\n    Write-OctopusSuccess \"The setting to wait for completion was set, waiting until task has finished\"\n    $startTime = Get-Date\n    $currentTime = Get-Date\n    $dateDifference = $currentTime - $startTime\n\t\n    $taskStatusUrl = \"tasks/$runbookServerTaskId\"\n    $numberOfWaits = 0    \n    \n    While ($dateDifference.TotalSeconds -lt $runbookCancelInSeconds)\n    {\n        Write-OctopusInformation \"Waiting 5 seconds to check status\"\n        Start-Sleep -Seconds 5\n        $taskStatusResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint $taskStatusUrl -method \"GET\" -item $null\n        $taskStatusResponseState = $taskStatusResponse.State\n\n        if ($taskStatusResponseState -eq \"Success\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of Success\"\n            exit 0            \n        }\n        elseif($taskStatusResponseState -eq \"Failed\" -or $taskStatusResponseState -eq \"Canceled\")\n        {\n            Write-OctopusSuccess \"The task has finished with a status of $taskStatusResponseState status, stopping the run/deployment\"\n            exit 1            \n        }\n        elseif($taskStatusResponse.HasPendingInterruptions -eq $true)\n        {\n            if ($autoApproveRunbookRunManualInterventions -eq \"Yes\")\n            {\n                Submit-RunbookRunForAutoApproval -createdRunbookRun $createdRunbookRun -parentTaskApprovers $parentTaskApprovers -defaultUrl $DefaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -parentProjectName $parentProjectName -parentReleaseNumber $parentReleaseNumber -parentEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $parentTaskId\n            }\n            else\n            {\n                if ($numberOfWaits -ge 10)\n                {\n                    Write-OctopusSuccess \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"\n                }\n                else\n                {\n                    Write-OctopusInformation \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"                        \n                }\n            }\n        }\n        \n        $numberOfWaits += 1\n        if ($numberOfWaits -ge 10)\n        {\n        \tWrite-OctopusSuccess \"The task state is currently $taskStatusResponseState\"\n        \t$numberOfWaits = 0\n        }\n        else\n        {\n        \tWrite-OctopusInformation \"The task state is currently $taskStatusResponseState\"\n        }  \n        \n        $startTime = $taskStatusResponse.StartTime\n        if ($startTime -eq $null -or [string]::IsNullOrWhiteSpace($startTime) -eq $true)\n        {        \n        \tWrite-OctopusInformation \"The task is still queued, let's wait a bit longer\"\n        \t$startTime = Get-Date\n        }\n        $startTime = [DateTime]$startTime\n        \n        $currentTime = Get-Date\n        $dateDifference = $currentTime - $startTime        \n    }\n    \n    Write-OctopusSuccess \"The cancel timeout has been reached, cancelling the runbook run\"\n    $cancelResponse = Invoke-RestMethod \"$runbookBaseUrl/api/tasks/$runbookServerTaskId/cancel\" -Headers $header -Method Post\n    Write-OctopusSuccess \"Exiting with an error code of 1 because we reached the timeout\"\n    exit 1\n}\n\nfunction Get-QueueDate\n{\n\tparam ( \n    \t$futureDeploymentDate\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($futureDeploymentDate) -or $futureDeploymentDate -eq \"N/A\")\n    {\n    \treturn $null\n    }\n    \n    [datetime]$outputDate = New-Object DateTime\n    $currentDate = Get-Date\n\n    if ([datetime]::TryParse($futureDeploymentDate, [ref]$outputDate) -eq $false)\n    {\n        Write-OctopusCritical \"The suppplied date $futureDeploymentDate cannot be parsed by DateTime.TryParse.  Please verify format and try again.  Please [refer to Microsoft's Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.datetime.tryparse) on supported formats.\"\n        exit 1\n    }\n    \n    if ($currentDate -gt $outputDate)\n    {\n    \tWrite-OctopusCritical \"The supplied date $futureDeploymentDate is set for the past.  All queued deployments must be in the future.\"\n        exit 1\n    }\n    \n    return $outputDate\n}\n\nfunction Get-QueueExpiryDate\n{\n\tparam (\n    \t$queueDate\n    )\n    \n    if ($null -eq $queueDate)\n    {\n    \treturn $null\n    }\n    \n    return $queueDate.AddHours(1)\n}\n\nfunction Get-RunbookSpecificMachines\n{\n    param (\n        $runbookPreview,\n        $runbookMachines,        \n        $runbookRunName        \n    )\n\n    if ($runbookMachines -eq \"N/A\")\n    {\n        return @()\n    }\n\n    if ([string]::IsNullOrWhiteSpace($runbookMachines) -eq $true)\n    {\n        return @()\n    }\n\n    $translatedList = Get-MachineIdsFromMachineNames -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -targetMachines $runbookMachines\n\n    $filteredList = @()    \n    foreach ($runbookMachine in $translatedList)\n    {    \t\n    \t$runbookMachineId = $runbookMachine.Trim().ToLower()\n    \tWrite-OctopusVerbose \"Checking if $runbookMachineId is set to run on any of the runbook steps\"\n        \n        foreach ($step in $runbookPreview.StepsToExecute)\n        {\n            foreach ($machine in $step.Machines)\n            {\n            \tWrite-OctopusVerbose \"Checking if $runbookMachineId matches $($machine.Id) and it isn't already in the $($filteredList -join \",\")\"\n                if ($runbookMachineId -eq $machine.Id.Trim().ToLower() -and $filteredList -notcontains $machine.Id)\n                {\n                \tWrite-OctopusInformation \"Adding $($machine.Id) to the list\"\n                    $filteredList += $machine.Id\n                }\n            }\n        }\n    }\n\n    if ($filteredList.Length -le 0)\n    {\n        Write-OctopusSuccess \"The current task is targeting specific machines, but the runbook $runBookRunName does not run against any of these machines $runbookMachines. Skipping this run.\"\n        exit 0\n    }\n\n    return $filteredList\n}\n\nfunction Get-ParentTaskApprovers\n{\n    param (\n        $parentTaskId,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n    \n    $approverList = @()\n    if ($null -eq $parentTaskId)\n    {\n    \tWrite-OctopusInformation \"The deployment task id to pull the approvers from is null, return an empty approver list\"\n    \treturn $approverList\n    }\n\n    Write-OctopusInformation \"Getting all the events from the parent project\"\n    $parentEvents = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"events?regardingAny=$parentTaskId\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"\n    \n    foreach ($parentEvent in $parentEvents.Items)\n    {\n        Write-OctopusVerbose \"Checking $($parentEvent.Message) for manual intervention\"\n        if ($parentEvent.Message -like \"Submitted interruption*\")\n        {\n            Write-OctopusVerbose \"The event $($parentEvent.Id) is a manual intervention approval event which was approved by $($parentEvent.Username).\"\n\n            $approverExists = $approverList | Where-Object {$_.Id -eq $parentEvent.UserId}        \n\n            if ($null -eq $approverExists)\n            {\n                $approverInformation = @{\n                    Id = $parentEvent.UserId;\n                    Username = $parentEvent.Username;\n                    Teams = @()\n                }\n\n                $approverInformation.Teams = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"teammembership?userId=$($approverInformation.Id)\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"            \n\n                Write-OctopusVerbose \"Adding $($approverInformation.Id) to the approval list\"\n                $approverList += $approverInformation\n            }        \n        }\n    }\n\n    return $approverList\n}\n\nfunction Get-ApprovalTaskIdFromDeployment\n{\n    param (\n        $parentReleaseId,\n        $approvalEnvironment,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n\n    $releaseDeploymentList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"releases/$parentReleaseId/deployments\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    \n    $lastDeploymentTime = $(Get-Date).AddYears(-50)\n    $approvalTaskId = $null\n    foreach ($deployment in $releaseDeploymentList.Items)\n    {\n        if ($deployment.EnvironmentId -ne $approvalEnvironment.Id)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) deployed to $($deployment.EnvironmentId) which doesn't match $($approvalEnvironment.Id).\"\n            continue\n        }\n        \n        Write-OctopusInformation \"The deployment $($deployment.Id) was deployed to the approval environment $($approvalEnvironment.Id).\"\n\n        $deploymentTask = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $null -endPoint \"tasks/$($deployment.TaskId)\" -apiKey $octopusApiKey -Method \"Get\"\n        if ($deploymentTask.IsCompleted -eq $true -and $deploymentTask.FinishedSuccessfully -eq $false)\n        {\n            Write-Information \"The deployment $($deployment.Id) was deployed to the approval environment, but it encountered a failure, moving onto the next deployment.\"\n            continue\n        }\n\n        if ($deploymentTask.StartTime -gt $lastDeploymentTime)\n        {\n            $approvalTaskId = $deploymentTask.Id\n            $lastDeploymentTime = $deploymentTask.StartTime\n        }\n    }        \n\n    if ($null -eq $approvalTaskId)\n    {\n    \tWrite-OctopusVerbose \"Unable to find a deployment to the environment, determining if it should've happened already.\"\n        $channelInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$parentChannelId\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n        $lifecycle = Get-OctopusLifeCycle -channel $channelInformation -defaultUrl $defaultUrl -spaceId $spaceId -OctopusApiKey $octopusApiKey\n        $lifecyclePhases = Get-LifecyclePhases -lifecycle $lifecycle -defaultUrl $defaultUrl -spaceId $spaceid -OctopusApiKey $octopusApiKey\n        \n        $foundDestinationFirst = $false\n        $foundApprovalFirst = $false\n        \n        foreach ($phase in $lifecyclePhases.Phases)\n        {\n        \tif ($phase.AutomaticDeploymentTargets -contains $parentEnvironmentId -or $phase.OptionalDeploymentTargets -contains $parentEnvironmentId)\n            {\n            \tif ($foundApprovalFirst -eq $false)\n                {\n                \t$foundDestinationFirst = $true\n                }\n            }\n            \n            if ($phase.AutomaticDeploymentTargets -contains $approvalEnvironment.Id -or $phase.OptionalDeploymentTargets -contains $approvalEnvironment.Id)\n            {\n            \tif ($foundDestinationFirst -eq $false)\n                {\n                \t$foundApprovalFirst = $true\n                }\n            }\n        }\n        \n        $messageToLog = \"Unable to find a deployment for the environment $approvalEnvironmentName.  Auto approvals are disabled.\"\n        if ($foundApprovalFirst -eq $true)\n        {\n        \tWrite-OctopusWarning $messageToLog\n        }\n        else\n        {\n        \tWrite-OctopusInformation $messageToLog\n        }\n        \n        return $null\n    }\n\n    return $approvalTaskId\n}\n\nfunction Get-ApprovalTaskIdFromRunbook\n{\n    param (\n        $parentRunbookId,\n        $approvalEnvironment,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey \n    )\n}\n\nfunction Get-ApprovalTaskId\n{\n\tparam (\n    \t$autoApproveRunbookRunManualInterventions,\n        $parentTaskId,\n        $parentReleaseId,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $approvalEnvironmentName,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey        \n    )\n    \n    if ($autoApproveRunbookRunManualInterventions -eq $false)\n    {\n    \tWrite-OctopusInformation \"Auto approvals are disabled, skipping pulling the approval deployment task id\"\n        return $null\n    }\n    \n    if ([string]::IsNullOrWhiteSpace($approvalEnvironmentName) -eq $true)\n    {\n    \tWrite-OctopusInformation \"Approval environment not supplied, using the current environment id for approvals.\"\n        return $parentTaskId\n    }\n    \n    if ($approvalEnvironmentName.ToLower().Trim() -eq $parentEnvironmentName.ToLower().Trim())\n    {\n        Write-OctopusInformation \"The approval environment is the same as the current environment, using the current task id $parentTaskId\"\n        return $parentTaskId\n    }\n    \n    $approvalEnvironment = Get-OctopusItemFromListEndpoint -itemNameToFind $approvalEnvironmentName -itemType \"Environment\" -defaultUrl $DefaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -defaultValue $null -endpoint \"environments\"\n    \n    if ([string]::IsNullOrWhiteSpace($parentReleaseId) -eq $false)\n    {\n        return Get-ApprovalTaskIdFromDeployment -parentReleaseId $parentReleaseId -approvalEnvironment $approvalEnvironment -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId\n    }\n\n    return Get-ApprovalTaskIdFromRunbook -parentRunbookId $parentRunbookId -approvalEnvironment $approvalEnvironment -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n}\n\nfunction Get-OctopusLifecycle\n{\n    param (\n        $channel,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the lifecycle information $($channel.Name)\"\n    if ($null -eq $channel.LifecycleId)\n    {\n        $lifecycleName = \"Default Lifecycle\"\n        $lifecycleList = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles?partialName=$([uri]::EscapeDataString($lifecycleName))\u0026skip=0\u0026take=1\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $lifecycle = $lifecycleList.Items[0]\n    }\n    else\n    {\n        $lifecycle = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($channel.LifecycleId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n    }\n\n    Write-Host \"Successfully found the lifecycle $($lifecycle.Name) to use for this channel.\"\n\n    return $lifecycle\n}\n\nfunction Get-LifecyclePhases\n{\n    param (\n        $lifecycle,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the phase in the lifecycle $($lifecycle.Name) with the environment $environmentName to find the previous phase.\"\n    if ($lifecycle.Phases.Count -eq 0)\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has no set phases, calling the preview endpoint.\"\n        $lifecyclePreview = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"lifecycles/$($lifecycle.Id)/preview\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        $phases = $lifecyclePreview.Phases\n    }\n    else\n    {\n        Write-OctopusInformation \"The lifecycle $($lifecycle.Name) has set phases, using those.\"\n        $phases = $lifecycle.Phases    \n    }\n\n    Write-OctopusInformation \"Found $($phases.Length) phases in this lifecycle.\"\n    return $phases\n}\n\nfunction Submit-RunbookRunForAutoApproval\n{\n    param (\n        $createdRunbookRun,\n        $parentTaskApprovers,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $parentRunbookId,\n        $parentEnvironmentName,\n        $parentTaskId        \n    )\n\n    Write-OctopusSuccess \"The task has a pending manual intervention.  Checking parent approvals.\"    \n    $manualInterventionInformation = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions?regarding=$($createdRunbookRun.TaskId)\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n    foreach ($manualIntervention in $manualInterventionInformation.Items)\n    {\n        if ($manualIntervention.IsPending -eq $false)\n        {\n            Write-OctopusInformation \"This manual intervention has already been approved.  Proceeding onto the next one.\"\n            continue\n        }\n\n        if ($manualIntervention.CanTakeResponsibility -eq $false)\n        {\n            Write-OctopusSuccess \"The user associated with the API key doesn't have permissions to take responsibility for the manual intervention.\"\n            Write-OctopusSuccess \"If you wish to leverage the auto-approval functionality give the user permissions.\"\n            continue\n        }        \n\n        $automaticApprover = $null\n        Write-OctopusVerbose \"Checking to see if one of the parent project approvers is assigned to one of the manual intervention teams $($manualIntervention.ResponsibleTeamIds)\"\n        foreach ($approver in $parentTaskApprovers)\n        {\n            foreach ($approverTeam in $approver.Teams)\n            {\n                Write-OctopusVerbose \"Checking to see if $($manualIntervention.ResponsibleTeamIds) contains $($approverTeam.TeamId)\"\n                if ($manualIntervention.ResponsibleTeamIds -contains $approverTeam.TeamId)\n                {\n                    $automaticApprover = $approver\n                    break\n                }\n            }\n\n            if ($null -ne $automaticApprover)\n            {\n                break\n            }\n        }\n\n        if ($null -ne $automaticApprover)\n        {\n        \tWrite-OctopusSuccess \"Matching approver found auto-approving.\"\n            if ($manualIntervention.HasResponsibility -eq $false)\n            {\n                Write-OctopusInformation \"Taking over responsibility for this manual intervention.\"\n                $takeResponsiblilityResponse = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/responsible\" -method \"PUT\" -apiKey $octopusApiKey -spaceId $spaceId\n                Write-OctopusVerbose \"Response from taking responsibility $($takeResponsiblilityResponse.Id)\"\n            }\n            \n            if ([string]::IsNullOrWhiteSpace($parentReleaseNumber) -eq $false)\n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName release $parentReleaseNumber to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that deployment $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n            else \n            {\n                $notes = \"Auto-approving this runbook run.  Parent project $parentProjectName runbook run $parentRunbookId to $parentEnvironmentName with the task id $parentTaskId was approved by $($automaticApprover.UserName).  That user is a member of one of the teams this manual intervention requires.  You can view that runbook run $defaultUrl/app#/$spaceId/tasks/$parentTaskId\"\n            }\n\n            $submitApprovalBody = @{\n                Instructions = $null;\n                Notes = $notes\n                Result = \"Proceed\"\n            }\n            $submitResult = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/submit\" -method \"POST\" -apiKey $octopusApiKey -item $submitApprovalBody -spaceId $spaceId\n            Write-OctopusSuccess \"Successfully auto approved the manual intervention $($submitResult.Id)\"\n        }\n        else\n        {\n            Write-OctopusSuccess \"Couldn't find an approver to auto-approve the child project.  Waiting until timeout or child project is approved.\"    \n        }\n    }\n}\n\n\n$runbookWaitForFinish = GetCheckboxBoolean -Value $runbookWaitForFinish\n$runbookUseGuidedFailure = GetCheckboxBoolean -Value $runbookUseGuidedFailure\n$runbookUsePublishedSnapshot = GetCheckboxBoolean -Value $runbookUsePublishedSnapshot\n$runbookCancelInSeconds = [int]$runbookCancelInSeconds\n\nWrite-OctopusInformation \"Wait for Finish Before Check: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure Before Check: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Use Published Snapshot Before Check: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Runbook Name $runbookRunName\"\nWrite-OctopusInformation \"Runbook Base Url: $runbookBaseUrl\"\nWrite-OctopusInformation \"Runbook Space Name: $runbookSpaceName\"\nWrite-OctopusInformation \"Runbook Environment Name: $runbookEnvironmentName\"\nWrite-OctopusInformation \"Runbook Tenant Name: $runbookTenantName\"\nWrite-OctopusInformation \"Wait for Finish: $runbookWaitForFinish\"\nWrite-OctopusInformation \"Use Guided Failure: $runbookUseGuidedFailure\"\nWrite-OctopusInformation \"Cancel run in seconds: $runbookCancelInSeconds\"\nWrite-OctopusInformation \"Use Published Snapshot: $runbookUsePublishedSnapshot\"\nWrite-OctopusInformation \"Auto Approve Runbook Run Manual Interventions: $autoApproveRunbookRunManualInterventions\"\nWrite-OctopusInformation \"Auto Approve environment name to pull approvals from: $approvalEnvironmentName\"\n\nWrite-OctopusInformation \"Octopus runbook run machines: $runbookMachines\"\nWrite-OctopusInformation \"Parent Task Id: $parentTaskId\"\nWrite-OctopusInformation \"Parent Release Id: $parentReleaseId\"\nWrite-OctopusInformation \"Parent Channel Id: $parentChannelId\"\nWrite-OctopusInformation \"Parent Environment Id: $parentEnvironmentId\"\nWrite-OctopusInformation \"Parent Runbook Id: $parentRunbookId\"\nWrite-OctopusInformation \"Parent Environment Name: $parentEnvironmentName\"\nWrite-OctopusInformation \"Parent Release Number: $parentReleaseNumber\"\n\n$verificationPassed = @()\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookRunName -variableName \"Runbook Name\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookBaseUrl -variableName \"Base Url\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookApiKey -variableName \"Api Key\"\n$verificationPassed += Test-RequiredValues -variableToCheck $runbookEnvironmentName -variableName \"Environment Name\"\n\nif ($verificationPassed -contains $false)\n{\n\tWrite-OctopusInformation \"Required values missing\"\n\tExit 1\n}\n\n$runbookSpace = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookSpaceName -endpoint \"spaces\" -spaceId $null -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl -itemType \"Space\" -defaultValue $octopusSpaceId\n$runbookSpaceId = $runbookSpace.Id\n\n$projectToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookProjectName -endpoint \"projects\" -spaceId $runbookSpaceId -defaultValue $null -itemType \"Project\" -octopusApiKey $runbookApiKey -defaultUrl $runbookBaseUrl\nif ($null -ne $projectToUse)\n{\t    \n    $runbookEndPoint = \"projects/$($projectToUse.Id)/runbooks\"\n}\nelse\n{\n\t$runbookEndPoint = \"runbooks\"\n}\n\n$environmentToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookEnvironmentName -itemType \"Environment\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -defaultValue $null -endpoint \"environments\"\n\n$runbookToRun = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookRunName -itemType \"Runbook\" -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -endpoint $runbookEndPoint -octopusApiKey $runbookApiKey -defaultValue $null\n\n$runbookSnapShotIdToUse = Get-RunbookSnapshotIdToRun -runbookToRun $runbookToRun -runbookUsePublishedSnapshot $runbookUsePublishedSnapshot -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $octopusSpaceId\n$projectNameForUrl = Get-ProjectSlug -projectToUse $projectToUse -runbookToRun $runbookToRun -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId\n\n$tenantToUse = Get-OctopusItemFromListEndpoint -itemNameToFind $runbookTenantName -itemType \"Tenant\" -defaultValue $null -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey -endpoint \"tenants\" -defaultUrl $runbookBaseUrl\nif ($null -ne $tenantToUse)\n{\t\n    $tenantIdToUse = $tenantToUse.Id    \n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)/$($tenantIdToUse)\" -method \"GET\" -item $null\n}\nelse\n{\n    $runBookPreview = Invoke-OctopusApi -octopusUrl $runbookBaseUrl -spaceId $runbookSpaceId -apiKey $runbookApiKey -endPoint \"runbooks/$($runbookToRun.Id)/runbookRuns/preview/$($environmentToUse.Id)\" -method \"GET\" -item $null\n}\n\n$childRunbookRunSpecificMachines = Get-RunbookSpecificMachines -runbookPreview $runBookPreview -runbookMachines $runbookMachines -runbookRunName $runbookRunName\n$runbookFormValues = Get-RunbookFormValues -runbookPreview $runBookPreview -runbookPromptedVariables $runbookPromptedVariables\n\n$queueDate = Get-QueueDate -futureDeploymentDate $runbookFutureDeploymentDate\n$queueExpiryDate = Get-QueueExpiryDate -queueDate $queueDate\n\n$runbookBody = @{\n    RunbookId = $($runbookToRun.Id);\n    RunbookSnapShotId = $runbookSnapShotIdToUse;\n    FrozenRunbookProcessId = $null;\n    EnvironmentId = $($environmentToUse.Id);\n    TenantId = $tenantIdToUse;\n    SkipActions = @();\n    QueueTime = $queueDate;\n    QueueTimeExpiry = $queueExpiryDate;\n    FormValues = $runbookFormValues;\n    ForcePackageDownload = $false;\n    ForcePackageRedeployment = $true;\n    UseGuidedFailure = $runbookUseGuidedFailure;\n    SpecificMachineIds = @($childRunbookRunSpecificMachines);\n    ExcludedMachineIds = @()\n}\n\n$approvalTaskId = Get-ApprovalTaskId -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentTaskId $parentTaskId -parentReleaseId $parentReleaseId -parentRunbookId $parentRunbookId -parentEnvironmentName $parentEnvironmentName -approvalEnvironmentName $approvalEnvironmentName -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -defaultUrl $runbookBaseUrl -spaceId $runbookSpaceId -octopusApiKey $runbookApiKey\n$parentTaskApprovers = Get-ParentTaskApprovers -parentTaskId $approvalTaskId -spaceId $runbookSpaceId -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey\n\nInvoke-OctopusDeployRunbook -runbookBody $runbookBody -runbookWaitForFinish $runbookWaitForFinish -runbookCancelInSeconds $runbookCancelInSeconds -projectNameForUrl $projectNameForUrl -defaultUrl $runbookBaseUrl -octopusApiKey $runbookApiKey -spaceId $runbookSpaceId -parentTaskApprovers $parentTaskApprovers -autoApproveRunbookRunManualInterventions $autoApproveRunbookRunManualInterventions -parentProjectName $projectNameForUrl -parentReleaseNumber $parentReleaseNumber -approvalEnvironmentName $approvalEnvironmentName -parentRunbookId $parentRunbookId -parentTaskId $approvalTaskId"
        "Octopus.Action.RunOnServer"                      = "true"
        "Run.Runbook.UsePublishedSnapShot"                = "True"
        "Run.Runbook.Api.Key"                             = "#{DemoSpaceCreator.Octopus.APIKey}"
        "Octopus.Action.Script.Syntax"                    = "PowerShell"
        "Run.Runbook.Project.Name"                        = "Instance Manager"
        "Run.Runbook.CancelInSeconds"                     = "1800"
        "Run.Runbook.Name"                                = "Delete tenant"
        "Run.Runbook.PromptedVariables"                   = "DemoSpaceCreator.DeleteTenant.TenantId::#{Octopus.Deployment.Tenant.Id}"
        "Run.Runbook.Space.Name"                          = "#{Octopus.Space.Name}"
        "Run.Runbook.Base.Url"                            = "#{Octopus.Web.ServerUri}"
        "Run.Runbook.DateTime"                            = "N/A"
        "Octopus.Action.Script.ScriptSource"              = "Inline"
        "Run.Runbook.AutoApproveManualInterventions"      = "No"
        "Run.Runbook.Waitforfinish"                       = "False"
        "Run.Runbook.Machines"                            = "N/A"
        "Run.Runbook.Environment.Name"                    = "#{Octopus.Environment.Name}"
        "Run.Runbook.ManualIntervention.EnvironmentToUse" = "#{Octopus.Environment.Name}"
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
  depends_on = [octopusdeploy_tag_set.tagset_state, octopusdeploy_tag.tag_created]
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = "https://dev138661.service-now.com/"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = "octopus"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_james_c" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_james_c.id}"
  value                   = "James' demo space"
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_shawn_sesna" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_shawn_sesna.id}"
  value                   = "shawn.sesna@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "mark.harrison@octopus.com"
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = "ndc.demo.octopus.app"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

variable "demo_space_creator_demospacecreator_createtenant_createecsdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateECSDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createecsdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createecsdemo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateECSDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.6: Create ECS Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = "bfe7aca9561311107d74c64615bafbdb"
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_mark_lamprecht" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value          = "True"
}

data "octopusdeploy_worker_pools" "workerpool_hosted_ubuntu" {
  ids          = null
  partial_name = "Hosted Ubuntu"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a worker pool called \"Hosted Ubuntu\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.worker_pools) != 0
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "https://stormer.atlassian.net"
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "False"
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_rob_pearson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_pearson.id}"
  value                   = "d21c10b8ab382110b598dc751f0de0d7"
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

variable "demo_space_creator_demospacecreator_createtenant_createtenantsdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateTenantsDemo"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createtenantsdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createtenantsdemo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateTenantsDemo"
  type         = "String"
  description  = ""
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.3: Create Tenants Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

variable "demo_space_creator_demospacecreator_prompts_createkubernetesdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateKubernetesDemo"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createkubernetesdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createkubernetesdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateKubernetesDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "05. Create Kubernetes Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "fe18bc11f7e7311081521b677423ceca"
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "adam.close@octopus.com\ntony.kelly@octopus.com\nrobert.vanhaaren@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = "https://rousseau.atlassian.net/"
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "james.chatmas@octopus.com"
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "harrisonmeister"
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_runbook_process" "runbook_process_demo_space_creator_quick_start" {
  runbook_id = "${octopusdeploy_runbook.runbook_demo_space_creator_quick_start.id}"

  step {
    condition           = "Success"
    name                = "Check tenant name length"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Check tenant name length"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "Octopus.Action.RunOnServer"         = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax"       = "PowerShell"
        "Octopus.Action.Script.ScriptBody"   = "$name = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.TenantName\"]\n\nif ($name.Length -gt 20) {\n\tFail-Step \"`\"$name`\" is more than 20 characters. Please update your tenant name to be 20 characters or fewer. This is a limitation of space names.\"\n}"
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
    name                = "Clone template tenant"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Clone template tenant"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "CloneTenantStep_CloneTags"          = "True"
        "Octopus.Action.Script.ScriptBody"   = "$securityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12\n[Net.ServicePointManager]::SecurityProtocol = $securityProtocol\n\n$octopusBaseUrl = $CloneTenantStep_OctopusUrl.Trim('/')\n$apiKey = $CloneTenantStep_ApiKey\n$tenantToClone = $CloneTenantStep_TenantIdToClone\n$tenantName = $CloneTenantStep_TenantName\n$cloneVariables = $CloneTenantStep_CloneVariables\n$cloneTags = $CloneTenantStep_CloneTags\n$spaceId = $CloneTenantStep_SpaceId\n\n$ErrorActionPreference = 'Stop'\n\nif ([string]::IsNullOrWhiteSpace($octopusBaseUrl)) {\n    throw \"The step parameter 'Octopus Base Url' was not found. This step requires the Octopus Server URL to function, please provide one and try again.\"\n}\n\nif ([string]::IsNullOrWhiteSpace($apiKey)) {\n    throw \"The step parameter 'Octopus API Key' was not found. This step requires an API Key to function, please provide one and try again.\"\n}\n\nif ([string]::IsNullOrWhiteSpace($tenantToClone)) {\n    throw \"The step parameter 'Id of Tenant to Clone' was not found. Please provide one and try again.\"\n}\n\nif ([string]::IsNullOrWhiteSpace($tenantName)) {\n    throw \"The step parameter 'New Tenant Name' was not found. Please provide one and try again.\"\n}\n\nfunction Invoke-OctopusApi {\n    param(\n        [Parameter(Position = 0, Mandatory)]$Uri,\n        [ValidateSet(\"Get\", \"Post\", \"Put\", \"Delete\")]$Method = 'Get',\n        $Body\n    )\n    \n    $uriParts = @($octopusBaseUrl, $Uri.TrimStart('/'))    \n    $uri = ($uriParts -join '/')\n\n    Write-Verbose \"Uri: $uri\"\n    \n    $requestParameters = @{\n        Uri = $uri\n        Method = $Method\n        Headers = @{ \"X-Octopus-ApiKey\" = $apiKey }\n        UseBasicParsing = $true\n    }\n    \n    if ($null -ne $Body) { $requestParameters.Add('Body', ($Body | ConvertTo-Json -Depth 10)) }\n    \n    return Invoke-WebRequest @requestParameters | % Content | ConvertFrom-Json\n}\n\nfunction Test-SpacesApi {\n\tWrite-Verbose \"Checking API compatibility\";\n\t$rootDocument = Invoke-OctopusApi 'api/';\n    if($rootDocument.Links -ne $null -and $rootDocument.Links.Spaces -ne $null) {\n    \tWrite-Verbose \"Spaces API found\"\n    \treturn $true;\n    }\n    Write-Verbose \"Pre-spaces API found\"\n    return $false;\n}\n\nif([string]::IsNullOrWhiteSpace($spaceId)) {\n\tif(Test-SpacesApi) {\n      \t$spaceId = $OctopusParameters['Octopus.Space.Id'];\n      \tif([string]::IsNullOrWhiteSpace($spaceId)) {\n          \tthrow \"This step needs to be run in a context that provides a value for the 'Octopus.Space.Id' system variable. In this case, we received a blank value, which isn't expected - please reach out to our support team at https://help.octopus.com if you encounter this error or try providing the Space Id parameter.\";\n      \t}\n\t}\n}\n\n$apiPrefix = \"api/\"\n$tenantUrlBase = @($octopusBaseUrl, 'app#')\n\nif ($spaceId) {\n\t$apiPrefix += $spaceId\n    $tenantUrlBase += $spaceId\n}\n\nWrite-Host \"Fetching source tenant\"\n$tenant = Invoke-OctopusApi \"$apiPrefix/tenants/$tenantToClone\"\n\n$sourceTenantId = $tenant.Id\n$sourceTenantName = $tenant.Name\n$tenant.Id = $null\n$tenant.Name = $tenantName\n\nif ($cloneTags -ne $true) {\n\tWrite-Host \"Clearing tenant tags\"\n    $tenant.TenantTags = @()\n}\n\nWrite-Host \"Creating new tenant\"\n$newTenant = Invoke-OctopusApi \"$apiPrefix/tenants\" -Method Post -Body $tenant\n\nif ($cloneVariables -eq $true) {\n\tWrite-Host \"Cloning variables\"\n    $variables = Invoke-OctopusApi $tenant.Links.Variables\n    $variables.TenantId = $newTenant.Id\n    $variables.TenantName = $tenantName\n\n    Invoke-OctopusApi $newTenant.Links.Variables -Method Put -Body $variables | Out-Null\n}\n\n$tenantUrl = ($tenantUrlBase + \"tenants\" + $newTenant.Id + \"overview\") -join '/'\n$sourceTenantUrl = ($tenantUrlBase + \"tenants\" + $sourceTenantId + \"overview\") -join '/'\n\nSet-OctopusVariable -Name \"TenantId\" -Value $newTenant.Id\n\nWrite-Highlight \"New tenant [$tenantName]($tenantUrl) has been cloned from [$sourceTenantName]($sourceTenantUrl)\""
        "CloneTenantStep_OctopusUrl"         = "#{if Octopus.Web.ServerUri}#{Octopus.Web.ServerUri}#{else}#{Octopus.Web.BaseUrl}#{/if}"
        "CloneTenantStep_SpaceId"            = "#{Octopus.Space.Id}"
        "CloneTenantStep_ApiKey"             = "#{DemoSpaceCreator.Octopus.APIKey}"
        "CloneTenantStep_TenantIdToClone"    = "Tenants-269"
        "Octopus.Action.Script.Syntax"       = "PowerShell"
        "Octopus.Action.RunOnServer"         = "true"
        "CloneTenantStep_TenantName"         = "#{DemoSpaceCreator.CreateTenant.TenantName}"
        "Octopus.Action.Script.ScriptSource" = "Inline"
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
    name                = "Set common variables"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Set common variables"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "Octopus.Action.RunOnServer"         = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax"       = "PowerShell"
        "Octopus.Action.Script.ScriptBody"   = "$octopusURL = \"https://demo.octopus.app\"\n$octopusAPIKey = $OctopusParameters[\"DemoSpaceCreator.Octopus.APIKey\"]\n$spaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n\n##PROCESS\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$tenantId = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.ClonedTenantId\"]\n\n$variablesUri = \"$OctopusURL/api/$spaceId/tenants/$tenantId/variables\"\n\n$variables = (Invoke-RestMethod $variablesUri -Headers $header)\n\n$libraryVars = $variables.LibraryVariables\n\n\n### DSC ###\n\n$dsc = $libraryVars.\"LibraryVariableSets-267\"\n\n$dsc.Variables | Add-Member -NotePropertyName \"f77b7a30-6426-4229-b71d-b2a4a4ed45a5\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.UserEmail\"]\n$dsc.Variables | Add-Member -NotePropertyName \"a413e201-b146-4e0e-af6f-4796ae6f0add\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.SpaceDescription\"]\n\n\n### CAC ###\n\n$cac = $libraryVars.\"LibraryVariableSets-541\"\n\n$cac.Variables | Add-Member -NotePropertyName \"9681f304-170d-427a-9e33-8b8739b4e698\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.GitHubUsername\"]\n$cac.Variables | Add-Member -NotePropertyName \"4e8be2bf-9827-4fd6-b9b5-86b11b127195\" -NotePropertyValue ([PsCustomObject]@{\n    HasValue = $true\n    NewValue = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.GitHubPAT\"]\n})\n$cac.Variables | Add-Member -NotePropertyName \"79c3f193-d087-4c74-b01f-d313d1601d07\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.GitHubRepositoryName\"]\n\n\n### JSM ###\n\n$jsm = $libraryVars.\"LibraryVariableSets-1401\"\n\n$jsm.Variables | Add-Member -NotePropertyName \"43c203aa-748a-44ac-b3a2-3ac90e50c16f\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.JSMBaseUrl\"]\n$jsm.Variables | Add-Member -NotePropertyName \"49d581c2-577c-4c9a-8a84-db75b723ccc1\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.JSMUsername\"]\n$jsm.Variables | Add-Member -NotePropertyName \"7096b076-5e1d-43d8-b467-3ed6ccc9a070\" -NotePropertyValue ([PsCustomObject]@{\n    HasValue = $true\n    NewValue = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.JSMUserToken\"]\n})\n$jsm.Variables | Add-Member -NotePropertyName \"1c3ca56c-0ce2-498f-994d-46c45cbae343\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.JSMProjectName\"]\n\n\n### SNOW ###\n\n$snow = $libraryVars.\"LibraryVariableSets-542\"\n\n$snow.Variables | Add-Member -NotePropertyName \"28e3ecc9-e671-40c9-978a-8b4470a06fc4\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.SNOWBaseUrl\"]\n$snow.Variables | Add-Member -NotePropertyName \"8e31b85c-2387-4c4b-b728-ad236eba01e9\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.SNOWOAuthClientId\"]\n$snow.Variables | Add-Member -NotePropertyName \"6f7fab04-d064-44df-bac4-f992b60f6b48\" -NotePropertyValue ([PsCustomObject]@{\n    HasValue = $true\n    NewValue = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.SNOWClientSecret\"]\n})\n$snow.Variables | Add-Member -NotePropertyName \"35654467-ca9b-46c0-8560-607d282a3b00\" -NotePropertyValue $OctopusParameters[\"DemoSpaceCreator.CreateTenant.SNOWServiceAccountUser\"]\n$snow.Variables | Add-Member -NotePropertyName \"18dfaa58-28ff-4878-a582-9e97c833496d\" -NotePropertyValue ([PsCustomObject]@{\n    HasValue = $true\n    NewValue = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.SNOWServiceAccountUserPassword\"]\n})\n\n$variables = (Invoke-RestMethod $variablesUri -Method PUT -Headers $header -Body ($variables | ConvertTo-Json -depth 10))\n"
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
    name                = "Set tenant role"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Set tenant role"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "Octopus.Action.Script.Syntax"       = "PowerShell"
        "Octopus.Action.Script.ScriptBody"   = "$octopusURL = \"https://demo.octopus.app\"\n$octopusAPIKey = $OctopusParameters[\"DemoSpaceCreator.Octopus.APIKey\"]\n$spaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n\n##PROCESS\n$header = @{ \"X-Octopus-ApiKey\" = $octopusAPIKey }\n\n$tenantId = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.ClonedTenantId\"]\n$role = $OctopusParameters[\"DemoSpaceCreator.CreateTenant.TenantRole\"]\n\n$uri = \"$OctopusURL/api/$spaceId/tenants/$tenantId\"\n\n$tenant = (Invoke-RestMethod $uri -Headers $header)\n\n$tenant.TenantTags += $role\n\n$tenant = (Invoke-RestMethod $uri -Method PUT -Headers $header -Body ($tenant | ConvertTo-Json -depth 10))"
        "Octopus.Action.RunOnServer"         = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
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
    condition           = "Variable"
    name                = "Deploy everything"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Deploy everything"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      worker_pool_variable               = "DemoSpaceCreator.WorkerPool"
      properties                         = {
        "ChildProject.ManualInterventions.UseApprovalsFromParent" = "Yes"
        "Octopus.Action.Script.ScriptSource"                      = "Inline"
        "Octopus.Action.Script.ScriptBody"                        = "[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12\n\n# Supplied Octopus Parameters\n$parentReleaseId = $OctopusParameters[\"Octopus.Release.Id\"]\n$parentChannelId = $OctopusParameters[\"Octopus.Release.Channel.Id\"]\n$destinationSpaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n$specificMachines = $OctopusParameters[\"Octopus.Deployment.SpecificMachines\"]\n$excludeMachines = $OctopusParameters[\"Octopus.Deployment.ExcludedMachines\"]\n$deploymentMachines = $OctopusParameters[\"Octopus.Deployment.Machines\"]\n$parentDeploymentTaskId = $OctopusParameters[\"Octopus.Task.Id\"]\n$parentProjectName = $OctopusParameters[\"Octopus.Project.Name\"]\n$parentReleaseNumber = $OctopusParameters[\"Octopus.Release.Number\"]\n$parentEnvironmentName = $OctopusParameters[\"Octopus.Environment.Name\"]\n$parentEnvironmentId = $OctopusParameters[\"Octopus.Environment.Id\"]\n$parentSpaceId = $OctopusParameters[\"Octopus.Space.Id\"]\n\n# User Parameters\n$octopusApiKey = $OctopusParameters[\"ChildProject.Api.Key\"]\n$projectName = $OctopusParameters[\"ChildProject.Project.Name\"]\n$channelName = $OctopusParameters[\"ChildProject.Channel.Name\"]\n$releaseNumber = $OctopusParameters[\"ChildProject.Release.Number\"]\n$environmentName = $OctopusParameters[\"ChildProject.Destination.EnvironmentName\"]\n$sourceEnvironmentName = $OctopusParameters[\"ChildProject.SourceEnvironment.Name\"]\n$formValues = $OctopusParameters[\"ChildProject.Prompted.Variables\"]\n$destinationSpaceName = $OctopusParameters[\"ChildProject.Space.Name\"]\n$whatIfValue = $OctopusParameters[\"ChildProject.WhatIf.Value\"]\n$waitForFinishValue = $OctopusParameters[\"ChildProject.WaitForFinish.Value\"]\n$deploymentCancelInSeconds = $OctopusParameters[\"ChildProject.CancelDeployment.Seconds\"]\n$ignoreSpecificMachineMismatchValue = $OctopusParameters[\"ChildProject.Deployment.IgnoreSpecificMachineMismatch\"]\n$autoapproveChildManualInterventionsValue = $OctopusParameters[\"ChildProject.ManualInterventions.UseApprovalsFromParent\"]\n$saveReleaseNotesAsArtifactValue = $OctopusParameters[\"ChildProject.ReleaseNotes.SaveAsArtifact\"]\n$futureDeploymentDate = $OctopusParameters[\"ChildProject.Deployment.FutureTime\"]\n$errorHandleForNoRelease = $OctopusParameters[\"ChildProject.Release.NotFoundError\"]\n$approvalEnvironmentName = $OctopusParameters[\"ChildProject.ManualIntervention.EnvironmentToUse\"]\n$approvalTenantName = $OctopusParameters[\"ChildProject.ManualIntervention.Tenant.Name\"]\n$refreshVariableSnapShot = $OctopusParameters[\"ChildProject.RefreshVariableSnapShots.Option\"]\n$deploymentMode = $OctopusParameters[\"ChildProject.DeploymentMode.Value\"]\n$targetMachines = $OctopusParameters[\"ChildProject.Target.MachineNames\"]\n$deploymentTenantName = $OctopusParameters[\"ChildProject.Tenant.Name\"]\n$defaultUrl = $OctopusParameters[\"ChildProject.Web.ServerUrl\"]\n\n$cachedResults = @{}\n\nfunction Write-OctopusVerbose\n{\n    param($message)\n    \n    Write-Verbose $message  \n}\n\nfunction Write-OctopusInformation\n{\n    param($message)\n    \n    Write-Host $message  \n}\n\nfunction Write-OctopusSuccess\n{\n    param($message)\n\n    Write-Highlight $message \n}\n\nfunction Write-OctopusWarning\n{\n    param($message)\n\n    Write-Warning \"$message\" \n}\n\nfunction Write-OctopusCritical\n{\n    param ($message)\n\n    Write-Error \"$message\" \n}\n\nfunction Test-RequiredValues\n{\n\tparam (\n    \t$variableToCheck,\n        $variableName\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($variableToCheck) -eq $true)\n    {\n    \tWrite-OctopusCritical \"$variableName is required.\"\n        return $false\n    }\n    \n    return $true\n}\n\nfunction Invoke-OctopusApi\n{\n    param\n    (\n        $octopusUrl,\n        $endPoint,\n        $spaceId,\n        $apiKey,\n        $method,\n        $item,\n        $ignoreCache     \n    )\n\n    if ([string]::IsNullOrWhiteSpace($SpaceId))\n    {\n        $url = \"$OctopusUrl/api/$EndPoint\"\n    }\n    else\n    {\n        $url = \"$OctopusUrl/api/$spaceId/$EndPoint\"    \n    }  \n\n    try\n    {        \n        if ($null -ne $item)\n        {\n            $body = $item | ConvertTo-Json -Depth 10\n            Write-OctopusVerbose $body\n\n            Write-OctopusInformation \"Invoking $method $url\"\n            return Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -Body $body -ContentType 'application/json; charset=utf-8' \n        }\n\n        if (($null -eq $ignoreCache -or $ignoreCache -eq $false) -and $method.ToUpper().Trim() -eq \"GET\")\n        {\n            Write-OctopusVerbose \"Checking to see if $url is already in the cache\"\n            if ($cachedResults.ContainsKey($url) -eq $true)\n            {\n                Write-OctopusVerbose \"$url is already in the cache, returning the result\"\n                return $cachedResults[$url]\n            }\n        }\n        else\n        {\n            Write-OctopusVerbose \"Ignoring cache.\"    \n        }\n\n        Write-OctopusVerbose \"No data to post or put, calling bog standard invoke-restmethod for $url\"\n        $result = Invoke-RestMethod -Method $method -Uri $url -Headers @{\"X-Octopus-ApiKey\" = \"$ApiKey\" } -ContentType 'application/json; charset=utf-8'\n\n        if ($cachedResults.ContainsKey($url) -eq $true)\n        {\n            $cachedResults.Remove($url)\n        }\n        Write-OctopusVerbose \"Adding $url to the cache\"\n        $cachedResults.add($url, $result)\n\n        return $result\n\n               \n    }\n    catch\n    {\n        if ($null -ne $_.Exception.Response)\n        {\n            if ($_.Exception.Response.StatusCode -eq 401)\n            {\n                Write-OctopusCritical \"Unauthorized error returned from $url, please verify API key and try again\"\n            }\n            elseif ($_.Exception.Response.statusCode -eq 403)\n            {\n                Write-OctopusCritical \"Forbidden error returned from $url, please verify API key and try again\"\n            }\n            else\n            {                \n                Write-OctopusVerbose -Message \"Error calling $url $($_.Exception.Message) StatusCode: $($_.Exception.Response.StatusCode )\"\n            }            \n        }\n        else\n        {\n            Write-OctopusVerbose $_.Exception\n        }\n    }\n\n    Throw \"There was an error calling the Octopus API please check the log for more details\"\n}\n\nfunction Get-ListFromOctopusApi\n{\n    param (\n        $octopusUrl,\n        $endPoint,\n        $spaceId,\n        $apiKey,\n        $propertyName\n    )\n\n    $rawItemList = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint $endPoint -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n\n    $returnList = @($rawItemList.$propertyName)\n\n    Write-OctopusVerbose \"The endpoint $endPoint returned a list with $($returnList.Count) items\"\n\n    return ,$returnList\n}\n\nfunction Get-FilteredOctopusItem\n{\n    param(\n        $itemList,\n        $itemName\n    )\n\n    if ($itemList.Count -eq 0)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        Exit 1\n    }  \n\n    $item = $itemList | Where-Object { $_.Name.ToLower().Trim() -eq $itemName.ToLower().Trim() }      \n\n    if ($null -eq $item)\n    {\n        Write-OctopusCritical \"Unable to find $itemName.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n\n    return $item\n}\n\nfunction Test-PhaseContainsEnvironmentId\n{\n    param (\n        $phase,\n        $environmentId\n    )\n\n    Write-OctopusVerbose \"Checking to see if $($phase.Name) automatic deployment environments $($phase.AutomaticDeploymentTargets) contains $environmentId\"\n    if ($phase.AutomaticDeploymentTargets -contains $environmentId)\n    {\n        Write-OctopusVerbose \"It does, returning true\"\n        return $true\n    } \n    \n    Write-OctopusVerbose \"Checking to see if $($phase.Name) optional deployment environments $($phase.OptionalDeploymentTargets) contains $environmentId\"\n    if ($phase.OptionalDeploymentTargets -contains $environmentId)\n    {\n        Write-OctopusVerbose \"It does, returning true\"\n        return $true\n    }\n\n    Write-OctopusVerbose \"The phase does not contain the environment returning false\"\n    return $false\n}\n\nfunction Get-OctopusItemByName\n{\n    param(\n        $itemName,\n        $itemType,\n        $endpoint,\n        $defaultValue,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n\n    if ([string]::IsNullOrWhiteSpace($itemName) -or $itemName -like \"#{Octopus*\")\n    {\n        Write-OctopusVerbose \"The item name passed in was $itemName, returning the default value for $itemType\"\n        return $defaultValue\n    }\n\n    Write-OctopusInformation \"Attempting to find $itemType with the name of $itemName\"\n    \n    $itemList = Get-ListFromOctopusApi -octopusUrl $defaultUrl -endPoint \"$($endPoint)?partialName=$([uri]::EscapeDataString($itemName))\u0026skip=0\u0026take=100\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\" -propertyName \"Items\"   \n    $item = Get-FilteredOctopusItem -itemList $itemList -itemName $itemName\n\n    Write-OctopusInformation \"Successfully found $itemName with id of $($item.Id)\"\n\n    return $item\n}\n\nfunction Get-OctopusItemById\n{\n    param(\n        $itemId,\n        $itemType,\n        $endpoint,\n        $defaultValue,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n\n    if ([string]::IsNullOrWhiteSpace($itemId))\n    {\n        return $defaultValue\n    }\n\n    Write-OctopusInformation \"Attempting to find $itemType with the id of $itemId\"\n    \n    $item = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"$endPoint/$itemId\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"        \n\n    if ($null -eq $item)\n    {\n        Write-OctopusCritical \"Unable to find $itemType with the id of $itemId\"\n        exit 1\n    }\n    else \n    {\n        Write-OctopusInformation \"Successfully found $itemId with name of $($item.Name)\"    \n    }\n    \n    return $item\n}\n\nfunction Get-OctopusSpaceIdByName\n{\n\tparam(\n    \t$spaceName,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey    \n    )\n    \n    if ([string]::IsNullOrWhiteSpace($spaceName))\n    {\n    \treturn $spaceId\n    }\n\n    $space = Get-OctopusItemByName -itemName $spaceName -itemType \"Space\" -endpoint \"spaces\" -defaultValue $spaceId -spaceId $null -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n    \n    return $space.Id\n}\n\nfunction Get-OctopusProjectByName\n{\n    param (\n        $projectName,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    return Get-OctopusItemByName -itemName $projectName -itemType \"Project\" -endpoint \"projects\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey    \n}\n\nfunction Get-OctopusEnvironmentByName\n{\n    param (\n        $environmentName,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    return Get-OctopusItemByName -itemName $environmentName -itemType \"Environment\" -endpoint \"environments\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey    \n}\n\nfunction Get-OctopusTenantByName\n{\n    param (\n        $tenantName,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    return Get-OctopusItemByName -itemName $tenantName -itemType \"Tenant\" -endpoint \"tenants\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey    \n}\n\nfunction Get-OctopusApprovalTenant\n{\n    param (\n        $tenantToDeploy,\n        $approvalTenantName,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Checking to see if there is an approval tenant to consider\"\n\n    if ($null -eq $tenantToDeploy)\n    {\n        Write-OctopusInformation \"Not doing tenant deployments, skipping this check\"    \n        return $null\n    }\n\n    if ([string]::IsNullOrWhiteSpace($approvalTenantName) -eq $true -or $approvalTenantName -eq \"#{Octopus.Deployment.Tenant.Name}\")\n    {\n        Write-OctopusInformation \"No approval tenant was provided, returning $($tenantToDeploy.Id)\"\n        return $tenantToDeploy\n    }\n\n    if ($approvalTenantName.ToLower().Trim() -eq $tenantToDeploy.Name.ToLower().Trim())\n    {\n        Write-OctopusInformation \"The approval tenant name matches the deployment tenant name, using the current tenant\"\n        return $tenantToDeploy\n    }\n\n    return Get-OctopusTenantByName -tenantName $approvalTenantName -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n}\n\nfunction Get-OctopusChannel\n{\n    param (\n        $channelName,\n        $project,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    Write-OctopusInformation \"Attempting to find the channel information for project $projectName matching the channel name $channelName\"\n    $channelList = Get-ListFromOctopusApi -octopusUrl $defaultUrl -endPoint \"projects/$($project.Id)/channels?skip=0\u0026take=1000\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\" -propertyName \"Items\"\n    $channelToUse = $null\n    foreach ($channel in $channelList)\n    {\n        if ([string]::IsNullOrWhiteSpace($channelName) -eq $true -and $channel.IsDefault -eq $true)\n        {\n            Write-OctopusVerbose \"The channel name specified is null or empty and the current channel $($channel.Name) is the default, using that\"\n            $channelToUse = $channel\n            break\n        }\n\n        if ([string]::IsNullOrWhiteSpace($channelName) -eq $false -and $channel.Name.Trim().ToLowerInvariant() -eq $channelName.Trim().ToLowerInvariant())\n        {\n            Write-OctopusVerbose \"The channel name specified $channelName matches the the current channel $($channel.Name) using that\"\n            $channelToUse = $channel\n            break\n        }\n    }\n\n    if ($null -eq $channelToUse)\n    {\n        Write-OctopusCritical \"Unable to find a channel to use.  Exiting with an exit code of 1.\"\n        exit 1\n    }\n\n    return $channelToUse\n}\n\nfunction Get-OctopusLifecyclePhases\n{\n    param (\n        $channel,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey,\n        $project\n    )\n\n    Write-OctopusInformation \"Attempting to find the lifecycle information $($channel.Name)\"\n    if ($null -eq $channel.LifecycleId)\n    {\n        return Get-ListFromOctopusApi -octopusUrl $defaultUrl -endPoint \"lifecycles/$($project.LifecycleId)/preview\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\" -propertyName \"Phases\"\n    }\n    else\n    {\n        return Get-ListFromOctopusApi -octopusUrl $defaultUrl -endPoint \"lifecycles/$($channel.LifecycleId)/preview\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\" -propertyName \"Phases\"\n    }\n}\n\nfunction Get-SourceDestinationEnvironmentInformation\n{\n    param (\n        $phaseList,\n        $targetEnvironment,\n        $sourceEnvironment,\n        $isPromotionMode\n    )\n\n    Write-OctopusVerbose \"Attempting to pull the environment ids from the source and destination phases\"\n\n    $destTargetEnvironmentInfo = @{        \n        TargetEnvironment = $targetEnvironment\n        SourceEnvironmentList = @()\n        FirstLifecyclePhase = $false\n        HasRequiredPhase = $false\n    }\n\n    if ($isPromotionMode -eq $false)\n    {\n        Write-OctopusInformation \"Currently running in redeploy mode, setting the source environment to the target environment.\"\n        $destTargetEnvironmentInfo.SourceEnvironmentList = $targetEnvironment.Id\n\n        return $destTargetEnvironmentInfo\n    }\n\n    $indexOfTargetEnvironment = $null\n    for ($i = 0; $i -lt $phaseList.Length; $i++)\n    {\n        Write-OctopusInformation \"Checking to see if lifecycle phase $($phaseList[$i].Name) contains the target environment id $($targetEnvironment.Id)\"\n\n        if (Test-PhaseContainsEnvironmentId -phase $phaseList[$i] -environmentId $targetEnvironment.Id)    \n        {            \n            Write-OctopusVerbose \"The phase $($phaseList[$i].Name) has the environment $($targetEnvironment.Name).\"\n            $indexOfTargetEnvironment = $i\n            break\n        }\n    }\n\n    if ($null -eq $indexOfTargetEnvironment)\n    {\n        Write-OctopusCritical \"Unable to find the target phase in this lifecycle attached to this channel.  Exiting with exit code of 1\"\n        Exit 1\n    }\n\n    if ($indexOfTargetEnvironment -eq 0)\n    {\n        Write-OctopusInformation \"This is the first phase in the lifecycle.  The current mode is promotion.  Going to get the latest release created that matches the release number rules for the channel.\"\n        $destTargetEnvironmentInfo.FirstLifecyclePhase = $true        \n        $destTargetEnvironmentInfo.SourceEnvironmentList += $targetEnvironment.Id\n\n        return $destTargetEnvironmentInfo\n    }\n    \n    if ($null -ne $sourceEnvironment)\n    {\n        Write-OctopusInformation \"The source environment $($sourceEnvironment.Name) was provided, using that as the source environment\"\n        $destTargetEnvironmentInfo.SourceEnvironmentList += $sourceEnvironment.Id\n\n        return $destTargetEnvironmentInfo\n    }\n\n    Write-OctopusVerbose \"Looping through all the previous phases until a required phase is found.\"\n    $startingIndex = ($indexOfTargetEnvironment - 1)\n    for($i = $startingIndex; $i -ge 0; $i--)\n    {\n        $previousPhase = $phaseList[$i]\n        Write-OctopusInformation \"Adding environments from the phase $($previousPhase.Name)\"\n        foreach ($environmentId in $previousPhase.AutomaticDeploymentTargets)\n        {\n            $destTargetEnvironmentInfo.SourceEnvironmentList += $environmentId\n        }\n\n        foreach ($environmentId in $previousPhase.OptionalDeploymentTargets)\n        {\n            $destTargetEnvironmentInfo.SourceEnvironmentList += $environmentId\n        }\n\n        if ($previousPhase.IsOptionalPhase -eq $false)\n        {\n            Write-OctopusVerbose \"The phase $($previousPhase.Name) is a required phase, exiting previous phase loop\"\n            $destTargetEnvironmentInfo.HasRequiredPhase = $true\n            break\n        }\n        elseif ($i -gt 0)\n        {\n            Write-OctopusVerbose \"The phase $($previousPhase.Name) is an optional phase, continuing going to check the next phase\"    \n        }\n        else\n        {\n            Write-OctopusVerbose \"The phase $($previousPhase.Name) is an optional phase.  This is the last phase so I'm stopping now.\"    \n        }\n    }\n\n    return $destTargetEnvironmentInfo             \n}\n\nfunction Get-ReleaseCanBeDeployedToTargetEnvironment\n{\n    param (\n        $release,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey,\n        $sourceDestinationEnvironmentInfo,\n        $tenantToDeploy,\n        $isPromotionMode\n    )\n\n    if ($isPromotionMode -eq $false)\n    {\n        Write-OctopusInformation \"The current mode is redeploy.  Of course the release can be deployed to the target environment, no need to recheck it.\"\n        return $true\n    }\n\n    Write-OctopusInformation \"Pulling the deployment template information for release $($release.Version)\"\n    $releaseDeploymentTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"releases/$($release.Id)/deployments/template\" -spaceId $spaceId -method GET -apiKey $octopusApiKey\n\n    $releaseCanBeDeployedToDestination = $false    \n    Write-OctopusInformation \"Looping through deployment template list for $($release.Version) to see if it can be deployed to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name).\"\n    foreach ($promoteToEnvironment in $releaseDeploymentTemplate.PromoteTo)\n    {\n        if ($promoteToEnvironment.Id -eq $sourceDestinationEnvironmentInfo.TargetEnvironment.Id)\n        {\n            Write-OctopusInformation \"The environment $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name) was found in the list of environments to promote to\"\n            $releaseCanBeDeployedToDestination = $true\n            break\n        }\n    }    \n\n    if ($null -eq $tenantToDeploy -or $releaseDeploymentTemplate.TenantPromotions.Length -le 0)\n    {\n        return $releaseCanBeDeployedToDestination\n    }\n\n    $releaseCanBeDeployedToDestination = $false\n    Write-OctopusInformation \"The tenant id was supplied, looping through the tenant templates to see if it can be deployed to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name).\"\n    foreach ($tenantPromotion in $releaseDeploymentTemplate.TenantPromotions)\n    {\n        if ($tenantPromotion.Id -ne $tenantToDeploy.Id)\n        {\n            Write-OctopusVerbose \"The tenant ids $($tenantPromotion.Id) and $($tenantToDeploy.Id) don't match, moving onto the next one\"\n            continue\n        }\n\n        Write-OctopusVerbose \"The tenant Id matches checking to see if the environment can be promoted to.\"\n        foreach ($promoteToEnvironment in $tenantPromotion.PromoteTo)\n        {\n            if ($promoteToEnvironment.Id -ne $sourceDestinationEnvironmentInfo.TargetEnvironment.Id)\n            {\n                Write-OctopusVerbose \"The environmentIds $($promoteToEnvironment.Id) and $($sourceDestinationEnvironmentInfo.TargetEnvironment.Id) don't match, moving onto the next one.\"\n                continue\n            }\n\n            Write-OctopusInformation \"The environment $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name) was found in the list of environments tenant $($tenantToDeploy.Id) can be promoted to\"\n            $releaseCanBeDeployedToDestination = $true\n        }\n    }\n\n    return $releaseCanBeDeployedToDestination\n}\n\nfunction Get-DeploymentPreview\n{\n    param (\n        $releaseToDeploy,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey,\n        $targetEnvironment,\n        $deploymentTenant\n    )\n\n    if ($null -eq $deploymentTenant)\n    {\n        Write-OctopusInformation \"The deployment tenant id was not sent in, generating a preview by hitting releases/$($releaseToDeploy.Id)/deployments/preview/$($targetEnvironment.Id)?includeDisabledSteps=true\"    \n        return Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"releases/$($releaseToDeploy.Id)/deployments/preview/$($targetEnvironment.Id)?includeDisabledSteps=true\" -apiKey $octopusApiKey -method \"GET\" -spaceId $spaceId\n    }\n\n    Write-OctopusInformation \"The deployment tenant id was sent in, generating a preview by hitting releases/$($releaseToDeploy.Id)/deployments/previews\" \n    $requestBody = @{\n    \t\tDeploymentPreviews = @(\n    \t\t\t@{\n                \tTenantId = $deploymentTenant.Id;\n            \t\tEnvironmentId = $targetEnvironment.Id\n                 }\n            )\n    }\n    return Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"releases/$($releaseToDeploy.Id)/deployments/previews\" -apiKey $octopusApiKey -method \"POST\" -spaceId $spaceId -item $requestBody -itemIsArray $true\n}\n\nfunction Get-ValuesForPromptedVariables\n{\n    param (\n        $deploymentPreview,\n        $formValues\n    )\n\n    $deploymentFormValues = @{}\n    if ([string]::IsNullOrWhiteSpace($formValues) -eq $true)\n    {\n        return $deploymentFormValues\n    }   \n    \n    $promptedValueList = @(($formValues -Split \"`n\").Trim())\n    Write-OctopusVerbose $promptedValueList.Length\n    \n    foreach($element in $deploymentPreview.Form.Elements)\n    {\n        $nameToSearchFor = $element.Control.Name\n        $uniqueName = $element.Name\n        $isRequired = $element.Control.Required\n        \n        $promptedVariablefound = $false\n        \n        Write-OctopusVerbose \"Looking for the prompted variable value for $nameToSearchFor\"\n        foreach ($promptedValue in $promptedValueList)\n        {\n            $splitValue = $promptedValue -Split \"::\"\n            Write-OctopusVerbose \"Comparing $nameToSearchFor with provided prompted variable $($promptedValue[0])\"\n            if ($splitValue.Length -gt 1)\n            {\n                if ($nameToSearchFor.ToLower().Trim() -eq $splitValue[0].ToLower().Trim())\n                {\n                    Write-OctopusVerbose \"Found the prompted variable value $nameToSearchFor\"\n                    $deploymentFormValues[$uniqueName] = $splitValue[1]\n                    $promptedVariableFound = $true\n                    break\n                }\n            }\n        }\n        \n        if ($promptedVariableFound -eq $false -and $isRequired -eq $true)\n        {\n            Write-OctopusCritical \"Unable to find a value for the required prompted variable $nameToSearchFor, exiting\"\n            Exit 1\n        }\n    }\n    \n    return $deploymentFormValues\n}\n\nfunction Test-ProjectTenantSettings\n{\n    param (\n        $tenantToDeploy,\n        $project,\n        $targetEnvironment\n    )\n\n    Write-OctopusVerbose \"About to check if $tenantToDeploy is not null and tenant deploy mode on the project $($project.TenantedDeploymentMode) \u003c\u003e Untenanted\"\n    if ($null -eq $tenantToDeploy)\n    {\n        Write-OctopusInformation \"Not doing a tenanted deployment, no need to check if the project supports tenanted deployments.\"\n        return $null\n    }\n\n    if ($project.TenantedDeploymentMode -eq \"Untenanted\")\n    {\n        Write-OctopusInformation \"The project is not tenanted, but we are doing a tenanted deployment, removing the tenant from the equation\"\n        return $null\n    }\n\n    Write-OctopusInformation \"Found the tenant $($tenantToDeploy.Name) checking to see if $($project.Name) is assigned to it.\"\n        \n    Write-OctopusVerbose \"Checking to see if $($tenantToDeploy.ProjectEnvironments) has $($project.Id) as a property.\"\n    if ($null -eq (Get-Member -InputObject $tenantToDeploy.ProjectEnvironments -Name $project.Id -MemberType Properties))\n    {\n        Write-OctopusSuccess \"The tenant $($tenantToDeploy.Name) is not assigned to $($project.Name).  Exiting.\"\n        Insert-EmptyOutputVariables -releaseToDeploy $null\n        \n        Exit 0\n    }\n\n    Write-OctopusInformation \"The tenant $($tenantToDeploy.Name) is assigned to $($project.Name).  Now checking to see if it can be deployed to the target environment.\"\n    $tenantProjectId = $project.Id\n    \n    Write-OctopusVerbose \"Checking to see if $($tenantToDeploy.ProjectEnvironments.$tenantProjectId) has $($targetEnvironment.Id)\"    \n    if ($tenantToDeploy.ProjectEnvironments.$tenantProjectId -notcontains $targetEnvironment.Id)\n    {\n        Write-OctopusSuccess \"The tenant $($tenantToDeploy.Name) is assigned to $($project.Name), but not to the environment $($targetEnvironment.Name).  Exiting.\"\n        Insert-EmptyOutputVariables -releaseToDeploy $null\n        \n        Exit 0\n    } \n    \n    return $tenantToDeploy\n}\n\nfunction Test-ReleaseToDeploy\n{\n\tparam (\n    \t$releaseToDeploy,\n        $errorHandleForNoRelease,\n        $releaseNumber,        \n        $sourceDestinationEnvironmentInfo, \n        $environmentList\n    )\n    \n    if ($null -ne $releaseToDeploy)\n    {\n    \treturn\n    }\n        \n    $errorMessage = \"No releases were found in environment(s)\" \n\n    $environmentMessage = @()\n    foreach ($environmentId in $sourceDestinationEnvironmentInfo.SourceEnvironmentList)\n    {\n        $environment = $environmentList | Where-Object {$_.Id -eq $environmentId }\n\n        if ($null -ne $environment)\n        {\n            $environmentMessage += $environment.Name\n        }\n    }\n\n    $errorMessage += \" $($environmentMessage -join \",\")\"\n    \n    if ([string]::IsNullOrWhitespace($releaseNumber) -eq $false)\n    {\n    \t$errorMessage = \"$errorMessage matching $releaseNumber\"\n    }\n    \n    $errorMessage = \"$errorMessage that can be deployed to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name)\"\n    \n    if ($errorHandleForNoRelease -eq \"Error\")\n    {\n    \tWrite-OctopusCritical $errorMessage\n        exit 1\n    }\n    \n    Insert-EmptyOutputVariables -releaseToDeploy $null\n    \n    if ($errorHandleForNoRelease -eq \"Skip\")\n    {\n    \tWrite-OctopusInformation $errorMessage\n        exit 0\n    }\n    \n    Write-OctopusSuccess $errorMessage\n    exit 0\n}\n\nfunction Get-TenantIsAssignedToPreviousEnvironments\n{\n    param (\n        $tenantToDeploy,\n        $sourceDestinationEnvironmentInfo,\n        $projectId,\n        $isPromotionMode\n    )\n\n    if ($null -eq $tenantToDeploy)\n    {\n        Write-OctopusVerbose \"The tenant is null, skipping the check to see if it is assigned to the previous environment list.\"\n        return $false\n    }\n\n    if ($isPromotionMode -eq $false)\n    {\n        Write-OctopusVerbose \"The current mode is redeploy, the source and destination environment are the same, no need to check.\"\n        return $true\n    }\n\n    Write-OctopusVerbose \"Checking to see if $($tenantToDeploy.Name) is assigned to the previous environments.\"     \n    Write-OctopusVerbose \"Checking to see if $($tenantToDeploy.ProjectEnvironments.$projectId) is assigned to the source environments(s) $($sourceDestinationEnvironmentInfo.SourceEnvironmentList)\"\n\n    foreach ($environmentId in $tenantToDeploy.ProjectEnvironments.$projectId)\n    {\n        Write-OctopusVerbose \"Checking to see if $environmentId appears in $($sourceDestinationEnvironmentInfo.SourceEnvironmentList)\"\n        if ($sourceDestinationEnvironmentInfo.SourceEnvironmentList -contains $environmentId)\n        {\n            Write-OctopusVerbose \"Found the environment $environmentId assigned to $($tenantToDeploy.Name), attempting to find the latest release for this tenant\"\n            return $true\n        }\n    }\n\n    Write-OctopusVerbose \"The tenant is not assigned to any environment in the source environments $($sourceDestinationEnvironmentInfo.SourceEnvironmentList), pulling the latest release to the environment regardless of tenant.\"\n    return $false\n}\n\nfunction Create-NewOctopusDeployment\n{\n\tparam (\n    \t$releaseToDeploy,\n        $targetEnvironment,\n        $createdDeployment,\n        $project,\n        $waitForFinish,\n        $deploymentCancelInSeconds,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentDeploymentApprovers,\n        $parentProjectName,\n        $parentReleaseNumber, \n        $parentEnvironmentName, \n        $parentDeploymentTaskId,\n        $autoapproveChildManualInterventions,\n        $approvalTenant\n    )\n    \n    Write-OctopusSuccess \"Deploying $($releaseToDeploy.Version) to $($targetEnvironment.Name)\"\n\n    $createdDeploymentResponse = Invoke-OctopusApi -method \"POST\" -endPoint \"deployments\" -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -item $createdDeployment\n    Write-OctopusInformation \"The task id for the new deployment is $($createdDeploymentResponse.TaskId)\"\n\n    Write-OctopusSuccess \"Deployment was successfully invoked, you can access the deployment [here]($defaultUrl/app#/$spaceId/projects/$($project.Slug)/deployments/releases/$($releaseToDeploy.Version)/deployments/$($createdDeploymentResponse.Id)?activeTab=taskSummary)\"\n    \n    if ($null -ne $createdDeployment.QueueTime -and $waitForFinish -eq $true)\n    {\n    \tWrite-OctopusWarning \"The option to wait for the deployment to finish was set to yes AND a future deployment date was set to a future value.  Ignoring the wait for finish option and exiting.\"\n        return\n    }\n    \n    if ($waitForFinish -eq $true)\n    {\n        Write-OctopusSuccess \"Waiting until deployment has finished\"\n        $startTime = Get-Date\n        $currentTime = Get-Date\n        $dateDifference = $currentTime - $startTime\n\n        $numberOfWaits = 0    \n\n        While ($dateDifference.TotalSeconds -lt $deploymentCancelInSeconds)\n        {\n\t        $numberOfWaits += 1\n        \n            Write-Host \"Waiting 5 seconds to check status\"\n            Start-Sleep -Seconds 5\n            $taskStatusResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $spaceId -apiKey $octopusApiKey -endPoint \"tasks/$($createdDeploymentResponse.TaskId)\" -method \"GET\" -ignoreCache $true   \n            $taskStatusResponseState = $taskStatusResponse.State\n\n            if ($taskStatusResponseState -eq \"Success\")\n            {\n                Write-OctopusSuccess \"The task has finished with a status of Success\"\n                exit 0            \n            }\n            elseif($taskStatusResponseState -eq \"Failed\" -or $taskStatusResponseState -eq \"Canceled\")\n            {\n                Write-OctopusSuccess \"The task has finished with a status of $taskStatusResponseState status, stopping the deployment\"\n                exit 1            \n            }\n            elseif($taskStatusResponse.HasPendingInterruptions -eq $true)\n            {\n            \tif ($autoapproveChildManualInterventions -eq $true)\n                {\n                \tSubmit-ChildProjectDeploymentForAutoApproval -createdDeployment $createdDeploymentResponse -parentDeploymentApprovers $parentDeploymentApprovers -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -parentProjectName $parentProjectName -parentReleaseNumber $parentReleaseNumber -parentEnvironmentName $parentEnvironmentName -parentDeploymentTaskId $parentDeploymentTaskId -approvalTenant $approvalTenant\n                }\n                else\n                {\n                \tif ($numberOfWaits -ge 10)\n                    {\n                \t\tWrite-OctopusSuccess \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"\n                    }\n                    else\n                    {\n                    \tWrite-OctopusInformation \"The child project has pending manual intervention(s).  Unless you approve it, this task will time out.\"                        \n                    }\n                }\n            }\n            \n            if ($numberOfWaits -ge 10)\n            {\n                Write-OctopusSuccess \"The task state is currently $taskStatusResponseState\"\n                $numberOfWaits = 0\n            }\n            else\n            {\n                Write-OctopusInformation \"The task state is currently $taskStatusResponseState\"\n            }  \n\n            $startTime = $taskStatusResponse.StartTime\n            if ($null -eq $startTime -or [string]::IsNullOrWhiteSpace($startTime) -eq $true)\n            {        \n                Write-Host \"The task is still queued, let's wait a bit longer\"\n                $startTime = Get-Date\n            }\n            $startTime = [DateTime]$startTime\n\n            $currentTime = Get-Date\n            $dateDifference = $currentTime - $startTime        \n        }\n\n        Write-OctopusCritical \"The cancel timeout has been reached, cancelling the deployment\"\n        Invoke-OctopusApi -octopusUrl $defaultUrl -apiKey $octopusApiKey -spaceId $spaceId -method \"POST\" -endPoint \"tasks/$($createdDeploymentResponse.TaskId)/cancel\"    \n        Write-OctopusInformation \"Exiting with an error code of 1 because we reached the timeout\"\n        exit 1\n    }\n}\n\nfunction Get-ChildDeploymentSpecificMachines\n{\n    param (\n        $deploymentPreview,\n        $deploymentMachines,\n        $specificMachineDeployment\n    )\n\n    if ($specificMachineDeployment -eq $false)\n    {\n        Write-OctopusVerbose \"Not doing specific machine deployments, returning any empty list of specific machines to deploy to\"\n        return @()\n    }\n\n    $filteredList = @()\n    $deploymentMachineList = $deploymentMachines -split \",\"\n\n    Write-OctopusInformation \"Doing a specific machine deployment, comparing the machines being targeted with the machines the child project can deploy to.  The number of machines being targeted is $($deploymentMachineList.Count)\"\n\n    foreach ($deploymentMachine in $deploymentMachineList)\n    {\n        $deploymentMachineLowerTrim = $deploymentMachine.Trim().ToLower()           \n\n        foreach ($step in $deploymentPreview.StepsToExecute)\n        {\n            foreach ($machine in $step.Machines)\n            {   \n                $machineLowerTrim = $machine.Id.Trim().ToLower()\n                \n                Write-OctopusVerbose \"Comparing $deploymentMachineLowerTrim with $machineLowerTrim\"\n                if ($deploymentMachineLowerTrim -ne $machineLowerTrim)\n                {\n                    Write-OctopusVerbose \"The two machine ids do not match, moving on to the next machine\"\n                    continue\n                }\n\n                Write-OctopusVerbose \"Checking to see if $machineLowerTrim is already in the filtered list.\"\n                if ($filteredList -notcontains $machine.Id)\n                {\n                    Write-OctopusVerbose \"The machine is not in the list, adding it to the list.\"\n                    $filteredList += $machine.Id\n                }\n            }\n        }\n    }\n\n    if ($filteredList.Count -gt 0)\n    {\n        Write-OctopusSuccess \"The machines applicable to this project are $filteredList.\"\n    }    \n\n    return $filteredList\n}\n\nfunction Test-ChildProjectDeploymentCanProceed\n{\n\tparam (\n    \t$releaseToDeploy,\n        $specificMachineDeployment,                        \n        $environmentName,\n        $childDeploymentSpecificMachines,\n        $project,\n        $ignoreSpecificMachineMismatch,\n        $deploymentMachines,\n        $releaseHasAlreadyBeenDeployed,\n        $isPromotionMode       \n    )\n    \n\tif ($releaseHasAlreadyBeenDeployed -eq $true -and $isPromotionMode -eq $true)\n    {\t     \t \n    \tWrite-OctopusSuccess \"Release $($releaseToDeploy.Version) is the most recent version deployed to $environmentName.  The deployment mode is Promote.  If you wish to redeploy this release then set the deployment mode to Redeploy.  Skipping this project.\"\n        \n        if ($specificMachineDeployment -eq $true -and $childDeploymentSpecificMachines.Length -gt 0)\n        {\n            Write-OctopusSuccess \"$($project.Name) can deploy to $childDeploymentSpecificMachines but redeployments are not allowed.\"\n        }\n        \n        Insert-EmptyOutputVariables -releaseToDeploy $releaseToDeploy\n\n        exit 0\n    }\n    \n    if ($childDeploymentSpecificMachines.Length -le 0 -and $specificMachineDeployment -eq $true -and $ignoreSpecificMachineMismatch -eq $false)\n    {\n        Write-OctopusSuccess \"$($project.Name) does not deploy to $($deploymentMachines -replace \",\", \" OR \").  The value for \"\"Ignore specific machine mismatch\"\" is set to \"\"No\"\".  Skipping this project.\"\n        \n        Insert-EmptyOutputVariables -releaseToDeploy $releaseToDeploy\n        \n        Exit 0\n    }\n\n    if ($childDeploymentSpecificMachines.Length -le 0 -and $specificMachineDeployment -eq $true -and $ignoreSpecificMachineMismatch -eq $true)\n    {\n        Write-OctopusSuccess \"You are doing a deployment for specific machines but $($project.Name) does not deploy to $($deploymentMachines -replace \",\", \" OR \").  You have set the value for \"\"Ignore specific machine mismatch\"\" to \"\"Yes\"\".  The child project will be deployed to, but it will do this for all machines, not any specific machines.\"\n    }\n}\n\nfunction Get-ParentDeploymentApprovers\n{\n    param (\n        $parentDeploymentTaskId,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n    \n    $approverList = @()\n    if ($null -eq $parentDeploymentTaskId)\n    {\n    \tWrite-OctopusInformation \"The deployment task id to pull the approvers from is null, return an empty approver list\"\n    \treturn $approverList\n    }\n\n    Write-OctopusInformation \"Getting all the events from the parent project\"\n    $parentDeploymentEvents = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"events?regardingAny=$parentDeploymentTaskId\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"\n    \n    foreach ($parentDeploymentEvent in $parentDeploymentEvents.Items)\n    {\n        Write-OctopusVerbose \"Checking $($parentDeploymentEvent.Message) for manual intervention\"\n        if ($parentDeploymentEvent.Message -like \"Submitted interruption*\")\n        {\n            Write-OctopusVerbose \"The event $($parentDeploymentEvent.Id) is a manual intervention approval event which was approved by $($parentDeploymentEvent.Username).\"\n\n            $approverExists = $approverList | Where-Object {$_.Id -eq $parentDeploymentEvent.UserId}        \n\n            if ($null -eq $approverExists)\n            {\n                $approverInformation = @{\n                    Id = $parentDeploymentEvent.UserId;\n                    Username = $parentDeploymentEvent.Username;\n                    Teams = @()\n                }\n\n                $approverInformation.Teams = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"teammembership?userId=$($approverInformation.Id)\u0026spaces=$spaceId\u0026includeSystem=true\" -apiKey $octopusApiKey -method \"GET\"            \n\n                Write-OctopusVerbose \"Adding $($approverInformation.Id) to the approval list\"\n                $approverList += $approverInformation\n            }        \n        }\n    }\n\n    return $approverList\n}\n\nfunction Submit-ChildProjectDeploymentForAutoApproval\n{\n    param (\n        $createdDeployment,\n        $parentDeploymentApprovers,\n        $defaultUrl,\n        $octopusApiKey,\n        $spaceId,\n        $parentProjectName,\n        $parentReleaseNumber,\n        $parentEnvironmentName,\n        $parentDeploymentTaskId,\n        $approvalTenant\n    )\n\n    Write-OctopusSuccess \"The task has a pending manual intervention.  Checking parent approvals.\"    \n    $manualInterventionInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"interruptions?regarding=$($createdDeployment.TaskId)\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId -ignoreCache $true\n    foreach ($manualIntervention in $manualInterventionInformation.Items)\n    {\n        if ($manualIntervention.IsPending -eq $false)\n        {\n            Write-OctopusInformation \"This manual intervention has already been approved.  Proceeding onto the next one.\"\n            continue\n        }\n\n        if ($manualIntervention.CanTakeResponsibility -eq $false)\n        {\n            Write-OctopusSuccess \"The user associated with the API key doesn't have permissions to take responsibility for the manual intervention.\"\n            Write-OctopusSuccess \"If you wish to leverage the auto-approval functionality give the user permissions.\"\n            continue\n        }        \n\n        $automaticApprover = $null\n        Write-OctopusVerbose \"Checking to see if one of the parent project approvers is assigned to one of the manual intervention teams $($manualIntervention.ResponsibleTeamIds)\"\n        foreach ($approver in $parentDeploymentApprovers)\n        {\n            foreach ($approverTeam in $approver.Teams)\n            {\n                Write-OctopusVerbose \"Checking to see if $($manualIntervention.ResponsibleTeamIds) contains $($approverTeam.TeamId)\"\n                if ($manualIntervention.ResponsibleTeamIds -contains $approverTeam.TeamId)\n                {\n                    $automaticApprover = $approver\n                    break\n                }\n            }\n\n            if ($null -ne $automaticApprover)\n            {\n                break\n            }\n        }\n\n        if ($null -ne $automaticApprover)\n        {\n            Write-OctopusVerbose \"Found matching approvers, attempting to auto approve.\"\n            if ($manualIntervention.HasResponsibility -eq $false)\n            {\n                Write-OctopusInformation \"Taking over responsibility for this manual intervention.\"\n                $takeResponsiblilityResponse = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/responsible\" -method \"PUT\" -apiKey $octopusApiKey -spaceId $spaceId -ignoreCache $true\n                Write-OctopusVerbose \"Response from taking responsibility $($takeResponsiblilityResponse.Id)\"\n            }\n            \n            if ($null -ne $approvalTenant)\n            {\n                $approvalMessage = \"Parent project $parentProjectName release $parentReleaseNumber to $parentEnvironmentName for the tenant $($approvalTenant.Name) with the task id $parentDeploymentTaskId was approved by $($automaticApprover.UserName).\"\n            }\n            else\n            {\n                $approvalMessage = \"Parent project $parentProjectName release $parentReleaseNumber to $parentEnvironmentName with the task id $parentDeploymentTaskId was approved by $($automaticApprover.UserName).\"\n            }\n\n            $submitApprovalBody = @{\n                Instructions = $null;\n                Notes = \"Auto-approving this deployment. $approvalMessage That user is a member of one of the teams this manual intervention requires.  You can view that deployment $defaultUrl/app#/$spaceId/tasks/$parentDeploymentTaskId\";\n                Result = \"Proceed\"\n            }\n            $submitResult = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"interruptions/$($manualIntervention.Id)/submit\" -method \"POST\" -apiKey $octopusApiKey -item $submitApprovalBody -spaceId $spaceId -ignoreCache $true\n            Write-OctopusSuccess \"Successfully auto approved the manual intervention $($submitResult.Id)\"\n        }\n        else\n        {\n            Write-OctopusSuccess \"Couldn't find an approver to auto-approve the child project.  Waiting until timeout or child project is approved.\"    \n        }\n    }\n}\n\nfunction Get-ReleaseNotes\n{\n\tparam (\n    \t$releaseToDeploy,\n        $deploymentPreview,\n        $channel,\n        $spaceId,\n        $defaultUrl,\n        $octopusApiKey\n    )\n            \n    $releaseNotes = @(\"\")\n    $releaseNotes += \"**Release Information**\"\n    $releaseNotes += \"\"\n\n    $packageVersionAdded = @()\n    $workItemsAdded = @()\n    $commitsAdded = @()\n\n    if ($null -ne $releaseToDeploy.BuildInformation -and $releaseToDeploy.BuildInformation.Count -gt 0)\n    {\n        $releaseNotes += \"- Package Versions\"\n        foreach ($change in $deploymentPreview.Changes)\n        {        \n            foreach ($package in $change.BuildInformation)\n            {\n                $packageInformation = \"$($package.PackageId).$($package.Version)\"\n                if ($packageVersionAdded -notcontains $packageInformation)\n                {\n                    $releaseNotes += \"  - $packageInformation\"\n                    $packageVersionAdded += $packageInformation\n                }\n            }\n        }\n\n\t\t$releaseNotes += \"\"\n        $releaseNotes += \"- Work Items\"\n        foreach ($change in $deploymentPreview.Changes)\n        {        \n            foreach ($workItem in $change.WorkItems)\n            {            \n                if ($workItemsAdded -notcontains $workItem.Id)\n                {\n                    $workItemInformation = \"[$($workItem.Id)]($($workItem.LinkUrl)) - $($workItem.Description)\"\n                    $releaseNotes += \"  - $workItemInformation\"\n                    $workItemsAdded += $workItem.Id\n                }\n            }\n        }\n\n\t\t$releaseNotes += \"\"\n        $releaseNotes += \"- Commits\"\n        foreach ($change in $deploymentPreview.Changes)\n        {        \n            foreach ($commit in $change.Commits)\n            {            \n                if ($commitsAdded -notcontains $commit.Id)\n                {\n                    $commitInformation = \"[$($commit.Id)]($($commit.LinkUrl)) - $($commit.Comment)\"\n                    $releaseNotes += \"  - $commitInformation\"\n                    $commitsAdded += $commit.Id\n                }\n            }\n        }            \n    }\n    else\n    {\n        $releaseNotes += $releaseToDeploy.ReleaseNotes\n        $releaseNotes += \"\"\n        $releaseNotes += \"Package Versions\"  \n        \n        $releaseDeploymentTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"deploymentprocesses/$($releaseToDeploy.ProjectDeploymentProcessSnapshotId)/template?channel=$($channel.Id)\u0026releaseId=$($releaseToDeploy.Id)\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n        \n        foreach ($package in $releaseToDeploy.SelectedPackages)\n        {\n        \tWrite-OctopusVerbose \"Attempting to find $($package.StepName) and $($package.ActionName)\"\n            \n            $deploymentProcessPackageInformation = $releaseDeploymentTemplate.Packages | Where-Object {$_.StepName -eq $package.StepName -and $_.actionName -eq $package.ActionName}\n            if ($null -ne $deploymentProcessPackageInformation)\n            {\n                $packageInformation = \"$($deploymentProcessPackageInformation.PackageId).$($package.Version)\"\n                if ($packageVersionAdded -notcontains $packageInformation)\n                {\n                    $releaseNotes += \"  - $packageInformation\"\n                    $packageVersionAdded += $packageInformation\n                }\n            }\n        }\n    }\n\n    return $releaseNotes -join \"`n\"\n}\n\nfunction Get-QueueDate\n{\n\tparam ( \n    \t$futureDeploymentDate\n    )\n    \n    if ([string]::IsNullOrWhiteSpace($futureDeploymentDate) -or $futureDeploymentDate -eq \"N/A\")\n    {\n    \treturn $null\n    }\n    \n    [datetime]$outputDate = New-Object DateTime\n    $currentDate = Get-Date\n\n    if ([datetime]::TryParse($futureDeploymentDate, [ref]$outputDate) -eq $false)\n    {\n        Write-OctopusCritical \"The suppplied date $futureDeploymentDate cannot be parsed by DateTime.TryParse.  Please verify format and try again.  Please [refer to Microsoft's Documentation](https://docs.microsoft.com/en-us/dotnet/api/system.datetime.tryparse) on supported formats.\"\n        exit 1\n    }\n    \n    if ($currentDate -gt $outputDate)\n    {\n    \tWrite-OctopusCritical \"The supplied date $futureDeploymentDate is set for the past.  All queued deployments must be in the future.\"\n        exit 1\n    }\n    \n    return $outputDate\n}\n\nfunction Get-QueueExpiryDate\n{\n\tparam (\n    \t$queueDate\n    )\n    \n    if ($null -eq $queueDate)\n    {\n    \treturn $null\n    }\n    \n    return $queueDate.AddHours(1)\n}\n\nfunction Insert-EmptyOutputVariables\n{\n\tparam (\n    \t$releaseToDeploy\n    )\n    \n\tif ($null -ne $releaseToDeploy)\n    {\n\t\tSet-OctopusVariable -Name \"ReleaseToPromote\" -Value $($releaseToDeploy.Version)\n        Set-OctopusVariable -Name \"ReleaseNotes\" -value \"Release already deployed to destination environment.\"\n    }\n    else\n    {\n    \tSet-OctopusVariable -Name \"ReleaseToPromote\" -Value \"N/A\"\n        Set-OctopusVariable -Name \"ReleaseNotes\" -value \"No release found\"\n    }        \n    \n    Write-OctopusInformation \"Setting the output variable ChildReleaseToDeploy to $false\"\n    Set-OctopusVariable -Name \"ChildReleaseToDeploy\" -Value $false\n}\n\nfunction Get-ApprovalDeploymentTaskId\n{\n\tparam (\n    \t$autoapproveChildManualInterventions,\n        $parentDeploymentTaskId,\n        $parentReleaseId,\n        $parentEnvironmentName,\n        $approvalEnvironmentName,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey,\n        $parentChannelId,    \n        $parentEnvironmentId,\n        $approvalTenant,\n        $parentProject\n    )\n    \n    if ($autoapproveChildManualInterventions -eq $false)\n    {\n    \tWrite-OctopusInformation \"Auto approvals are disabled, skipping pulling the approval deployment task id\"\n        return $null\n    }\n    \n    if ([string]::IsNullOrWhiteSpace($approvalEnvironmentName) -eq $true)\n    {\n    \tWrite-OctopusInformation \"Approval environment not supplied, using the current environment id for approvals.\"\n        return $parentDeploymentTaskId\n    }\n    \n    if ($approvalEnvironmentName.ToLower().Trim() -eq $parentEnvironmentName.ToLower().Trim())\n    {\n        Write-OctopusInformation \"The approval environment is the same as the current environment, using the current task id $parentDeploymentTaskId\"\n        return $parentDeploymentTaskId\n    }\n    \n    $approvalEnvironment = Get-OctopusEnvironmentByName -environmentName $approvalEnvironmentName -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n    $releaseDeploymentList = Get-ListFromOctopusApi -octopusUrl $defaultUrl -endPoint \"releases/$parentReleaseId/deployments?skip=0\u0026take=1000\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId -propertyName \"Items\"\n    \n    $lastDeploymentTime = $(Get-Date).AddYears(-50)\n    $approvalTaskId = $null\n    foreach ($deployment in $releaseDeploymentList)\n    {\n        if ($deployment.EnvironmentId -ne $approvalEnvironment.Id)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) deployed to $($deployment.EnvironmentId) which doesn't match $($approvalEnvironment.Id).  Moving onto the next deployment.\"\n            continue\n        }\n\n        if ($null -ne $approvalTenant -and $null -ne $deployment.TenantId -and $deployment.TenantId -ne $approvalTenant.Id)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) was deployed to the correct environment, $($approvalEnvironment.Id), but the deployment tenant $($deployment.TenantId) doesn't match the approval tenant $($approvalTenant.Id).  Moving onto the next deployment.\"\n            continue\n        }\n        \n        Write-OctopusInformation \"The deployment $($deployment.Id) was deployed to the approval environment $($approvalEnvironment.Id).\"\n\n        $deploymentTask = Invoke-OctopusApi -octopusUrl $defaultUrl -spaceId $null -endPoint \"tasks/$($deployment.TaskId)\" -apiKey $octopusApiKey -Method \"Get\"\n        if ($deploymentTask.IsCompleted -eq $false)\n        {\n            Write-OctopusInformation \"The deployment $($deployment.Id) is being deployed to the approval environment, but it hasn't completed, moving onto the next deployment.\"\n            continue\n        }\n\n        if ($deploymentTask.IsCompleted -eq $true -and $deploymentTask.FinishedSuccessfully -eq $false)\n        {\n            Write-Information \"The deployment $($deployment.Id) was deployed to the approval environment, but it encountered a failure, moving onto the next deployment.\"\n            continue\n        }\n\n        if ($deploymentTask.StartTime -gt $lastDeploymentTime)\n        {\n            $approvalTaskId = $deploymentTask.Id\n            $lastDeploymentTime = $deploymentTask.StartTime\n        }\n    }        \n\n    if ($null -eq $approvalTaskId)\n    {\n    \tWrite-OctopusVerbose \"Unable to find a deployment to the environment, determining if it should've happened already.\"\n        $channelInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$parentChannelId\" -method \"GET\" -apiKey $octopusApiKey -spaceId $spaceId\n        $lifecyclePhases = Get-OctopusLifeCyclePhases -channel $channelInformation -defaultUrl $defaultUrl -spaceId $spaceId -OctopusApiKey $octopusApiKey -project $parentProject        \n        \n        $foundDestinationFirst = $false\n        $foundApprovalFirst = $false\n        \n        foreach ($phase in $lifecyclePhases)\n        {\n        \tif (Test-PhaseContainsEnvironmentId -phase $phase -environmentId $parentEnvironmentId)\n            {\n            \tif ($foundApprovalFirst -eq $false)\n                {\n                \t$foundDestinationFirst = $true\n                }\n            }\n            \n            if (Test-PhaseContainsEnvironmentId -phase $phase -environmentId $approvalEnvironment.Id)\n            {\n            \tif ($foundDestinationFirst -eq $false)\n                {\n                \t$foundApprovalFirst = $true\n                }\n            }\n        }\n        \n        $messageToLog = \"Unable to find a deployment for the environment $approvalEnvironmentName.  Auto approvals are disabled.\"\n        if ($foundApprovalFirst -eq $true)\n        {\n        \tWrite-OctopusWarning $messageToLog\n        }\n        else\n        {\n        \tWrite-OctopusInformation $messageToLog\n        }\n        \n        return $null\n    }\n\n    return $approvalTaskId\n}\n\nfunction Invoke-RefreshVariableSnapshot\n{\n\tparam (\n    \t$refreshVariableSnapShot,\n        $whatIf,\n        $releaseToDeploy,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n    \n    Write-OctopusVerbose \"Checking to see if variable snapshot will be updated.\"\n    \n    if ($refreshVariableSnapShot -eq \"No\")\n    {\n    \tWrite-OctopusVerbose \"Refreshing variables is set to no, skipping\"\n    \treturn\n    }\n    \n    $releaseDeploymentTemplate = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"releases/$($releaseToDeploy.Id)/deployments/template\" -spaceId $spaceId -method GET -apiKey $octopusApiKey\n    \n    if ($releaseDeploymentTemplate.IsVariableSetModified -eq $false -and $releaseDeploymentTemplate.IsLibraryVariableSetModified -eq $false)\n    {\n    \tWrite-OctopusVerbose \"Variables have not been updated since release creation, skipping\"\n        return\n    }\n    \n    if ($whatIf -eq $true)\n    {\n    \tWrite-OctopusSuccess \"Variables have been updated since release creation, whatif set to true, no update will occur.\"\n        return\n    }\n    \n    $snapshotVariables = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"releases/$($releaseToDeploy.Id)/snapshot-variables\" -spaceId $spaceId -method \"POST\" -apiKey $octopusApiKey\n    Write-OctopusSuccess \"Variables have been modified since release creation.  Variable snapshot was updated on $($snapshotVariables.LastModifiedOn)\"\n}\n\nfunction Get-MatchingOctopusDeploymentTasks\n{\n    param (\n        $spaceId,\n        $project,\n        $tenantToDeploy,\n        $tenantIsAssignedToPreviousEnvironments,\n        $sourceDestinationEnvironmentInfo,\n        $defaultUrl,\n        $octopusApiKey\n    )\n\n    $taskEndPoint = \"tasks?skip=0\u0026take=100\u0026spaces=$spaceId\u0026includeSystem=false\u0026project=$($project.Id)\u0026name=Deploy\u0026states=Success\"\n\n    if ($null -ne $tenantToDeploy -and $tenantIsAssignedToPreviousEnvironments -eq $true)\n    {\n        $taskEndPoint += \"\u0026tenant=$($tenantToDeploy.Id)\"\n    }\n\n    $taskList = @()\n\n    foreach ($sourceEnvironmentId in $sourceDestinationEnvironmentInfo.SourceEnvironmentList)\n    {\n        $octopusTaskList = Get-ListFromOctopusApi -octopusUrl $DefaultUrl -endPoint \"$($taskEndPoint)\u0026environment=$sourceEnvironmentId\" -spaceId $null -apiKey $octopusApiKey -method \"GET\" -propertyName \"Items\"\n        $taskList += $octopusTaskList\n    }\n\n    $orderedTaskList = @($taskList | Sort-Object -Property StartTime -Descending)\n    Write-OctopusVerbose \"We have $($orderedTaskList.Count) number of tasks to loop through\"\n\n    return $orderedTaskList\n}\n\nfunction Get-ReleaseToDeployFromTaskList\n{\n    param (\n        $taskList,\n        $channel,\n        $releaseNumber,\n        $tenantToDeploy,\n        $sourceDestinationEnvironmentInfo,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey,\n        $isPromotionMode\n    )\n    \n    foreach ($task in $taskList)\n    {\n        Write-OctopusVerbose \"Pulling the deployment information for $($task.Id)\"\n        $deploymentInformation = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"deployments/$($task.Arguments.DeploymentId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n\n        if ($deploymentInformation.ChannelId -ne $channel.Id)\n        {\n            Write-OctopusInformation \"The deployment was not for the channel we want to deploy to, moving onto next task.\"\n            continue\n        }\n\n        Write-OctopusVerbose \"Pulling the release information for $($deploymentInformation.Id)\"\n        $releaseInformation = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"releases/$($deploymentInformation.ReleaseId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n        \n        if ($isPromotionMode -eq $false)\n        {\n            Write-OctopusInformation \"Current mode is set to redeploy, the release is for the correct channel and was successful, using it.\"            \n            return $releaseInformation\n        }\n\n        if ([string]::IsNullOrWhiteSpace($releaseNumber) -eq $false -and $releaseInformation.Version -notlike $releaseNumber)\n        {\n            Write-OctopusInformation \"The release version $($releaseInformation.Version) does not match $releaseNumber.  Moving onto the next task.\"\n            continue\n        }\n\n        $releaseCanBeDeployed = Get-ReleaseCanBeDeployedToTargetEnvironment -defaultUrl $defaultUrl -release $releaseInformation -spaceId $spaceId -octopusApiKey $octopusApiKey -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -tenantToDeploy $tenantToDeploy -isPromotionMode $isPromotionMode\n\n        if ($releaseCanBeDeployed -eq $true)\n        {\n            Write-OctopusInformation \"The release $($releaseInformation.Version) can be deployed to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name).\"\n            return $releaseInformation                                    \n        }\n\n        Write-OctopusInformation \"The release $($releaseInformation.Version) cannot be deployed to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name).  Moving onto next task\"\n    } \n    \n    return $null\n}\n\nfunction Get-ReleaseToDeployFromChannel\n{\n    param (\n        $channel,\n        $releaseNumber,\n        $tenantToDeploy,\n        $sourceDestinationEnvironmentInfo,        \n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey,\n        $isPromotionMode\n    )\n\n    if ([string]::IsNullOrWhiteSpace($releaseNumber) -eq $false)\n    {        \n        $urlReleaseNumber = $releaseNumber.Replace(\"*\", \"\")\n        Write-OctopusInformation \"The release number was sent in, sending $urlReleaseNumber to the channel endpoint to have the server filter on that number first.\"\n        $releaseChannelList = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$($channel.Id)/releases?skip=0\u0026take=100\u0026searchByVersion=$urlReleaseNumber\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"    \n    }\n    else\n    {\n        Write-OctopusInformation \"The release number was not sent in, attempting to find the latest release from the channel to deploy.\"\n        $releaseChannelList = Invoke-OctopusApi -octopusUrl $defaultUrl -endPoint \"channels/$($channel.Id)/releases?skip=0\u0026take=100\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"    \n    }\n    \n    Write-OctopusInformation \"There are $($releaseChannelList.Items.Count) potential releases to go through.\"\n\n    foreach ($releaseInformation in $releaseChannelList.Items)\n    {\n        if ([string]::IsNullOrWhiteSpace($releaseNumber) -eq $false -and $releaseInformation.Version -notlike $releaseNumber)\n        {\n            Write-OctopusInformation \"The release version $($releaseInformation.Version) does not match $releaseNumber.  Moving onto the next release in the channel.\"\n            continue\n        }\n\n        $releaseCanBeDeployed = Get-ReleaseCanBeDeployedToTargetEnvironment -defaultUrl $defaultUrl -release $releaseInformation -spaceId $spaceId -octopusApiKey $octopusApiKey -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -tenantToDeploy $tenantToDeploy -isPromotionMode $isPromotionMode\n\n        if ($releaseCanBeDeployed -eq $true)\n        {\n            Write-OctopusInformation \"The release $($releaseInformation.Version) can be deployed to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name).\"\n            return $releaseInformation                                    \n        }\n\n        Write-OctopusInformation \"The release $($releaseInformation.Version) cannot be deployed to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name).  Moving onto next release in the channel.\"\n    }\n\n    return $null\n}\n\nfunction Get-ReleaseHasAlreadyBeenPromotedToTargetEnvironment\n{\n    param (\n        $releaseToDeploy,\n        $tenantToDeploy,\n        $sourceDestinationEnvironmentInfo,\n        $isPromotionMode,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    if ($isPromotionMode -eq $false)\n    {\n        Write-OctopusInformation \"Currently in redeploy mode, of course the release has already been deployed to the target environment.  Exiting the Release Has Already Been Promoted To Target Environment check.\"\n        return $true\n    }\n\n    Write-OctopusVerbose \"Pulling the last release for the target environment to see if the release to deploy is the latest one in that environment.\"\n    $taskEndPoint = \"tasks?skip=0\u0026take=1\u0026spaces=$spaceId\u0026includeSystem=false\u0026project=$($releaseToDeploy.ProjectId)\u0026name=Deploy\u0026states=Success\u0026environment=$($sourceDestinationEnvironmentInfo.TargetEnvironment.Id)\"\n\n    if ($null -ne $tenantToDeploy)\n    {\n        $taskEndPoint += \"\u0026tenant=$($tenantToDeploy.Id)\"\n    }\n\n    $octopusTaskList = Get-ListFromOctopusApi -octopusUrl $DefaultUrl -endPoint \"$taskEndPoint\" -spaceId $null -apiKey $octopusApiKey -method \"GET\" -propertyName \"Items\"\n\n    if ($octopusTaskList.Count -eq 0)\n    {\n        Write-OctopusInformation \"There have been no releases to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name) for this project.\"\n        return $false\n    }\n\n    $task = $octopusTaskList[0]\n    $deploymentInformation = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"deployments/$($task.Arguments.DeploymentId)\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n\n    if ($releaseToDeploy.Id -eq $deploymentInformation.ReleaseId)\n    {\n        Write-OctopusInformation \"The release to deploy $($release.ReleaseNumber) is the last successful release to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name)\"\n        return $true\n    }\n\n    Write-OctopusInformation \"The release to deploy $($release.ReleaseNumber) is different than the last successful release to $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name)\"\n    return $false\n}\n\nfunction Get-MachineIdsFromMachineNames\n{\n    param (\n        $targetMachines,\n        $defaultUrl,\n        $spaceId,\n        $octopusApiKey\n    )\n\n    $targetMachineList = $targetMachines -split \",\"\n    $translatedList = @()\n\n    foreach ($machineName in $targetMachineList)\n    {\n    \t$trimmedMachineName = $machineName.Trim()\n        Write-OctopusVerbose \"Translating $trimmedMachineName into an Octopus Id\"\n    \tif ($trimmedMachineName -like \"Machines-*\")\n        {\n        \tWrite-OctopusVerbose \"$trimmedMachineName is already an Octopus Id, adding it to the list\"\n        \t$translatedList += $machineName\n            continue\n        }\n        \n        $machineObject = Get-OctopusItemByName -itemName $trimmedMachineName -itemType \"Deployment Target\" -endpoint \"machines\" -defaultValue $null -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n\n        $translatedList += $machineObject.Id\n    }\n\n    return $translatedList -join \",\"\n}\n\nfunction Write-ReleaseInformation\n{\n    param (\n        $releaseToDeploy,\n        $environmentList\n    )\n\n    $releaseDeployments = Invoke-OctopusApi -octopusUrl $DefaultUrl -endPoint \"releases/$($releaseToDeploy.Id)/deployments\" -spaceId $spaceId -apiKey $octopusApiKey -method \"GET\"\n    $releaseEnvironmentList = @()\n\n    foreach ($deployment in $releaseDeployments.Items)\n    {        \n        $releaseEnvironment = $environmentList | Where-Object {$_.Id -eq $deployment.EnvironmentId }\n        \n        if ($null -ne $releaseEnvironment -and $releaseEnvironmentList -notcontains $releaseEnvironment.Name)\n        {\n            Write-OctopusVerbose \"Adding $($releaseEnvironment.Name) to the list of environments this release has been deployed to\"\n            $releaseEnvironmentList += $releaseEnvironment.Name\n        }                \n    }\n    \n    if ($releaseEnvironmentList.Count -gt 0)\n    {\n        Write-OctopusSuccess \"The release to deploy is $($releaseToDeploy.Version) which has been deployed to $($releaseEnvironmentList -join \",\")\"\n    }\n    else\n    {\n        Write-OctopusSuccess \"The release to deploy is $($releaseToDeploy.Version) which currently has no deployments.\"    \n    }\n}\n\nfunction Get-GuidedFailureMode\n{\n\tparam (\n    \t$projectToDeploy,\n        $environmentToDeployTo\n    )\n    \n    Write-OctopusInformation \"Checking $($projectToDeploy.DefaultGuidedFailureMode) and $($environmentToDeployTo.UseGuidedFailure) to determine guided failure mode.\"\n    \n    if ($projectToDeploy.DefaultGuidedFailureMode -eq \"EnvironmentDefault\" -and $environmentToDeployTo.UseGuidedFailure -eq $true)\n    {\n    \tWrite-OctopusInformation \"Guided failure for the project is set to environment default, and destination environment says to use guided failure.  Setting guided failure to true.\"\n        return $true\n    }\n    \n    if ($projectToDeploy.DefaultGuidedFailureMode -eq \"On\")\n    {\n    \tWrite-OctopusInformation \"Guided failure for the project is set to always use guided falure.  Setting guided failure to true.\"\n        return $true\n    }\n    \n    Write-OctopusInformation \"Guided failure is not turned on for the project nor the environment.  Setting to false.\"\n    return $false\n}\n\nWrite-OctopusInformation \"Octopus SpaceId: $destinationSpaceId\"\nWrite-OctopusInformation \"Octopus Deployment Task Id: $parentDeploymentTaskId\"\nWrite-OctopusInformation \"Octopus Project Name: $parentProjectName\"\nWrite-OctopusInformation \"Octopus Release Number: $parentReleaseNumber\"\nWrite-OctopusInformation \"Octopus Release Id: $parentReleaseId\"\nWrite-OctopusInformation \"Octopus Environment Name: $parentEnvironmentName\"\nWrite-OctopusInformation \"Octopus Release Channel Id: $parentChannelId\"\nWrite-OctopusInformation \"Octopus Specific deployment machines: $specificMachines\"\nWrite-OctopusInformation \"Octopus Exclude deployment machines: $excludeMachines\"\nWrite-OctopusInformation \"Octopus deployment machines: $deploymentMachines\"\n\nWrite-OctopusInformation \"Child Project Name: $projectName\"\nWrite-OctopusInformation \"Child Project Space Name: $destinationSpaceName\"\nWrite-OctopusInformation \"Child Project Channel Name: $channelName\"\nWrite-OctopusInformation \"Child Project Release Number: $releaseNumber\"\nWrite-OctopusInformation \"Child Project Error Handle No Release Found: $errorHandleForNoRelease\"\nWrite-OctopusInformation \"Destination Environment Name: $environmentName\"\nWrite-OctopusInformation \"Source Environment Name: $sourceEnvironmentName\"\nWrite-OctopusInformation \"Ignore specific machine mismatch: $ignoreSpecificMachineMismatchValue\"\nWrite-OctopusInformation \"Save release notes as artifact: $saveReleaseNotesAsArtifactValue\"\nWrite-OctopusInformation \"What If: $whatIfValue\"\nWrite-OctopusInformation \"Wait for finish: $waitForFinishValue\"\nWrite-OctopusInformation \"Cancel deployment in seconds: $deploymentCancelInSeconds\"\nWrite-OctopusInformation \"Scheduling: $futureDeploymentDate\"\nWrite-OctopusInformation \"Auto-Approve Child Project Manual Interventions: $autoapproveChildManualInterventionsValue\"\nWrite-OctopusInformation \"Approval Environment: $approvalEnvironmentName\"\nWrite-OctopusInformation \"Approval Tenant: $approvalTenantName\"\nWrite-OctopusInformation \"Refresh Variable Snapshot: $refreshVariableSnapShot\"\nWrite-OctopusInformation \"Deployment Mode: $deploymentMode\"\nWrite-OctopusInformation \"Target Machine Names: $targetMachines\"\nWrite-OctopusInformation \"Deployment Tenant Name: $deploymentTenantName\"\n\n$whatIf = $whatIfValue -eq \"Yes\"\n$waitForFinish = $waitForFinishValue -eq \"Yes\"\n$ignoreSpecificMachineMismatch = $ignoreSpecificMachineMismatchValue -eq \"Yes\"\n$autoapproveChildManualInterventions = $autoapproveChildManualInterventionsValue -eq \"Yes\"\n$saveReleaseNotesAsArtifact = $saveReleaseNotesAsArtifactValue -eq \"Yes\"\n\n$verificationPassed = @()\n$verificationPassed += Test-RequiredValues -variableToCheck $octopusApiKey -variableName \"Octopus API Key\"\n$verificationPassed += Test-RequiredValues -variableToCheck $destinationSpaceName -variableName \"Child Project Space\"\n$verificationPassed += Test-RequiredValues -variableToCheck $projectName -variableName \"Child Project Name\"\n$verificationPassed += Test-RequiredValues -variableToCheck $environmentName -variableName \"Destination Environment Name\"\n\nif ($verificationPassed -contains $false)\n{\n\tWrite-OctopusInformation \"Required values missing\"\n\tExit 1\n}\n\n$isPromotionMode = $deploymentMode -eq \"Promote\"\n$spaceId = Get-OctopusSpaceIdByName -spaceName $destinationSpaceName -spaceId $destinationSpaceId -defaultUrl $defaultUrl -OctopusApiKey $octopusApiKey    \n\nWrite-OctopusSuccess \"The current mode of the step template is $deploymentMode\"\n\nif ($isPromotionMode -eq $false)\n{\n    Write-OctopusSuccess \"Currently in redeploy mode, release number filter will be ignored, source environment will be set to the target environment, all redeployment checks will be ignored.\"\n}\n\nif ($isPromotionMode -eq $true -and [string]::IsNullOrWhiteSpace($sourceEnvironmentName) -eq $false -and $sourceEnvironmentName.ToLower().Trim() -eq $environmentName.ToLower().Trim())\n{\n    Write-OctopusSuccess \"The current mode is promotion.  Both the source environment and destination environment are the same.  You cannot promote from the same environment as the source environment.  Exiting.  Change the deployment mode value to redeploy if you want to redeploy.\"\n    Exit 0\n}\n\n$specificMachineDeployment = $false\nif ([string]::IsNullOrWhiteSpace($specificMachines) -eq $false)\n{\n\tWrite-OctopusSuccess \"This deployment is targeting the specific machines $specificMachines.\"\n\t$specificMachineDeployment = $true\n}\n\nif ([string]::IsNullOrWhiteSpace($excludeMachines) -eq $false)\n{\n\tWrite-OctopusSuccess \"This deployment is excluding the specific machines $excludeMachines.  The machines being deployed to are: $deploymentMachines.\"\n    $specificMachineDeployment = $true\n}\n\nif ([string]::IsNullOrWhiteSpace($targetMachines) -eq $false -and $targetMachines -ne \"N/A\")\n{\n    Write-OctopusSuccess \"You have specified specific machines to target in this deployment.  Ignoring the machines that triggered this deployment.\"\n    $specificMachineDeployment = $true\n    $deploymentMachines = Get-MachineIdsFromMachineNames -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -targetMachines $targetMachines\n}\n\n$project = Get-OctopusProjectByName -projectName $projectName -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n$parentProject = Get-OctopusProjectByName -projectName $parentProjectName -defaultUrl $defaultUrl -spaceId $parentSpaceId -octopusApiKey $octopusApiKey\n$tenantToDeploy = Get-OctopusTenantByName -tenantName $deploymentTenantName -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n$targetEnvironment = Get-OctopusEnvironmentByName -environmentName $environmentName -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n$tenantToDeploy = Test-ProjectTenantSettings -tenantToDeploy $tenantToDeploy -project $project -targetEnvironment $targetEnvironment\n\n$sourceEnvironment = Get-OctopusEnvironmentByName -environmentName $sourceEnvironmentName -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n$channel = Get-OctopusChannel -channelName $channelName -defaultUrl $defaultUrl -project $project -spaceId $spaceId -octopusApiKey $octopusApiKey\n$phaseList = Get-OctopusLifecyclePhases -channel $channel -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -project $project\n$sourceDestinationEnvironmentInfo = Get-SourceDestinationEnvironmentInformation -phaseList $phaseList -targetEnvironment $targetEnvironment -sourceEnvironment $sourceEnvironment -isPromotionMode $isPromotionMode\n\nif ($sourceDestinationEnvironmentInfo.FirstLifecyclePhase -eq $false)\n{\n    $tenantIsAssignedToPreviousEnvironments = Get-TenantIsAssignedToPreviousEnvironments -tenantToDeploy $tenantToDeploy -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -projectId $project.Id -isPromotionMode $isPromotionMode\n    $taskList = Get-MatchingOctopusDeploymentTasks -spaceId $spaceId -project $project -tenantToDeploy $tenantToDeploy -tenantIsAssignedToPreviousEnvironments $tenantIsAssignedToPreviousEnvironments -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n    $releaseToDeploy = Get-ReleaseToDeployFromTaskList -taskList $taskList -channel $channel -releaseNumber $releaseNumber -tenantToDeploy $tenantToDeploy -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -defaultUrl $DefaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -isPromotionMode $isPromotionMode    \n\n    if ($null -eq $releaseToDeploy -and $sourceDestinationEnvironmentInfo.HasRequiredPhase -eq $false)\n    {\n        Write-OctopusInformation \"No release was found that has been deployed.  However, all the phases prior to the destination phase is optional.  Checking to see if any releases exist at the channel level that haven't been deployed.\"\n        $releaseToDeploy = Get-ReleaseToDeployFromChannel -channel $channel -releaseNumber $releaseNumber -tenantToDeploy $tenantToDeploy -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -isPromotionMode $isPromotionMode    \n    }\n}\nelse\n{\n    $releaseToDeploy = Get-ReleaseToDeployFromChannel -channel $channel -releaseNumber $releaseNumber -tenantToDeploy $tenantToDeploy -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -isPromotionMode $isPromotionMode    \n}\n\n$environmentList = Get-ListFromOctopusApi -octopusUrl $defaultUrl -endPoint \"environments?skip=0\u0026take=1000\" -spaceId $spaceId -propertyName \"Items\" -apiKey $octopusApiKey\n\nTest-ReleaseToDeploy -releaseToDeploy $releaseToDeploy -errorHandleForNoRelease $errorHandleForNoRelease -releaseNumber $releaseNumber -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -environmentList $environmentList\n\nif ($null -ne $releaseToDeploy)\n{\n    Write-ReleaseInformation -releaseToDeploy $releaseToDeploy -environmentList $environmentList\n}\n\n$releaseHasAlreadyBeenDeployed = Get-ReleaseHasAlreadyBeenPromotedToTargetEnvironment -releaseToDeploy $releaseToDeploy -tenantToDeploy $tenantToDeploy -sourceDestinationEnvironmentInfo $sourceDestinationEnvironmentInfo -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -isPromotionMode $isPromotionMode\n\n$deploymentPreview = Get-DeploymentPreview -releaseToDeploy $releaseToDeploy -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -targetEnvironment $targetEnvironment -deploymentTenant $tenantToDeploy\n$childDeploymentSpecificMachines = Get-ChildDeploymentSpecificMachines -deploymentPreview $deploymentPreview -deploymentMachines $deploymentMachines -specificMachineDeployment $specificMachineDeployment\n$deploymentFormValues = Get-ValuesForPromptedVariables -formValues $formValues -deploymentPreview $deploymentPreview\n\n$queueDate = Get-QueueDate -futureDeploymentDate $futureDeploymentDate\n$queueExpiryDate = Get-QueueExpiryDate -queueDate $queueDate\n$useGuidedFailure = Get-GuidedFailureMode -projectToDeploy $project -environmentToDeployTo $targetEnvironment\n\n$createdDeployment = @{\n    EnvironmentId = $targetEnvironment.Id;\n    ExcludeMachineIds = @();\n    ForcePackageDownload = $false;\n    ForcePackageRedeployment = $false;\n    FormValues = $deploymentFormValues;\n    QueueTime = $queueDate;\n    QueueTimeExpiry = $queueExpiryDate;\n    ReleaseId = $releaseToDeploy.Id;\n    SkipActions = @();\n    SpecificMachineIds = @($childDeploymentSpecificMachines);\n    TenantId = $null;\n    UseGuidedFailure = $useGuidedFailure\n}\n\nif ($null -ne $tenantToDeploy -and $project.TenantedDeploymentMode -ne \"Untenanted\")\n{\n    $createdDeployment.TenantId = $tenantToDeploy.Id\n}\n\nif ($whatIf -eq $true)\n{    \t\n    Write-OctopusVerbose \"Would have done a POST to /api/$spaceId/deployments with the body:\"\n    Write-OctopusVerbose $($createdDeployment | ConvertTo-JSON)        \n    \n    Write-OctopusSuccess \"What If set to true.\"\n    Write-OctopusSuccess \"Setting the output variable ReleaseToPromote to $($releaseToDeploy.Version).\"            \n\tSet-OctopusVariable -Name \"ReleaseToPromote\" -Value ($releaseToDeploy.Version)       \n}\n\nWrite-OctopusVerbose \"Getting the release notes\"\n$releaseNotes = Get-ReleaseNotes -releaseToDeploy $releaseToDeploy -deploymentPreview $deploymentPreview -channel $channel -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\nWrite-OctopusSuccess \"Setting the output variable ReleaseNotes which contains the release notes from the child project\"\nSet-OctopusVariable -Name \"ReleaseNotes\" -value $releaseNotes\n\nTest-ChildProjectDeploymentCanProceed -releaseToDeploy $releaseToDeploy -specificMachineDeployment $specificMachineDeployment -environmentName $environmentName -childDeploymentSpecificMachines $childDeploymentSpecificMachines -project $project -ignoreSpecificMachineMismatch $ignoreSpecificMachineMismatch -deploymentMachines $deploymentMachines -releaseHasAlreadyBeenDeployed $releaseHasAlreadyBeenDeployed -isPromotionMode $isPromotionMode\n\nif ($saveReleaseNotesAsArtifact -eq $true)\n{\n\t$releaseNotes | Out-File \"ReleaseNotes.txt\"\n    $currentDate = Get-Date\n\t$currentDateFormatted = $currentDate.ToString(\"yyyy_MM_dd_HH_mm\")\n    $artifactName = \"$($project.Name) $($releaseToDeploy.Version) $($sourceDestinationEnvironmentInfo.TargetEnvironment.Name).ReleaseNotes_$($currentDateFormatted).txt\"\n    Write-OctopusInformation \"Creating the artifact $artifactName\"\n    \n\tNew-OctopusArtifact -Path \"ReleaseNotes.txt\" -Name $artifactName\n}\n\nInvoke-RefreshVariableSnapshot -refreshVariableSnapShot $refreshVariableSnapShot -whatIf $whatIf -releaseToDeploy $releaseToDeploy -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey\n\nif ($whatif -eq $true)\n{\n    Write-OctopusSuccess \"Exiting because What If set to true.\"\n    Write-OctopusInformation \"Setting the output variable ChildReleaseToDeploy to $true\"\n    Set-OctopusVariable -Name \"ChildReleaseToDeploy\" -Value $true\n    Exit 0\n}\n\n$approvalTenant = Get-OctopusApprovalTenant -tenantToDeploy $tenantToDeploy -approvalTenantName $approvalTenantName -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n$approvalDeploymentTaskId = Get-ApprovalDeploymentTaskId -autoapproveChildManualInterventions $autoapproveChildManualInterventions  -parentDeploymentTaskId $parentDeploymentTaskId -parentReleaseId $parentReleaseId -parentEnvironmentName $parentEnvironmentName -approvalEnvironmentName $approvalEnvironmentName -defaultUrl $defaultUrl -spaceId $spaceId -octopusApiKey $octopusApiKey -parentChannelId $parentChannelId -parentEnvironmentId $parentEnvironmentId -approvalTenant $approvalTenant -parentProject $parentProject\n$parentDeploymentApprovers = Get-ParentDeploymentApprovers -parentDeploymentTaskId $approvalDeploymentTaskId -spaceId $spaceId -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey\n\nCreate-NewOctopusDeployment -releaseToDeploy $releaseToDeploy -targetEnvironment $targetEnvironment -createdDeployment $createdDeployment -project $project -waitForFinish $waitForFinish -deploymentCancelInSeconds $deploymentCancelInSeconds -defaultUrl $defaultUrl -octopusApiKey $octopusApiKey -spaceId $spaceId -parentDeploymentApprovers $parentDeploymentApprovers -parentProjectName $parentProjectName -parentReleaseNumber $parentReleaseNumber -parentEnvironmentName $approvalEnvironmentName -parentDeploymentTaskId $approvalDeploymentTaskId -autoapproveChildManualInterventions $autoapproveChildManualInterventions -approvalTenant $approvalTenant"
        "Octopus.Action.RunOnServer"                              = "true"
        "ChildProject.Project.Name"                               = "#{Octopus.Project.Name}"
        "ChildProject.Api.Key"                                    = "#{DemoSpaceCreator.Octopus.APIKey}"
        "ChildProject.ReleaseNotes.SaveAsArtifact"                = "No"
        "ChildProject.Deployment.FutureTime"                      = "N/A"
        "ChildProject.WhatIf.Value"                               = "No"
        "ChildProject.Target.MachineNames"                        = "N/A"
        "ChildProject.Space.Name"                                 = "#{Octopus.Space.Name}"
        "ChildProject.Prompted.Variables"                         = "DemoSpaceCreator.Prompts.CreateECSDemo::#{DemoSpaceCreator.CreateTenant.CreateECSDemo}\nDemoSpaceCreator.Prompts.CreateHelmDemo::#{DemoSpaceCreator.CreateTenant.CreateHelmDemo}\nDemoSpaceCreator.Prompts.CreateKubernetesDemo::#{DemoSpaceCreator.CreateTenant.CreateKubernetesDemo}\nDemoSpaceCreator.Prompts.CreateOctoFXDemo::#{DemoSpaceCreator.CreateTenant.CreateOctoFXDemo}\nDemoSpaceCreator.Prompts.CreateServiceNowDemo::#{DemoSpaceCreator.CreateTenant.CreateServiceNowDemo}\nDemoSpaceCreator.Prompts.CreateTenantsDemo::#{DemoSpaceCreator.CreateTenant.CreateTenantsDemo}\nDemoSpaceCreator.Prompts.CreateJSMDemo::#{DemoSpaceCreator.CreateTenant.CreateJSMDemo}\nDemoSpaceCreator.Prompts.CreateLambdaDemo::#{DemoSpaceCreator.CreateTenant.CreateLambdaDemo}"
        "ChildProject.WaitForFinish.Value"                        = "Yes"
        "ChildProject.DeploymentMode.Value"                       = "Promote"
        "Octopus.Action.Script.Syntax"                            = "PowerShell"
        "ChildProject.ManualIntervention.Tenant.Name"             = "#{DemoSpaceCreator.CreateTenant.TenantName}"
        "ChildProject.Web.ServerUrl"                              = "#{Octopus.Web.ServerUri}"
        "ChildProject.Destination.EnvironmentName"                = "#{Octopus.Environment.Name}"
        "ChildProject.Release.NotFoundError"                      = "Error"
        "ChildProject.RefreshVariableSnapShots.Option"            = "No"
        "ChildProject.ManualIntervention.EnvironmentToUse"        = "#{Octopus.Environment.Name}"
        "ChildProject.CancelDeployment.Seconds"                   = "1800"
        "ChildProject.Deployment.IgnoreSpecificMachineMismatch"   = "No"
        "ChildProject.Tenant.Name"                                = "#{DemoSpaceCreator.CreateTenant.TenantName}"
      }
      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []
      features              = []
    }

    properties   = {
      "Octopus.Step.ConditionVariableExpression" = "#{unless Octopus.Deployment.Error}#{DemoSpaceCreator.CreateTenant.DeployEverything}#{/unless}"
    }
    target_roles = []
  }
  depends_on = []
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

data "octopusdeploy_worker_pools" "workerpool_hosted_windows" {
  ids          = null
  partial_name = "Hosted Windows"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a worker pool called \"Hosted Windows\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.worker_pools) != 0
    }
  }
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "https://octopetshop.atlassian.net/"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = ""
}

variable "demo_space_creator_demospacecreator_createtenant_snowoauthclientid_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.SNOWOAuthClientId"
  default     = "not set"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_snowoauthclientid_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_snowoauthclientid_1}"
  name         = "DemoSpaceCreator.CreateTenant.SNOWOAuthClientId"
  type         = "String"
  description  = "The OAuth client ID to use when connecting to the ServiceNow instance."
  is_sensitive = false

  prompt {
    description = "The OAuth client ID to use when connecting to the ServiceNow instance."
    label       = "5.2: ServiceNow OAuth Client Id"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = "robpearson"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_ryan_s_sandbox" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value          = "False"
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_james_c" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_james_c.id}"
  value                   = "ea19ae94ead211109ea84047dc17d4dc"
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "True"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "not set"
}

variable "demo_space_creator_demospacecreator_createtenant_jsmprojectname_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.JSMProjectName"
  default     = "Goji"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_jsmprojectname_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_jsmprojectname_1}"
  name         = "DemoSpaceCreator.CreateTenant.JSMProjectName"
  type         = "String"
  description  = "The name of the project in JSM to create and check issues."
  is_sensitive = false

  prompt {
    description = "The name of the project in JSM to create and check issues."
    label       = "4.4: JSM Project Name"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "Goji"
}

variable "runbook_demo_space_creator_quick_start_name" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The name of the runbook exported from Quick start"
  default     = "Quick start"
}
resource "octopusdeploy_runbook" "runbook_demo_space_creator_quick_start" {
  name                        = "${var.runbook_demo_space_creator_quick_start_name}"
  project_id                  = "${octopusdeploy_project.project_demo_space_creator.id}"
  environment_scope           = "All"
  environments                = []
  force_package_download      = false
  default_guided_failure_mode = "EnvironmentDefault"
  description                 = "**Action**: Create a tenant and optionally create the space and deploy templates to it.\n\n**Affects**: Everyone."
  multi_tenancy_mode          = "Untenanted"

  retention_policy {
    quantity_to_keep    = 100
    should_keep_forever = false
  }

  connectivity_policy {
    allow_deployments_to_no_targets = true
    exclude_unhealthy_targets       = false
    skip_machine_behavior           = "None"
  }
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant" "tenant_ryan_s_sandbox" {
  name        = "Ryan's Sandbox"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Options/Run Daily Deployments", "Options/Dev and QA Teams",
    "Region/NA", "Role/Solutions Engineer", "State/Created", "Active Projects/OctoFX Template",
    "Active Projects/Tenants Template", "Active Projects/Kubernetes Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_dev_and_qa_teams,
    octopusdeploy_tag.tag_kubernetes_template, octopusdeploy_tag.tag_octofx_template,
    octopusdeploy_tag.tag_tenants_template
  ]
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant" "tenant_devtools" {
  name        = "DevTools"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created",
    "Active Projects/OctoFX Template", "Active Projects/Tenants Template", "Active Projects/Kubernetes Template",
    "Active Projects/Helm Template", "Active Projects/ECS Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_ecs_template,
    octopusdeploy_tag.tag_helm_template, octopusdeploy_tag.tag_kubernetes_template,
    octopusdeploy_tag.tag_octofx_template, octopusdeploy_tag.tag_tenants_template
  ]
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = "octopus"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_kubecon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon.id}"
  value                   = "KubeCon NAM 2023"
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "b2d2c9196baf3110a63d52a0f9929577"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "False"
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_ryan_s_sandbox" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value                   = "ryanrousseau"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "https://dev201672.service-now.com"
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant" "tenant_kailen_garcia" {
  name        = "Kailen Garcia"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/SDR", "State/Created"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_sdr, octopusdeploy_tag.tag_created
  ]
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_insights" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_insights.id}"
  value          = "True"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

data "octopusdeploy_library_variable_sets" "library_variable_set_demo_space_management" {
  ids          = null
  partial_name = "Demo Space Management"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a library variable set called \"Demo Space Management\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.library_variable_sets) != 0
    }
  }
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant" "tenant_matthew_casperson" {
  name        = "Matthew Casperson"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "Region/APAC", "State/Created",
    "Options/Do Not Delete", "Options/Run Daily Deployments", "Options/Dev and QA Teams",
    "Active Projects/Lambda Template", "Active Projects/Point of Sale Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_apac, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_do_not_delete,
    octopusdeploy_tag.tag_dev_and_qa_teams, octopusdeploy_tag.tag_lambda_template,
    octopusdeploy_tag.tag_point_of_sale_template
  ]
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_ryan_s_sandbox" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value          = "False"
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = "rob.enterprise.demo.octopus.app"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = "NDC_DEMO_2"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_mark_lamprecht" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_lamprecht.id}"
  value                   = "mark.lamprecht@octopus.com"
}

variable "demo_space_creator_demospacecreator_prompts_createservicenowdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateServiceNowDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createservicenowdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createservicenowdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateServiceNowDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "08. Create ServiceNow Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_shawn_sesna" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_shawn_sesna.id}"
  value                   = "shawn.sesna@octopus.com"
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

variable "demo_space_creator_demospacecreator_octopus_apikey_1" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable DemoSpaceCreator.Octopus.APIKey"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_octopus_apikey_1" {
  owner_id        = "${octopusdeploy_project.project_demo_space_creator.id}"
  name            = "DemoSpaceCreator.Octopus.APIKey"
  type            = "Sensitive"
  sensitive_value = "${var.demo_space_creator_demospacecreator_octopus_apikey_1}"
  is_sensitive    = true
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tenant" "tenant_adam_close" {
  name        = "Adam Close"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created",
    "Active Projects/OctoFX Template", "Active Projects/Tenants Template", "Active Projects/Kubernetes Template",
    "Active Projects/Helm Template", "Active Projects/ECS Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_ecs_template,
    octopusdeploy_tag.tag_helm_template, octopusdeploy_tag.tag_kubernetes_template,
    octopusdeploy_tag.tag_octofx_template, octopusdeploy_tag.tag_tenants_template
  ]
}

resource "octopusdeploy_tenant" "tenant_justin_bowlby" {
  name        = "Justin Bowlby"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Account Executive", "State/Created", "Region/NA",
    "Options/Run Daily Deployments"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_account_executive, octopusdeploy_tag.tag_na,
    octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_run_daily_deployments
  ]
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = "matthew.casperson@octopus.com"
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

variable "demo_space_creator_demospacecreator_exporttask_password_1" {
  type        = string
  nullable    = true
  sensitive   = true
  description = "The secret variable value associated with the variable DemoSpaceCreator.ExportTask.Password"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_exporttask_password_1" {
  owner_id        = "${octopusdeploy_project.project_demo_space_creator.id}"
  name            = "DemoSpaceCreator.ExportTask.Password"
  type            = "Sensitive"
  sensitive_value = "${var.demo_space_creator_demospacecreator_exporttask_password_1}"
  is_sensitive    = true
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_canary" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_canary.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tenant" "tenant_kubecon" {
  name        = "KubeCon"
  description = "Space for KubeCon event "
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Options/Run Daily Deployments", "Options/Shared Access",
    "Options/Dev and QA Teams", "Role/Conference", "Region/NA"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_conference, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_run_daily_deployments,
    octopusdeploy_tag.tag_shared_access, octopusdeploy_tag.tag_dev_and_qa_teams
  ]
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "not set"
}

data "octopusdeploy_channels" "channel__default" {
  ids          = []
  partial_name = "Default"
  skip         = 0
  take         = 1
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_ryan_s_sandbox" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value                   = "demo.sandbox2"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_shawn_sesna" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_shawn_sesna.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "markocto"
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "Multi-TenancyCon North America 2023"
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

provider "octopusdeploy" {
  address  = "${trimspace(var.octopus_server)}"
  api_key  = "${trimspace(var.octopus_apikey)}"
  space_id = "${trimspace(var.octopus_space_id)}"
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = "marketing.demo.octopus.app"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_kubecon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant" "tenant_james_c" {
  name        = "James C"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "Region/NA",
    "Options/Run Daily Deployments", "Options/Dev and QA Teams", "State/Created", "Active Projects/Lambda Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_dev_and_qa_teams,
    octopusdeploy_tag.tag_lambda_template
  ]
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_iis_and_sql" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_iis_and_sql.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "https://markharrison.atlassian.net/"
}

resource "octopusdeploy_tenant" "tenant_marketing" {
  name        = "Marketing"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Product"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_product
  ]
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = "14b841c59e6731105130015f17e10d4c"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_marketing" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_marketing.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

variable "demo_space_creator_demospacecreator_prompts_createecsdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateECSDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createecsdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createecsdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateECSDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "07.  Create ECS Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_ndc_oslo" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_ndc_oslo.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_james_c" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_james_c.id}"
  value                   = "https://dev112958.service-now.com/"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant" "tenant_shawn_sesna" {
  name        = "Shawn Sesna"
  tenant_tags = [
    "Cloud Provider/Azure", "Role/Solutions Engineer", "Region/NA", "Cloud Provider/AWS", "State/Created",
    "Active Projects/OctoFX Template", "Active Projects/Tenants Template", "Active Projects/Kubernetes Template",
    "Active Projects/Helm Template", "Active Projects/ECS Template", "Active Projects/Lambda Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer,
    octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_ecs_template,
    octopusdeploy_tag.tag_helm_template, octopusdeploy_tag.tag_kubernetes_template,
    octopusdeploy_tag.tag_lambda_template, octopusdeploy_tag.tag_octofx_template,
    octopusdeploy_tag.tag_tenants_template, octopusdeploy_tag_set.tagset_cloud_provider,
    octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag_set.tagset_active_projects
  ]
}

variable "demo_space_creator_demospacecreator_prompts_createoctofxdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateOctoFXDemo"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createoctofxdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createoctofxdemo_1}"
  name         = "DemoSpaceCreator.Prompts.CreateOctoFXDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "03. Create OctoFX Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = "adamoctoclose"
}

resource "octopusdeploy_tenant" "tenant_iis_and_sql" {
  name        = "IIS and SQL"
  description = "Shared space for demoing IIS and SQL deployments"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Region/NA", "Options/Run Daily Deployments", "Options/Guest Access",
    "Options/Shared Access", "Options/Dev and QA Teams", "Role/Feature", "State/Created"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_feature, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_guest_access, octopusdeploy_tag.tag_run_daily_deployments,
    octopusdeploy_tag.tag_shared_access, octopusdeploy_tag.tag_dev_and_qa_teams
  ]
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_chris_fraser" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_chris_fraser.id}"
  value                   = "chris.fraser@octopus.com"
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_james_c" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_james_c.id}"
  value          = "True"
}

variable "demo_space_creator_demospacecreator_createtenant_snowserviceaccountuser_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.SNOWServiceAccountUser"
  default     = "not set"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_snowserviceaccountuser_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_snowserviceaccountuser_1}"
  name         = "DemoSpaceCreator.CreateTenant.SNOWServiceAccountUser"
  type         = "String"
  description  = "The service account user to use when connecting to the ServiceNow instance."
  is_sensitive = false

  prompt {
    description = "The service account user to use when connecting to the ServiceNow instance."
    label       = "5.4: ServiceNow Service Account User"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "tonykelly-octopus"
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant" "tenant_ndc_oslo" {
  name        = "NDC Oslo"
  description = "Demos specific to NDC London 2023 event "
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Conference"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_conference
  ]
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_matthew_casperson" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_matthew_casperson.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_environment" "environment_administration" {
  name                         = "Administration"
  description                  = ""
  allow_dynamic_infrastructure = true
  use_guided_failure           = false
  sort_order                   = 0

  jira_extension_settings {
    environment_type = "unmapped"
  }

  jira_service_management_extension_settings {
    is_enabled = false
  }

  servicenow_extension_settings {
    is_enabled = false
  }
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_ryan_s_sandbox" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_ryan_s_sandbox.id}"
  value          = "True"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

variable "demo_space_creator_demospacecreator_createtenant_createkubernetesdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateKubernetesDemo"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createkubernetesdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createkubernetesdemo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateKubernetesDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.4: Create Kubernetes Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

variable "demo_space_creator_demospacecreator_exporttask_taskid_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.ExportTask.TaskId"
  default     = "#{Octopus.Action[Export projects].Output.TaskId}"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_exporttask_taskid_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_exporttask_taskid_1}"
  name         = "DemoSpaceCreator.ExportTask.TaskId"
  type         = "String"
  is_sensitive = false
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "Zach's training space"
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "lianne.crocker@octopus.com"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = "Describe the demo space"
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = "d21c10b8ab382110b598dc751f0de0d7"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = "12b1d195fe203110cc6c12484e9f1ec6"
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_3_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "True"
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "ea19ae94ead211109ea84047dc17d4dc"
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_adam_close" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_adam_close.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_enterprise" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value          = "False"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_white_rock_global" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_white_rock_global.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "Goji"
}

variable "demo_space_creator_demospacecreator_createtenant_createoctofxdemo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateOctoFXDemo"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createoctofxdemo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createoctofxdemo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateOctoFXDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.2: Create OctoFX Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "https://dev112958.service-now.com/"
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "JChatmasOctopus"
}

variable "demo_space_creator_demospacecreator_prompts_createspace_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.Prompts.CreateSpace"
  default     = "True"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_prompts_createspace_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_prompts_createspace_1}"
  name         = "DemoSpaceCreator.Prompts.CreateSpace"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "02. Create Space?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

variable "demo_space_creator_demospacecreator_createtenant_snowbaseurl_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.SNOWBaseUrl"
  default     = "not set"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_snowbaseurl_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_snowbaseurl_1}"
  name         = "DemoSpaceCreator.CreateTenant.SNOWBaseUrl"
  type         = "String"
  description  = "The URL used to access the ServiceNow instance."
  is_sensitive = false

  prompt {
    description = "The URL used to access the ServiceNow instance."
    label       = "5.1: ServiceNow Base Url"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_insights" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_insights.id}"
  value          = "True"
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tenant" "tenant_insights" {
  name        = "Insights"
  description = "Shared space for demoing Enterprise Insights"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Region/NA", "Options/Do Not Delete", "Options/Run Daily Deployments",
    "Options/Dev and QA Teams", "State/Created", "Role/Feature"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_feature, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_do_not_delete,
    octopusdeploy_tag.tag_dev_and_qa_teams
  ]
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant" "tenant_zach_schatz" {
  name        = "Zach Schatz"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/TAM", "Region/NA", "State/Created",
    "Active Projects/OctoFX Template", "Options/Do Not Delete", "Active Projects/Tenants Template",
    "Active Projects/Kubernetes Template", "Active Projects/Helm Template", "Active Projects/ECS Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_tam, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_do_not_delete, octopusdeploy_tag.tag_ecs_template, octopusdeploy_tag.tag_helm_template,
    octopusdeploy_tag.tag_kubernetes_template, octopusdeploy_tag.tag_octofx_template,
    octopusdeploy_tag.tag_tenants_template
  ]
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_1_kubecon" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_kubecon.id}"
  value          = "True"
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "not set"
}

data "octopusdeploy_library_variable_sets" "library_variable_set_config_as_code" {
  ids          = null
  partial_name = "Config as Code"
  skip         = 0
  take         = 1
  lifecycle {
    postcondition {
      error_message = "Failed to resolve a library variable set called \"Config as Code\". This resource must exist in the space before this Terraform configuration is applied."
      condition     = length(self.library_variable_sets) != 0
    }
  }
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_kubecon_eu" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_kubecon_eu.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_robert_van_haaren" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_robert_van_haaren.id}"
  value                   = "RobertvanHaaren"
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant" "tenant_rob_enterprise" {
  name        = "Rob Enterprise"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "Region/APAC", "State/Created",
    "Options/Run Daily Deployments", "Options/Do Not Delete", "Active Projects/OctoFX Template",
    "Active Projects/Tenants Template", "Active Projects/Kubernetes Template", "Active Projects/Lambda Template",
    "Active Projects/JSM Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_apac, octopusdeploy_tag.tag_created,
    octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_do_not_delete,
    octopusdeploy_tag.tag_jsm_template, octopusdeploy_tag.tag_kubernetes_template,
    octopusdeploy_tag.tag_lambda_template, octopusdeploy_tag.tag_octofx_template, octopusdeploy_tag.tag_tenants_template
  ]
}

variable "demo_space_creator_demospacecreator_exporttask_projectids_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.ExportTask.ProjectIds"
  default     = "Projects-345"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_exporttask_projectids_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_exporttask_projectids_1}"
  name         = "DemoSpaceCreator.ExportTask.ProjectIds"
  type         = "String"
  is_sensitive = false
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_meghan_mattingly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_meghan_mattingly.id}"
  value                   = "meghan.mattingly@octopus.com"
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = ""
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tenant" "tenant_kubecon_eu" {
  name        = "KubeCon EU"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "State/Created",
    "Active Projects/OctoFX Template", "Active Projects/Kubernetes Template", "Active Projects/Helm Template",
    "Active Projects/ECS Template"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_state,
    octopusdeploy_tag_set.tagset_active_projects, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_ecs_template,
    octopusdeploy_tag.tag_helm_template, octopusdeploy_tag.tag_kubernetes_template,
    octopusdeploy_tag.tag_octofx_template
  ]
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_mark_h___enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_h___enterprise.id}"
  value                   = "demo.octopus.app"
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_3_james_c" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_james_c.id}"
  value          = "False"
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_retail_tech" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_retail_tech.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant" "tenant_mark_harrison" {
  name        = "Mark Harrison"
  tenant_tags = [
    "Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "Region/EMEA",
    "Options/Run Daily Deployments", "Options/Dev and QA Teams", "Options/Do Not Delete", "State/Created"
  ]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag_set.tagset_options, octopusdeploy_tag.tag_azure,
    octopusdeploy_tag.tag_aws, octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_emea,
    octopusdeploy_tag.tag_created, octopusdeploy_tag.tag_run_daily_deployments, octopusdeploy_tag.tag_do_not_delete,
    octopusdeploy_tag.tag_dev_and_qa_teams
  ]
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "devtools-demo-app"
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_solutions_engineer" {
  name        = "Solutions Engineer"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#52818C"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = "rob.pearson@octopus.com"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_enterprise.id}"
  value                   = "https://octopetshop.atlassian.net/"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_zach_schatz" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_zach_schatz.id}"
  value                   = "zach.schatz@octopus.com"
}

resource "octopusdeploy_tag_set" "tagset_role" {
  name       = "Role"
  sort_order = 1
}

resource "octopusdeploy_tag" "tag_shared_access" {
  name        = "Shared Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#3156B3"
  description = "Used to mark a space as Shared (events, features)"
  sort_order  = 5
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_dev_and_qa_teams" {
  name        = "Dev and QA Teams"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable5_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = ""
}

resource "octopusdeploy_tenant" "tenant_mike_nguyen" {
  name        = "Mike Nguyen"
  description = "Mike Nguyen Tenant"
  tenant_tags = ["Cloud Provider/Azure", "Cloud Provider/AWS", "Role/Solutions Engineer", "Region/NA", "State/Created"]

  project_environment {
    environments = ["${octopusdeploy_environment.environment_administration.id}"]
    project_id   = "${octopusdeploy_project.project_demo_space_creator.id}"
  }

  depends_on = [
    octopusdeploy_tag_set.tagset_cloud_provider, octopusdeploy_tag_set.tagset_role, octopusdeploy_tag_set.tagset_region,
    octopusdeploy_tag_set.tagset_state, octopusdeploy_tag.tag_azure, octopusdeploy_tag.tag_aws,
    octopusdeploy_tag.tag_solutions_engineer, octopusdeploy_tag.tag_na, octopusdeploy_tag.tag_created
  ]
}

variable "demo_space_creator_demospacecreator_createtenant_jsmusername_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.JSMUsername"
  default     = "not set"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_jsmusername_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_jsmusername_1}"
  name         = "DemoSpaceCreator.CreateTenant.JSMUsername"
  type         = "String"
  description  = "The username of the JSM account to use when creating and checking issues."
  is_sensitive = false

  prompt {
    description = "The username of the JSM account to use when creating and checking issues."
    label       = "4.2: JSM Username"
    is_required = false

    display_settings {
      control_type = "SingleLineText"
    }
  }
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_devtools" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_devtools.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_multi_tenancycon" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_multi_tenancycon.id}"
  value                   = "ryan.rousseau@octopus.com"
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_azure" {
  name        = "Azure"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tag" "tag_run_daily_deployments" {
  name        = "Run Daily Deployments"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#36A766"
  description = "Queue deployments for each project in the space daily"
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_guest_access" {
  name        = "Guest Access"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#ECAD3F"
  description = "Used to give readonly guest access to a space"
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_justin_bowlby" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_demo_space_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_justin_bowlby.id}"
  value                   = "justin.bowlby@octopus.com"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_2_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "OctoFX"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tenant_design" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tenant_design.id}"
  value                   = "not set"
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_tony_kelly" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_tony_kelly.id}"
  value                   = ""
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_mark_harrison" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_mark_harrison.id}"
  value                   = ""
}

resource "octopusdeploy_tag_set" "tagset_region" {
  name       = "Region"
  sort_order = 2
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_github_universe_test" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_github_universe_test.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_product" {
  name        = "Product"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#227647"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_na" {
  name        = "NA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_engineering" {
  name        = "Engineering"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#36A766"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tenant_project_variable" "tenantprojectvariable_3_redgate_summit" {
  environment_id = "${octopusdeploy_environment.environment_administration.id}"
  project_id     = ""
  template_id    = ""
  tenant_id      = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value          = "False"
}

resource "octopusdeploy_tag_set" "tagset_cloud_provider" {
  name       = "Cloud Provider"
  sort_order = 0
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_created" {
  name        = "Created"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_state.id}"
  color       = "#227647"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_do_not_delete" {
  name        = "Do Not Delete"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_options.id}"
  color       = "#000000"
  description = "The delete space runbook will fail if this tag is present"
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

variable "demo_space_creator_demospacecreator_createtenant_createlambdademo_1" {
  type        = string
  nullable    = true
  sensitive   = false
  description = "The value associated with the variable DemoSpaceCreator.CreateTenant.CreateLambdaDemo"
  default     = "False"
}
resource "octopusdeploy_variable" "demo_space_creator_demospacecreator_createtenant_createlambdademo_1" {
  owner_id     = "${octopusdeploy_project.project_demo_space_creator.id}"
  value        = "${var.demo_space_creator_demospacecreator_createtenant_createlambdademo_1}"
  name         = "DemoSpaceCreator.CreateTenant.CreateLambdaDemo"
  type         = "String"
  is_sensitive = false

  prompt {
    description = ""
    label       = "2.9: Create Lambda Demo?"
    is_required = false

    display_settings {
      control_type = "Checkbox"
    }
  }
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable4_redgate_summit" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_redgate_summit.id}"
  value                   = "octopus.SNOW"
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_helm_template" {
  name        = "Helm Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_csm" {
  name        = "CSM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#203A88"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag" "tag_octofx_template" {
  name        = "OctoFX Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 7
}

resource "octopusdeploy_tag" "tag_account_executive" {
  name        = "Account Executive"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_jira_service_management.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "Goji"
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_apac" {
  name        = "APAC"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#77B7C5"
  description = ""
  sort_order  = 0
}

resource "octopusdeploy_tag_set" "tagset_state" {
  name       = "State"
  sort_order = 3
}

resource "octopusdeploy_tag" "tag_tenants_template" {
  name        = "Tenants Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 9
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable3_k8s_demo___mark_l" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_k8s_demo___mark_l.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag_set" "tagset_options" {
  name       = "Options"
  sort_order = 4
}

resource "octopusdeploy_tag" "tag_feature" {
  name        = "Feature"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag" "tag_servicenow_template" {
  name        = "ServiceNow Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 8
}

resource "octopusdeploy_tag" "tag_kubernetes_template" {
  name        = "Kubernetes Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 5
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable1_rob_enterprise" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_servicenow.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_rob_enterprise.id}"
  value                   = "https://dev138661.service-now.com/"
}

resource "octopusdeploy_tag" "tag_aws" {
  name        = "AWS"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_cloud_provider.id}"
  color       = "#A77B22"
  description = ""
  sort_order  = 3
}

resource "octopusdeploy_tag" "tag_ecs_template" {
  name        = "ECS Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 2
}

resource "octopusdeploy_tag" "tag_lambda_template" {
  name        = "Lambda Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tag" "tag_sdr" {
  name        = "SDR"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#E8634F"
  description = ""
  sort_order  = 6
}

resource "octopusdeploy_tenant_common_variable" "tenantcommonvariable2_support_debrief" {
  library_variable_set_id = "${data.octopusdeploy_library_variable_sets.library_variable_set_config_as_code.library_variable_sets[0].id}"
  template_id             = ""
  tenant_id               = "${octopusdeploy_tenant.tenant_support_debrief.id}"
  value                   = "not set"
}

resource "octopusdeploy_tag" "tag_conference" {
  name        = "Conference"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_jsm_template" {
  name        = "JSM Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 4
}

resource "octopusdeploy_tag_set" "tagset_active_projects" {
  name       = "Active Projects"
  sort_order = 5
}

resource "octopusdeploy_tag" "tag_emea" {
  name        = "EMEA"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_region.id}"
  color       = "#ECAD3F"
  description = ""
  sort_order  = 1
}

resource "octopusdeploy_tag" "tag_point_of_sale_template" {
  name        = "Point of Sale Template"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_active_projects.id}"
  color       = "#333333"
  description = ""
  sort_order  = 10
}

resource "octopusdeploy_tag" "tag_tam" {
  name        = "TAM"
  tag_set_id  = "${octopusdeploy_tag_set.tagset_role.id}"
  color       = "#3156B3"
  description = ""
  sort_order  = 8
}

