import os
import unittest

from domain.context.octopus_context import collect_llm_context
from domain.sanitizers.sanitize_strings import add_spaces_before_capitals
from domain.tools.function_definition import FunctionDefinition, FunctionDefinitions
from domain.tools.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from infrastructure.octopus import get_feeds
from infrastructure.openai import llm_tool_query


def get_test_cases(limit=0):
    """
    Generates a set of test cases based on the status of a real Octopus instance.
    :return: a list of tuples matching a project name, id, description and versioning strategy template
    """
    tenants = get_feeds(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                        os.environ.get("TEST_OCTOPUS_SPACE_ID"))

    tenants = list(
        map(lambda x: (x.get("Name"), x.get("Id"), x.get("FeedUri"), x.get("FeedType")), tenants))

    if limit > 0:
        return tenants[:limit]

    return tenants


def general_query_handler(original_query, body, messages):
    api_key = os.environ.get("TEST_OCTOPUS_API_KEY")
    url = os.environ.get("TEST_OCTOPUS_URL")

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
    * feed
    """

    def test_feeds(self):
        # Get the test cases generated from the space
        test_cases = get_test_cases()
        # Loop through each case
        for name, id, uri, type in test_cases:

            with self.subTest(f"{name} - {id} - {uri}"):
                # Create a query that should generate the same result as the test case
                query = (f"List the ID, feed type, and URI of the feed \"{name}\" "
                         + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space.")

                def get_tools(tool_query):
                    return FunctionDefinitions([
                        FunctionDefinition(answer_general_query_wrapper(tool_query, general_query_handler),
                                           AnswerGeneralQuery), ])

                result = llm_tool_query(query, get_tools).call_function()

                print(result)

                self.assertTrue(id in result, f"Expected \"{id}\" for Feed {name} in result:\n{result}")

                # The LLM will helpfully expand strings like "AwsElasticContainerRegistry"
                # to "Aws Elastic Container Registry"
                feed_type = add_spaces_before_capitals(type).strip()
                self.assertTrue(feed_type in result or type in result,
                                f"Expected \"{feed_type}\" for Feed {name} in result:\n{result}")

                if uri and uri.strip():
                    self.assertTrue(uri in result, f"Expected \"{uri}\" for Feed {name} in result:\n{result}")
