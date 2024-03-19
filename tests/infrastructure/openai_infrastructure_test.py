import os
import unittest

from parameterized import parameterized

from infrastructure.openai import llm_tool_query, llm_message_query
from tests.infrastructure.tools.build_test_tools import build_mock_test_tools


class MockRequests(unittest.TestCase):
    """
    Integration tests verifying calls to the OpenAI service.

    These tests should mostly be focused on ensuring tools are correctly matched to queries by having the correct
    function comments, and that the correct entities are extracted from the query.

    Tests can also submit mock data to verify the response. Be aware that LLMs are non-deterministic, so it can be hard
    to verify the response.

    Use the CopilotChatTest class to verify the function calls work against a real Octopus instance.
    """

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

        function = llm_tool_query(query, build_mock_test_tools)

        self.assertEqual(function.function.__name__, "get_mock_octopus_projects")
        self.assertEqual(function.function_args["space_name"], "MySpace")

        results = function.call_function()
        self.assertIn("First Test Project", results)
        self.assertIn("Second Test Project", results)

    def test_empty_arguments(self):
        """
        Tests that the llm can find the appropriate mock function and arguments
        """

        function = llm_tool_query("List the projects saved under the space called \"\".",
                                  build_mock_test_tools)

        self.assertEqual(function.function.__name__, "get_mock_octopus_projects")
        self.assertEqual(function.function_args["space_name"], "")

        try:
            function.call_function()
            self.fail()
        except Exception as e:
            pass

    def test_no_match(self):
        """
        Tests that the llm responds appropriately when no function is a match
        """

        function = llm_tool_query("What is the size of the earth?", build_mock_test_tools)

        self.assertTrue(function.call_function().index("Sorry, I did not understand that request.") != -1)

    def test_general_project_question(self):
        """
        Tests that the llm responds appropriately when no function is a match
        """

        function = llm_tool_query("What does the project \"Project1\" do?", build_mock_test_tools)

        self.assertEqual(function.name, "answer_general_query")

    def test_general_variable_question(self):
        """
        Tests that the llm responds appropriately when no function is a match
        """

        function = llm_tool_query("Where is the variable \"Database\" used in the project \"Project1\"?",
                                  build_mock_test_tools)
        body = function.call_function()

        self.assertEqual(function.name, "answer_general_query")
        self.assertTrue("Database" in body["variable_names"], "body")

    def test_general_project_step_question(self):
        """
        Tests that the llm responds appropriately when no function is a match
        """

        function = llm_tool_query("What do does the step \"Manual Intervention\" in the \"Project1\" do?",
                                  build_mock_test_tools)
        body = function.call_function()

        self.assertEqual(function.name, "answer_general_query")
        self.assertTrue("Manual Intervention" in body["step_names"], "body")

    def test_general_prompt(self):
        """
        Tests that the llm responds some response to a general prompt
        """

        response = llm_message_query([
            ('system', 'You are a helpful agent.'),
            ('user', '{input}')
        ],
            {"input": 'What is the size of the earth?'})

        # Make sure we get some kind of response
        self.assertTrue(response)

    def test_long_prompt(self):
        """
        Tests that the llm fails with the expected message when passed too much context
        """

        current_file_path = os.path.abspath(__file__)
        path_without_filename = os.path.dirname(current_file_path)

        with open(os.path.join(path_without_filename, 'large_example.tf'), 'r') as file:
            data = file.read()

        response = llm_message_query([
            ('system', 'You are a helpful agent.'),
            ('user', '{input}'),
            ('user', '###\n{hcl}\n###')
        ],
            {"input": 'What does this project do?', "hcl": data})

        # Make sure we get some kind of response
        self.assertTrue(response.index("reduce the length of the messages") != -1)


if __name__ == '__main__':
    unittest.main()
