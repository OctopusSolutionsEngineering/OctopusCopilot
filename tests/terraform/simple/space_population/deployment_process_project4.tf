resource "octopusdeploy_deployment_process" "deployment_process_project4" {
  project_id = "${octopusdeploy_project.project_project4.id}"

  step {
    condition           = "Success"
    name                = "Step that will fail"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Step that will fail"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties                         = {
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.ScriptBody" = "Fail-Step \"This step has failed. Retrying will also fail :)\""
        "Octopus.Action.Script.Syntax" = "PowerShell"
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

  depends_on = []
}
