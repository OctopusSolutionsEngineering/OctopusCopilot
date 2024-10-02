import json
import os
import time
import unittest
from datetime import datetime

import azure.functions as func
from openai import RateLimitError
from requests.exceptions import HTTPError
from retry import retry
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs

from domain.transformers.sse_transformers import (
    convert_from_sse_response,
    get_confirmation_id,
)
from domain.url.session import create_session_blob
from function_app import copilot_handler_internal

from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.application.test_copilot_chat import build_request

from tests.infrastructure.create_release import create_release
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.test_octopus_infrastructure import run_terraform


class CopilotChatReleaseAndDeployTest(unittest.TestCase):
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
                "The tests will fail because Azurite is not running. Run Azureite with: "
                + "docker run -d -p 10000:10000 -p 10001:10001 -p 10002:10002 mcr.microsoft.com/azure-storage/azurite"
            )
            print(e)
            return

        try:
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
                "../terraform/simple/space_creation", Octopus_Url, Octopus_Api_Key
            )
            run_terraform(
                "../terraform/simple/space_population",
                Octopus_Url,
                Octopus_Api_Key,
                json.loads(output)["octopus_space_id"]["value"],
            )
            run_terraform(
                "../terraform/empty/space_creation", Octopus_Url, Octopus_Api_Key
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

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_create_release(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        prompt = f'Create release in the "Deploy Web App Container" project with version "{version}" and with channel "Default"'
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
        self.assertTrue(
            f"Release {version}" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_create_release_handles_existing_version(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        # Create the release via the api
        create_release(space_name="Simple", release_version=version)
        # Then create it via a prompt
        prompt = f'Create release in the "Deploy Web App Container" project with version "{version}" and with channel "Default"'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        self.assertTrue(
            f'Release version "{version}" already exists.' in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_create_release_with_deployment_environment(self):
        project_name = "Deploy Web App Container"
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        deploy_environment = "Development"
        prompt = f'Create release in the "{project_name}" project with version "{version}" and deploy to the "{deploy_environment}" environment'
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
        self.assertTrue(
            f"Deployment of {project_name} release {version} to {deploy_environment}"
            in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_create_release_with_deployment_and_missing_variables(self):
        project_name = "Prompted Variable Project"
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        deploy_environment = "Development"
        prompt = f'Create release in the "{project_name}" project with version "{version}" and deploy to the "{deploy_environment}" environment with the variables slot=, notify=false'
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

        self.assertTrue(
            "The Deployment is missing values for required variables: slot"
            in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_create_release_with_deployment_and_variables(self):
        project_name = "Prompted Variable Project"
        deploy_environment = "Development"
        prompt = f'Create release in the "{project_name}" project and deploy to the "{deploy_environment}" environment with the variables slot=Staging, notify=false'
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
        self.assertTrue(
            f"Deployment of {project_name} release "
            and f"to {deploy_environment}" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_deploy_release(self):
        project_name = "Deploy Web App Container"
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        release = create_release(
            space_name="Simple", project_name=project_name, release_version=version
        )
        deploy_environment = "Development"
        prompt = f"Deploy release version \"{release['Version']}\" for project \"{project_name}\" to the \"{deploy_environment}\" environment"
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
        self.assertTrue(
            f"Deployment of {project_name} release {version} to {deploy_environment}"
            in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_deploy_release_default_project(self):
        project_name = "Deploy Web App Container"
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        release = create_release(
            space_name="Simple", project_name=project_name, release_version=version
        )
        deploy_environment = "Development"
        prompt = f"Deploy release version \"{release['Version']}\" to the \"{deploy_environment}\" environment"
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
        self.assertTrue(
            f"Deployment of {project_name} release {version} to {deploy_environment}"
            in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_deploy_release_to_tenant(self):
        project_name = "Deploy AWS Lambda"
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        release = create_release(
            space_name="Simple", project_name=project_name, release_version=version
        )
        deploy_environment = "Development"
        tenant_name = "Marketing"
        prompt = f"Deploy release version \"{release['Version']}\" for project \"{project_name}\" to the \"{deploy_environment}\" environment for tenant \"{tenant_name}\""
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
        self.assertTrue(
            f"Deployment of {project_name} release {version} to {deploy_environment} for {tenant_name}"
            in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_deploy_release_with_variables(self):
        project_name = "Prompted Variable Project"
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        release = create_release(
            space_name="Simple", project_name=project_name, release_version=version
        )
        deploy_environment = "Development"
        prompt = (
            f"Deploy release version \"{release['Version']}\" for project \"{project_name}\" to the "
            f'"{deploy_environment}" environment with variables notify=false, slot=Staging'
        )
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
        self.assertTrue(
            f"Deployment of {project_name} release {version} to {deploy_environment}"
            in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_deploy_release_with_missing_required_variable(self):
        project_name = "Prompted Variable Project"
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        release = create_release(
            space_name="Simple", project_name=project_name, release_version=version
        )
        deploy_environment = "Development"
        prompt = f"Deploy release version \"{release['Version']}\" for project \"{project_name}\" to the \"{deploy_environment}\" environment with variables notify=false, slot="
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "The Deployment is missing values for required variables: slot"
            in response_text,
            "Response was " + response_text,
        )


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


def build_no_octopus_request(message):
    """
    Build a request where all values are passed through headers. This supports tests that do not
    populate the Azurite database, as all details can be extracted from the headers.
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
            "X-Octopus-ApiKey": Octopus_Api_Key,
            "X-Octopus-Server": Octopus_Url,
        },
    )


def build_no_octopus_encrypted_github_request(message):
    """
    Build a request where all values are passed through headers. This supports tests that do not
    populate the Azurite database, as all details can be extracted from the headers.
    :param message:
    :return:
    """
    session_json = create_session_blob(
        os.environ["GH_TEST_TOKEN"],
        os.environ.get("ENCRYPTION_PASSWORD"),
        os.environ.get("ENCRYPTION_SALT"),
    )

    return func.HttpRequest(
        method="POST",
        body=json.dumps({"messages": [{"content": message}]}).encode("utf8"),
        url="/api/form_handler",
        params=None,
        headers={
            "X-GitHub-Encrypted-Token": session_json,
            "X-Slack-Token": os.environ.get("SLACK_TEST_TOKEN"),
            "X-Octopus-ApiKey": Octopus_Api_Key,
            "X-Octopus-Server": Octopus_Url,
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


def build_test_request(message):
    """
    Builds a request that directly embeds the API key and server, removing the need to query the GitHub API.
    :param message:
    :return:
    """
    return func.HttpRequest(
        method="POST",
        body=json.dumps({"messages": [{"content": message}]}).encode("utf8"),
        url="/api/form_handler",
        params=None,
        headers={
            "X-Octopus-ApiKey": Octopus_Api_Key,
            "X-Octopus-Server": Octopus_Url,
            "X-Slack-Token": os.environ.get("SLACK_TEST_TOKEN"),
        },
    )
