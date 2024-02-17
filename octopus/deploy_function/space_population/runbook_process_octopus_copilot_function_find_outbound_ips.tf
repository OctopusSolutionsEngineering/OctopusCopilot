resource "octopusdeploy_runbook_process" "runbook_process_octopus_copilot_function_find_outbound_ips" {
  runbook_id = "${octopusdeploy_runbook.runbook_octopus_copilot_function_find_outbound_ips.id}"

  step {
    condition           = "Success"
    name                = "Run an Azure Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzurePowerShell"
      name                               = "Run an Azure Script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.Azure.AccountId" = "${data.octopusdeploy_accounts.account_azure___solutions_engineering.accounts[0].id}"
        "Octopus.Action.Script.ScriptBody" = "az webapp show --resource-group OctopusCopilot --name octopuscopilotproduction --query outboundIpAddresses --output tsv"
        "OctopusUseBundledTooling" = "False"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax" = "PowerShell"
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
      features              = []
    }

    properties   = {}
    target_roles = []
  }
  depends_on = []
}
