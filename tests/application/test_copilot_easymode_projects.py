import glob
import json
import os
import time
import unittest
import uuid
from unittest import skip

import azure.functions as func
import pytest
from openai import RateLimitError
from retry import retry
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs

from domain.transformers.sse_transformers import (
    convert_from_sse_response,
    get_confirmation_id,
)
from domain.url.build_url import build_url
from function_app import copilot_handler_internal
from infrastructure.http_pool import http, TAKE_ALL
from infrastructure.octopus import (
    get_accounts,
    get_environments,
    get_feeds,
    get_machines,
    get_project_channel,
    get_raw_deployment_process,
    get_runbook_fuzzy,
    get_space_id_and_name_from_name,
    get_tenants,
    handle_response,
    sync_community_step_templates,
)
from infrastructure.terraform_context import save_terraform_context
from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.test_octopus_infrastructure import run_terraform

# When OCTOPUS_TEST_REMOTE is "Y" or "TRUE", tests run against a remote Octopus instance
# identified by OCTOPUS_CLI_SERVER and OCTOPUS_CLI_API_KEY. A temporary space with a random
# name is created and deleted around the test run.
Remote_Test = os.environ.get("OCTOPUS_TEST_REMOTE", "").upper() in ("Y", "TRUE")
Remote_Octopus_Url = os.environ.get("OCTOPUS_CLI_SERVER", "")
Remote_Octopus_Api_Key = os.environ.get("OCTOPUS_CLI_API_KEY", "")
Space_Manager_Team = os.environ.get("OCTOPUS_SPACE_MANAGER_TEAM", "")

# The space the prompts are run against. When running remotely, a random space name is
# generated to avoid collisions. When running locally, the space created by terraform is used.
Space_Name = "Simple"

# The Octopus Server and SQL Server images are only published for linux/amd64, so the platform
# is requested explicitly. This is a no-op on amd64 hosts, and lets the containers run under
# emulation on hosts with a different architecture.
Container_Platform = "linux/amd64"


class EasyModeTestBase(unittest.TestCase):
    """
    Base class that manages the Octopus Deploy test infrastructure.

    Handles starting and stopping Docker containers (or creating a remote space) around the
    test run, populating blob storage with Terraform context files, and saving user details.
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
            cls._remote_space_name = space_name

            sync_community_step_templates(
                Remote_Octopus_Api_Key, Remote_Octopus_Url
            )
        else:
            cls._remote_space_id = None
            cls._remote_space_name = None

            try:
                terraform_dir = "../terraform/"

                cls.mssql = (
                    DockerContainer("mcr.microsoft.com/mssql/server:2022-latest")
                    .with_kwargs(platform=Container_Platform)
                    .with_env("ACCEPT_EULA", "True")
                    .with_env("SA_PASSWORD", "Password01!")
                )
                cls.mssql.start()
                wait_for_logs(cls.mssql, "SQL Server is now ready for client connections")

                mssql_ip = get_container_ip(cls.mssql)

                cls.octopus = (
                    DockerContainer("octopusdeploy/octopusdeploy")
                    .with_kwargs(platform=Container_Platform)
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
                wait_for_octopus()

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
        # The user details are saved again before each test, because a long running test class can
        # otherwise reach a point where the details are no longer resolved and the assistant
        # responds by asking the user to log in again.
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


@pytest.mark.split_group("group8")
class EasyModeTest(EasyModeTestBase):
    """
    End-to-end tests that verify the projects documented in the Octopus Easy Mode blog series
    (https://octopus.com/blog/easymode) are created as expected by the AI Assistant.

    This class contains tests 01–10.

    Each test runs one of the copy-and-paste prompts published in the series and verifies that
    the resources described by that post are created.

    The prompts are reproduced verbatim from the blog posts, with the space appended so the
    assistant does not have to guess which space to build in. The assertions deliberately focus
    on the resources the prompt explicitly asks for, because names and scripts invented by the
    LLM (step names, generated scripts, tenant names) vary between runs.
    """

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_01_basic_script_app(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-01-script
        """

        project_name = "01. Basic Script App"
        run_prompt(self, f'Create a Script project called "{project_name}".')

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # The project is backed by a lifecycle progressing through the environments.
        lifecycle = get_lifecycle_by_id(space_id, project["LifecycleId"])
        phase_environments = [
            get_environment_names(space_id, get_phase_environments(phase))
            for phase in lifecycle["Phases"]
        ]
        self.assertTrue(
            ["Development"] in phase_environments,
            f"The lifecycle should have a phase targeting Development. It has: {phase_environments}",
        )
        self.assertTrue(
            ["Production"] in phase_environments,
            f"The lifecycle should have a phase targeting Production. It has: {phase_environments}",
        )

        # The deployment process has a single script step printing a message.
        steps = get_deployment_process_steps(space_name, project_name)
        self.assertEqual(
            1, len(steps), f"The deployment process should have one step. It has: {steps}"
        )
        self.assertEqual("Octopus.Script", get_action_type(steps[0]))

        # Release versioning is based on the date the release was created.
        versioning_template = project["VersioningStrategy"]["Template"]
        self.assertTrue(
            "Octopus.Date" in versioning_template,
            f"Release versioning should be date based. It is: {versioning_template}",
        )

        # A worker pool variable defines the pool used by the script step.
        variables = get_project_variables(project)
        self.assertTrue(
            any(variable["Type"] == "WorkerPool" for variable in variables),
            f"The project should have a worker pool variable. It has: {variable_names(variables)}",
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_02_environment_variables(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-02-variables
        """

        project_name = "02. Script App with Environment Vars"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Add three project variables called "Message", each scoped to an environment, with the following values:
  * Development: "Hello from Development!"
  * Test: "Hello from Testing!"
  * Production: "Hello from Production!"
* Update the script step to echo the "Message" variable using the syntax "#{{Message}}\"""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # Three variables called "Message", each scoped to a single environment.
        variables = get_project_variables(project)
        messages = [
            variable for variable in variables if variable["Name"] == "Message"
        ]
        self.assertEqual(
            3,
            len(messages),
            f'The project should have three variables called "Message". It has: {variable_names(variables)}',
        )

        scoped_values = {}
        for message in messages:
            environments = get_environment_names(
                space_id, message["Scope"].get("Environment", [])
            )
            self.assertEqual(
                1,
                len(environments),
                f'The "Message" variable should be scoped to a single environment. It is scoped to: {environments}',
            )
            scoped_values[environments[0]] = message["Value"]

        self.assertEqual("Hello from Development!", scoped_values.get("Development"))
        self.assertEqual("Hello from Testing!", scoped_values.get("Test"))
        self.assertEqual("Hello from Production!", scoped_values.get("Production"))

        # The script step echoes the variable.
        steps = get_deployment_process_steps(space_name, project_name)
        scripts = get_scripts(steps)
        self.assertTrue(
            any("#{Message}" in script for script in scripts),
            f'A script step should reference "#{{Message}}". The scripts are: {scripts}',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_03_manual_intervention(self):
        """
        Verifies the project created by
        https://octopus.com/blog/octo-easy-mode-03-manual-intervention
        """

        project_name = "03. Script App with Manual Intervention"
        instructions = "Please approve deployment to Production"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Add a manual intervention step as the first step in the deployment process, scoped to the Production environment only, with the instruction "{instructions}".""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        steps = get_deployment_process_steps(space_name, project_name)
        self.assertEqual(
            2,
            len(steps),
            f"The deployment process should have two steps. It has: {step_names(steps)}",
        )

        # The manual intervention is the first step, and only runs in Production.
        manual_step = steps[0]
        self.assertEqual(
            "Octopus.Manual",
            get_action_type(manual_step),
            f"The first step should be a manual intervention. It is: {step_names(steps)}",
        )
        manual_action = manual_step["Actions"][0]
        environments = get_environment_names(space_id, manual_action["Environments"])
        self.assertEqual(
            ["Production"],
            environments,
            f"The manual intervention should only run in Production. It runs in: {environments}",
        )
        self.assertEqual(
            instructions,
            manual_action["Properties"].get("Octopus.Action.Manual.Instructions"),
        )

        # The script step is retained after the manual intervention.
        self.assertEqual("Octopus.Script", get_action_type(steps[1]))

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_04_retries(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-04-retry
        """

        project_name = "04. Script App with Retries"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Enable retries on the script step.
* Replace the script with one that randomly fails by returning a non-zero exit code 50% of the time.
* Do not create a placeholder script.""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        steps = get_deployment_process_steps(space_name, project_name)
        script_steps = [
            step for step in steps if get_action_type(step) == "Octopus.Script"
        ]
        self.assertTrue(
            script_steps,
            f"The deployment process should have a script step. It has: {step_names(steps)}",
        )

        # Retries are enabled on the script step. The number of retries is chosen by the LLM.
        retries = [
            step["Actions"][0]["Properties"].get(
                "Octopus.Action.AutoRetry.MaximumCount"
            )
            for step in script_steps
        ]
        self.assertTrue(
            any(retry_count and int(retry_count) > 0 for retry_count in retries),
            f"Retries should be enabled on the script step. The retry counts are: {retries}",
        )

        # The script exits with a non-zero exit code some of the time. The script itself is
        # generated by the LLM, so only the failure path is verified.
        scripts = get_scripts(steps)
        self.assertTrue(
            any("exit 1" in script.lower() for script in scripts),
            f"A script step should be able to fail. The scripts are: {scripts}",
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_05_build_information(self):
        """
        Verifies the project created by
        https://octopus.com/blog/octo-easy-mode-05-build-information
        """

        project_name = "05. Script App with Build Information"
        feed_name = "Octopus Maven Feed"
        feed_uri = "https://octopus-sales-public-maven-repo.s3.ap-southeast-2.amazonaws.com/snapshot"
        package_id = "com.octopus:octopub-frontend"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Add a Maven feed called "{feed_name}" pointing to {feed_uri} with anonymous authentication
* Add a reference package to the script step from the Maven feed "{feed_name}" with the package ID "{package_id}\"""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # An anonymous Maven feed pointing at the public Octopus repository.
        feeds = get_space_collection(space_id, "Feeds")
        feed = find_by_name(feeds, feed_name)
        self.assertIsNotNone(
            feed,
            f'There should be a feed called "{feed_name}". The feeds are: {names(feeds)}',
        )
        self.assertEqual("Maven", feed["FeedType"])
        self.assertEqual(feed_uri, feed["FeedUri"])
        self.assertFalse(
            feed.get("Username"),
            f"The feed should use anonymous authentication. The username is: {feed.get('Username')}",
        )

        # The script step consumes a package from the new feed.
        steps = get_deployment_process_steps(space_name, project_name)
        packages = [
            package
            for step in steps
            for action in step["Actions"]
            for package in action.get("Packages", [])
        ]
        self.assertTrue(
            any(
                package["PackageId"] == package_id
                and package["FeedId"] == feed["Id"]
                for package in packages
            ),
            f'A step should reference "{package_id}" from the new feed. The packages are: {packages}',
        )

    @skip("This test is flaky")
    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_06_tenants(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-06-tenants
        """

        project_name = "06. Script App with Tenants"
        tag_set_name = "Region"
        tags = ["AMEA", "EMEA", "APAC"]
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Add 5 tenants named after major capital cities in the world
* Add a tenant tag called "{tag_set_name}" with values "{tags[0]}", "{tags[1]}", and "{tags[2]}"
* Assign the appropriate tag to each tenant based on their location
* Link the tenants to the project
* Require a tenant for deployments of the project. Do not support untenanted deployments.""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # Deployments require a tenant to be selected.
        self.assertEqual("Tenanted", project["TenantedDeploymentMode"])

        # A tag set holding the three regions.
        tag_sets = get_space_collection(space_id, "TagSets")
        tag_set = find_by_name(tag_sets, tag_set_name)
        self.assertIsNotNone(
            tag_set,
            f'There should be a tag set called "{tag_set_name}". The tag sets are: {names(tag_sets)}',
        )
        self.assertEqual(sorted(tags), sorted(names(tag_set["Tags"])))

        # Five tenants are linked to the project. The tenants are named by the LLM, so only the
        # number of tenants and the tags assigned to them are verified.
        tenants = get_tenants(get_active_api_key(), get_active_octopus_url(), space_id)
        linked_tenants = [
            tenant
            for tenant in tenants
            if project["Id"] in tenant.get("ProjectEnvironments", {})
        ]
        self.assertEqual(
            5,
            len(linked_tenants),
            f"Five tenants should be linked to the project. The linked tenants are: {names(linked_tenants)}",
        )

        for tenant in linked_tenants:
            tenant_tags = [
                tag for tag in tenant["TenantTags"] if tag.startswith(f"{tag_set_name}/")
            ]
            self.assertTrue(
                tenant_tags,
                f'The tenant "{tenant["Name"]}" should have a "{tag_set_name}" tag. It has: {tenant["TenantTags"]}',
            )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_07_runbooks(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-07-runbooks
        """

        project_name = "07. Script App with Runbooks"
        runbook_names = [
            "Backup Database",
            "Restore Database",
            "Restart Web App",
            "Clear Cache",
        ]
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Add runbooks called "{runbook_names[0]}", "{runbook_names[1]}", "{runbook_names[2]}", and "{runbook_names[3]}"
* Each runbook should have a single script step that echoes the name of the runbook being run
* Each runbook must only be run in the "Production" environment""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        for runbook_name in runbook_names:
            runbook = get_runbook_fuzzy(
                space_id, project["Id"], runbook_name, get_active_api_key(), get_active_octopus_url()
            )
            self.assertEqual(runbook_name, runbook["Name"])

            # The runbook is restricted to the Production environment.
            self.assertEqual("Specified", runbook["EnvironmentScope"])
            environments = get_environment_names(space_id, runbook["Environments"])
            self.assertEqual(
                ["Production"],
                environments,
                f'The runbook "{runbook_name}" should only run in Production. It runs in: {environments}',
            )

            # A single script step echoing the name of the runbook.
            steps = get_runbook_process_steps(space_id, runbook)
            self.assertEqual(
                1,
                len(steps),
                f'The runbook "{runbook_name}" should have one step. It has: {step_names(steps)}',
            )
            self.assertEqual("Octopus.Script", get_action_type(steps[0]))
            scripts = get_scripts(steps)
            self.assertTrue(
                any(runbook_name in script for script in scripts),
                f'The runbook "{runbook_name}" should echo its name. The scripts are: {scripts}',
            )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_08_library_variable_set(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-08-lvs
        """

        project_name = "08. Script App with Library Variable Set"
        variable_set_name = "Common Settings"
        connection_string = (
            "Server=myServer;Database=myDB;User Id=myUser;Password=myPass;"
        )
        api_endpoint = "https://api.example.com"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Create a library variable set called "{variable_set_name}" with the following variables:
  * "ConnectionString" with the value "{connection_string}"
  * "ApiEndpoint" with the value "{api_endpoint}"
* Link the library variable set to the project
* Change the script step to echo the values of the variables using the syntax "#{{ConnectionString}}" and "#{{ApiEndpoint}}\"""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # A library variable set holding the two shared settings.
        variable_sets = get_space_collection(space_id, "LibraryVariableSets")
        variable_set = find_by_name(variable_sets, variable_set_name)
        self.assertIsNotNone(
            variable_set,
            f'There should be a library variable set called "{variable_set_name}". '
            f"The library variable sets are: {names(variable_sets)}",
        )

        variables = get_variable_set_variables(space_id, variable_set["VariableSetId"])
        values = {variable["Name"]: variable["Value"] for variable in variables}
        self.assertEqual(connection_string, values.get("ConnectionString"))
        self.assertEqual(api_endpoint, values.get("ApiEndpoint"))

        # The library variable set is linked to the project.
        self.assertIn(
            variable_set["Id"],
            project["IncludedLibraryVariableSetIds"],
            f'The project should include the "{variable_set_name}" library variable set.',
        )

        # The script step echoes both variables.
        steps = get_deployment_process_steps(space_name, project_name)
        scripts = get_scripts(steps)
        for binding in ["#{ConnectionString}", "#{ApiEndpoint}"]:
            self.assertTrue(
                any(binding in script for script in scripts),
                f'A script step should reference "{binding}". The scripts are: {scripts}',
            )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_09_tenant_templates(self):
        """
        Verifies the project created by
        https://octopus.com/blog/octo-easy-mode-09-tenant-templates
        """

        project_name = (
            "09. Script App with Library Variable Set and Tenant Templates"
        )
        variable_set_name = "Tenant Settings"
        template_name = "TenantNamespace"
        tenant_values = {"Tenant A": "TenantA", "Tenant B": "TenantB"}
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Create a library variable set called "{variable_set_name}" with the variable "{template_name}" as a tenant template variable
* Link the library variable set to the project
* Create two tenants called "Tenant A" and "Tenant B"
* Link the tenants to the project
* Define the "{template_name}" tenant template variable for each tenant with a value of "TenantA" and "TenantB", respectively
* Change the script step to echo the values of the variables using the syntax "#{{{template_name}}}"
* Require tenanted deployments for the project. Do not allow untenanted deployments.""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)
        self.assertEqual("Tenanted", project["TenantedDeploymentMode"])

        # The library variable set defines the tenant template, and is linked to the project.
        variable_sets = get_space_collection(space_id, "LibraryVariableSets")
        variable_set = find_by_name(variable_sets, variable_set_name)
        self.assertIsNotNone(
            variable_set,
            f'There should be a library variable set called "{variable_set_name}". '
            f"The library variable sets are: {names(variable_sets)}",
        )
        self.assertIn(variable_set["Id"], project["IncludedLibraryVariableSetIds"])

        templates = get_resource(
            f"/api/{space_id}/LibraryVariableSets/{variable_set['Id']}"
        )["Templates"]
        self.assertTrue(
            any(template["Name"] == template_name for template in templates),
            f'The library variable set should define a "{template_name}" template. '
            f"It defines: {names(templates)}",
        )

        # Each tenant is linked to the project and supplies its own value for the template.
        tenants = get_tenants(get_active_api_key(), get_active_octopus_url(), space_id)
        for tenant_name, expected_value in tenant_values.items():
            tenant = find_by_name(tenants, tenant_name)
            self.assertIsNotNone(
                tenant,
                f'There should be a tenant called "{tenant_name}". The tenants are: {names(tenants)}',
            )
            self.assertIn(
                project["Id"],
                tenant["ProjectEnvironments"],
                f'The tenant "{tenant_name}" should be linked to the project.',
            )
            self.assertEqual(
                expected_value,
                get_tenant_template_value(
                    space_id, tenant, variable_set["Id"], template_name
                ),
                f'The tenant "{tenant_name}" should define "{template_name}" as "{expected_value}".',
            )

        # The script step echoes the tenant template variable.
        steps = get_deployment_process_steps(space_name, project_name)
        scripts = get_scripts(steps)
        self.assertTrue(
            any(f"#{{{template_name}}}" in script for script in scripts),
            f'A script step should reference "#{{{template_name}}}". The scripts are: {scripts}',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_10_project_tenant_variables(self):
        """
        Verifies the project created by
        https://octopus.com/blog/octo-easy-mode-10-project-templates
        """

        project_name = (
            "10. Script App with Library Variable Set and Project Tenant Variables"
        )
        template_name = "TenantNamespace"
        tenant_values = {"Tenant C": "TenantC", "Tenant D": "TenantD"}
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Create a project tenant variable called "{template_name}"
* Change the script step to echo the values of the variables using the syntax "#{{{template_name}}}"
* Create two tenants called "Tenant C" and "Tenant D"
* Link the tenants to the project
* Define the "{template_name}" project tenant variable for each tenant set to "TenantC" and "TenantD" respectively
* Require tenanted deployments for the project. Do not allow untenanted deployments.""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)
        self.assertEqual("Tenanted", project["TenantedDeploymentMode"])

        # The tenant variable is defined directly on the project rather than in a library
        # variable set.
        self.assertTrue(
            any(
                template["Name"] == template_name for template in project["Templates"]
            ),
            f'The project should define a "{template_name}" tenant variable. '
            f"It defines: {names(project['Templates'])}",
        )

        # Each tenant is linked to the project and supplies its own value.
        tenants = get_tenants(get_active_api_key(), get_active_octopus_url(), space_id)
        for tenant_name, expected_value in tenant_values.items():
            tenant = find_by_name(tenants, tenant_name)
            self.assertIsNotNone(
                tenant,
                f'There should be a tenant called "{tenant_name}". The tenants are: {names(tenants)}',
            )
            self.assertIn(
                project["Id"],
                tenant["ProjectEnvironments"],
                f'The tenant "{tenant_name}" should be linked to the project.',
            )

            values = get_tenant_project_variable_values(
                space_id, tenant, project["Id"], template_name
            )
            self.assertTrue(
                values,
                f'The tenant "{tenant_name}" should define "{template_name}".',
            )
            self.assertEqual(
                {expected_value},
                set(values.values()),
                f'The tenant "{tenant_name}" should define "{template_name}" as '
                f'"{expected_value}" in every environment. It defines: {values}',
            )

        # The script step echoes the project tenant variable.
        steps = get_deployment_process_steps(space_name, project_name)
        scripts = get_scripts(steps)
        self.assertTrue(
            any(f"#{{{template_name}}}" in script for script in scripts),
            f'A script step should reference "#{{{template_name}}}". The scripts are: {scripts}',
        )


@pytest.mark.split_group("group9")
class EasyModeTest2(EasyModeTestBase):
    """
    End-to-end tests that verify the projects documented in the Octopus Easy Mode blog series
    (https://octopus.com/blog/easymode) are created as expected by the AI Assistant.

    This class contains tests 11–20.
    """

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_11_community_step_template(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-11-community
        """

        project_name = "11. Script App with Community Step Template"
        step_name = "Calculate Deployment Mode"
        template_website = "https://library.octopus.com/step-templates/d166457a-1421-4731-b143-dd6766fb95d5"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}".
Modify the deployment process to add the community step template with the website "{template_website}" as the first step with the name "{step_name}".
You must have two steps in the final process: the community step template, and the script step.""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # The community step template is installed into the space.
        action_templates = get_space_collection(space_id, "ActionTemplates")
        action_template = find_by_name(action_templates, step_name)
        self.assertIsNotNone(
            action_template,
            f'There should be a step template called "{step_name}". '
            f"The step templates are: {names(action_templates)}",
        )
        self.assertTrue(
            action_template["CommunityActionTemplateId"],
            "The step template should come from the community library.",
        )

        # The community step template is the first step, followed by the script step.
        steps = get_deployment_process_steps(space_name, project_name)
        self.assertEqual(
            2,
            len(steps),
            f"The deployment process should have two steps. It has: {step_names(steps)}",
        )
        self.assertEqual(step_name, steps[0]["Name"])
        self.assertEqual(
            action_template["Id"],
            steps[0]["Actions"][0]["Properties"].get("Octopus.Action.Template.Id"),
            "The first step should be sourced from the community step template.",
        )
        self.assertEqual("Octopus.Script", get_action_type(steps[1]))

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_12_channels(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-12-channels
        """

        project_name = "12. Script App with Channel"
        hot_fix = "Hot Fix"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Define a lifecycle called "{hot_fix}" that includes the "Production" environment as the only phase
* Add a channel to the project called "{hot_fix}" that uses the "{hot_fix}" lifecycle""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # A lifecycle with a single phase deploying straight to Production.
        lifecycles = get_space_collection(space_id, "Lifecycles")
        lifecycle = find_by_name(lifecycles, hot_fix)
        self.assertIsNotNone(
            lifecycle,
            f'There should be a lifecycle called "{hot_fix}". The lifecycles are: {names(lifecycles)}',
        )
        self.assertEqual(
            1,
            len(lifecycle["Phases"]),
            f'The "{hot_fix}" lifecycle should have one phase. It has: {names(lifecycle["Phases"])}',
        )
        phase_environments = get_environment_names(
            space_id, get_phase_environments(lifecycle["Phases"][0])
        )
        self.assertEqual(["Production"], phase_environments)

        # A channel using the new lifecycle. The automatically created default channel is left
        # in place as the default.
        channels = get_project_channel(
            get_active_api_key(), get_active_octopus_url(), space_id, project["Id"]
        )
        channel = find_by_name(channels, hot_fix)
        self.assertIsNotNone(
            channel,
            f'There should be a channel called "{hot_fix}". The channels are: {names(channels)}',
        )
        self.assertEqual(lifecycle["Id"], channel["LifecycleId"])

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_13_lifecycles(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-13-lifecycles
        """

        project_name = "13. Script App with Lifecycle"
        lifecycle_name = "Auto Deploy"
        channel_name = "Application"
        run_prompt(
            self,
            f"""Create a Script project called "{project_name}", and then:
* Define a lifecycle called "{lifecycle_name}" that includes:
  * The "Development" phase with the "Development" environment as the first phase set to automatically deploy
  * The "Test" phase with the "Test" environment as the second phase
  * The "Production" phase with the "Production" environment as the third phase
* Define a channel to the project called "{channel_name}" that uses the "{lifecycle_name}" lifecycle, and make this the default channel""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # The lifecycle progresses through the three environments in order, and the first phase
        # deploys automatically.
        lifecycles = get_space_collection(space_id, "Lifecycles")
        lifecycle = find_by_name(lifecycles, lifecycle_name)
        self.assertIsNotNone(
            lifecycle,
            f'There should be a lifecycle called "{lifecycle_name}". '
            f"The lifecycles are: {names(lifecycles)}",
        )

        phases = lifecycle["Phases"]
        self.assertEqual(
            [["Development"], ["Test"], ["Production"]],
            [
                get_environment_names(space_id, get_phase_environments(phase))
                for phase in phases
            ],
            f"The lifecycle phases should progress through the environments in order. "
            f"They are: {names(phases)}",
        )
        self.assertTrue(
            phases[0]["AutomaticDeploymentTargets"],
            "The first phase should deploy automatically.",
        )

        # The new channel uses the new lifecycle and is the default channel.
        channels = get_project_channel(
            get_active_api_key(), get_active_octopus_url(), space_id, project["Id"]
        )
        channel = find_by_name(channels, channel_name)
        self.assertIsNotNone(
            channel,
            f'There should be a channel called "{channel_name}". The channels are: {names(channels)}',
        )
        self.assertEqual(lifecycle["Id"], channel["LifecycleId"])
        self.assertTrue(
            channel["IsDefault"],
            f'The "{channel_name}" channel should be the default channel.',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_14_kubernetes(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-14-k8s
        """

        project_name = "K8s Web App"
        account_name = "Mock Token"
        feed_name = "Docker Hub"
        feed_uri = "https://index.docker.io"
        target_tag = "Kubernetes"
        target_url = "https://mockk8s.octopusdemos.com"
        run_prompt(
            self,
            f"""Create a Kubernetes project called "{project_name}", and then:
* Use client side apply in the Kubernetes step (the mock Kubernetes cluster only supports client side apply).
* Disable verification checks in the Kubernetes steps (the mock Kubernetes cluster doesn't support verification checks).
* Enable retries on the K8s deployment step.

---

Create a token account called "{account_name}".

---

Create a feed called "{feed_name}" pointing to "{feed_uri}" using anonymous authentication.

---

Create a Kubernetes target with the tag "{target_tag}", the URL {target_url}, using the health check container image "octopusdeploy/worker-tools:6.5.0-ubuntu.22.04" from the "{feed_name}" feed, using the token account, and the "Hosted Ubuntu" worker pool.""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # A token account and an anonymous Docker feed back the Kubernetes target.
        accounts = get_accounts(get_active_api_key(), get_active_octopus_url(), space_id)
        account = find_by_name(accounts, account_name)
        self.assertIsNotNone(
            account,
            f'There should be an account called "{account_name}". The accounts are: {names(accounts)}',
        )
        self.assertEqual("Token", account["AccountType"])

        feeds = get_feeds(get_active_api_key(), get_active_octopus_url(), space_id)
        feed = find_by_name(feeds, feed_name)
        self.assertIsNotNone(
            feed,
            f'There should be a feed called "{feed_name}". The feeds are: {names(feeds)}',
        )

        # A Kubernetes target pointing at the mock cluster. The target name is chosen by the LLM,
        # so it is matched on its URL and tag instead.
        machines = get_machines(get_active_api_key(), get_active_octopus_url(), space_id)
        targets = [
            machine
            for machine in machines
            if machine["Endpoint"].get("ClusterUrl") == target_url
        ]
        self.assertTrue(
            targets,
            f"There should be a Kubernetes target for {target_url}. The targets are: {names(machines)}",
        )
        self.assertIn(
            target_tag,
            targets[0]["Roles"],
            f'The Kubernetes target should have the "{target_tag}" tag. It has: {targets[0]["Roles"]}',
        )

        # The deployment process deploys raw YAML, gated by a manual intervention, and scans the
        # SBOM of the sample application.
        steps = get_deployment_process_steps(space_name, project_name)
        action_types = [get_action_type(step) for step in steps]
        self.assertIn(
            "Octopus.KubernetesDeployRawYaml",
            action_types,
            f"The deployment process should deploy raw YAML. The steps are: {step_names(steps)}",
        )
        self.assertIn(
            "Octopus.Manual",
            action_types,
            f"The deployment process should have a manual intervention. The steps are: {step_names(steps)}",
        )

        # The Kubernetes step uses client side apply, skips the verification checks the mock
        # cluster does not support, and retries on failure.
        kubernetes_action = next(
            step["Actions"][0]
            for step in steps
            if get_action_type(step) == "Octopus.KubernetesDeployRawYaml"
        )
        properties = kubernetes_action["Properties"]
        self.assertEqual(
            "False",
            properties.get("Octopus.Action.Kubernetes.ServerSideApply.Enabled"),
            "The Kubernetes step should use client side apply.",
        )
        self.assertEqual(
            "False",
            properties.get("Octopus.Action.Kubernetes.ResourceStatusCheck"),
            "The Kubernetes step should not run verification checks.",
        )
        self.assertTrue(
            properties.get("Octopus.Action.AutoRetry.MaximumCount"),
            "Retries should be enabled on the Kubernetes deployment step.",
        )

        # A dedicated environment and a trigger rerun the security scan daily.
        environments = get_environments(get_active_api_key(), get_active_octopus_url(), space_id)
        self.assertIsNotNone(
            find_by_name(environments, "Security"),
            f'There should be a "Security" environment. The environments are: {names(environments)}',
        )
        triggers = get_resource(f"/api/{space_id}/Projects/{project['Id']}/Triggers")[
            "Items"
        ]
        self.assertTrue(
            triggers,
            "The project should have a trigger to rerun the security scan.",
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_15_ephemeral_environments(self):
        """
        Verifies the project created by
        https://octopus.com/blog/octo-easy-mode-15-ephemeral-environments
        """

        project_name = "K8s Web App with Ephemeral Environments"
        features = "Features"
        run_prompt(
            self,
            f"""Create a Kubernetes project called "{project_name}", and then:
* Use client side apply in the Kubernetes step (the mock Kubernetes cluster only supports client side apply).
* Disable verification checks in the Kubernetes steps (the mock Kubernetes cluster doesn't support verification checks).
* Enable retries on the K8s deployment step.
* Add support for ephemeral environments, with the Parent Environment and Ephemeral Environment channel both called "{features}"

---

Create a token account called "Mock Token".

---

Create a feed called "Docker Hub" pointing to "https://index.docker.io" using anonymous authentication.

---

Create a Kubernetes target with the tag "Kubernetes", the URL https://mockk8s.octopusdemos.com, attach it to the "Development", "Test", "Production" environments and the "{features}" parent environment, using the health check container image "octopusdeploy/worker-tools:6.5.0-ubuntu.22.04" from the "Docker Hub" feed, using the token account, and the "Hosted Ubuntu" worker pool.""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # A channel that deploys to an ephemeral environment named after a custom field.
        channels = get_project_channel(
            get_active_api_key(), get_active_octopus_url(), space_id, project["Id"]
        )
        channel = find_by_name(channels, features)
        self.assertIsNotNone(
            channel,
            f'There should be a channel called "{features}". The channels are: {names(channels)}',
        )
        self.assertEqual("EphemeralEnvironment", channel["Type"])
        self.assertEqual(
            ["FeatureBranch"],
            [field["FieldName"] for field in channel["CustomFieldDefinitions"]],
        )
        self.assertIn(
            "FeatureBranch",
            channel["EphemeralEnvironmentNameTemplate"],
            "Ephemeral environments should be named after the FeatureBranch custom field.",
        )

        # The channel creates its ephemeral environments under a parent environment. Parent
        # environments are not part of the environments collection and have their own endpoint, so
        # the parent is resolved through the channel.
        parent_environment_id = channel["ParentEnvironmentId"]
        self.assertTrue(
            parent_environment_id,
            f'The "{features}" channel should have a parent environment.',
        )
        parent_environment = get_resource(
            f"/api/{space_id}/ParentEnvironments/{parent_environment_id}"
        )
        self.assertEqual(features, parent_environment["Name"])

        # The Kubernetes deployment step is retained.
        steps = get_deployment_process_steps(space_name, project_name)
        self.assertIn(
            "Octopus.KubernetesDeployRawYaml",
            [get_action_type(step) for step in steps],
            f"The deployment process should deploy raw YAML. The steps are: {step_names(steps)}",
        )

        # The post then runs a second prompt against the new project to add the runbooks that
        # provision and deprovision the ephemeral environment.
        runbook_names = ["Provision Environment", "Deprovision Environment"]
        run_prompt(
            self,
            f"""Create a runbook called "{runbook_names[0]}" in the project "{project_name}".
Allow the runbook to be run from the "Features" environment.
Add a "Run a kubectl script" step run against the target tag "Kubernetes" and echo the text "Provisioning the environment" from a bash script.
Run the step from the "Hosted Ubuntu" worker pool.

---

Create a runbook called "{runbook_names[1]}" in the project "{project_name}".
Allow the runbook to be run from the "Features" environment.
Add a "Run a kubectl script" step run against the target tag "Kubernetes" and echo the text "Deprovisioning the environment" from a bash script.
Run the step from the "Hosted Ubuntu" worker pool.""",
        )

        # One runbook to provision the ephemeral environment, and one to deprovision it.
        for runbook_name in runbook_names:
            runbook = get_runbook_fuzzy(
                space_id, project["Id"], runbook_name, get_active_api_key(), get_active_octopus_url()
            )
            self.assertEqual(runbook_name, runbook["Name"])

            # The runbook runs against the parent environment the ephemeral environments belong
            # to, rather than the regular deployment environments.
            self.assertEqual("Specified", runbook["EnvironmentScope"])
            self.assertEqual([parent_environment_id], runbook["Environments"])

            steps = get_runbook_process_steps(space_id, runbook)
            self.assertEqual(
                ["Octopus.KubernetesRunScript"],
                [get_action_type(step) for step in steps],
                f'The runbook "{runbook_name}" should run a single kubectl script. '
                f"Its steps are: {step_names(steps)}",
            )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_16_argo_cd_manifest_update(self):
        """
        Verifies the project created by
        https://octopus.com/blog/octo-easy-mode-16-argocd-manifest-update
        """

        project_name = "16. Argo CD Manifest Update"
        project_slug = "argo-cd-octopub-manifest"
        git_credential_name = "Mock"
        allowed_repository = "https://mockgit.octopusdemos.com/*"
        run_prompt(
            self,
            f'Create an Argo CD Manifest Update project called "{project_name}" with the slug '
            f'"{project_slug}" using a Git Connection called "{git_credential_name}" with a random '
            f'username and the allowed repository "{allowed_repository}"',
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # The slug links an Argo CD Application to the Octopus project, so it must match exactly.
        self.assertEqual(project_slug, project["Slug"])

        # Git credentials restricted to the mock Git repository.
        git_credentials = get_space_collection(space_id, "Git-Credentials")
        git_credential = find_by_name(git_credentials, git_credential_name)
        self.assertIsNotNone(
            git_credential,
            f'There should be a Git credential called "{git_credential_name}". '
            f"The Git credentials are: {names(git_credentials)}",
        )
        self.assertIn(
            allowed_repository,
            git_credential["RepositoryRestrictions"]["AllowedRepositories"],
            f"The Git credential should be restricted to {allowed_repository}.",
        )

        # A step that commits the processed manifest template back to the repository.
        steps = get_deployment_process_steps(space_name, project_name)
        self.assertIn(
            "Octopus.ArgoCDUpdateManifests",
            [get_action_type(step) for step in steps],
            f"The deployment process should update Argo CD manifests. "
            f"The steps are: {step_names(steps)}",
        )

        # The template file the step processes contains the variables injected per environment.
        manifest_action = next(
            step["Actions"][0]
            for step in steps
            if get_action_type(step) == "Octopus.ArgoCDUpdateManifests"
        )
        self.assertTrue(
            manifest_action["Properties"].get("Octopus.Action.ArgoCD.InputPath"),
            "The step should read a manifest template from the repository.",
        )

        # The theme variable substituted into the manifest template.
        variables = get_project_variables(project)
        self.assertTrue(
            any(
                variable["Name"] == "Project.Frontend.Theme" for variable in variables
            ),
            f"The project should define Project.Frontend.Theme. "
            f"It defines: {variable_names(variables)}",
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_17_claude_agent(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-17-claude
        """

        project_name = "17. Categorize Changes"
        run_prompt(self, f'Create a Claude project called "{project_name}"')

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # The Claude agent categorizes the commits, and a manual intervention gates the deployment
        # when the agent reports a high risk change.
        steps = get_deployment_process_steps(space_name, project_name)
        action_types = [get_action_type(step) for step in steps]
        self.assertIn(
            "Octopus.Claude",
            action_types,
            f"The deployment process should run a Claude agent. "
            f"The steps are: {step_names(steps)}",
        )
        self.assertIn(
            "Octopus.Manual",
            action_types,
            f"The deployment process should have a manual intervention. "
            f"The steps are: {step_names(steps)}",
        )

        # The Claude agent step is prompted with the commits contributing to the deployment.
        claude_action = next(
            step["Actions"][0]
            for step in steps
            if get_action_type(step) == "Octopus.Claude"
        )
        claude_properties = " ".join(
            value
            for value in claude_action["Properties"].values()
            if isinstance(value, str)
        )
        self.assertIn(
            "Octopus.Deployment.Changes",
            claude_properties,
            "The Claude agent should be prompted with the deployment changes.",
        )

        # The API keys the project needs to read the commits and call Claude.
        variables = get_project_variables(project)
        for variable_name in ["Project.GitHub.PAT", "Project.Claude.ApiKey"]:
            self.assertTrue(
                any(variable["Name"] == variable_name for variable in variables),
                f"The project should define {variable_name}. "
                f"It defines: {variable_names(variables)}",
            )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_18_progressive_rollout(self):
        """
        Verifies the project created by
        https://octopus.com/blog/octo-easy-mode-18-progressive-rollouts
        """

        project_name = "18. Progressive rollout"
        lifecycle_name = "Progressive"
        rollout_environments = ["Prod 10", "Prod 50", "Prod 100"]
        runbook_name = "Deploy Release"
        run_prompt(
            self,
            f'Create a new progressive deployment project called "{project_name}".',
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # An environment for each slice of production traffic.
        environments = get_environments(get_active_api_key(), get_active_octopus_url(), space_id)
        for environment_name in rollout_environments:
            self.assertIsNotNone(
                find_by_name(environments, environment_name),
                f'There should be a "{environment_name}" environment. '
                f"The environments are: {names(environments)}",
            )

        # The lifecycle promotes a release through the environments in increasing order.
        lifecycles = get_space_collection(space_id, "Lifecycles")
        lifecycle = find_by_name(lifecycles, lifecycle_name)
        self.assertIsNotNone(
            lifecycle,
            f'There should be a lifecycle called "{lifecycle_name}". '
            f"The lifecycles are: {names(lifecycles)}",
        )
        phase_environments = [
            get_environment_names(space_id, get_phase_environments(phase))
            for phase in lifecycle["Phases"]
        ]
        self.assertEqual(
            [["Development"], ["Prod 10"], ["Prod 50"], ["Prod 100"]],
            phase_environments,
            f"The lifecycle should roll out through the production environments in order. "
            f"Its phases target: {phase_environments}",
        )

        # A prompted variable can fail the validation step to halt the rollout.
        variables = get_project_variables(project)
        simulate_fail = next(
            (
                variable
                for variable in variables
                if variable["Name"] == "Project.SimulateFail"
            ),
            None,
        )
        self.assertIsNotNone(
            simulate_fail,
            f"The project should define Project.SimulateFail. "
            f"It defines: {variable_names(variables)}",
        )
        self.assertIsNotNone(
            simulate_fail["Prompt"],
            "Project.SimulateFail should be a prompted variable.",
        )

        # The deployment process simulates a deployment, validates it, then chains the rollout to
        # the next environment through a runbook.
        steps = get_deployment_process_steps(space_name, project_name)
        self.assertTrue(
            len(steps) >= 3,
            f"The deployment process should have at least three steps. "
            f"It has: {step_names(steps)}",
        )

        # The runbook that promotes the release to the next production environment.
        runbook = get_runbook_fuzzy(
            space_id, project["Id"], runbook_name, get_active_api_key(), get_active_octopus_url()
        )
        self.assertEqual(runbook_name, runbook["Name"])
        runbook_steps = get_runbook_process_steps(space_id, runbook)
        self.assertTrue(
            runbook_steps,
            f'The runbook "{runbook_name}" should have at least one step.',
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_19_blue_green(self):
        """
        Verifies the project created by https://octopus.com/blog/octo-easy-mode-19-bluegreen
        """

        project_name = "19. Blue-Green deployments"
        lifecycle_name = "Blue Green"
        production_environments = ["Blue Production", "Green Production"]
        run_prompt(
            self,
            f'Create a new blue/green deployment project called "{project_name}".',
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        project = get_project_by_name(self, space_id, project_name)

        # An environment for each production stack.
        environments = get_environments(get_active_api_key(), get_active_octopus_url(), space_id)
        for environment_name in production_environments:
            self.assertIsNotNone(
                find_by_name(environments, environment_name),
                f'There should be a "{environment_name}" environment. '
                f"The environments are: {names(environments)}",
            )

        # The lifecycle progresses to either production stack, with both optional so a release can
        # be promoted to one without the other.
        lifecycles = get_space_collection(space_id, "Lifecycles")
        lifecycle = find_by_name(lifecycles, lifecycle_name)
        self.assertIsNotNone(
            lifecycle,
            f'There should be a lifecycle called "{lifecycle_name}". '
            f"The lifecycles are: {names(lifecycles)}",
        )

        optional_phase_environments = [
            get_environment_names(space_id, get_phase_environments(phase))
            for phase in lifecycle["Phases"]
            if phase["IsOptionalPhase"]
        ]
        for environment_name in production_environments:
            self.assertIn(
                [environment_name],
                optional_phase_environments,
                f'The lifecycle should have an optional phase for "{environment_name}". '
                f"Its optional phases target: {optional_phase_environments}",
            )

        # A step detects consecutive deployments to the same production stack, and a manual
        # intervention gates the deployment.
        steps = get_deployment_process_steps(space_name, project_name)
        self.assertIn(
            "Octopus.Manual",
            [get_action_type(step) for step in steps],
            f"The deployment process should have a manual approval. "
            f"The steps are: {step_names(steps)}",
        )
        self.assertTrue(
            len(steps) >= 3,
            f"The deployment process should have at least three steps. "
            f"It has: {step_names(steps)}",
        )

    @retry((AssertionError, RateLimitError), tries=2, delay=2)
    def test_20_microservice_orchestration(self):
        """
        Verifies the projects created by
        https://octopus.com/blog/octo-easy-mode-20-microservices
        """

        microservices = ["20. Microservice 1", "20. Microservice 2"]
        orchestration_project_name = "20. Kubernetes Microservice Orchestration"
        target_name = "Mock K8s"
        target_url = "https://mockk8s.octopusdemos.com"
        run_prompt(
            self,
            f"""* Create a token account called "Mock Token".
* Create a feed called "Docker Hub" pointing to "https://index.docker.io" using anonymous authentication.
* Add a target called "{target_name}", with the tag "Kubernetes", using the token account, pointing to "{target_url}", using the health check image "octopusdeploy/worker-tools:6.5.0-ubuntu.22.04" from the "Docker Hub" feed, using the worker pool "Hosted Ubuntu".

---

Create a Kubernetes project called "{microservices[0]}", and then:
* Place the project in the "Orchestrator" project group.
* Configure the Kubernetes steps to use client side apply (client side apply is required by the "{target_name}" target).
* Disable verification checks in the Kubernetes steps (verification checks are not supported by the "{target_name}" target).
* Enable retries on the Kubernetes step.

---

Create a Kubernetes project called "{microservices[1]}", and then:
* Place the project in the "Orchestrator" project group.
* Configure the Kubernetes steps to use client side apply (client side apply is required by the "{target_name}" target).
* Disable verification checks in the Kubernetes steps (verification checks are not supported by the "{target_name}" target).
* Enable retries on the Kubernetes step.

---

Create an Orchestration project called "{orchestration_project_name}" managing the projects "{microservices[0]}" and "{microservices[1]}".""",
        )

        space_id, space_name = get_space_id_and_name_from_name(
            Space_Name, get_active_api_key(), get_active_octopus_url()
        )

        # The shared Kubernetes target the microservices deploy to.
        machines = get_machines(get_active_api_key(), get_active_octopus_url(), space_id)
        self.assertTrue(
            any(
                machine["Endpoint"].get("ClusterUrl") == target_url
                for machine in machines
            ),
            f"There should be a Kubernetes target for {target_url}. "
            f"The targets are: {names(machines)}",
        )

        # Each microservice is independently deployable, so each gets its own Kubernetes
        # deployment process.
        child_projects = []
        for microservice_name in microservices:
            child_project = get_project_by_name(self, space_id, microservice_name)
            child_projects.append(child_project)

            steps = get_deployment_process_steps(space_name, microservice_name)
            self.assertIn(
                "Octopus.KubernetesDeployRawYaml",
                [get_action_type(step) for step in steps],
                f'The project "{microservice_name}" should deploy raw YAML. '
                f"Its steps are: {step_names(steps)}",
            )

        # The orchestration project deploys a release of each microservice in turn.
        orchestration_project = get_project_by_name(
            self, space_id, orchestration_project_name
        )
        orchestration_steps = get_deployment_process_steps(
            space_name, orchestration_project_name
        )
        deploy_release_actions = [
            step["Actions"][0]
            for step in orchestration_steps
            if get_action_type(step) == "Octopus.DeployRelease"
        ]
        self.assertEqual(
            2,
            len(deploy_release_actions),
            f'The project "{orchestration_project_name}" should deploy two releases. '
            f"Its steps are: {step_names(orchestration_steps)}",
        )

        # One step per microservice, and the microservices are deployed sequentially.
        deployed_project_ids = [
            action["Properties"].get("Octopus.Action.DeployRelease.ProjectId")
            for action in deploy_release_actions
        ]
        for child_project in child_projects:
            self.assertIn(
                child_project["Id"],
                deployed_project_ids,
                f'The orchestration project should deploy "{child_project["Name"]}".',
            )


if __name__ == "__main__":
    unittest.main()


def save_user_details():
    """
    Simulate the result of a user login by saving the Octopus details and the default values the
    prompts rely on.
    """
    github_user = os.environ["TEST_GH_USER"]
    octopus_url = Remote_Octopus_Url if Remote_Test else Octopus_Url
    octopus_api_key = Remote_Octopus_Api_Key if Remote_Test else Octopus_Api_Key
    save_users_octopus_url_from_login(
        github_user,
        octopus_url,
        octopus_api_key,
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


def get_active_octopus_url():
    """Return the Octopus URL for the current test mode."""
    return Remote_Octopus_Url if Remote_Test else Octopus_Url


def get_active_api_key():
    """Return the Octopus API key for the current test mode."""
    return Remote_Octopus_Api_Key if Remote_Test else Octopus_Api_Key


def create_remote_space(space_name):
    """
    Create a new space on the remote Octopus server and return its ID.
    :param space_name: the name for the new space
    :return: the ID of the created space e.g. "Spaces-123"
    """
    api, headers = build_url(Remote_Octopus_Url, Remote_Octopus_Api_Key, "/api/spaces")
    headers["Content-Type"] = "application/json"
    teams = ["teams-administrators"]
    if Space_Manager_Team:
        teams.append(Space_Manager_Team)
    body = json.dumps({
        "Name": space_name,
        "IsDefault": False,
        "TaskQueueStopped": False,
        "SpaceManagersTeamMembers": None,
        "SpaceManagersTeams": teams,
    }).encode("utf8")
    resp = handle_response(
        lambda: http.request("POST", api, headers=headers, body=body)
    )
    space = resp.json()
    print(f"Created remote space '{space_name}' with ID {space['Id']}")
    return space["Id"]


def delete_remote_space(space_id):
    """
    Mark a space on the remote Octopus server for deletion by stopping its task queue, then
    delete it.
    :param space_id: the ID of the space to delete
    """
    # First, stop the task queue so the space can be deleted
    get_api, get_headers = build_url(
        Remote_Octopus_Url, Remote_Octopus_Api_Key, f"/api/spaces/{space_id}"
    )
    resp = handle_response(
        lambda: http.request("GET", get_api, headers=get_headers)
    )
    space = resp.json()
    space["TaskQueueStopped"] = True

    put_api, put_headers = build_url(
        Remote_Octopus_Url, Remote_Octopus_Api_Key, f"/api/spaces/{space_id}"
    )
    put_headers["Content-Type"] = "application/json"
    handle_response(
        lambda: http.request(
            "PUT", put_api, headers=put_headers, body=json.dumps(space).encode("utf8")
        )
    )

    # Now delete the space
    del_api, del_headers = build_url(
        Remote_Octopus_Url, Remote_Octopus_Api_Key, f"/api/spaces/{space_id}"
    )
    handle_response(
        lambda: http.request("DELETE", del_api, headers=del_headers)
    )
    print(f"Deleted remote space {space_id}")


def wait_for_octopus(timeout=1800):
    """
    Wait until the Octopus API is serving requests. The container logs are deliberately not used
    to detect readiness, because streaming logs from the container runtime blocks until the
    server writes its next line, which can exceed the runtime client's socket timeout when the
    server is slow to start.
    :param timeout: the number of seconds to wait before giving up
    """
    api, headers = build_url(Octopus_Url, Octopus_Api_Key, "/api")
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            if http.request("GET", api, headers=headers, timeout=10).status == 200:
                return
        except Exception:
            pass
        time.sleep(5)

    raise TimeoutError(f"Octopus was not ready at {Octopus_Url} after {timeout} seconds")


def get_container_ip(container):
    """
    Return the IP address a container can be reached on from another container. The
    testcontainers bridge_ip helper reads the network name from a container listing that some
    container runtimes (Podman, for example) do not populate, so the network settings are read
    from the container itself.
    :param container: the container
    :return: the IP address of the container
    """
    wrapped_container = container.get_wrapped_container()
    # The attributes are captured when the container is created, before it has an IP address.
    wrapped_container.reload()
    networks = wrapped_container.attrs["NetworkSettings"]["Networks"]
    return next(
        network["IPAddress"] for network in networks.values() if network["IPAddress"]
    )


def run_prompt(test, prompt):
    """
    Run a prompt against the AI Assistant, accept the confirmation, and verify the resources
    were created. If the prompt contains '---' separators, it is split into multiple prompts
    that are run sequentially. The AI Assistant can reference resources created in previous
    prompts by name. The space is appended to each prompt so the assistant does not have to
    guess where to create the resources.
    :param test: the test case used to make the assertions
    :param prompt: the prompt from the blog post
    :return: the text of the response to the last confirmation
    """
    sections = [section.strip() for section in prompt.split("---")]
    sections = [section for section in sections if section]

    response_text = None
    for section in sections:
        response_text = run_single_prompt(test, section)

    return response_text


def run_single_prompt(test, prompt):
    """
    Run a single prompt against the AI Assistant, accept the confirmation, and verify the
    resources were created. The space is appended to the prompt so the assistant does not have
    to guess where to create the resources.
    :param test: the test case used to make the assertions
    :param prompt: the prompt from the blog post
    :return: the text of the response to the confirmation
    """
    response = copilot_handler_internal(
        build_request(f'{prompt}\n\nThe current space is "{Space_Name}"')
    )
    response_body = response.get_body().decode("utf8")
    try:
        confirmation_id = get_confirmation_id(response_body)
    except StopIteration:
        # No confirmation means the assistant did not produce a plan to approve. The response
        # explains why, so report it rather than the StopIteration raised while looking for the
        # confirmation.
        test.fail(
            "The prompt did not return a plan to confirm. The response was: "
            + convert_from_sse_response(response_body)
        )
    test.assertTrue(confirmation_id != "", "Confirmation ID was " + confirmation_id)

    confirmation = build_confirmation_body(confirmation_id)

    run_response = copilot_handler_internal(build_confirmation_request(confirmation))
    response_text = convert_from_sse_response(run_response.get_body().decode("utf8"))
    print(response_text)
    test.assertTrue(
        "The following Octopus resources were created successfully:" in response_text,
        response_text,
    )

    return response_text


def get_project_by_name(test, space_id, project_name):
    """
    Return the project with the given name. The name is matched exactly, because the fuzzy lookup
    used by the application falls back to the closest match, which hides the case where the prompt
    did not create the project at all.
    :param test: the test case used to make the assertion
    :param space_id: the ID of the space
    :param project_name: the name of the project
    :return: the project resource
    """
    projects = get_space_collection(space_id, "Projects")
    project = find_by_name(projects, project_name)
    test.assertIsNotNone(
        project,
        f'There should be a project called "{project_name}". The projects are: {names(projects)}',
    )
    return project


def get_space_collection(space_id, collection):
    """
    Return every item in one of a space's resource collections.
    :param space_id: the ID of the space
    :param collection: the name of the collection e.g. "Feeds"
    :return: the list of resources
    """
    api, headers = build_url(
        get_active_octopus_url(),
        get_active_api_key(),
        f"/api/{space_id}/{collection}",
        query=dict(take=TAKE_ALL),
    )
    resp = handle_response(lambda: http.request("GET", api, headers=headers))
    return resp.json()["Items"]


def get_resource(path):
    """
    Return a single resource from one of the links exposed by a parent resource.
    :param path: the path of the resource
    :return: the resource
    """
    api, headers = build_url(get_active_octopus_url(), get_active_api_key(), path)
    resp = handle_response(lambda: http.request("GET", api, headers=headers))
    return resp.json()


def get_lifecycle_by_id(space_id, lifecycle_id):
    return get_resource(f"/api/{space_id}/Lifecycles/{lifecycle_id}")


def get_project_variables(project):
    """
    Return the variables defined directly against a project.
    :param project: the project resource
    :return: the list of variables
    """
    return get_resource(project["Links"]["Variables"])["Variables"]


def get_deployment_process_steps(space_name, project_name):
    """
    Return the steps in a project's deployment process.
    :param space_name: the name of the space
    :param project_name: the name of the project
    :return: the list of steps
    """
    raw_deployment_process = get_raw_deployment_process(
        space_name, project_name, get_active_api_key(), get_active_octopus_url()
    )
    return json.loads(raw_deployment_process)["Steps"]


def get_variable_set_variables(space_id, variable_set_id):
    """
    Return the variables in a variable set, for example the variable set backing a library
    variable set.
    :param space_id: the ID of the space
    :param variable_set_id: the ID of the variable set
    :return: the list of variables
    """
    return get_resource(f"/api/{space_id}/Variables/{variable_set_id}")["Variables"]


def get_tenant_template_value(space_id, tenant, variable_set_id, template_name):
    """
    Return the value a tenant supplies for a library variable set tenant template. The values are
    read from the API because the serialized terraform does not reliably include them.
    :param space_id: the ID of the space
    :param tenant: the tenant resource
    :param variable_set_id: the ID of the library variable set defining the template
    :param template_name: the name of the template
    :return: the value supplied by the tenant, or None
    """
    tenant_variables = get_resource(
        f"/api/{space_id}/Tenants/{tenant['Id']}/Variables"
    )
    library_variables = tenant_variables["LibraryVariables"].get(variable_set_id, {})
    template_id = next(
        (
            template["Id"]
            for template in library_variables.get("Templates", [])
            if template["Name"] == template_name
        ),
        None,
    )
    return library_variables.get("Variables", {}).get(template_id)


def get_tenant_project_variable_values(space_id, tenant, project_id, template_name):
    """
    Return the values a tenant supplies for a project tenant variable, keyed by environment ID. A
    value is supplied for each environment the tenant is linked to. The values are read from the
    API because the serialized terraform does not reliably include them.
    :param space_id: the ID of the space
    :param tenant: the tenant resource
    :param project_id: the ID of the project defining the tenant variable
    :param template_name: the name of the project tenant variable
    :return: the values supplied by the tenant, keyed by environment ID
    """
    tenant_variables = get_resource(
        f"/api/{space_id}/Tenants/{tenant['Id']}/Variables"
    )
    project_variables = tenant_variables["ProjectVariables"].get(project_id, {})
    template_id = next(
        (
            template["Id"]
            for template in project_variables.get("Templates", [])
            if template["Name"] == template_name
        ),
        None,
    )
    return {
        environment_id: values[template_id]
        for environment_id, values in project_variables.get("Variables", {}).items()
        if template_id in values
    }


def get_phase_environments(phase):
    """
    Return the environments targeted by a lifecycle phase. Phases target environments either
    automatically or optionally, and the blog posts describe both as part of the phase.
    :param phase: the lifecycle phase
    :return: the IDs of the environments targeted by the phase
    """
    return phase["AutomaticDeploymentTargets"] + phase["OptionalDeploymentTargets"]


def get_runbook_process_steps(space_id, runbook):
    """
    Return the steps in a runbook's process.
    :param space_id: the ID of the space
    :param runbook: the runbook resource
    :return: the list of steps
    """
    process = get_resource(
        f"/api/{space_id}/RunbookProcesses/{runbook['RunbookProcessId']}"
    )
    return process["Steps"]


def get_environment_names(space_id, environment_ids):
    """
    Convert a list of environment IDs into their names. Environments are scoped and referenced
    by ID, but the blog posts describe them by name.
    :param space_id: the ID of the space
    :param environment_ids: the IDs of the environments
    :return: the names of the environments
    """
    environments = get_space_collection(space_id, "Environments")
    return [
        environment["Name"]
        for environment in environments
        if environment["Id"] in environment_ids
    ]


def get_action_type(step):
    """
    Return the action type of the first action in a step.
    :param step: the step
    :return: the action type
    """
    return step["Actions"][0]["ActionType"]


def get_scripts(steps):
    """
    Return the inline scripts defined by a collection of steps.
    :param steps: the steps
    :return: the list of scripts
    """
    return [
        action["Properties"]["Octopus.Action.Script.ScriptBody"]
        for step in steps
        for action in step["Actions"]
        if "Octopus.Action.Script.ScriptBody" in action["Properties"]
    ]


def step_names(steps):
    return [step["Name"] for step in steps]


def variable_names(variables):
    return [variable["Name"] for variable in variables]


def names(resources):
    return [resource["Name"] for resource in resources]


def find_by_name(resources, name):
    """
    Find a resource by name.
    :param resources: the list of resources
    :param name: the name to find
    :return: the matching resource, or None
    """
    return next(
        (resource for resource in resources if resource["Name"] == name),
        None,
    )


def build_confirmation_body(confirmation_id):
    """
    Build the confirmation body accepted by copilot_handler_internal.
    :param confirmation_id: the confirmation ID returned from the initial response
    :return: dict representing the accepted confirmation message
    """
    return {
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
