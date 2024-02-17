resource "octopusdeploy_runbook_process" "runbook_process_octopus_copilot_function_create_function_app" {
  runbook_id = "${octopusdeploy_runbook.runbook_octopus_copilot_function_create_function_app.id}"

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
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.Azure.ResourceGroupTemplateParameters" = "azure/functions/parameters.json"
        "Octopus.Action.Azure.ResourceGroupName" = "OctopusCopilot"
        "Octopus.Action.Azure.AccountId" = "${data.octopusdeploy_accounts.account_azure___solutions_engineering.accounts[0].id}"
        "Octopus.Action.Azure.TemplateSource" = "Package"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Azure.ResourceGroupTemplate" = "azure/functions/template.json"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Azure.ResourceGroupDeploymentMode" = "Incremental"
        "Octopus.Action.RunOnServer" = "true"
      }

      container {
        feed_id = "${data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id}"
        image   = "octopusdeploy/worker-tools:6.1.1-ubuntu.22.04"
      }

      environments          = []
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "OctopusSolutionsEngineering/OctopusCopilot"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_github_releases.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = []
    }

    properties   = {}
    target_roles = []
  }
  depends_on = []
}
