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
from domain.transformers.clean_response import strip_before_first_curly_bracket
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
from infrastructure.users import save_users_octopus_url_from_login, save_default_values
from tests.infrastructure.cancel_task import cancel_task
from tests.infrastructure.create_and_deploy_release import (
    create_and_deploy_release,
    wait_for_task,
)
from tests.infrastructure.create_release import create_release
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.octopus_infrastructure_test import run_terraform
from tests.infrastructure.publish_runbook import publish_runbook


class CopilotChatTest(unittest.TestCase):
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
    def test_runbook_run(self):
        publish_runbook("Simple", "Copilot Test Runbook Project", "Backup Database")
        prompt = 'Run runbook "Backup Database" in the "Copilot Test Runbook Project" project'
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
            "Backup Database" in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_runbook_run_with_variables(self):
        publish_runbook(
            "Simple", "Copilot Test Runbook Project", "Prompted Variables Runbook"
        )
        prompt = 'Run runbook "Prompted Variables Runbook" in the "Copilot Test Runbook Project" project with variables notify=false, slot=Staging, othervariable=extra'
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

        run_response_text = convert_from_sse_response(
            run_response.get_body().decode("utf8")
        )

        self.assertTrue(
            "Prompted Variables Runbook" in run_response_text,
            "Response was " + run_response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_runbook_run_with_missing_required_variable(self):
        publish_runbook(
            "Simple", "Copilot Test Runbook Project", "Prompted Variables Runbook"
        )
        prompt = 'Run runbook "Prompted Variables Runbook" in the "Copilot Test Runbook Project" project with variables notify=false, slot='
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "The runbook is missing values for required variables: slot"
            in response_text,
            "Response was " + response_text,
        )

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
    def test_approve_manual_intervention_for_deployment(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Copilot manual approval"
        environment_name = "Development"
        create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            release_version=version,
        )
        time.sleep(5)

        prompt = f'Approve "{version}" to the "{environment_name}" environment for project "{project_name}" in space "{space_name}"'
        response = copilot_handler_internal(build_request(prompt))
        response_body_decoded = response.get_body().decode("utf8")

        confirmation_id = get_confirmation_id(response_body_decoded)
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
            f"{project_name}" and "☑️ Manual intervention approved" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_approve_manual_intervention_with_guided_failure_interruption(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Copilot guided failure"
        environment_name = "Development"
        deploy_response = create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            release_version=version,
            use_guided_failure=True,
        )
        time.sleep(15)

        prompt = f'Approve release "{version}" to the "{environment_name}" environment for project "{project_name}"'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "🚫 An incompatible interruption (guided failure) was found for"
            and version
            and "Proceed" in response_text,
            "Response was " + response_text,
        )

        # clean-up task by canceling it
        cancel_response = cancel_task(
            deploy_response["SpaceId"], deploy_response["TaskId"]
        )
        self.assertTrue(cancel_response["Id"] == deploy_response["TaskId"])
        self.assertTrue(cancel_response["State"] in ["Canceled", "Cancelling"])

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_reject_manual_intervention_for_deployment(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Copilot manual approval"
        environment_name = "Development"
        create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            release_version=version,
        )
        time.sleep(5)

        prompt = f'Reject "{version}" to the "{environment_name}" environment for project "{project_name}" in space "{space_name}"'
        response = copilot_handler_internal(build_request(prompt))
        response_body_decoded = response.get_body().decode("utf8")

        confirmation_id = get_confirmation_id(response_body_decoded)
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
            f"{project_name}" and "⛔ Manual intervention rejected" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_reject_manual_intervention_with_guided_failure_interruption(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Copilot guided failure"
        environment_name = "Development"
        deploy_response = create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            release_version=version,
            use_guided_failure=True,
        )
        time.sleep(15)

        prompt = f'Reject release "{version}" to the "{environment_name}" environment for project "{project_name}"'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "🚫 An incompatible interruption (guided failure) was found for"
            and version
            and "Abort" in response_text,
            "Response was " + response_text,
        )

        # clean-up task by canceling it
        cancel_response = cancel_task(
            deploy_response["SpaceId"], deploy_response["TaskId"]
        )
        self.assertTrue(cancel_response["Id"] == deploy_response["TaskId"])
        self.assertTrue(cancel_response["State"] in ["Canceled", "Cancelling"])

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_cancel_task_by_invalid_id(self):
        invalid_task_id = "ServerTax-74872356"
        prompt = f'Cancel the task "{invalid_task_id}"'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            f'⚠️ Unable to determine task to cancel from: "{invalid_task_id}".'
            in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_cancel_task_already_canceled(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Long running script"
        environment_name = "Development"
        deploy_response = create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            release_version=version,
        )
        time.sleep(5)
        cancel_task(deploy_response["SpaceId"], deploy_response["TaskId"])
        wait_for_task(deploy_response["TaskId"], space_name=space_name)
        prompt = f"Cancel the task \"{deploy_response['TaskId']}\""

        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            f"Task already cancelled." in response_text, "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_cancel_task_by_id(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Long running script"
        environment_name = "Development"
        deploy_response = create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            release_version=version,
        )

        prompt = f"Cancel the task \"{deploy_response['TaskId']}\""
        response = copilot_handler_internal(build_request(prompt))
        response_body_decoded = response.get_body().decode("utf8")

        confirmation_id = get_confirmation_id(response_body_decoded)
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
            f"{project_name}" and "⛔ Task canceled" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_cancel_deployment(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Long running script"
        environment_name = "Development"
        create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            release_version=version,
        )

        prompt = f'Cancel the latest deployment for the project "{project_name}" to the environment "{environment_name}" in the space "{space_name}".'
        response = copilot_handler_internal(build_request(prompt))
        response_body_decoded = response.get_body().decode("utf8")

        confirmation_id = get_confirmation_id(response_body_decoded)
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
            f"{project_name}" and "⛔ Task canceled" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_cancel_tenanted_deployment(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        space_name = "Simple"
        project_name = "Long running script"
        environment_name = "Development"
        tenant_name = "Marketing"
        create_and_deploy_release(
            space_name=space_name,
            project_name=project_name,
            environment_name=environment_name,
            tenant_name=tenant_name,
            release_version=version,
        )
        time.sleep(5)
        prompt = (
            f'Cancel the latest deployment for the project "{project_name}" to the environment '
            f'"{environment_name}" for the tenant "{tenant_name}" in the space "{space_name}".'
        )
        response = copilot_handler_internal(build_request(prompt))
        response_body_decoded = response.get_body().decode("utf8")

        confirmation_id = get_confirmation_id(response_body_decoded)
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
            f"{project_name}" and "⛔ Task canceled" in response_text,
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_cancel_runbook_run(self):
        space_name = "Simple"
        project_name = "Copilot Test Runbook Project"
        runbook_name = "Long Running Runbook"
        environment_name = "Development"
        publish_runbook(space_name, project_name, runbook_name)
        space_id, space_name = get_space_id_and_name_from_name(
            space_name, Octopus_Api_Key, Octopus_Url
        )
        run_published_runbook_fuzzy(
            space_id,
            project_name,
            runbook_name,
            environment_name,
            tenant_name="",
            variables=None,
            my_api_key=Octopus_Api_Key,
            my_octopus_api=Octopus_Url,
        )

        prompt = f'Cancel the runbook "{runbook_name}" for project "{project_name}" to the environment "{environment_name}" in the space "{space_name}".'
        response = copilot_handler_internal(build_request(prompt))
        response_body_decoded = response.get_body().decode("utf8")

        confirmation_id = get_confirmation_id(response_body_decoded)
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
            f"{project_name}" and "⛔ Task canceled" in response_text,
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
        untenanted_version = str(uuid.uuid4())
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
        self.assertTrue(
            "Simple / Deploy AWS Lambda" in response_text,
            "Response was " + response_text,
        )
        self.assertTrue("Marketing" in response_text, "Response was " + response_text)
        self.assertTrue(version in response_text, "Response was " + response_text)
        self.assertTrue(
            untenanted_version in response_text, "Response was " + response_text
        )
        self.assertTrue(
            "This is a highlight" in response_text, "Response was " + response_text
        )
        self.assertTrue("file.txt" in response_text, "Response was " + response_text)
        print(response_text)

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_logs(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        deployment = create_and_deploy_release(
            space_name="Simple", release_version=version
        )
        wait_for_task(deployment["TaskId"], space_name="Simple")

        prompt = "List anything interesting in the deployment logs for the latest project deployment."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        self.assertTrue(
            "sorry" not in response_text.casefold(), "Response was " + response_text
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_get_logs_raw(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        deployment = create_and_deploy_release(
            space_name="Simple", release_version=version
        )
        wait_for_task(deployment["TaskId"], space_name="Simple")

        prompt = "Print the last 30 lines of text from the deployment logs of the latest project deployment."
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # The response should have formatted the text as a code block
        self.assertTrue(
            "```" in response_text.casefold(), "Response was " + response_text
        )

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

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_count_projects(self):
        prompt = "How many projects are there in this space?"
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # This should return the one default project (even though there are 3 overall)
        self.assertTrue(
            "1" in response_text.casefold() or "one" in response_text.casefold(),
            "Response was " + response_text,
        )

    @retry((AssertionError, RateLimitError, HTTPError), tries=3, delay=2)
    def test_find_retries(self):
        prompt = 'What project steps have retries enabled? Provide the response as a literal JSON object like {"steps": [{"name": "Step 1", "retries": false}, {"name": "Step 2", "retries": true}]} with no markdown formatting.'
        response = copilot_handler_internal(build_request(prompt))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        try:
            response_json = json.loads(strip_before_first_curly_bracket(response_text))
        except Exception as e:
            print(response_text)

        self.assertTrue(
            next(
                filter(
                    lambda step: step["name"] == "Run a Script 2",
                    response_json["steps"],
                )
            )["retries"]
        )
        self.assertTrue(
            next(
                filter(
                    lambda step: step["name"] == "Deploy to IIS", response_json["steps"]
                )
            )["retries"]
        )
        self.assertFalse(
            next(
                filter(
                    lambda step: step["name"] == "Configure the load balancer",
                    response_json["steps"],
                )
            )["retries"]
        )
        # This is a red herring. The step is named "Retry this step" but it doesn't actually have retries enabled.
        self.assertFalse(
            next(
                filter(
                    lambda step: step["name"] == "Retry this step",
                    response_json["steps"],
                )
            )["retries"]
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
