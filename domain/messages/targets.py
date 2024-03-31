def build_targets_prompt():
    """
    Build a message prompt for the LLM that demonstrates how targets are matched to environments and tenants.
    :return: The messages to pass to the llm.
    """

    # Some of the prompts come from https://arxiv.org/pdf/2312.16171.pdf
    messages = [
        ("system",
         "The supplied HCL context provides details on projects, environments, tenants, targets, machines, and agents."),
        ("system", "You must link the targets to the projects, environments, and tenants."),
        ("system",
         "You must include the azure-iss target."),
        ("system", "I’m going to tip $500 for a better solution!"),
        ("user", "Question1: List the name and ID of targets that belong to the \"Test\" environment."),
        ("user", """HCL1: ###
    resource "octopusdeploy_environment" "environment_test" {{
      id                           = "Environments-10923"
      name                         = "Test"
    }}
    resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis" {{
      id                                = "Machines-18962"
      environments                      = [octopusdeploy_environment.environment_test.id]
      name                              = "Web App"
      roles                             = ["payments-team"]
    }}
    resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_5" {{
      id                                = "Machines-18477"
      environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                              = "sydney-client-5"
      roles                             = ["payments-team"]
    }}
    resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis_2" {{
      id                                = "Machines-19002"
      environments                      = [octopusdeploy_environment.environment_test.id]
      name                              = "Web App 2"
      roles                             = ["payments-team"]
    }}
    resource octopusdeploy_kubernetes_cluster_deployment_target test_eks {{
    id                                = "Machines-18963"
      cluster_url                       = "https://cluster"
      environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                              = "Worker Cluster"
      roles                             = ["payments-team"]
    }}
    resource "octopusdeploy_ssh_connection_deployment_target" "target_3_25_215_87" {{
      id                    = "Machines-18964"
      environments          = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                  = "Linux Jump Box"
      roles                 = ["vm"]
    }}
    resource "octopusdeploy_listening_tentacle_deployment_target" "target_vm_listening_ngrok" {{
      id                                = "Machines-18965"
      environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                              = "Database"
      roles                             = ["vm"]
    }}
    resource "octopusdeploy_offline_package_drop_deployment_target" "target_offline" {{
      id                                = "Machines-18966"
      environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                              = "Remote Site"
      roles                             = ["offline"]
    }}
    resource "octopusdeploy_azure_cloud_service_deployment_target" "target_azure" {{
      id                                = "Machines-18967"
      environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                              = "Old Azure Service"
      roles                             = ["cloud"]
    }}
    resource "octopusdeploy_azure_service_fabric_cluster_deployment_target" "target_service_fabric" {{
      id                                = "Machines-18968"
      environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                              = "Finance Cluster"
      roles                             = ["cloud"]
    }}
    resource "octopusdeploy_azure_web_app_deployment_target" "target_web_app" {{
      id                                = "Machines-14526"
      environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
      name                              = "New Web App"
      roles                             = ["cloud"]
    }}
    resource "octopusdeploy_azure_web_app_deployment_target" "target_web_app_prod" {{
      id                                = "Machines-14530"
      environments                      = ["${{octopusdeploy_environment.environment_production.id}}"]
      name                              = "New Web App Prod"
      roles                             = ["azure"]
    }}
    ###
    Answer 1:
    First, find the environment with the name "Development".  The "octopusdeploy_environment" resource has the name "Development". This is the environment that the targets must be assigned to.
    Second, find the following resources that represent targets or machines:
    - "octopusdeploy_cloud_region_deployment_target"
    - "octopusdeploy_polling_tentacle_deployment_target"
    - "octopusdeploy_kubernetes_cluster_deployment_target"
    - "octopusdeploy_ssh_connection_deployment_target" 
    - "octopusdeploy_listening_tentacle_deployment_target"
    - "octopusdeploy_offline_package_drop_deployment_target"
    - "octopusdeploy_azure_cloud_service_deployment_target"
    - "octopusdeploy_azure_service_fabric_cluster_deployment_target"
    - "octopusdeploy_azure_web_app_deployment_target"
    Third, filter the resources based on the "environments" attribute to find the targets belonging to the "Development" environment.

    The targets that belong to the "Test" environment are:
    - Name: "sydney-client-5" ID: "Machines-18477"
    - Name: "Web App" ID: "Machines-18962"
    - Name: "Web App 2" ID: "Machines-19002"
    - Name: "Worker Cluster" ID: "Machines-18963"
    - Name: "Linux Jump Box" ID: "Machines-18964"
    - Name: "Database" ID: "Machines-18965"
    - Name: "Remote Site" ID: "Machines-18966"
    - Name: "Old Azure Service" ID: "Machines-18967"
    - Name: "Finance Cluster" ID: "Machines-18968"
    - Name: "New Web App" ID: "Machines-14526"
    """),
        ("user", "Question2: {input}"),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "HCL2: ###\n{hcl}\n###")]

    return messages
