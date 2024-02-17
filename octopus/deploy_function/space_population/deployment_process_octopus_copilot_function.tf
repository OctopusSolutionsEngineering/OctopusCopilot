variable "project_octopus_copilot_function_step_deploy_an_azure_app_service_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named  from step Deploy an Azure App Service in project Octopus Copilot Function"
  default     = "OctopusCopilot"
}
variable "project_octopus_copilot_function_step_security_scan_package_octopuscopilot_packageid" {
  type        = string
  nullable    = false
  sensitive   = false
  description = "The package ID for the package named OctopusCopilot from step Security Scan in project Octopus Copilot Function"
  default     = "OctopusCopilot"
}
resource "octopusdeploy_deployment_process" "deployment_process_octopus_copilot_function" {
  project_id = "${octopusdeploy_project.project_octopus_copilot_function.id}"

  step {
    condition           = "Success"
    name                = "Deploy an Azure App Service"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.AzureAppService"
      name                               = "Deploy an Azure App Service"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      worker_pool_variable               = ""
      properties                         = {
        "Octopus.Action.Azure.DeploymentType" = "Package"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Package.DownloadOnTentacle" = "False"
        "Octopus.Action.Azure.AppSettings" = jsonencode([
        {
        "name" = "OPENAI_API_KEY"
        "value" = "#{Azure.OpenAI.Key}"
        "slotSetting" = "false"
                },
        {
        "name" = "OPENAI_ENDPOINT"
        "value" = "#{Azure.OpenAI.Endpoint}"
        "slotSetting" = "false"
                },
        ])
        "OctopusUseBundledTooling" = "False"
      }

      container {
        feed_id = "${data.octopusdeploy_feeds.feed_docker_hub.feeds[0].id}"
        image   = "octopusdeploy/worker-tools:6.1.1-ubuntu.22.04"
      }

      environments          = ["${data.octopusdeploy_environments.environment_production.environments[0].id}"]
      excluded_environments = []
      channels              = []
      tenant_tags           = []

      primary_package {
        package_id           = "${var.project_octopus_copilot_function_step_deploy_an_azure_app_service_packageid}"
        acquisition_location = "Server"
        feed_id              = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties           = { SelectionMode = "immediate" }
      }

      features = ["Octopus.Features.JsonConfigurationVariables", "Octopus.Features.ConfigurationTransforms", "Octopus.Features.SubstituteInFiles"]
    }

    properties   = {}
    target_roles = ["Azure.Functions.OctopusCopilot"]
  }
  step {
    condition           = "Success"
    name                = "Security Scan"
    package_requirement = "LetOctopusDecide"
    start_trigger       = "StartAfterPrevious"

    action {
      action_type                        = "Octopus.Script"
      name                               = "Security Scan"
      condition                          = "Success"
      run_on_server                      = true
      is_disabled                        = false
      can_be_used_for_project_versioning = true
      is_required                        = false
      worker_pool_id                     = "${data.octopusdeploy_worker_pools.workerpool_hosted_ubuntu.worker_pools[0].id}"
      properties                         = {
        "Octopus.Action.Script.Syntax" = "Bash"
        "Octopus.Action.Script.ScriptBody" = "echo \"Pulling Trivy Docker Image\"\necho \"##octopus[stdout-verbose]\"\ndocker pull aquasec/trivy\necho \"##octopus[stdout-default]\"\n\nTIMESTAMP=$(date +%s%3N)\nSUCCESS=0\nfor x in $(find . -name bom.json -type f -print); do\n    echo \"Scanning $${x}\"\n\n    # Delete any existing report file\n    if [[ -f \"$PWD/depscan-bom.json\" ]]; then\n      rm \"$PWD/depscan-bom.json\"\n    fi\n\n    # Generate the report, capturing the output, and ensuring $? is set to the exit code\n    OUTPUT=$(bash -c \"docker run --rm -v \\\"$PWD/$${x}:/app/$${x}\\\" aquasec/trivy sbom \\\"/app/$${x}\\\"; exit \\$?\" 2\u003e\u00261)\n\n    # Success is set to 1 if the exit code is not zero\n    if [[ $? -ne 0 ]]; then\n        SUCCESS=1\n    fi\n\n    # Print the output stripped of ANSI colour codes\n    echo -e \"$${OUTPUT}\" | sed 's/\\x1b\\[[0-9;]*m//g'\ndone\n\n# Cleanup\nfor i in {1..10}\ndo\n    chmod -R +rw bundle \u0026\u003e /dev/null\n    rm -rf bundle \u0026\u003e /dev/null\n    if [[ $? == 0 ]]; then break; fi\n    echo \"Attempting to clean up files\"\n    sleep 1\ndone\n\nset_octopusvariable \"VerificationResult\" $SUCCESS\n\nif [[ $SUCCESS -ne 0 ]]; then\n  \u003e\u00262 echo \"Critical vulnerabilities were detected\"\nfi\n\nexit 0\n"
        "Octopus.Action.RunOnServer" = "true"
        "Octopus.Action.Script.ScriptSource" = "Inline"
      }
      environments                       = []
      excluded_environments              = []
      channels                           = []
      tenant_tags                        = []

      package {
        name                      = "OctopusCopilot"
        package_id                = "${var.project_octopus_copilot_function_step_security_scan_package_octopuscopilot_packageid}"
        acquisition_location      = "Server"
        extract_during_deployment = false
        feed_id                   = "${data.octopusdeploy_feeds.feed_octopus_server__built_in_.feeds[0].id}"
        properties                = { Extract = "True", Purpose = "", SelectionMode = "immediate" }
      }
      features = []
    }

    properties   = {}
    target_roles = []
  }
  depends_on = []
}
