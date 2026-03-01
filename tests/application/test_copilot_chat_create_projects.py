import glob
import json
import os
import unittest

import Levenshtein
import azure.functions as func
from openai import RateLimitError
from retry import retry
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs

from domain.transformers.sse_transformers import (
    convert_from_sse_response,
    get_confirmation_id,
)
from function_app import copilot_handler_internal
from infrastructure.octopus import (
    get_space_id_and_name_from_name,
    get_project,
    get_runbook_fuzzy,
    get_raw_deployment_process,
    get_tenants,
    sync_community_step_templates,
)
from infrastructure.terraform_context import save_terraform_context
from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.test_octopus_infrastructure import run_terraform


# @unittest.skip
class CopilotChatTestCreateProjects(unittest.TestCase):
    """
    End-to-end tests that verify the complete query including:
    * Persisting user details such as Octopus URL and API key
    * Querying the Octopus API to build context
    * Passing the context and query to OpenAI to generate a response

    These tests are against a space with a small number of resources. They verify that basic context is successfully
    passed to the LLM and that the responses are valid.

    The answers provided by LLMs degrade with more complex contexts, so these tests are not exhaustive. But they do
    serve to validate the query workflow at a low level.
    """

    @classmethod
    def setUpClass(cls):
        populate_blob_storage()

        # Simulate the result of a user login and saving their Octopus details
        try:
            github_user = os.environ["TEST_GH_USER"]
            save_users_octopus_url_from_login(
                github_user,
                Octopus_Url,
                Octopus_Api_Key,
                os.environ["ENCRYPTION_PASSWORD"],
                os.environ["ENCRYPTION_SALT"],
                os.environ["AzureWebJobsStorage"],
            )
            save_default_values(
                github_user, "space", "Simple", os.environ["AzureWebJobsStorage"]
            )
            save_default_values(
                github_user,
                "project",
                "Deploy Web App Container",
                os.environ["AzureWebJobsStorage"],
            )
            save_default_values(
                github_user,
                "environment",
                "Development",
                os.environ["AzureWebJobsStorage"],
            )
            save_default_values(
                github_user,
                "owner",
                "OctopusSolutionsEngineering",
                os.environ["AzureWebJobsStorage"],
            )
            save_default_values(
                github_user,
                "repository",
                "OctopusCopilot",
                os.environ["AzureWebJobsStorage"],
            )
            save_default_values(
                github_user, "workflow", "build.yaml", os.environ["AzureWebJobsStorage"]
            )
        except Exception as e:
            print(
                "The tests will fail because Azurite is not running. Run Azurite with: "
                + "docker run -d -p 10000:10000 -p 10001:10001 -p 10002:10002 --restart unless-stopped mcr.microsoft.com/azure-storage/azurite"
            )
            print(
                "Then set the AzureWebJobsStorage environment variable to: "
                + "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"
            )
            print(e)
            return

        try:
            terraform_dir = "../terraform/"

            cls.mssql = (
                DockerContainer("mcr.microsoft.com/mssql/server:2022-latest")
                .with_env("ACCEPT_EULA", "True")
                .with_env("SA_PASSWORD", "Password01!")
            )
            cls.mssql.start()
            wait_for_logs(cls.mssql, "SQL Server is now ready for client connections")

            mssql_ip = cls.mssql.get_docker_client().bridge_ip(
                cls.mssql.get_wrapped_container().id
            )

            cls.octopus = (
                DockerContainer("octopusdeploy/octopusdeploy")
                .with_bind_ports(8080, 8080)
                .with_env("ACCEPT_EULA", "Y")
                .with_env(
                    "DB_CONNECTION_STRING",
                    "Server="
                    + mssql_ip
                    + ",1433;Database=OctopusDeploy;User=sa;Password=Password01!",
                )
                .with_env("ADMIN_API_KEY", Octopus_Api_Key)
                .with_env("DISABLE_DIND", "Y")
                .with_env("ADMIN_USERNAME", "admin")
                .with_env("ADMIN_PASSWORD", "Password01!")
                .with_env("OCTOPUS_SERVER_BASE64_LICENSE", os.environ["LICENSE"])
                .with_env("ENABLE_USAGE", "N")
            )
            cls.octopus.start()
            wait_for_logs(cls.octopus, "Web server is ready to process requests", 300)

            sync_community_step_templates(Octopus_Api_Key, Octopus_Url)

            output = run_terraform(
                terraform_dir + "simple/space_creation", Octopus_Url, Octopus_Api_Key
            )
            run_terraform(
                terraform_dir + "simple/space_population",
                Octopus_Url,
                Octopus_Api_Key,
                json.loads(output)["octopus_space_id"]["value"],
            )
            run_terraform(
                terraform_dir + "empty/space_creation", Octopus_Url, Octopus_Api_Key
            )
        except Exception as e:
            print(
                "Failed to start containers. Consider running ryuk in privileged mode by setting "
                + "TESTCONTAINERS_RYUK_PRIVILEGED=true or disabling ryuk by setting "
                + "TESTCONTAINERS_RYUK_DISABLED=true."
            )
            print(e)
            cls.tearDownClass()

    @classmethod
    def tearDownClass(cls):
        try:
            cls.octopus.stop()
        except Exception as e:
            pass
        finally:
            cls.octopus = None

        try:
            cls.mssql.stop()
        except Exception as e:
            pass
        finally:
            cls.mssql = None

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_k8s_project(self):
        project_name = "My K8s Project"
        prompt = f'Create a Kubernetes project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertTrue(
            project["Name"] == project_name,
        )

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )

        mandatory_step = "Approve Production Deployment"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_k8s_project_no_prompt(self):
        project_name = "My K8s Project Two"
        prompt = f'Create a Kubernetes project called "{project_name}" with no prompt.'
        response = copilot_handler_internal(build_request(prompt))

        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_vm_blue_green_project(self):
        project_name = "My VM Blue Green project"
        prompt = f'Create a VM Blue/Green project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_azure_web_app_project(self):
        project_name = "My Azure WebApp Project"
        prompt = f'Create an Azure Web App project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )
        mandatory_step = "Validate setup"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_azure_web_app_project_with_new_step(self):
        project_name = "My Azure WebApp with step"
        additional_step_name = "Smoke test"
        prompt = f'Create an Azure web app project called "{project_name}". Add a new "Run an Azure Script" step called "{additional_step_name}" at the end of the deployment process. It must test a HTTP endpoint returns a 200 status code.'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)
        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )

        mandatory_step = "Validate setup"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )

        self.assertTrue(
            any(
                # The LLM might change the step name slightly, so we use Levenshtein distance to check for similarity
                Levenshtein.distance(step["Name"], additional_step_name) <= 2
                for step in deployment_process["Steps"]
            ),
            f'The deployment process should have an additional step called "{additional_step_name}".',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_azure_function_project(self):
        project_name = "My Azure Function Project"
        prompt = f'Create an Azure Function project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )
        mandatory_step = "Validate setup"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_tomcat_project(self):
        project_name = "My Tomcat Project"
        prompt = f'Create a Tomcat project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_script_project(self):
        project_name = "My Script Project"
        prompt = f'Create a Script project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_terraform_project(self):
        project_name = "My Terraform Project"
        prompt = f'Create a Terraform project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )

    @unittest.skip("This test is known to be flaky")
    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_argo_project(self):
        project_name = "My Argo Project"
        prompt = f'Create a Argo CD Tag Update project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {"state": "accepted", "confirmation": {"id": confirmation_id}}
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )
        mandatory_step = "Approve Production Deployment"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_lambda_project(self):
        project_name = "My AWS Lambda"
        prompt = f'Create an AWS Lambda project called "{project_name}". Use the project group "AWS".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {
                            "state": "accepted",
                            "confirmation": {"id": confirmation_id},
                        }
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)

        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )
        mandatory_step = "Attempt Login"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )

    @unittest.skip(
        "This test is currently unreliable because of limitations in the TF provider around tag creation. We need to add a data source for individual tags to reliably support stateless module creation."
    )
    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_lambda_project_tenanted(self):
        project_name = "My tenanted Lambda"
        prompt = f"""Create an AWS Lambda project called "{project_name}".
Configure the project to require tenants for deployment.
Create 5 tenants named after cities located in England and assign them to the project.
Create 5 tag sets that represent counties from England and assign them to the tenants."""
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {
                            "state": "accepted",
                            "confirmation": {"id": confirmation_id},
                        }
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"].casefold(), project_name.casefold())
        project_tenant_mode = project["TenantedDeploymentMode"]
        self.assertTrue(
            project_tenant_mode == ("Tenanted" or "TenantedOrUntenanted"),
            f"TenantedDeploymentMode was: {project_tenant_mode}",
        )
        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )

        mandatory_step = "Attempt Login"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )

        tenants = get_tenants(Octopus_Api_Key, Octopus_Url, space_id)
        number_of_tenants = len(tenants)
        self.assertTrue(
            number_of_tenants >= 5,
            f"The deployment process should have at least 5 tenants. It has: {number_of_tenants}",
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_lambda_project_with_additional_runbook(self):
        project_name = "Lambda with Runbook"
        new_runbook_name = "Switch Load Balancer"
        prompt = f"""Create an AWS Lambda project called "{project_name}", retaining the example steps, and include an additional runbook in the new project called "{new_runbook_name}". 
            The additional runbook should have a single step in the runbook process. 
            The step is called "Switch load balancer production group" and it is an AWS run a CLI script step. 
            The step should be a bash script that switches traffic from one target group to the other. 
            The runbook should only run in the "Test" and "Production" environments."""
        response = copilot_handler_internal(build_request(prompt))
        response_body = response.get_body().decode("utf8")
        confirmation_id = get_confirmation_id(response_body)
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = {
            "messages": [
                {
                    "role": "user",
                    "content": "",
                    "copilot_references": None,
                    "copilot_confirmations": [
                        {
                            "state": "accepted",
                            "confirmation": {"id": confirmation_id},
                        }
                    ],
                }
            ]
        }

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following resources were created:" in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project(space_id, project_name, Octopus_Api_Key, Octopus_Url)
        self.assertEqual(project["Name"], project_name)
        runbook = get_runbook_fuzzy(
            space_id,
            project["Id"],
            new_runbook_name,
            Octopus_Api_Key,
            Octopus_Url,
        )
        self.assertTrue(
            runbook["Name"] == new_runbook_name,
        )
        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, Octopus_Api_Key, Octopus_Url
        )
        deployment_process = json.loads(raw_deployment_process)
        number_of_steps = len(deployment_process["Steps"])
        self.assertTrue(
            number_of_steps > 2,
            f"The deployment process should have at least two steps. It has: {number_of_steps}",
        )

        mandatory_step = "Attempt Login"
        self.assertTrue(
            any(step["Name"] == mandatory_step for step in deployment_process["Steps"]),
            f'The deployment process should have a step called "{mandatory_step}".',
        )


if __name__ == "__main__":
    unittest.main()


def build_request(message):
    """
    Build a request with the Slack and GitHub tokens passed through headers. Octopus details
    are expected to be sourced from the database.
    :param message:
    :return:
    """
    return func.HttpRequest(
        method="POST",
        body=json.dumps({"messages": [{"content": message}]}).encode("utf8"),
        url="/api/form_handler",
        params=None,
        headers={
            "X-GitHub-Token": os.environ["GH_TEST_TOKEN"],
            "X-Slack-Token": os.environ.get("SLACK_TEST_TOKEN"),
        },
    )


def build_confirmation_request(body):
    return func.HttpRequest(
        method="POST",
        body=json.dumps(body).encode("utf8"),
        url="/api/form_handler",
        params=None,
        headers={
            "X-GitHub-Token": os.environ["GH_TEST_TOKEN"],
            "X-Slack-Token": os.environ.get("SLACK_TEST_TOKEN"),
        },
    )


def populate_blob_storage():
    # The path changes depending on where the tests are run from.
    context_path = (
        "../../context/" if os.path.exists("../../context/context.tf") else "context/"
    )

    pattern_tf = os.path.join(context_path, "*.tf")
    pattern_txt = os.path.join(context_path, "*.txt")

    all_files = glob.glob(pattern_tf) + glob.glob(pattern_txt)
    all_files.sort()

    for file_path in all_files:
        with open(file_path, "r") as file:
            file_content = file.read()
            filename = os.path.basename(file_path)
            save_terraform_context(
                filename, file_content, os.environ["AzureWebJobsStorage"]
            )
