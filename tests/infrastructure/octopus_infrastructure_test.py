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
from domain.logging.app_logging import configure_logging
from domain.transformers.chat_responses import get_dashboard_response
from infrastructure.octopus import get_project_progression, get_raw_deployment_process, get_octopus_project_names_base, \
    get_current_user, create_limited_api_key, get_deployment_status_base, get_dashboard, get_deployment_logs, \
    get_item_ignoring_case
from tests.infrastructure.create_and_deploy_release import create_and_deploy_release
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url

logger = configure_logging(__name__)


class LiveRequests(unittest.TestCase):
    """
    This class creates a real Octopus instance with the latest Docker image and then calls the real Octopus API to
    get the results. The purpose of these tests is to validate that the API interactions with Octopus work as expected,
    especially with the ongoing releases of Octopus.

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

        output = run_terraform("../terraform/simple/space_creation", Octopus_Url, Octopus_Api_Key)
        run_terraform("../terraform/simple/space_population", Octopus_Url, Octopus_Api_Key,
                      json.loads(output)["octopus_space_id"]["value"])
        run_terraform("../terraform/empty/space_creation", Octopus_Url, Octopus_Api_Key)

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

        actual_space_name, projects = get_octopus_project_names_base(space,
                                                                     Octopus_Api_Key,
                                                                     Octopus_Url)

        self.assertEqual("Simple", actual_space_name)
        self.assertTrue(len(projects) != 0)

    def test_get_projects_preconditions(self):
        """
        Tests the preconditions work
        """

        with self.assertRaises(ValueError):
            get_octopus_project_names_base("", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_octopus_project_names_base("Simple", "", Octopus_Url)

        with self.assertRaises(ValueError):
            get_octopus_project_names_base("Simple", Octopus_Api_Key, "")

    def test_generate_temp_api_key(self):
        """
        Tests that we can create a temporary API key
        """

        user = get_current_user(Octopus_Api_Key, Octopus_Url)
        api_key = create_limited_api_key(user, Octopus_Api_Key, Octopus_Url)
        self.assertTrue(str(api_key).startswith("API-"))

    def test_generate_temp_api_key_preconditions(self):
        """
        Tests that the preconditions work
        """

        with self.assertRaises(ValueError):
            get_current_user("", Octopus_Url)

        with self.assertRaises(ValueError):
            get_current_user(Octopus_Api_Key, "")

        with self.assertRaises(ValueError):
            create_limited_api_key("", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            create_limited_api_key("MyId", "", Octopus_Url)

        with self.assertRaises(ValueError):
            create_limited_api_key("MyId", Octopus_Api_Key, "")

    def test_invalid_api_key(self):
        """
        Tests that we catch bad credentials
        """

        with self.assertRaises(OctopusApiKeyInvalid):
            get_current_user("API-XXXXXXXXXXXXXXXXXXXXXX", Octopus_Url)

    @retry(AssertionError, tries=3, delay=2)
    def test_get_deployment(self):
        """
        Tests that we return the details of a deployment
        """

        create_and_deploy_release(space_name="Simple")

        time.sleep(30)

        actual_space_name, actual_environment_name, actual_project_name, deployment = (
            get_deployment_status_base("Simple", "Development", "First Test Project", Octopus_Api_Key, Octopus_Url))

        self.assertEqual("Simple", actual_space_name)
        self.assertEqual("Development", actual_environment_name)
        self.assertEqual("First Test Project", actual_project_name)
        self.assertTrue(deployment["State"] == "Executing" or deployment["State"] == "Success")

    @retry(AssertionError, tries=3, delay=2)
    def test_get_deployment_logs(self):
        """
        Tests that we return the details of a deployment
        """

        create_and_deploy_release(space_name="Simple")

        time.sleep(30)

        logs = get_deployment_logs("Simple",
                                   "Project1",
                                   "Development",
                                   "latest",
                                   Octopus_Api_Key,
                                   Octopus_Url)

        self.assertTrue("The deployment completed successfully" in logs)

    def test_get_no_environment(self):
        """
        Tests that we fail appropriately when the environment does not exist
        """

        with self.assertRaises(ResourceNotFound):
            get_deployment_status_base("Simple", "UAT2", "First Test Project", Octopus_Api_Key, Octopus_Url)

    def test_et_deployment_status_preconditions(self):
        """
        Tests preconditions
        """

        with self.assertRaises(ValueError):
            get_deployment_status_base("Simple", "", "First Test Project", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_deployment_status_base("", "UAT", "First Test Project", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_deployment_status_base("Simple", "UAT", "", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_deployment_status_base("Simple", "UAT", "First Test Project", "", Octopus_Url)

        with self.assertRaises(ValueError):
            get_deployment_status_base("Simple", "UAT", "First Test Project", Octopus_Api_Key, "")

    def test_get_dashboard(self):
        """
        Tests that we return the details of a deployment
        """

        create_and_deploy_release(space_name="Simple")

        space_name, dashboard_json = get_dashboard("Simple", Octopus_Api_Key, Octopus_Url)
        dashboard = get_dashboard_response(space_name, dashboard_json)

        # Make sure something was returned. We aren't trying to validate the Markdown tables here though.
        self.assertTrue(dashboard)

    def test_get_dashboard_preconditions(self):
        """
        Tests the preconditions
        """

        with self.assertRaises(ValueError):
            get_dashboard("", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_dashboard("Simple", "", Octopus_Url)

        with self.assertRaises(ValueError):
            get_dashboard("Simple", Octopus_Api_Key, "")

    def test_get_project_progression(self):
        """
        Tests that we return the details of a deployments and releases
        """

        create_and_deploy_release(space_name="Simple")

        json_response = get_project_progression("Simple", "First Test Project", Octopus_Api_Key, Octopus_Url)

        deployment_json = json.loads(json_response)

        # Test the response by verifying the expected resources exist
        self.assertTrue(deployment_json.get("Releases")[0].get("Deployments"))

    def test_get_project_progression_preconditions(self):
        """
        Tests the preconditions
        """

        with self.assertRaises(ValueError):
            get_project_progression("", "First Test Project", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_project_progression("Simple", "", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_project_progression("Simple", "First Test Project", "", Octopus_Url)

        with self.assertRaises(ValueError):
            get_project_progression("Simple", "First Test Project", Octopus_Api_Key, "")

    def test_get_raw_deployment_process(self):
        """
        Tests that we return the details of a deployments and releases
        """

        json_response = get_raw_deployment_process("Simple", "First Test Project", Octopus_Api_Key, Octopus_Url)

        deployment_json = json.loads(json_response)

        # Test the response by verifying the expected resources exist
        self.assertTrue(deployment_json.get("Steps"))

    def test_get_raw_deployment_process_preconditions(self):
        """
        Tests the preconditions
        """

        with self.assertRaises(ValueError):
            get_raw_deployment_process("", "First Test Project", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_raw_deployment_process("Simple", "", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_raw_deployment_process("Simple", "First Test Project", "", Octopus_Url)

        with self.assertRaises(ValueError):
            get_raw_deployment_process("Simple", "First Test Project", Octopus_Api_Key, "")


class UnitTests(unittest.TestCase):
    def test_get_item_ignoring_case(self):
        self.assertEqual("Test", get_item_ignoring_case([{"Name": "Test"}], "test")["Name"])
        self.assertEqual("Test", get_item_ignoring_case([{"Name": "Test"}], "Test")["Name"])
        self.assertEqual("Test", get_item_ignoring_case([{"Name": "test"}, {"Name": "Test"}], "Test")["Name"])
        self.assertEqual("test", get_item_ignoring_case([{"Name": "test"}, {"Name": "Test"}], "test")["Name"])


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
