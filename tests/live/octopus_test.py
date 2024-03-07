import json
import os
import shutil
import subprocess
import tempfile
import time
import unittest

from parameterized import parameterized
from retry import retry
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs

from domain.exceptions.resource_not_found import ResourceNotFound
from domain.exceptions.user_not_loggedin import OctopusApiKeyInvalid
from domain.handlers.copilot_handler import handle_copilot_tools_execution
from domain.logging.app_logging import configure_logging
from domain.transformers.chat_responses import get_deployment_status_base_response, get_octopus_project_names_response
from tests.infrastructure.tools.build_test_tools import build_live_test_tools
from tests.live.create_and_deploy_release import create_and_deploy_release
from tests.live.octopus_config import Octopus_Api_Key

logger = configure_logging()


class LiveRequests(unittest.TestCase):
    """
    This class creates a real Octopus instance with Docker, uses OpenAI to construct the queries,
    and then calls the real Octopus API to get the results. The purpose of these tests is to validate
    that the API interactions with Octopus work as expected.

    The MockRequests class can be used to verify that OpenAI executes the correct function with the correct arguments.
    MockRequests does not require an Octopus instance to be running, and so is a more efficient way to verify
    queries.
    """

    @classmethod
    def setUpClass(cls):
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

        output = run_terraform("../terraform/simple/space_creation", "http://localhost:8080", Octopus_Api_Key)
        run_terraform("../terraform/simple/space_population", "http://localhost:8080", Octopus_Api_Key,
                      json.loads(output)["octopus_space_id"]["value"])
        run_terraform("../terraform/empty/space_creation", "http://localhost:8080", Octopus_Api_Key)

    @classmethod
    def tearDownClass(cls):
        try:
            cls.octopus.stop()
        except Exception as e:
            pass

        try:
            cls.mssql.stop()
        except Exception as e:
            pass

    @parameterized.expand([
        "Simple",
        "simple",
    ])
    def test_get_projects(self, space):
        """
        Tests that we can get a list of projects from Octopus
        """

        function = handle_copilot_tools_execution("What are the projects associated with space " + space + "?",
                                                  build_live_test_tools)

        self.assertEqual(function.function.__name__, "get_octopus_project_names")
        self.assertEqual(function.function_args["space_name"], space)

        space_name, results = function.call_function()
        self.assertIn("Project1", results)
        self.assertIn("Project2", results)
        self.assertEqual("Simple", space_name)

        # Make sure the chat response does not throw an exception with real data
        get_octopus_project_names_response(space_name, results)

    def test_generate_temp_api_key(self):
        """
        Tests that we can create a temporary API key
        """

        function = handle_copilot_tools_execution(
            "Create a temporary API key from the API Key " + Octopus_Api_Key + " and URL http://localhost:8080",
            build_live_test_tools)

        self.assertEqual(function.function.__name__, "set_octopus_details")
        self.assertEqual(function.function_args["octopus_url"], "http://localhost:8080")
        self.assertEqual(function.function_args["api_key"], Octopus_Api_Key)

        results = function.call_function()
        self.assertTrue(str(results).startswith("API-"))

    def test_invalid_api_key(self):
        """
        Tests that we catch bad credentails
        """

        function = handle_copilot_tools_execution(
            "Get the details of the current user with API Key API-XXXXXXXXXXXXXXXXXXXXXX and URL http://localhost:8080",
            build_live_test_tools)

        self.assertEqual(function.function.__name__, "get_octopus_user")
        self.assertEqual(function.function_args["octopus_url"], "http://localhost:8080")
        self.assertEqual(function.function_args["api_key"], "API-XXXXXXXXXXXXXXXXXXXXXX")

        try:
            function.call_function()
            self.fail("Should have thrown an exception")
        except OctopusApiKeyInvalid as e:
            pass

    @retry(AssertionError, tries=3, delay=2)
    def test_get_deployment(self):
        """
        Tests that we return the details of a deployment
        """

        create_and_deploy_release(space_name="Simple")

        function = handle_copilot_tools_execution(
            "Return the status of the latest deployment to the space Simple, environment Development, "
            + "and project Project1 with API Key " + Octopus_Api_Key + " and URL http://localhost:8080",
            build_live_test_tools)

        self.assertEqual(function.function.__name__, "get_deployment_status")
        self.assertEqual(function.function_args["octopus_url"], "http://localhost:8080")
        self.assertEqual(function.function_args["api_key"], Octopus_Api_Key)

        time.sleep(30)

        actual_space_name, actual_environment_name, actual_project_name, deployment = function.call_function()

        self.assertTrue(deployment["State"] == "Executing" or deployment["State"] == "Success")

        # A test that makes sure the response doesn't throw any exceptions with real data
        get_deployment_status_base_response(actual_space_name, actual_environment_name, actual_project_name, deployment)

    def test_get_no_environment(self):
        """
        Tests that we fail appropriately when the environment does not exist
        """

        function = handle_copilot_tools_execution(
            "Return the status of the latest deployment to the space called 'Simple', environment UAT2, "
            + "and project Project1 with API Key " + Octopus_Api_Key + " and URL http://localhost:8080",
            build_live_test_tools)

        self.assertEqual(function.function.__name__, "get_deployment_status")
        self.assertEqual(function.function_args["octopus_url"], "http://localhost:8080")
        self.assertEqual(function.function_args["api_key"], Octopus_Api_Key)
        self.assertEqual(function.function_args["environment_name"], "UAT2")

        with self.assertRaises(ResourceNotFound):
            function.call_function()

    def test_get_no_deployment(self):
        """
        Tests that we fail appropriately in an empty space
        """

        function = handle_copilot_tools_execution(
            "Return the status of the latest deployment to the space called 'Empty Space', environment Development, "
            + "and project Project1 with API Key " + Octopus_Api_Key + " and URL http://localhost:8080",
            build_live_test_tools)

        self.assertEqual(function.function.__name__, "get_deployment_status")
        self.assertEqual(function.function_args["octopus_url"], "http://localhost:8080")
        self.assertEqual(function.function_args["api_key"], Octopus_Api_Key)

        with self.assertRaises(ResourceNotFound):
            function.call_function()

    def test_get_deployment_with_defaults(self):
        """
        Tests that we return the details of a deployment
        """

        create_and_deploy_release(space_name="Simple")

        function = handle_copilot_tools_execution(
            "Return the status of the latest deployment with API Key " + Octopus_Api_Key + " and URL http://localhost:8080",
            build_live_test_tools)

        self.assertEqual(function.function.__name__, "get_deployment_status")
        self.assertEqual(function.function_args["octopus_url"], "http://localhost:8080")
        self.assertEqual(function.function_args["api_key"], Octopus_Api_Key)
        self.assertNotIn("space_name", function.function_args)
        self.assertNotIn("project_name", function.function_args)
        self.assertNotIn("environment_name", function.function_args)

        time.sleep(10)

        actual_space_name, actual_environment_name, actual_project_name, deployment = function.call_function()

        self.assertTrue(deployment["State"] == "Executing" or deployment["State"] == "Success")

        # A test that makes sure the response doesn't throw any exceptions with real data
        get_deployment_status_base_response(actual_space_name, actual_environment_name, actual_project_name, deployment)

    def test_get_dashboard(self):
        """
        Tests that we return the details of a deployment
        """

        create_and_deploy_release(space_name="Simple")

        function = handle_copilot_tools_execution(
            "Get the dashboard from space Simple with API Key " + Octopus_Api_Key + " and URL http://localhost:8080",
            build_live_test_tools)

        dashboard = function.call_function()

        # Make sure something was returned. We aren't trying to validate the Markdown tables here though.
        self.assertTrue(dashboard)


def run_terraform(directory, url, api, space=None):
    with tempfile.TemporaryDirectory() as temp_dir:
        shutil.copytree(os.path.abspath(os.path.join(os.path.dirname(__file__), directory)), temp_dir,
                        dirs_exist_ok=True)
        subprocess.run(["terraform", "init"], check=True, cwd=temp_dir)

        args = ["terraform", "apply", "-auto-approve", "-var=octopus_server=" + url, "-var=octopus_apikey=" + api]
        if space is not None:
            args.append("-var=octopus_space_id=" + space)

        subprocess.run(args, check=True, cwd=temp_dir)
        output = subprocess.run(["terraform", "output", "-json"], check=True, cwd=temp_dir, capture_output=True)
        return output.stdout


if __name__ == '__main__':
    unittest.main()
