resource "octopusdeploy_deployment_process" "deployment_process_project3" {
  project_id = "${octopusdeploy_project.project_project3.id}"

  step {
    condition           = "Success"
    name                = "Approve deployment"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Manual"
      name                               = "Approve deployment"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties                         = {
        "Octopus.Action.Manual.Instructions" = "Approve the manual intervention"
        "Octopus.Action.Manual.BlockConcurrentDeployments" = "False"
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
