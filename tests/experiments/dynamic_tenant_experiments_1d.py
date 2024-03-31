import os
import unittest

from domain.context.octopus_context import collect_llm_context
from domain.messages.general import build_hcl_prompt
from domain.sanitizers.sanitize_strings import remove_double_whitespace, remove_empty_lines
from domain.sanitizers.sanitized_list import sanitize_list
from domain.tools.function_definition import FunctionDefinition, FunctionDefinitions
from domain.tools.general_query import answer_general_query_callback, AnswerGeneralQuery
from infrastructure.octopus import get_tenants
from infrastructure.openai import llm_tool_query


def get_test_cases(limit=0):
    """
    Generates a set of test cases based on the status of a real Octopus instance.
    :return: a list of tuples matching a project name, id, description and versioning strategy template
    """
    tenants = get_tenants(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                          os.environ.get("TEST_OCTOPUS_SPACE_ID"))

    tenants = list(
        map(lambda x: (x["Name"], x["Id"], x["Description"], x["TenantTags"]), tenants))

    if limit > 0:
        return tenants[:limit]

    return tenants


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


class DynamicTenantExperiments(unittest.TestCase):
    """
    This test verifies the LLMs ability to match data across 1 dimension:
    * tenant
    """

    def test_tenants(self):
        # Get the test cases generated from the space
        test_cases = get_test_cases()
        # Loop through each case
        for name, id, description, tags in test_cases:
            tags_sanitized = sanitize_list(tags)

            with self.subTest(f"{name} - {id} - {description} - {','.join(tags_sanitized)}"):
                # Create a query that should generate the same result as the test case
                query = (f"List the ID, description, and tenants tags of the tenant \"{name}\" "
                         + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space. "
                         + "Print the description without modification in a code block.")

                def get_tools():
                    return FunctionDefinitions([
                        FunctionDefinition(answer_general_query_callback(query, general_query_handler),
                                           AnswerGeneralQuery), ])

                result = llm_tool_query(query, get_tools).call_function()

                print(result)

                self.assertTrue(id in result, f"Expected \"{id}\" for Tenant {name} in result:\n{result}")

                if description and description.strip():
                    # The LLM removes empty lines despite being told not to modify the description
                    sanitized_description = remove_double_whitespace(remove_empty_lines(description)).strip()
                    self.assertTrue(sanitized_description in result,
                                    f"Expected \"{sanitized_description}\" for Project {name} in result:\n{result}")

                for tag in tags_sanitized:
                    self.assertTrue(tag in result, f"Expected \"{tag}\" for Tenant {name} in result:\n{result}")
