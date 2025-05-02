from domain.messages.general import build_hcl_prompt


def answer_machines_wrapper(original_query, callback, logging=None):
    def answer_machines(
        space=None,
        projects=None,
        runbooks=None,
        targets=None,
        tenants=None,
        environments=None,
        accounts=None,
        certificates=None,
        workerpools=None,
        machinepolicies=None,
        tagsets=None,
        steps=None,
        **kwargs,
    ):
        """Answers a general query about machines, targets, agents, or machine policies in an Octopus space.
                   This does not provide details about channels.

        Args:
        space: Space name
        projects: project names
        runbooks: runbook names
        targets: target/machine names
        tenants: tenant names
        environments: environment names
        accounts: account names
        certificates: certificate names
        workerpools: worker pool names
        machinepolicies: machine policy names
        tagsets: tenant tag set names
        steps: step names"""

        if logging:
            logging("Enter:", "answer_machines")

        # Build a few shot sample query with a chain-of-thought example to help the LLM understand the relationships
        # between projects, deployment processes, and variables.

        few_shot = """
Question: List the name and ID of targets that belong to the \"Test\" environment.
HCL: ###
resource "octopusdeploy_space" "octopus_space_demo_space" {{
  id                          = "Spaces-2342"
  description                 = "Demo space"
  name                        = "Demo"
}}
resource "octopusdeploy_environment" "environment_test" {{
  id                           = "Environments-19923"
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
resource "octopusdeploy_azure_web_app_deployment_target" "target_azure_web_app_demo_myinstance_app_api_server_test" {{
  id                                = "Machines-62151"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "azure-web-app/demo.myinstance.app/api-server-test"
  roles                             = ["api-server"]
}}
###
Answer:
First, assume all targets belong to the space called "Demo".

Second, find the environment with the name "Test".
The "octopusdeploy_environment" resource called "environment_test" has the name "Test".
This is the environment that the targets must reference in their "environments" attribute.

Third, find all the following resources that represent targets or machines:
- "octopusdeploy_cloud_region_deployment_target"
- "octopusdeploy_polling_tentacle_deployment_target"
- "octopusdeploy_kubernetes_cluster_deployment_target"
- "octopusdeploy_ssh_connection_deployment_target"
- "octopusdeploy_listening_tentacle_deployment_target"
- "octopusdeploy_offline_package_drop_deployment_target"
- "octopusdeploy_azure_cloud_service_deployment_target"
- "octopusdeploy_azure_service_fabric_cluster_deployment_target"
- "octopusdeploy_azure_web_app_deployment_target"

Fourth, filter the target resources based on their "environments" attribute to find targets that reference the "octopusdeploy_environment" resource called "environment_test".

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
- Name: "azure-web-app/demo.myinstance.app/api-server-test" ID: "Machines-62151"

Question: What targets are defined in the space "Demo"?
HCL: ###
resource "octopusdeploy_space" "octopus_space_demo_space" {{
  id                          = "Spaces-2342"
  description                 = "Demo space"
  name                        = "Demo"
}}
resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis" {{
  id                                = "Machines-18962"
  environments                      = []
  name                              = "Web App"
  roles                             = ["payments-team"]
}}
resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_5" {{
  id                                = "Machines-18477"
  environments                      = [""]
  name                              = "sydney-client-5"
  roles                             = ["payments-team"]
}}
resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis_2" {{
  id                                = "Machines-19002"
  environments                      = []
  name                              = "Web App 2"
  roles                             = ["payments-team"]
}}
resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis_3" {{
  id                                = "Machines-19003"
  environments                      = []
  name                              = "Web App 3"
  roles                             = ["payments-team"]
}}
###
Answer:
First, assume all targets belong to the space called "Demo".

Second, find all the following resources that represent targets or machines:
- "octopusdeploy_cloud_region_deployment_target"
- "octopusdeploy_polling_tentacle_deployment_target"
- "octopusdeploy_kubernetes_cluster_deployment_target"
- "octopusdeploy_ssh_connection_deployment_target"
- "octopusdeploy_listening_tentacle_deployment_target"
- "octopusdeploy_offline_package_drop_deployment_target"
- "octopusdeploy_azure_cloud_service_deployment_target"
- "octopusdeploy_azure_service_fabric_cluster_deployment_target"
- "octopusdeploy_azure_web_app_deployment_target"

The targets that belong to the "Demo" space are:
- Name: "sydney-client-5" ID: "Machines-18477"
- Name: "Web App" ID: "Machines-18962"
- Name: "Web App 2" ID: "Machines-19002"
"""

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_hcl_prompt([("user", few_shot)])

        return callback(
            original_query,
            messages,
            space,
            projects,
            runbooks,
            targets,
            tenants,
            environments,
            accounts,
            certificates,
            workerpools,
            machinepolicies,
            tagsets,
            steps,
        )

    return answer_machines
