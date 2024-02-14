import unittest

from domain.handlers.copilot_handler import handle_copilot_chat
from tests.infrastructure.tools.build_test_tools import build_test_tools


class MockTestProjects(unittest.TestCase):
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
