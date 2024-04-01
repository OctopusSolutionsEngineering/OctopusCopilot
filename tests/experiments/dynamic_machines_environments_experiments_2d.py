import os
import unittest

from domain.context.octopus_context import collect_llm_context
from domain.messages.targets import build_targets_prompt
from domain.tools.function_definition import FunctionDefinition, FunctionDefinitions
from domain.tools.general_query import answer_general_query_wrapper, AnswerGeneralQuery
from infrastructure.octopus import get_machines, get_environments
from infrastructure.openai import llm_tool_query


def get_test_cases(limit=0):
    """
    Generates a set of test cases based on the status of a real Octopus instance.
    :return: a list of tuples matching a project name, id, status, scoped environments
    """
    machines = get_machines(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                            os.environ.get("TEST_OCTOPUS_SPACE_ID"))
    environments = get_environments(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                                    os.environ.get("TEST_OCTOPUS_SPACE_ID"))

    # Get a list of tuples with environment names and a list of tuples with the machine name and ID
    environment_machines = list(map(lambda e: (
        # environment name
        e.get("Name"),
        # machines in environment
        list(map(lambda m: (
            # machine name
            m.get("Name"),
            # machine id
            m.get("Id")), filter(lambda m: e.get("Id") in m.get("EnvironmentIds"), machines)))), environments))

    if limit > 0:
        return environment_machines[:limit]

    return environment_machines


def general_query_handler(original_query, body, messages):
    api_key = os.environ.get("TEST_OCTOPUS_API_KEY")
    url = os.environ.get("TEST_OCTOPUS_URL")

    # Override the default messages for this experiment
    messages = build_targets_prompt()
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


class DynamicMachineEnvironmentExperiments(unittest.TestCase):
    """
    This test verifies the LLMs ability to match data across 2 dimensions:
    * machine
    * environment
    """

    def test_machines(self):
        # Get the test cases generated from the space
        test_cases = get_test_cases()
        # Loop through each case
        for name, machines in test_cases:
            if len(machines) == 0:
                continue

            with self.subTest(f"{name} - {','.join(map(lambda m: m[0], machines))}"):
                # Create a query that should generate the same result as the test case
                query = (f"List the unique names and IDs of all machines "
                         + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space "
                         + f"belonging to the \"{name}\" environment")

                def get_tools(tool_query):
                    return FunctionDefinitions([FunctionDefinition(
                        answer_general_query_wrapper(tool_query, general_query_handler), AnswerGeneralQuery)])

                result = llm_tool_query(query, get_tools).call_function()

                print(result)
                print(f"Should have found {len(machines)} machines")

                # Make sure the machine is present
                missing_machines = []
                for machine in machines:
                    if not machine[1] in result:
                        missing_machines.append(machine[1])

                self.assertEqual(len(missing_machines), 0, f"Missing machines: {','.join(missing_machines)}")
