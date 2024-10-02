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


class CopilotChatTestTwo(unittest.TestCase):
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

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_all_defaults(self):
        prompt = "Get all default values."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Simple" in response_text, "Response was " + response_text)
        self.assertTrue(
            "Deploy Web App Container" in response_text, "Response was " + response_text
        )
        self.assertTrue("Development" in response_text, "Response was " + response_text)
        self.assertTrue(
            "OctopusSolutionsEngineering" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue(
            "OctopusCopilot" in response_text, "Response was " + response_text
        )
        self.assertTrue("build.yaml" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_default_space(self):
        prompt = "Get default space."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Simple" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_default_project(self):
        prompt = "Get default project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Deploy Web App Container" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_default_environment(self):
        prompt = "Get default environment."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Development" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_default_owner(self):
        prompt = "Get default owner."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "OctopusSolutionsEngineering" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_default_repository(self):
        prompt = "Get default repository."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "OctopusCopilot" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_default_workflow(self):
        prompt = "Get default workflow."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("build.yaml" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_space_lookup(self):
        prompt = 'List the variable names defined in the project "Deploy Web App Container" in space "Simpleish".'
        space_id, actual_space_name, warnings = lookup_space(
            Octopus_Url, Octopus_Api_Key, None, prompt, "Simpleish"
        )

        self.assertEqual(
            actual_space_name, "Simple", "Space name was " + actual_space_name
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_project_lookup(self):
        prompt = 'List the variable names defined in the project "Deploy Web App Containerish" in space "Simpleish".'
        space_id, actual_space_name, warnings = lookup_space(
            Octopus_Url, Octopus_Api_Key, None, prompt, "Simpleish"
        )
        sanitized_project_names, sanitized_projects = lookup_projects(
            Octopus_Url,
            Octopus_Api_Key,
            None,
            prompt,
            space_id,
            "Deploy Web App Containerish",
        )

        self.assertEqual(
            sanitized_project_names[0],
            "Deploy Web App Container",
            "Project name was " + sanitized_project_names[0],
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_environment_lookup(self):
        prompt = 'List the variable names defined in the project "Deploy Web App Containerish" in space "Simpleish" in environment "Developmentish".'
        space_id, actual_space_name, warnings = lookup_space(
            Octopus_Url, Octopus_Api_Key, None, prompt, "Simpleish"
        )
        sanitized_environment_names = lookup_environments(
            Octopus_Url, Octopus_Api_Key, None, prompt, space_id, "Developmentish"
        )

        self.assertEqual(
            sanitized_environment_names[0],
            "Development",
            "Environment name was " + sanitized_environment_names[0],
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_tenant_lookup(self):
        prompt = 'List the variable names defined in the project "Deploy Web App Containerish" in space "Simpleish" in environment "Developmentish" scoped to Tenant "Marketingish".'
        space_id, actual_space_name, warnings = lookup_space(
            Octopus_Url, Octopus_Api_Key, None, prompt, "Simpleish"
        )
        sanitized_tenant_names = lookup_tenants(
            Octopus_Url, Octopus_Api_Key, None, prompt, space_id, "Marketingish"
        )

        self.assertEqual(
            sanitized_tenant_names[0],
            "Marketing",
            "Tenant name was " + sanitized_tenant_names[0],
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_runbook_lookup(self):
        prompt = 'List the variable names defined in the project "Deploy Web App Containerish" in space "Simpleish" in environment "Developmentish" scoped to Tenant "Marketingish" and runbook "Backup Databaseish".'
        space_id, actual_space_name, warnings = lookup_space(
            Octopus_Url, Octopus_Api_Key, None, prompt, "Simpleish"
        )
        sanitized_project_names, sanitized_projects = lookup_projects(
            Octopus_Url,
            Octopus_Api_Key,
            None,
            prompt,
            space_id,
            "Copilot Test Runbook Projectish",
        )
        project = get_project(
            space_id, sanitized_project_names[0], Octopus_Api_Key, Octopus_Url
        )
        sanitized_runbook_names = lookup_runbooks(
            Octopus_Url,
            Octopus_Api_Key,
            None,
            prompt,
            space_id,
            project["Id"],
            "Backup Databaseish",
        )

        self.assertEqual(
            sanitized_runbook_names[0],
            "Backup Database",
            "Runbook name was " + sanitized_runbook_names[0],
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_get_variables(self):
        prompt = 'List the variable names defined in the project "Deploy Web App Container" in space "Simple".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Test.Variable" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_space_fuzzy_match(self):
        prompt = 'List the variables defined in the project "Deploy Web App Container" in space "Simple1".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Test.Variable" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_get_variables_no_github_user(self):
        prompt = 'List the variable names defined in the project "Deploy Web App Container" in space "Simple".'
        response = copilot_handler_internal(build_test_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Test.Variable" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_get_variables_with_defaults(self):
        prompt = "List the variable names defined in the project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Test.Variable" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_step(self):
        prompt = 'What does the step "Run a Script 2" do in the project "Deploy Web App Container" in space "Simple".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Hi there" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_missing_step(self):
        prompt = (
            'What does the project "Deploy Web App Container" in space "Simple" do.'
        )
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertFalse("Hi there" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_machines(self):
        prompt = 'What machines are in the space "Simple"?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Cloud Region Target" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_all_projects(self):
        prompt = 'What projects are in the space "Simple".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Deploy Web App Container" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_runbook(self):
        prompt = 'What is the description of the "Backup Database" runbook in the "Copilot Test Runbook Project" project.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Test Runbook" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_machine_policies(self):
        prompt = 'What is the powershell health check script defined in the "Windows VM Policy" machine policy?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "win32_LogicalDisk" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_project_groups(self):
        prompt = 'What is the description of the "Azure Apps" project group?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Test Description" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_tenants(self):
        prompt = 'Describe the tenant "Marketing".'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Marketing" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_list_tenants(self):
        """
        This query was an example where the name of the space was being set to "Space", and where the
        query was being answered by answer_project_variables_callback. The comment in
        answer_project_variables_callback was updated to reflect the fact that it has nothing to do with tenants.
        """
        prompt = "List the unique tenant names in the space, sorted in alphabetical order. Display the answer in a markdown table."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Marketing" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_environment(self):
        prompt = 'Does the "Development" environment allow dynamic infrastructure?.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Development" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_feed(self):
        prompt = 'What is the URI of the "Helm" feed?.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "https://charts.helm.sh/stable/" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_account(self):
        prompt = 'What is the access key in the "AWS Account" account.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "ABCDEFGHIJKLMNOPQRST" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_variable_set(self):
        prompt = 'List the variables belonging to the "Database Settings" library variable set.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Test.Variable" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_worker_pool(self):
        prompt = 'What is the description of the "Docker" worker pool?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "Workers running Docker containers" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_certificate(self):
        prompt = 'What is the note of the "Kind CA" certificate?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "A test certificate" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_tagsets(self):
        prompt = 'List the tags associated with the "regions" tag set?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("us-east-1" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_lifecycle(self):
        prompt = 'What environments are in the "Simple" lifecycle?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Production" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_git_creds(self):
        prompt = 'What is the username for the "GitHub Credentials" git credentials?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("admin" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(space_name="Simple", release_version=version)
        prompt = 'Get the release version of the latest deployment to the "Development" environment for the "Deploy Web App Container" project.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(version in response_text, "Response was " + response_text)

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
    def test_get_runbook_logs(self):
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
        prompt = 'Get the logs from the run of runbook "Backup Database" in the "Copilot Test Runbook Project" project.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue("Hello world" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_fuzzy(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        deployment = create_and_deploy_release(
            space_name="Simple", release_version=version
        )
        wait_for_task(deployment["TaskId"], space_name="Simple")
        prompt = 'Get the release version of the latest deployment to the "Develpment" environment for the "Deploy WebApp Container" project.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_date_range_deployment(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(space_name="Simple", release_version=version)
        prompt = 'Get the release version of the last deployment made to the "Development" environment for the "Deploy Web App Container" project between 1st January 2024 and 31st December 2099.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_get_channels(self):
        prompt = 'List the channels defined in the project "Deploy AWS Lambda" in the space "Simple" in a markdown table.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            re.search("Mainline", response_text), "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_channel(self):
        # Create a release in the Mainline channel against a tenant
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(
            space_name="Simple",
            channel_name="Mainline",
            project_name="Deploy AWS Lambda",
            tenant_name="Marketing",
            release_version=version,
        )
        # Create another release without a tenant to ensure the query is actually doing a search and not
        # returning the first version it finds
        create_and_deploy_release(
            space_name="Simple",
            project_name="Deploy AWS Lambda",
            release_version=str(uuid.uuid4()),
        )
        prompt = (
            'What is the release version of the latest deployment to the "Development" environment for the '
            + '"Deploy AWS Lambda" project in the "Mainline" channel for the "Marketing" tenant?'
        )
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_channel_fuzzy(self):
        # Create a release in the Mainline channel against a tenant
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(
            space_name="Simple",
            channel_name="Mainline",
            project_name="Deploy AWS Lambda",
            tenant_name="Marketing",
            release_version=version,
        )
        # Create another release without a tenant to ensure the query is actually doing a search and not
        # returning the first version it finds
        create_and_deploy_release(
            space_name="Simple",
            project_name="Deploy AWS Lambda",
            release_version=str(uuid.uuid4()),
        )
        # The project name is misspelled here deliberately to test the fuzzy matching
        prompt = (
            'What is the release version of the latest deployment to the "Development" environment for the '
            + '"Deploy AS Lambda" project in the "Mainline" channel for the "Marketing" tenant?'
        )
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_defaults(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(space_name="Simple", release_version=version)
        prompt = "What is the release version of the latest deployment?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_hotfix_deployments(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        deployment = create_and_deploy_release(
            space_name="Simple",
            release_version=version + "-hotfix-timeouts-iss253",
            channel_name="Hotfix",
        )
        wait_for_task(deployment["TaskId"], space_name="Simple")

        prompt = "Show the release version and time of the last successful deployment to the hotfix channel."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            version + "-hotfix-timeouts-iss253" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_general_question(self):
        prompt = 'What does the project "Deploy Web App Container" do?'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This response could be anything, but make sure the LLM isn't saying sorry for something.
        self.assertTrue(
            "sorry" not in response_text.casefold(), "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_help(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(space_name="Simple", release_version=version)
        time.sleep(5)

        for prompt in [
            "what questions can I ask",
            "help me",
            "hello",
            "hi",
            "what do you do",
            "what do you do?",
            "What do you do?",
        ]:
            response = copilot_handler_internal(build_request(prompt))
            response_text = convert_from_sse_response(
                response.get_body().decode("utf8")
            )

            self.assertTrue(
                "Here are some sample queries you can ask" in response_text,
                "Prompt was " + prompt + " Response was " + response_text,
            )
            # The project, environment, runbook, and space name must be included in the sample queries
            self.assertTrue(
                "Simple" in response_text,
                "Prompt was " + prompt + " Response was " + response_text,
            )
            self.assertTrue(
                "Deploy Web App Container" in response_text,
                "Prompt was " + prompt + " Response was " + response_text,
            )
            self.assertTrue(
                "Backup Database" in response_text,
                "Prompt was " + prompt + " Response was " + response_text,
            )
            self.assertTrue(
                "Development" in response_text,
                "Prompt was " + prompt + " Response was " + response_text,
            )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_docs(self):
        for prompt in ["How do I enable server side apply?"]:
            response = copilot_handler_internal(build_request(prompt))
            response_text = convert_from_sse_response(
                response.get_body().decode("utf8")
            )

            self.assertTrue(
                "Sorry, I did not understand that request." not in response_text,
                "Response was " + response_text,
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
