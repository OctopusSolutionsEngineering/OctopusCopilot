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
from domain.transformers.sse_transformers import convert_from_sse_response
from domain.url.session import create_session_blob
from function_app import copilot_handler_internal, health_internal
from infrastructure.octopus import (
    run_published_runbook_fuzzy,
    get_space_id_and_name_from_name,
    get_project,
)
from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.infrastructure.create_and_deploy_release import (
    create_and_deploy_release,
    wait_for_task,
)
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.test_octopus_infrastructure import run_terraform
from tests.infrastructure.publish_runbook import publish_runbook


class CopilotChatDashboardTest(unittest.TestCase):
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

    def test_health(self):
        health_internal()

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_runbook_dashboard(self):
        publish_runbook("Simple", "Copilot Test Runbook Project", "Backup Database")
        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        runbook_run = run_published_runbook_fuzzy(
            space_id,
            "Copilot Test Runbook Project",
            "Backup Database",
            "Development",
            tenant_name="",
            variables=None,
            my_api_key=Octopus_Api_Key,
            my_octopus_api=Octopus_Url,
        )
        wait_for_task(runbook_run["TaskId"], space_name="Simple")
        prompt = 'Get the runbook dashboard for runbook "Backup Database" in the "Copilot Test Runbook Project" project.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        print(response_text)
        self.assertTrue(
            "This is a highlight" in response_text, "Response was " + response_text
        )
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_dashboard(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(space_name="Simple", release_version=version)
        time.sleep(5)
        prompt = "Show the dashboard."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # Make sure one of these icons is in the output: 🔵🟡🟢🔴⚪
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_dashboard_fuzzy_space(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(space_name="Simple", release_version=version)
        time.sleep(5)
        prompt = 'Show the dashboard for space "Simpleish".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # Make sure one of these icons is in the output: 🔵🟡🟢🔴⚪
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue("Simple" in response_text, "Response was " + response_text)
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_deployment_summary_fuzzy_space(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        notes = """* GitHub Owner: OctopusSolutionsEngineering
        * GitHub Repo: OctopusCopilot
        * GitHub Workflow: build.yaml
        * GitHub Sha: fba6924ff1099794bc716bcdec12e451fd811d96
        * GitHub Run: 1401
        * GitHub Attempt: 1
        * GitHub Run Id: 9656530979"""
        deployment = create_and_deploy_release(
            space_name="Simple", release_version=version, release_notes=notes
        )
        wait_for_task(deployment["TaskId"], space_name="Simple")
        prompt = f'Show the task summary for release {version} of project "Deploy Web App Container" for space "Simpleish".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # Make sure one of these icons is in the output: 🔵🟡🟢🔴⚪
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue(
            f"Deploy Deploy Web App Container release {version} to Development"
            in response_text,
            response_text,
        )
        self.assertTrue(f"This is a highlight" in response_text, response_text)
        self.assertTrue(f"file.txt" in response_text, response_text)
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_project_dashboard_fuzzy_space(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        notes = """* GitHub Owner: OctopusSolutionsEngineering
                * GitHub Repo: OctopusCopilot
                * GitHub Workflow: build.yaml
                * GitHub Sha: fba6924ff1099794bc716bcdec12e451fd811d96
                * GitHub Run: 1401
                * GitHub Attempt: 1
                * GitHub Run Id: 9656530979"""
        prompt = 'Show the project dashboard for "Deploy Web App Container" for space "Simpleish".'
        deployment = create_and_deploy_release(
            space_name="Simple", release_version=version, release_notes=notes
        )

        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        self.assertTrue(
            "Configure the load balancer" in response_text,
            "Response was " + response_text,
        )
        print(response_text)

        wait_for_task(deployment["TaskId"], space_name="Simple")

        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # Make sure one of these icons is in the output: 🔵🟡🟢🔴⚪
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue(
            "Simple / Deploy Web App Container" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue(
            "This is a highlight" in response_text, "Response was " + response_text
        )
        self.assertTrue("file.txt" in response_text, "Response was " + response_text)
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_project_dashboard_default_space(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        notes = """* GitHub Owner: OctopusSolutionsEngineering
                        * GitHub Repo: OctopusCopilot
                        * GitHub Workflow: build.yaml
                        * GitHub Sha: fba6924ff1099794bc716bcdec12e451fd811d96
                        * GitHub Run: 1401
                        * GitHub Attempt: 1
                        * GitHub Run Id: 9656530979"""
        deployment = create_and_deploy_release(
            space_name="Simple", release_version=version, release_notes=notes
        )
        hotfix_deployment = create_and_deploy_release(
            space_name="Simple",
            channel_name="Hotfix",
            release_version=f"{version}-hf",
            release_notes=notes,
        )
        wait_for_task(deployment["TaskId"], space_name="Simple")
        wait_for_task(hotfix_deployment["TaskId"], space_name="Simple")
        prompt = 'Show the project dashboard for "Deploy Web App Container".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # Make sure one of these icons is in the output: 🔵🟡🟢🔴⚪
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue(
            "Simple / Deploy Web App Container" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue(
            "Channel: Default" in response_text, "Response was " + response_text
        )
        self.assertTrue(
            "Channel: Hotfix" in response_text, "Response was " + response_text
        )
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_tenant_project_dashboard(self):
        # Create a release in the Mainline channel against a tenant
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        prompt = (
            'Show the project dashboard for "Deploy AWS Lambda" for space "Simple"?'
        )

        deployment = create_and_deploy_release(
            space_name="Simple",
            channel_name="Mainline",
            project_name="Deploy AWS Lambda",
            tenant_name="Marketing",
            release_version=version,
        )
        # Create another release without a tenant to ensure the query is actually doing a search and not
        # returning the first version it finds
        untenanted_version = datetime.now().strftime("%Y%m%d.%H.%M.%S") + "-untenanted"
        untenanted_deployment = create_and_deploy_release(
            space_name="Simple",
            project_name="Deploy AWS Lambda",
            release_version=untenanted_version,
        )

        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))
        self.assertTrue(
            "Run a Script" in response_text, "Response was " + response_text
        )
        print(response_text)

        wait_for_task(deployment["TaskId"], space_name="Simple")
        wait_for_task(untenanted_deployment["TaskId"], space_name="Simple")

        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )
        self.assertIn(
            "Simple / Deploy AWS Lambda",
            response_text,
            "Response was " + response_text,
        )
        self.assertIn("Marketing", response_text, "Response was " + response_text)
        self.assertIn(version, response_text, "Response was " + response_text)
        self.assertIn(
            untenanted_version, response_text, "Response was " + response_text
        )
        self.assertIn(
            "This is a highlight", response_text, "Response was " + response_text
        )
        self.assertIn("file.txt", response_text, "Response was " + response_text)
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_github_task_summary(self):
        prompt = 'Show the github summary for workflow "build.yaml" from owner "OctopusSolutionsEngineering" and repo "OctopusCopilot".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # The response should have formatted the text as a code block
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text
            or "🟣" in response_text,
            "Response was " + response_text,
        )
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_github_task_summary_defaults(self):
        prompt = "Show the Github Workflow summary."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # The response should have formatted the text as a code block
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text
            or "🟣" in response_text,
            "Response was " + response_text,
        )
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_github_logs(self):
        prompt = 'Summarise the logs from the workflow "build.yaml" from owner "OctopusSolutionsEngineering" and repo "OctopusCopilot".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # We don't actually know what will be printed, but it shouldn't be an apology
        self.assertTrue("sorry" not in response_text)
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_github_task_summary_combined_repo_format(self):
        # Combine the owner and repo into a single string
        prompt = 'Get the summary for the workflow "build.yaml" in the repo "OctopusSolutionsEngineering/OctopusCopilot".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # The response should have formatted the text as a code block
        self.assertTrue(
            "🟣" in response_text
            or "🔵" in response_text
            or "🟡" in response_text
            or "🟢" in response_text
            or "🔴" in response_text
            or "⚪" in response_text,
            "Response was " + response_text,
        )
        print(response_text)


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
