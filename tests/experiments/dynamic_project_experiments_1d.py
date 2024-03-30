import os
import re
import unittest

from domain.context.octopus_context import collect_llm_context
from domain.messages.general import build_hcl_prompt
from domain.tools.function_definition import FunctionDefinition, FunctionDefinitions
from domain.tools.general_query import answer_general_query_callback, AnswerGeneralQuery
from infrastructure.octopus import get_projects
from infrastructure.openai import llm_tool_query


def get_test_cases(limit=0):
    """
    Generates a set of test cases based on the status of a real Octopus instance.
    :return: a list of tuples matching a project name, id, description and versioning strategy template
    """
    projects = get_projects(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                            os.environ.get("TEST_OCTOPUS_SPACE_ID"))

    projects = list(
        map(lambda x: (x["Name"], x["Id"], x["Description"],
                       (x.get("VersioningStrategy") if x.get("VersioningStrategy") else {}).get("Template")),
            projects))

    if limit > 0:
        return projects[:limit]

    return projects


def remove_non_alphanumeric_end(s):
    return re.sub(r'\W+$', '', s)


def remove_empty_lines(s):
    return "\n".join([line for line in s.splitlines() if line.strip()])


def general_query_handler(original_query, body):
    api_key = os.environ.get("TEST_OCTOPUS_API_KEY")
    url = os.environ.get("TEST_OCTOPUS_URL")

    messages = build_hcl_prompt()
    context = {"input": original_query}

    return collect_llm_context(original_query,
                               messages,
                               context,
                               os.environ.get('TEST_OCTOPUS_SPACE_NAME'),
                               body['project_names'],
                               body['runbook_names'],
                               body['target_names'],
                               body['tenant_names'],
                               body['library_variable_sets'],
                               body['environment_names'],
                               body['feed_names'],
                               body['account_names'],
                               body['certificate_names'],
                               body['lifecycle_names'],
                               body['workerpool_names'],
                               body['machinepolicy_names'],
                               body['tagset_names'],
                               body['projectgroup_names'],
                               body['channel_names'],
                               body['release_versions'],
                               body['step_names'],
                               body['variable_names'],
                               api_key,
                               url,
                               None)


class DynamicProjectExperiments(unittest.TestCase):
    """
    DynamicProjectExperiments works by building a set of test cases against a real Octopus instance, then running
    those tests cases via the LLM. This compares results we have determined by handcrafted API calls and data matching
    to what the LLM has extracted from a general context. It allows us to effectively run LLM queries across an entire
    space in an automated fashion to find edge cases that the LLM didn't handle correctly.

    This test verifies the LLMs ability to match data across 1 dimension:
    * project

    The issue at https://intellij-support.jetbrains.com/hc/en-us/community/posts/360000024199-Python-SubTest?utm_source=pocket_saves
    describes how to configure PyCharm to display the output of subtests individually.
    """

    def test_get_cases(self):
        # Get the test cases generated from the space
        test_cases = get_test_cases()
        # Loop through each case
        for name, id, description, template in test_cases:
            with self.subTest(f"{name} - {id} - {description} - {template}"):
                # Create a query that should generate the same result as the test case
                query = (f"What is the ID, description, and versioning strategy template of the project \"{name}\" "
                         + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space. "
                           "Print the description without modification in a code block.")

                def get_tools():
                    return FunctionDefinitions([
                        FunctionDefinition(answer_general_query_callback(query, general_query_handler),
                                           AnswerGeneralQuery), ])

                result = llm_tool_query(query, get_tools).call_function()

                self.assertTrue(id in result, f"Expected \"{id}\" for Project {name} in result:\n{result}")
                if template:
                    self.assertTrue(template in result,
                                    f"Expected \"{template}\" for Project {name} in result:\n{result}")
                if description and description.strip():
                    # The LLM removes empty lines despite being told not to modify the description
                    sanitized_description = remove_empty_lines(description).strip()
                    self.assertTrue(sanitized_description in result,
                                    f"Expected \"{sanitized_description}\" for Project {name} in result:\n{result}")
