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

from domain.config.octopus import min_octopus_version
from domain.exceptions.resource_not_found import ResourceNotFound
from domain.exceptions.user_not_loggedin import OctopusApiKeyInvalid
from domain.logging.app_logging import configure_logging
from domain.sanitizers.sanitized_list import sanitize_log_steps
from domain.transformers.deployments_from_dashboard import (
    get_deployments_from_dashboard,
)
from domain.versions.octopus_version import octopus_version_at_least
from domain.view.markdown.markdown_dashboards import get_dashboard_response
from infrastructure.octopus import (
    get_project_progression,
    get_raw_deployment_process,
    get_octopus_project_names_base,
    get_current_user,
    create_limited_api_key,
    get_deployment_status_base,
    get_dashboard,
    get_deployment_logs,
    get_item_fuzzy,
    get_space_id_and_name_from_name,
    activity_logs_to_string,
    get_version,
    run_published_runbook_fuzzy,
    get_runbook_deployment_logs,
    get_projects,
    get_tenants,
    get_feeds,
    get_accounts,
    get_machines,
    get_certificates,
    get_environments,
    get_project_channel,
    get_lifecycle,
    get_tenant,
    get_tenant_fuzzy,
    get_project_fuzzy,
    get_environment,
    get_channel_by_name_fuzzy,
    get_default_channel,
    get_teams,
    get_team,
    handle_manual_intervention_for_task,
    cancel_server_task,
    get_releases_by_version,
    get_project,
    match_deployment_variables,
)
from tests.infrastructure.create_and_deploy_release import (
    create_and_deploy_release,
    wait_for_task,
)
from tests.infrastructure.create_release import create_release
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.publish_runbook import publish_runbook

logger = configure_logging(__name__)


class OctopusAPIRequests(unittest.TestCase):
    """
    Integration tests that verify queries made to the Octopus API continue to work as expected. These tests spin up
    an Octopus instance using the latest version of the Docker image to ensure the tests are always up to date.
    """

    @classmethod
    def setUpClass(cls):
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

    def test_version(self):
        self.assertTrue(
            octopus_version_at_least(get_version(Octopus_Url), min_octopus_version)
        )

    @parameterized.expand(
        [
            "Simple",
            "simple",
        ]
    )
    def test_get_projects(self, space):
        """
        Tests that we can get a list of projects from Octopus
        """

        actual_space_name, projects = get_octopus_project_names_base(
            space, Octopus_Api_Key, Octopus_Url
        )

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

        time.sleep(5)

        actual_space_name, actual_environment_name, actual_project_name, deployment = (
            get_deployment_status_base(
                "Simple",
                "Development",
                "Deploy Web App Container",
                Octopus_Api_Key,
                Octopus_Url,
            )
        )

        self.assertEqual("Simple", actual_space_name)
        self.assertEqual("Development", actual_environment_name)
        self.assertEqual("Deploy Web App Container", actual_project_name)
        self.assertTrue(
            deployment["State"] == "Executing"
            or deployment["State"] == "Success"
            or deployment["State"] == "Queued"
        )

    @retry(AssertionError, tries=3, delay=2)
    def test_get_deployment_logs(self):
        """
        Tests that we return the details of a deployment
        """

        deployment = create_and_deploy_release(space_name="Simple")
        wait_for_task(deployment["TaskId"], space_name="Simple")

        _, activity_logs, actual_release_version = get_deployment_logs(
            "Simple",
            "Deploy Web App Container",
            "Development",
            None,
            "latest",
            Octopus_Api_Key,
            Octopus_Url,
        )

        logs = activity_logs_to_string(activity_logs, None)

        self.assertTrue("The deployment completed successfully" in logs)

    @retry(AssertionError, tries=3, delay=2)
    def test_get_runbook_logs(self):
        """
        Tests that we return the details of a deployment
        """
        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        publish_runbook("Simple", "Copilot Test Runbook Project", "Backup Database")
        task = run_published_runbook_fuzzy(
            space_id,
            "Copilot Test Runbook Project",
            "Backup Database",
            "Development",
            tenant_name="",
            variables=None,
            my_api_key=Octopus_Api_Key,
            my_octopus_api=Octopus_Url,
        )
        wait_for_task(task["TaskId"], space_name="Simple")

        _, activity_logs = get_runbook_deployment_logs(
            "Simple",
            "Copilot Test Runbook Project",
            "Backup Database",
            "Development",
            None,
            Octopus_Api_Key,
            Octopus_Url,
        )

        logs = activity_logs_to_string(activity_logs, None)

        self.assertTrue("Hello world" in logs, "Response was " + logs)

    def test_get_no_environment(self):
        """
        Tests that we fail appropriately when the environment does not exist
        """

        with self.assertRaises(ResourceNotFound):
            get_deployment_status_base(
                "Simple",
                "UAT2",
                "Deploy Web App Container",
                Octopus_Api_Key,
                Octopus_Url,
            )

    def test_get_dashboard_releases(self):
        """
        Tests that we can get the releases from a dashboard
        """

        create_and_deploy_release(space_name="Simple")

        time.sleep(5)

        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        deployments = get_deployments_from_dashboard(
            space_id, Octopus_Api_Key, Octopus_Url
        )

        self.assertTrue(len(deployments["Deployments"]) > 0)

    def test_get_deployment_status_preconditions(self):
        """
        Tests preconditions
        """

        with self.assertRaises(ValueError):
            get_deployment_status_base(
                "Simple", "", "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_deployment_status_base(
                "", "UAT", "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_deployment_status_base(
                "Simple", "UAT", "", Octopus_Api_Key, Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_deployment_status_base(
                "Simple", "UAT", "Deploy Web App Container", "", Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_deployment_status_base(
                "Simple", "UAT", "Deploy Web App Container", Octopus_Api_Key, ""
            )

    def test_get_dashboard(self):
        """
        Tests that we return the details of a deployment
        """

        create_and_deploy_release(space_name="Simple")

        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        dashboard_json = get_dashboard(space_id, Octopus_Api_Key, Octopus_Url)
        dashboard = get_dashboard_response(
            Octopus_Url, space_id, actual_space_name, dashboard_json
        )

        # Make sure something was returned. We aren't trying to validate the Markdown tables here though.
        self.assertTrue(dashboard)

    def test_get_all_projects(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        projects = get_projects(space_id, Octopus_Api_Key, Octopus_Url)

        self.assertTrue(
            any(filter(lambda x: x["Name"] == "Deploy Web App Container", projects))
        )

    def test_get_projects_fuzzy(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        project = get_project_fuzzy(
            space_id, "Deploy Web App Containerish", Octopus_Api_Key, Octopus_Url
        )
        self.assertEqual(project["Name"], "Deploy Web App Container")

        project = get_project_fuzzy(
            space_id, "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
        )
        self.assertEqual(project["Name"], "Deploy Web App Container")

    def test_get_all_tenants(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        tenants = get_tenants(Octopus_Api_Key, Octopus_Url, space_id)

        self.assertTrue(any(filter(lambda x: x["Name"] == "Marketing", tenants)))

        tenant = get_tenant(
            space_id,
            next(filter(lambda x: x["Name"] == "Marketing", tenants))["Id"],
            Octopus_Api_Key,
            Octopus_Url,
        )

        self.assertEqual(tenant["Name"], "Marketing")

    def test_get_tenant_fuzzy(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        tenant = get_tenant_fuzzy(space_id, "Marketing", Octopus_Api_Key, Octopus_Url)
        self.assertEqual(tenant["Name"], "Marketing")

        tenant = get_tenant_fuzzy(
            space_id, "Marketingish", Octopus_Api_Key, Octopus_Url
        )
        self.assertEqual(tenant["Name"], "Marketing")

    def test_get_all_feeds(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        feeds = get_feeds(Octopus_Api_Key, Octopus_Url, space_id)

        self.assertTrue(any(filter(lambda x: x["Name"] == "Helm", feeds)))

    def test_get_all_accounts(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        accounts = get_accounts(Octopus_Api_Key, Octopus_Url, space_id)

        self.assertTrue(any(filter(lambda x: x["Name"] == "AWS Account", accounts)))

    def test_get_all_machines(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        machines = get_machines(Octopus_Api_Key, Octopus_Url, space_id)

        self.assertTrue(
            any(filter(lambda x: x["Name"] == "Cloud Region Target", machines))
        )

    def test_get_all_certificates(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        certificates = get_certificates(Octopus_Api_Key, Octopus_Url, space_id)

        self.assertTrue(any(filter(lambda x: x["Name"] == "Kind CA", certificates)))

    def test_get_all_environments(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )

        environments = get_environments(Octopus_Api_Key, Octopus_Url, space_id)
        self.assertTrue(any(filter(lambda x: x["Name"] == "Development", environments)))

        environment = get_environment(
            space_id,
            next(filter(lambda x: x["Name"] == "Development", environments))["Id"],
            Octopus_Api_Key,
            Octopus_Url,
        )
        self.assertEqual(environment["Name"], "Development")

    def test_get_lifecycles(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        projects = get_projects(space_id, Octopus_Api_Key, Octopus_Url)
        project = next(filter(lambda x: x["Name"] == "Deploy AWS Lambda", projects))
        lifecycle = get_lifecycle(
            Octopus_Api_Key, Octopus_Url, space_id, project["LifecycleId"]
        )

        self.assertTrue(lifecycle["Name"] == "Application")

    def test_get_all_project_channels(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        projects = get_projects(space_id, Octopus_Api_Key, Octopus_Url)
        project = next(filter(lambda x: x["Name"] == "Deploy AWS Lambda", projects))

        channels = get_project_channel(
            Octopus_Api_Key, Octopus_Url, space_id, project["Id"]
        )

        self.assertTrue(any(filter(lambda x: x["Name"] == "Mainline", channels)))

    def test_get_channel_by_name(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        projects = get_projects(space_id, Octopus_Api_Key, Octopus_Url)
        project = next(
            filter(lambda x: x["Name"] == "Deploy Web App Container", projects)
        )

        channel = get_channel_by_name_fuzzy(
            space_id, project["Id"], "Hotfix", Octopus_Api_Key, Octopus_Url
        )
        self.assertTrue(channel["Name"] == "Hotfix")

    def test_get_default_channel(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        projects = get_projects(space_id, Octopus_Api_Key, Octopus_Url)
        project = next(
            filter(lambda x: x["Name"] == "Deploy Web App Container", projects)
        )

        channel = get_default_channel(
            space_id, project["Id"], Octopus_Api_Key, Octopus_Url
        )
        self.assertTrue(channel["IsDefault"])

    def test_get_dashboard_preconditions(self):
        """
        Tests the preconditions
        """

        with self.assertRaises(ValueError):
            get_dashboard("", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_dashboard("Spaces-1", "", Octopus_Url)

        with self.assertRaises(ValueError):
            get_dashboard("Spaces-1", Octopus_Api_Key, "")

    def test_get_project_progression(self):
        """
        Tests that we return the details of a deployments and releases
        """

        create_and_deploy_release(space_name="Simple")

        deployment_json = get_project_progression(
            "Simple", "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
        )

        # Test the response by verifying the expected resources exist
        self.assertTrue(deployment_json.get("Releases")[0].get("Deployments"))

    def test_log_filtering(self):
        """
        Tests that we return the details of a deployments and releases
        """

        deployment = create_and_deploy_release(space_name="Simple")
        wait_for_task(deployment["TaskId"], space_name="Simple")

        _, activity_logs, actual_release_version = get_deployment_logs(
            "Simple",
            "Deploy Web App Container",
            "Development",
            None,
            "latest",
            Octopus_Api_Key,
            Octopus_Url,
        )

        # Limit to the first step
        sanitized_logs = sanitize_log_steps(
            ["Configure the load balancer"],
            'Get the logs from step "Configure the load balancer" from the latest deployment',
            activity_logs,
        )
        logs1 = activity_logs_to_string(activity_logs, sanitized_logs)
        self.assertTrue("Step One" in logs1)
        self.assertTrue("Step Two" not in logs1)

        # Limit to the second step
        sanitized_logs = sanitize_log_steps(
            ["Retry this step"],
            'Get the logs from step "Retry this step" from the latest deployment',
            activity_logs,
        )
        logs2 = activity_logs_to_string(activity_logs, sanitized_logs)
        self.assertTrue("Step One" not in logs2)
        self.assertTrue("Step Two" in logs2)

    def test_get_project_progression_preconditions(self):
        """
        Tests the preconditions
        """

        with self.assertRaises(ValueError):
            get_project_progression(
                "", "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_project_progression("Simple", "", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_project_progression(
                "Simple", "Deploy Web App Container", "", Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_project_progression(
                "Simple", "Deploy Web App Container", Octopus_Api_Key, ""
            )

    def test_get_raw_deployment_process(self):
        """
        Tests that we return the details of a deployments and releases
        """

        json_response = get_raw_deployment_process(
            "Simple", "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
        )

        deployment_json = json.loads(json_response)

        # Test the response by verifying the expected resources exist
        self.assertTrue(deployment_json.get("Steps"))

    def test_get_raw_deployment_process_preconditions(self):
        """
        Tests the preconditions
        """

        with self.assertRaises(ValueError):
            get_raw_deployment_process(
                "", "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_raw_deployment_process("Simple", "", Octopus_Api_Key, Octopus_Url)

        with self.assertRaises(ValueError):
            get_raw_deployment_process(
                "Simple", "Deploy Web App Container", "", Octopus_Url
            )

        with self.assertRaises(ValueError):
            get_raw_deployment_process(
                "Simple", "Deploy Web App Container", Octopus_Api_Key, ""
            )

    def test_get_all_teams(self):
        space_id, actual_space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        teams = get_teams(space_id, Octopus_Api_Key, Octopus_Url)
        self.assertTrue(any(filter(lambda x: x["Name"] == "Simple team", teams)))

        team = get_team(
            next(filter(lambda x: x["Name"] == "Simple team", teams))["Id"],
            Octopus_Api_Key,
            Octopus_Url,
        )
        self.assertEqual(team["Name"], "Simple team")

    def test_handle_manual_intervention_for_task_validates_operation(self):
        """
        Tests that the function handling manual interventions throws an error if an invalid interruption_action is provided.
        """
        with self.assertRaises(ValueError):
            handle_manual_intervention_for_task(
                space_id="Spaces-1",
                project_id="Projects-1",
                release_version="0.0.1",
                environment_name="Development",
                tenant_name="TenantName",
                task_id="ServerTasks-1234",
                interruption_action="InvalidOption",
                my_api_key="API-XXXX",
                my_octopus_api="http://localhost:8080",
            )

    def test_cancel_task(self):
        deployment = create_and_deploy_release(space_name="Simple")
        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        cancel_response = cancel_server_task(
            space_id, deployment["TaskId"], Octopus_Api_Key, Octopus_Url
        )
        self.assertTrue(cancel_response["Id"] == deployment["TaskId"])
        self.assertTrue(cancel_response["State"] in ["Canceled", "Cancelling"])

    def test_get_releases_by_version(self):
        create_release(space_name="Simple", release_version="1.0.0")
        create_release(space_name="Simple", release_version="1.1.0")
        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        project = get_project(
            space_id, "Deploy Web App Container", Octopus_Api_Key, Octopus_Url
        )

        # Check both releases are returned.
        releases = get_releases_by_version(
            space_id, project["Id"], "1.", Octopus_Api_Key, Octopus_Url
        )
        self.assertEqual(2, len(releases))

        # Check no matches returned
        non_matching_releases = get_releases_by_version(
            space_id, project["Id"], "0.0.12", Octopus_Api_Key, Octopus_Url
        )
        self.assertIsNone(non_matching_releases)

    def test_match_deployment_variables_handles_json_variable_string(self):
        space_id, space_name = get_space_id_and_name_from_name(
            "Simple", Octopus_Api_Key, Octopus_Url
        )
        release = create_release(
            space_name="Simple",
            release_version="1.0.0",
            project_name="Prompted Variable Project",
        )
        environments = get_environments(Octopus_Api_Key, Octopus_Url, space_id)
        environment = next(filter(lambda x: x["Name"] == "Development", environments))
        variables = '{"slot": "Staging", "notify": "true", "extraVar1": "extraValue1", "extraVar2": "extraValue2"}'
        matching_variables, warning_message = match_deployment_variables(
            space_id,
            release["Id"],
            environment["Id"],
            variables,
            Octopus_Api_Key,
            Octopus_Url,
        )
        self.assertIsNotNone(matching_variables)
        self.assertTrue(
            f"Extra variables were found: extraVar1, extraVar2. These will be ignored."
            in warning_message,
            "Response was " + warning_message,
        )


class UnitTests(unittest.TestCase):
    def test_get_item_ignoring_case(self):
        self.assertEqual("Test", get_item_fuzzy([{"Name": "Test"}], "test")["Name"])
        self.assertEqual("Test", get_item_fuzzy([{"Name": "Test"}], "Test")["Name"])
        self.assertEqual(
            "Test", get_item_fuzzy([{"Name": "test"}, {"Name": "Test"}], "Test")["Name"]
        )
        self.assertEqual(
            "test", get_item_fuzzy([{"Name": "test"}, {"Name": "Test"}], "test")["Name"]
        )


def run_terraform(directory, url, api, space=None):
    with tempfile.TemporaryDirectory() as temp_dir:
        shutil.copytree(
            os.path.abspath(os.path.join(os.path.dirname(__file__), directory)),
            temp_dir,
            dirs_exist_ok=True,
        )
        subprocess.run(["terraform", "init"], check=True, cwd=temp_dir)

        args = [
            "terraform",
            "apply",
            "-auto-approve",
            "-var=octopus_server=" + url,
            "-var=octopus_apikey=" + api,
        ]
        if space is not None:
            args.append("-var=octopus_space_id=" + space)

        subprocess.run(args, check=True, cwd=temp_dir)
        output = subprocess.run(
            ["terraform", "output", "-json"],
            check=True,
            cwd=temp_dir,
            capture_output=True,
        )
        return output.stdout


if __name__ == "__main__":
    unittest.main()
