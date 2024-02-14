import os
import unittest

from testcontainers.core.container import DockerContainer
from testcontainers.core.waiting_utils import wait_for_logs

from domain.handlers.copilot_handler import handle_copilot_chat
from domain.logging.app_logging import configure_logging
from tests.infrastructure.tools.build_test_tools import build_test_tools

logger = configure_logging()


class LiveRequests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.mssql = DockerContainer("mcr.microsoft.com/mssql/server:2022-latest").with_bind_ports(1433, 11433).with_env(
            "ACCEPT_EULA", "True").with_env("SA_PASSWORD", "Password01!")
        cls.mssql.start()
        wait_for_logs(cls.mssql, "SQL Server is now ready for client connections")

        cls.octopus = DockerContainer("octopusdeploy/octopusdeploy").with_bind_ports(8080, 8080).with_env(
            "ACCEPT_EULA", "Y").with_env("DB_CONNECTION_STRING",
                                         "Server=172.17.0.1,11433;Database=OctopusDeploy;User=sa;Password=Password01!").with_env(
            "ADMIN_API_KEY", "API-ABCDEFGHIJKLMNOPQURTUVWXYZ12345").with_env("DISABLE_DIND", "Y").with_env(
            "ADMIN_USERNAME", "admin").with_env("ADMIN_PASSWORD", "Password01!").with_env(
            "OCTOPUS_SERVER_BASE64_LICENSE", os.environ["LICENSE"])
        cls.octopus.start()
        wait_for_logs(cls.octopus, "Web server is ready to process requests")

    @classmethod
    def tearDownClass(cls):
        try:
            cls.octopus.stop()
        except:
            pass

        try:
            cls.mssql.stop()
        except:
            pass

    def test_get_projects(self):
        """
        Tests that the llm can find the appropriate mock function and arguments
        """

        functions = build_test_tools()
        function = handle_copilot_chat("What are the projects associated with space MySpace?", functions.get_tools())

        self.assertEqual(function.function_name, "get_octopus_projects")
        self.assertEqual(function.function_args["space_name"], "MySpace")
        self.assertEqual(functions.call_function(function), ["Project1", "Project2"])


if __name__ == '__main__':
    unittest.main()
