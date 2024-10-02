import json
import os
import time
import unittest
from datetime import datetime

from openai import RateLimitError
from requests.exceptions import HTTPError
from retry import retry
from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs

from domain.transformers.sse_transformers import convert_from_sse_response
from function_app import copilot_handler_internal
from infrastructure.octopus import get_users, create_unlimited_api_key
from infrastructure.users import (
    save_users_octopus_url_from_login,
    delete_default_values,
)
from tests.application.test_copilot_chat import build_request
from tests.infrastructure.create_and_deploy_release import create_and_deploy_release
from tests.infrastructure.octopus_config import Octopus_Api_Key, Octopus_Url
from tests.infrastructure.test_octopus_infrastructure import run_terraform


class CopilotChatNoDefaultsTest(unittest.TestCase):
    """
    End-to-end tests that verify the complete query workflow for a user with no permissions. This validates
    how the extension functions when the user has no permissions to the space.
    """

    @classmethod
    def setUpClass(cls):
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

            # Find the service account and create an API key.
            # Note the service account has no permissions to anything.
            users = get_users(Octopus_Api_Key, Octopus_Url)
            service_account = next(
                (user for user in users if user["Username"] == "bsmith"), None
            )
            api_key = create_unlimited_api_key(
                service_account["Id"], Octopus_Api_Key, Octopus_Url
            )

            save_users_octopus_url_from_login(
                os.environ["TEST_GH_USER"],
                Octopus_Url,
                api_key,
                os.environ["ENCRYPTION_PASSWORD"],
                os.environ["ENCRYPTION_SALT"],
                os.environ["AzureWebJobsStorage"],
            )
            delete_default_values(
                os.environ["TEST_GH_USER"], os.environ["AzureWebJobsStorage"]
            )

        except Exception as e:
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
    def test_help(self):
        version = datetime.now().strftime("%Y%m%d.%H.%M.%S")
        create_and_deploy_release(space_name="Simple", release_version=version)
        time.sleep(5)

        response = copilot_handler_internal(build_request("help"))
        response_text = convert_from_sse_response(response.get_body().decode("utf8"))

        # The service account has no permission to any spaces or projects, but should display a link to the docs
        self.assertTrue(
            "https://octopus.com/docs/administration/copilot" in response_text,
            "Prompt was help. Response was " + response_text,
        )


if __name__ == "__main__":
    unittest.main()
