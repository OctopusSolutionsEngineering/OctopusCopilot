resource "octopusdeploy_deployment_process" "deployment_process_project5" {
  project_id = "${octopusdeploy_project.project_project5.id}"

  step {
    condition           = "Success"
    name                = "Run a Script"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Run a Script"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties = {
        "Octopus.Action.Script.Syntax"       = "Bash"
        "Octopus.Action.Script.ScriptBody"   = "echo \"Hi there from Step One\"\nwrite_highlight \"This is a highlight\"\necho \"hi there\" > file.txt\nnew_octopusartifact $(pwd)/file.txt\nsleep 60"
        "Octopus.Action.RunOnServer"         = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
      environments = []
      excluded_environments = []
      channels = []
      tenant_tags = []
      features = []
    }

    properties = {}
    target_roles = []
  }

  depends_on = []
}
