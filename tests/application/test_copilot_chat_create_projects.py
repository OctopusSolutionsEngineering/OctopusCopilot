import json
import os
import re
import time
import unittest
import uuid
from datetime import datetime

import azure.functions as func
from openai import RateLimitError
from requests.exceptions import HTTPError
from retry import retry
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs

from domain.lookup.octopus_lookups import (
    lookup_space,
    lookup_projects,
    lookup_environments,
    lookup_tenants,
    lookup_runbooks,
)
from domain.transformers.sse_transformers import (
    convert_from_sse_response,
    get_confirmation_id,
)
from domain.url.session import create_session_blob
from function_app import copilot_handler_internal, health_internal
from infrastructure.octopus import (
    run_published_runbook_fuzzy,
    get_space_id_and_name_from_name,
    get_project,
)
from infrastructure.terraform_context import save_terraform_context
from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.infrastructure.create_and_deploy_release import (
    create_and_deploy_release,
    wait_for_task,
)
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.publish_runbook import publish_runbook
from tests.infrastructure.test_octopus_infrastructure import run_terraform


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
            wait_for_logs(
                cls.octopus, "Web server is ready to process requests", timeout=300
            )

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
        prompt = 'Create a Kubernetes project called "My K8s Project".'
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

        project = get_project(space_id, "My K8s Project", Octopus_Api_Key, Octopus_Url)
        self.assertTrue(
            project["Name"] == "My K8s Project",
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_azure_web_app_project(self):
        prompt = 'Create an Azure Web App project called "My Azure Project".'
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

        project = get_project(
            space_id, "My Azure Project", Octopus_Api_Key, Octopus_Url
        )
        self.assertTrue(
            project["Name"] == "My Azure Project",
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_feed(self):
        prompt = 'Create a Docker feed called "Docker Hub".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_account(self):
        prompt = 'Create an AWS account called "AWS".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_certificate(self):
        prompt = 'Create a certificate account called "HTTPS".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_tenant(self):
        prompt = 'Create a tenant account called "ZAB65395".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_environment(self):
        prompt = 'Create a environment account called "Whatever".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_target(self):
        prompt = 'Create a SSH target called "Linux Server".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_machine_policy(self):
        prompt = 'Create a machine policy target called "Linux Server".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_worker(self):
        prompt = 'Create a worker called "Linux Server".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_worker_pool(self):
        prompt = 'Create a worker pool called "Linux Server".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_lifecycle(self):
        prompt = 'Create a lifecycle target called "DevSecOps".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_script_module(self):
        prompt = 'Create a script module called "Sort Array".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_step_template(self):
        prompt = 'Create a step template called "Sort Array".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_git_credential(self):
        prompt = 'Create a git credential called "GitLab".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_github_connection(self):
        prompt = 'Create a github connection called "GitLab".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_create_machine_proxy(self):
        prompt = 'Create a machine proxy called "Squid".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        print(response_text)
        self.assertTrue(
            f"Creating this kind of resource is not yet supported." in response_text,
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

    with open(context_path + "context.tf", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "context.tf", file_content, os.environ["AzureWebJobsStorage"]
        )

    with open(context_path + "k8ssystemprompt.txt", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "k8ssystemprompt.txt", file_content, os.environ["AzureWebJobsStorage"]
        )

    with open(context_path + "azurewebappsystemprompt.txt", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "azurewebappsystemprompt.txt",
            file_content,
            os.environ["AzureWebJobsStorage"],
        )

    with open(context_path + "generalinstructions.txt", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "generalinstructions.txt", file_content, os.environ["AzureWebJobsStorage"]
        )

    with open(context_path + "everystep.tf", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "everystep.tf", file_content, os.environ["AzureWebJobsStorage"]
        )

    with open(context_path + "k8s.tf", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "k8s.tf", file_content, os.environ["AzureWebJobsStorage"]
        )

    with open(context_path + "azurewebapp.tf", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "azurewebapp.tf", file_content, os.environ["AzureWebJobsStorage"]
        )

    with open(context_path + "projectsettings1.tf", "r") as file:
        file_content = file.read()

        save_terraform_context(
            "projectsettings1.tf", file_content, os.environ["AzureWebJobsStorage"]
        )
