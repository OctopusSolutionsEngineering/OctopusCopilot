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

from domain.transformers.clean_response import strip_before_first_curly_bracket
from domain.transformers.sse_transformers import convert_from_sse_response
from function_app import copilot_handler_internal, health_internal
from infrastructure.octopus import run_published_runbook_fuzzy, get_space_id_and_name_from_name
from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.infrastructure.create_and_deploy_release import create_and_deploy_release, wait_for_task
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.octopus_infrastructure_test import run_terraform
from tests.infrastructure.publish_runbook import publish_runbook


class CopilotChatTest(unittest.TestCase):
    """
    End-to-end tests that verify the complete query workflow including:
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
            save_users_octopus_url_from_login(os.environ["TEST_GH_USER"],
                                              Octopus_Url,
                                              Octopus_Api_Key,
                                              os.environ["ENCRYPTION_PASSWORD"],
                                              os.environ["ENCRYPTION_SALT"],
                                              os.environ["AzureWebJobsStorage"])
            save_default_values(os.environ["TEST_GH_USER"],
                                "space",
                                "Simple",
                                os.environ["AzureWebJobsStorage"])
            save_default_values(os.environ["TEST_GH_USER"],
                                "project",
                                "Deploy Web App Container",
                                os.environ["AzureWebJobsStorage"])
            save_default_values(os.environ["TEST_GH_USER"],
                                "environment",
                                "Development",
                                os.environ["AzureWebJobsStorage"])
        except Exception as e:
            print(
                "The tests will fail because Azurite is not running. Run Azureite with: "
                + "docker run -d -p 10000:10000 -p 10001:10001 -p 10002:10002 mcr.microsoft.com/azure-storage/azurite")
            print(e)
            return

        try:
            cls.mssql = DockerContainer("mcr.microsoft.com/mssql/server:2022-latest").with_env(
                "ACCEPT_EULA", "True").with_env("SA_PASSWORD", "Password01!")
            cls.mssql.start()
            wait_for_logs(cls.mssql, "SQL Server is now ready for client connections")

            mssql_ip = cls.mssql.get_docker_client().bridge_ip(cls.mssql.get_wrapped_container().id)

            cls.octopus = DockerContainer("octopusdeploy/octopusdeploy").with_bind_ports(8080, 8080).with_env(
                "ACCEPT_EULA", "Y").with_env("DB_CONNECTION_STRING",
                                             "Server=" + mssql_ip + ",1433;Database=OctopusDeploy;User=sa;Password=Password01!").with_env(
                "ADMIN_API_KEY", Octopus_Api_Key).with_env("DISABLE_DIND", "Y").with_env(
                "ADMIN_USERNAME", "admin").with_env("ADMIN_PASSWORD", "Password01!").with_env(
                "OCTOPUS_SERVER_BASE64_LICENSE", os.environ["LICENSE"])
            cls.octopus.start()
            wait_for_logs(cls.octopus, "Web server is ready to process requests")

            output = run_terraform("../terraform/simple/space_creation", Octopus_Url, Octopus_Api_Key)
            run_terraform("../terraform/simple/space_population", Octopus_Url, Octopus_Api_Key,
                          json.loads(output)["octopus_space_id"]["value"])
            run_terraform("../terraform/empty/space_creation", Octopus_Url, Octopus_Api_Key)
        except Exception as e:
            print("Failed to start containers. Consider running ryuk in privileged mode by setting "
                  + "TESTCONTAINERS_RYUK_PRIVILEGED=true or disabling ryuk by setting "
                  + "TESTCONTAINERS_RYUK_DISABLED=true.")
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
    def test_get_variables(self):
        prompt = "List the variable names defined in the project \"Deploy Web App Container\" in space \"Simple\"."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Test.Variable" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_space_fuzzy_match(self):
        prompt = "List the variables defined in the project \"Deploy Web App Container\" in space \"Simple1\"."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Test.Variable" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_get_variables_no_github_user(self):
        prompt = "List the variable names defined in the project \"Deploy Web App Container\" in space \"Simple\"."
        response = copilot_handler_internal(build_test_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Test.Variable" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_get_variables_with_defaults(self):
        prompt = "List the variable names defined in the project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Test.Variable" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_step(self):
        prompt = "What does the step \"Run a Script\" do in the project \"Deploy Web App Container\" in space \"Simple\"."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Hi there" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_missing_step(self):
        prompt = "What does the project \"Deploy Web App Container\" in space \"Simple\" do."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertFalse("Hi there" in response_text,
                         "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_machines(self):
        prompt = "What machines are in the space \"Simple\"?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Cloud Region Target" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_all_projects(self):
        prompt = "What projects are in the space \"Simple\"."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Deploy Web App Container" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_runbook(self):
        prompt = "What is the description of the \"Backup Database\" runbook in the \"Runbook Project\" project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Test Runbook" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_machine_policies(self):
        prompt = "What is the powershell health check script defined in the \"Windows VM Policy\" machine policy?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("win32_LogicalDisk" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_project_groups(self):
        prompt = "What is the description of the \"Azure Apps\" project group?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Test Description" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_tenants(self):
        prompt = "Describe the tenant \"Marketing\"."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

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
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Marketing" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_environment(self):
        prompt = "Does the \"Development\" environment allow dynamic infrastructure?."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Development" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_feed(self):
        prompt = "What is the URI of the \"Helm\" feed?."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("https://charts.helm.sh/stable/" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_account(self):
        prompt = "What is the access key in the \"AWS Account\" account."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("ABCDEFGHIJKLMNOPQRST" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_variable_set(self):
        prompt = "List the variables belonging to the \"Database Settings\" library variable set."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Test.Variable" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_worker_pool(self):
        prompt = "What is the description of the \"Docker\" worker pool?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Workers running Docker containers" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_certificate(self):
        prompt = "What is the note of the \"Kind CA\" certificate?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("A test certificate" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_tagsets(self):
        prompt = "List the tags associated with the \"regions\" tag set?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("us-east-1" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_lifecycle(self):
        prompt = "What environments are in the \"Simple\" lifecycle?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Production" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_describe_git_creds(self):
        prompt = "What is the username for the \"GitHub Credentials\" git credentials?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("admin" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", release_version=version)
        prompt = "Get the release version of the latest deployment to the \"Development\" environment for the \"Deploy Web App Container\" project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_runbook_dashboard(self):
        publish_runbook("Simple", "Runbook Project", "Backup Database")
        space_id, space_name = get_space_id_and_name_from_name("Simple", Octopus_Api_Key, Octopus_Url)
        deployment = run_published_runbook_fuzzy(
            space_id,
            "Runbook Project",
            "Backup Database",
            "Development",
            "",
            Octopus_Api_Key,
            Octopus_Url)
        wait_for_task(deployment["TaskId"], space_name="Simple")
        prompt = "Get the runbook dashboard for runbook \"Backup Database\" in the \"Runbook Project\" project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("🔵" in response_text or "🟡" in response_text or "🟢" in response_text
                        or "🔴" in response_text or "⚪" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_runbook_logs(self):
        publish_runbook("Simple", "Runbook Project", "Backup Database")
        space_id, space_name = get_space_id_and_name_from_name("Simple", Octopus_Api_Key, Octopus_Url)
        deployment = run_published_runbook_fuzzy(
            space_id,
            "Runbook Project",
            "Backup Database",
            "Development",
            "",
            Octopus_Api_Key,
            Octopus_Url)
        wait_for_task(deployment["TaskId"], space_name="Simple")
        prompt = "Get the logs from the run of runbook \"Backup Database\" in the \"Runbook Project\" project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("Hello world" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_fuzzy(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", release_version=version)
        prompt = "Get the release version of the latest deployment to the \"Develpment\" environment for the \"Deploy WebApp Container\" project."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_date_range_deployment(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", release_version=version)
        prompt = "Get the release version of the last deployment made to the \"Development\" environment for the \"Deploy Web App Container\" project between 1st January 2024 and 31st December 2099."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_get_channels(self):
        prompt = "List the channels defined in the \"Deploy AWS Lambda\" project in a markdown table."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(re.search("Mainline", response_text), "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_channel(self):
        # Create a release in the Mainline channel against a tenant
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", channel_name="Mainline", project_name="Deploy AWS Lambda",
                                  tenant_name="Marketing", release_version=version)
        # Create another release without a tenant to ensure the query is actually doing a search and not
        # returning the first version it finds
        create_and_deploy_release(space_name="Simple", project_name="Deploy AWS Lambda",
                                  release_version=str(uuid.uuid4()))
        prompt = ("What is the release version of the latest deployment to the \"Development\" environment for the "
                  + "\"Deploy AWS Lambda\" project in the \"Mainline\" channel for the \"Marketing\" tenant?")
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_channel_fuzzy(self):
        # Create a release in the Mainline channel against a tenant
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", channel_name="Mainline", project_name="Deploy AWS Lambda",
                                  tenant_name="Marketing", release_version=version)
        # Create another release without a tenant to ensure the query is actually doing a search and not
        # returning the first version it finds
        create_and_deploy_release(space_name="Simple", project_name="Deploy AWS Lambda",
                                  release_version=str(uuid.uuid4()))
        # The project name is misspelled here deliberately to test the fuzzy matching
        prompt = ("What is the release version of the latest deployment to the \"Development\" environment for the "
                  + "\"Deploy AS Lambda\" project in the \"Mainline\" channel for the \"Marketing\" tenant?")
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_latest_deployment_defaults(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", release_version=version)
        prompt = "What is the release version of the latest deployment?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(version in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_hotfix_deployments(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        deployment = create_and_deploy_release(space_name="Simple", release_version=version + "-hotfix-timeouts-iss253")
        wait_for_task(deployment["TaskId"], space_name="Simple")

        prompt = "When was the last deployment hotfix successfully applied?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue(version + "-hotfix-timeouts-iss253" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError), tries=3, delay=2)
    def test_general_question(self):
        prompt = "What does the project \"Deploy Web App Container\" do?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        # This response could be anything, but make sure the LLM isn't saying sorry for something.
        self.assertTrue("sorry" not in response_text.casefold(), "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_help(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", release_version=version)
        time.sleep(5)

        for prompt in ["what questions can I ask", "help me", "hello", "hi", "what do you do", "what do you do?",
                       "What do you do?"]:
            response = copilot_handler_internal(build_request(prompt))
            response_text = convert_from_sse_response(response.get_body().decode('utf8'))

            self.assertTrue("Here are some sample queries you can ask" in response_text,
                            "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_docs(self):
        for prompt in ["How do I enable server side apply?"]:
            response = copilot_handler_internal(build_request(prompt))
            response_text = convert_from_sse_response(response.get_body().decode('utf8'))

            self.assertTrue("Sorry, I did not understand that request." not in response_text,
                            "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_dashboard(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", release_version=version)
        time.sleep(5)
        prompt = "Show the dashboard."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        # Make sure one of these icons is in the output: 🔵🟡🟢🔴⚪
        self.assertTrue(
            "🔵" in response_text or "🟡" in response_text or "🟢" in response_text
            or "🔴" in response_text or "⚪" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_dashboard_fuzzy_space(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        create_and_deploy_release(space_name="Simple", release_version=version)
        time.sleep(5)
        prompt = "Show the dashboard for space \"Simpleish\"."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        # Make sure one of these icons is in the output: 🔵🟡🟢🔴⚪
        self.assertTrue(
            "🔵" in response_text or "🟡" in response_text or "🟢" in response_text
            or "🔴" in response_text or "⚪" in response_text, "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_logs(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        deployment = create_and_deploy_release(space_name="Simple", release_version=version)
        wait_for_task(deployment["TaskId"], space_name="Simple")

        prompt = "List anything interesting in the deployment logs for the latest deployment."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        self.assertTrue("sorry" not in response_text.casefold(), "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_logs_raw(self):
        version = datetime.now().strftime('%Y%m%d.%H.%M.%S')
        deployment = create_and_deploy_release(space_name="Simple", release_version=version)
        wait_for_task(deployment["TaskId"], space_name="Simple")

        prompt = "Print the last 30 lines of text from the deployment logs of the latest release."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        # The response should have formatted the text as a code block
        self.assertTrue("```" in response_text.casefold(), "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_count_projects(self):
        prompt = "How many projects are there in this space?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        # This should return the one default project (even though there are 3 overall)
        self.assertTrue("1" in response_text.casefold() or "one" in response_text.casefold(),
                        "Response was " + response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_find_retries(self):
        prompt = "What project steps have retries enabled? Provide the response as a JSON object like {\"steps\": [{\"name\": \"Step 1\", \"retries\": false}, {\"name\": \"Step 2\", \"retries\": true}]}."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode('utf8'))

        response_json = json.loads(strip_before_first_curly_bracket(response_text))

        self.assertTrue(next(filter(lambda step: step["name"] == "Run a Script 2", response_json["steps"]))["retries"]),
        self.assertTrue(next(filter(lambda step: step["name"] == "Deploy to IIS", response_json["steps"]))["retries"])
        self.assertFalse(
            next(filter(lambda step: step["name"] == "Configure the load balancer", response_json["steps"]))["retries"])
        # This is a red herring. The step is named "Retry this step" but it doesn't actually have retries enabled.
        self.assertFalse(
            next(filter(lambda step: step["name"] == "Retry this step", response_json["steps"]))["retries"])


if __name__ == '__main__':
    unittest.main()


def build_request(message):
    return func.HttpRequest(
        method='POST',
        body=json.dumps({
            "messages": [
                {
                    "content": message
                }
            ]
        }).encode('utf8'),
        url='/api/form_handler',
        params=None,
        headers={
            "X-GitHub-Token": os.environ["GH_TEST_TOKEN"]
        })


def build_test_request(message):
    """
    Builds a request that directly embeds the API key and server, removing the need to query the GitHub API.
    :param message:
    :return:
    """
    return func.HttpRequest(
        method='POST',
        body=json.dumps({
            "messages": [
                {
                    "content": message
                }
            ]
        }).encode('utf8'),
        url='/api/form_handler',
        params=None,
        headers={
            "X-Octopus-ApiKey": Octopus_Api_Key,
            "X-Octopus-Server": Octopus_Url,
        })
