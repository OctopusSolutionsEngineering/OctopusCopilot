import json
import os
import unittest
import uuid

import Levenshtein
import pytest
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
    get_raw_deployment_process,
    sync_community_step_templates,
)
from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.application.test_copilot_chat_create_projects import (
    populate_blob_storage,
    build_confirmation_body,
    build_request,
    build_confirmation_request,
)
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.test_octopus_infrastructure import run_terraform
from tests.infrastructure.remote_octopus import (
    Remote_Octopus_Api_Key,
    Remote_Octopus_Url,
    Remote_Test,
    create_remote_space,
    delete_remote_space,
    get_active_api_key,
    get_active_octopus_url,
)

# The space the prompts are run against. When running remotely, a random space name is
# generated to avoid collisions. When running locally, the space created by terraform is used.
Space_Name = "Simple"


@pytest.mark.split_group("group1")
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
        global Space_Name

        populate_blob_storage()

        # Simulate the result of a user login and saving their Octopus details
        try:
            save_user_details()
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

        if Remote_Test:
            # Running against a remote Octopus instance. Create a temporary space.
            cls.mssql = None
            cls.octopus = None
            space_name = f"EasyMode-{uuid.uuid4().hex[:8]}"
            cls._remote_space_id = create_remote_space(space_name)
            Space_Name = space_name

            sync_community_step_templates(
                Remote_Octopus_Api_Key, Remote_Octopus_Url
            )
            return

        cls._remote_space_id = None

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

    def setUp(self):
        # The user details are saved before each test, because the default space is only known once the
        # remote space has been created, and a long running test class can otherwise reach a point where the
        # details are no longer resolved and the assistant responds by asking the user to log in again.
        save_user_details()

    @classmethod
    def tearDownClass(cls):
        if Remote_Test:
            # Delete the temporary space created for remote testing
            if getattr(cls, "_remote_space_id", None):
                try:
                    delete_remote_space(cls._remote_space_id)
                except Exception as e:
                    print(f"Failed to delete remote space {cls._remote_space_id}: {e}")
            return

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

        confirmation = build_confirmation_body(confirmation_id)

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following Octopus resources were created successfully:"
            in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project(space_id, project_name, get_active_api_key(), get_active_octopus_url())
        self.assertTrue(
            project["Name"] == project_name,
        )

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, get_active_api_key(), get_active_octopus_url()
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
    def test_create_k8s_project_with_ephemeral_environments(self):
        project_name = "My K8s Project with Ephemeral Environments"
        prompt = f'''Create a Kubernetes project called "{project_name}", and then:
* Use client side apply in the Kubernetes step (the mock Kubernetes cluster only supports client side apply).
* Disable verification checks in the Kubernetes steps (the mock Kubernetes cluster doesn't support verification checks).
* Enable retries on the K8s deployment step.
* Add support for ephemeral environments, with the Parent Environment and Ephemeral Environment channel both called "Features"'''

        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = build_confirmation_body(confirmation_id)

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following Octopus resources were created successfully:"
            in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project(space_id, project_name, get_active_api_key(), get_active_octopus_url())
        self.assertTrue(
            project["Name"] == project_name,
        )

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, get_active_api_key(), get_active_octopus_url()
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
    def test_create_vm_blue_green_project(self):
        project_name = "My VM Blue Green project"
        prompt = f'Create a VM Blue/Green project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = build_confirmation_body(confirmation_id)

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following Octopus resources were created successfully:"
            in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_create_azure_web_app_project(self):
        project_name = "My Azure WebApp Project"
        prompt = f'Create an Azure Web App project called "{project_name}".'
        response = copilot_handler_internal(build_request(prompt))
        confirmation_id = get_confirmation_id(response.get_body().decode("utf8"))
        self.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

        confirmation = build_confirmation_body(confirmation_id)

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following Octopus resources were created successfully:"
            in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project(space_id, project_name, get_active_api_key(), get_active_octopus_url())
        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, get_active_api_key(), get_active_octopus_url()
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

        confirmation = build_confirmation_body(confirmation_id)

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following Octopus resources were created successfully:"
            in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project(space_id, project_name, get_active_api_key(), get_active_octopus_url())
        self.assertEqual(project["Name"], project_name)
        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, get_active_api_key(), get_active_octopus_url()
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

        confirmation = build_confirmation_body(confirmation_id)

        run_response = copilot_handler_internal(
            build_confirmation_request(confirmation)
        )
        response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )
        print(response_text)
        self.assertTrue(
            f"The following Octopus resources were created successfully:"
            in response_text,
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project(space_id, project_name, get_active_api_key(), get_active_octopus_url())
        self.assertEqual(project["Name"], project_name)

        raw_deployment_process = get_raw_deployment_process(
            space_name, project_name, get_active_api_key(), get_active_octopus_url()
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


def save_user_details():
    """
    Simulate the result of a user login by saving the Octopus details and the default values the
    prompts rely on.
    """
    github_user = os.environ["TEST_GH_USER"]
    save_users_octopus_url_from_login(
        github_user,
        get_active_octopus_url(),
        get_active_api_key(),
        os.environ["ENCRYPTION_PASSWORD"],
        os.environ["ENCRYPTION_SALT"],
        os.environ["AzureWebJobsStorage"],
    )

    defaults = {
        "space": Space_Name,
        "project": "Deploy Web App Container",
        "environment": "Development",
        "owner": "OctopusSolutionsEngineering",
        "repository": "OctopusCopilot",
        "workflow": "build.yaml",
    }
    for name, value in defaults.items():
        save_default_values(
            github_user, name, value, os.environ["AzureWebJobsStorage"]
        )
