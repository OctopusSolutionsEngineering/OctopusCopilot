import unittest

from parameterized import parameterized

from domain.handlers.copilot_handler import handle_copilot_chat
from tests.infrastructure.tools.build_test_tools import build_mock_test_tools


class MockRequests(unittest.TestCase):

    @parameterized.expand([
        "What are the projects associated with space MySpace?",
        "List the projects saved under MySpace.",
        "projcets under MySpace.",
        "Please show me the projects that have been created under the space called MySpace.",
    ])
    def test_get_projects(self, query):
        """
        Tests that the llm can find the appropriate mock function and arguments
        """

        function = handle_copilot_chat(query, build_mock_test_tools)

        self.assertEqual(function.function.__name__, "get_octopus_projects")
        self.assertEqual(function.function_args["space_name"], "MySpace")
        self.assertEqual(function.call_function(), ["Project1", "Project2"])

    def test_no_match(self):
        """
        Tests that the llm responds appropriately when no function is a match
        """

        function = handle_copilot_chat("What is the size of the earth?", build_mock_test_tools)

        self.assertTrue(function.call_function().index("Sorry, I did not understand that request.") != -1)


if __name__ == '__main__':
    unittest.main()
