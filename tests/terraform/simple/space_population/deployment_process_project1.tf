resource "octopusdeploy_deployment_process" "deployment_process_project1" {
  project_id = "${octopusdeploy_project.project_project1.id}"

  step {
    condition           = "Success"
    name                = "Configure the load balancer"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Configure the load balancer"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties = {
        "Octopus.Action.RunOnServer"         = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax"       = "Bash"
        "Octopus.Action.Script.ScriptBody"   = "echo \"Hi there from Step One\"\nwrite_highlight \"This is a highlight\"\n echo \"hi there\" > file.txt\nnew_octopusartifact $(pwd)/file.txt\nsleep 5"
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

  step {
    condition           = "Success"
    name                = "Retry this step"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Retry this step"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties = {
        "Octopus.Action.RunOnServer"         = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
        "Octopus.Action.Script.Syntax"       = "Bash"
        "Octopus.Action.Script.ScriptBody"   = "echo \"Hi there from Step Two\""
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

  step {
    condition           = "Success"
    name                = "Run a Script 2"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Run a Script 2"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = false
      is_required                        = false
      worker_pool_id                     = ""
      properties = {
        "Octopus.Action.RunOnServer"            = "true"
        "Octopus.Action.Script.ScriptSource"    = "Inline"
        "Octopus.Action.Script.Syntax"          = "Bash"
        "Octopus.Action.Script.ScriptBody"      = "echo \"Hi there\""
        "Octopus.Action.AutoRetry.MaximumCount" = "3"
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
      is_disabled                        = true
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_variable               = ""
      properties = {
        "Octopus.Action.IISWebSite.WebSiteName"                                     = "octopub"
        "Octopus.Action.Package.DownloadOnTentacle"                                 = "False"
        "Octopus.Action.IISWebSite.ApplicationPoolName"                             = "octopub"
        "Octopus.Action.IISWebSite.ApplicationPoolFrameworkVersion"                 = "v4.0"
        "Octopus.Action.Package.AutomaticallyUpdateAppSettingsAndConnectionStrings" = "True"
        "Octopus.Action.IISWebSite.Bindings" = jsonencode([
          {
            "host"                = ""
            "thumbprint"          = null
            "certificateVariable" = null
            "requireSni"          = "False"
            "enabled"             = "True"
            "protocol"            = "http"
            "port"                = "8080"
          },
        ])
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolIdentityType"     = "ApplicationPoolIdentity"
        "Octopus.Action.IISWebSite.WebApplication.ApplicationPoolFrameworkVersion" = "v4.0"
        "Octopus.Action.IISWebSite.EnableWindowsAuthentication"                    = "False"
        "Octopus.Action.IISWebSite.StartWebSite"                                   = "True"
        "Octopus.Action.IISWebSite.ApplicationPoolIdentityType"                    = "ApplicationPoolIdentity"
        "Octopus.Action.IISWebSite.WebRootType"                                    = "packageRoot"
        "Octopus.Action.IISWebSite.CreateOrUpdateWebSite"                          = "True"
        "Octopus.Action.IISWebSite.DeploymentType"                                 = "webSite"
        "Octopus.Action.IISWebSite.StartApplicationPool"                           = "True"
        "Octopus.Action.IISWebSite.EnableAnonymousAuthentication"                  = "True"
        "Octopus.Action.Package.AutomaticallyRunConfigurationTransformationFiles"  = "True"
        "Octopus.Action.IISWebSite.EnableBasicAuthentication"                      = "False"
        "Octopus.Action.AutoRetry.MaximumCount"                                    = "3"
      }
      environments = []
      excluded_environments = []
      channels = []
      tenant_tags = []

      primary_package {
        package_id           = "MyWebSite"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties = { SelectionMode = "immediate" }
      }

      features = [
        "", "Octopus.Features.IISWebSite", "Octopus.Features.ConfigurationTransforms",
        "Octopus.Features.ConfigurationVariables"
      ]
    }

    properties = {}
    target_roles = ["azure-iss"]
  }

  depends_on = []
}
