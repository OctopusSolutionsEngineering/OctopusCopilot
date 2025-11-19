import os
import unittest

from domain.context.octopus_context import collect_llm_context
from domain.messages.general import build_hcl_prompt
from domain.tools.wrapper.function_definition import (
    FunctionDefinition,
    FunctionDefinitions,
)
from domain.tools.wrapper.targets_query import answer_machines_wrapper
from infrastructure.octopus import (
    get_machines,
    get_environments,
    get_space_id_and_name_from_name,
)
from infrastructure.llm import llm_tool_query


def get_test_cases(limit=0):
    """
    Generates a set of test cases based on the status of a real Octopus instance.
    :return: a list of tuples matching a project name, id, status, scoped environments
    """
    machines = get_machines(
        os.environ.get("TEST_OCTOPUS_API_KEY"),
        os.environ.get("TEST_OCTOPUS_URL"),
        os.environ.get("TEST_OCTOPUS_SPACE_ID"),
    )
    environments = get_environments(
        os.environ.get("TEST_OCTOPUS_API_KEY"),
        os.environ.get("TEST_OCTOPUS_URL"),
        os.environ.get("TEST_OCTOPUS_SPACE_ID"),
    )

    # Get a list of tuples with environment names and a list of tuples with the machine name and ID
    environment_machines = list(
        map(
            lambda e: (
                # environment name
                e.get("Name"),
                # machines in environment
                list(
                    map(
                        lambda m: (
                            # machine name
                            m.get("Name"),
                            # machine id
                            m.get("Id"),
                        ),
                        filter(
                            lambda m: e.get("Id") in m.get("EnvironmentIds"), machines
                        ),
                    )
                ),
            ),
            environments,
        )
    )

    if limit > 0:
        return environment_machines[:limit]

    return environment_machines


def targets_callback(
    original_query,
    messages,
    space,
    projects,
    runbooks,
    targets,
    tenants,
    environments,
    accounts,
    certificates,
    workerpools,
    machinepolicies,
    tagsets,
    steps,
):
    api_key = os.environ.get("TEST_OCTOPUS_API_KEY")
    url = os.environ.get("TEST_OCTOPUS_URL")

    # Override the default messages for this experiment
    messages = build_hcl_prompt(messages)
    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, api_key, url)

    return collect_llm_context(
        original_query,
        messages,
        context,
        space_id,
        projects,
        runbooks,
        targets,
        tenants,
        None,
        environments,
        None,
        accounts,
        certificates,
        None,
        workerpools,
        machinepolicies,
        tagsets,
        None,
        None,
        None,
        steps,
        None,
        None,
        api_key,
        "",
        url,
        None,
    )


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
                query = (
                    f"What are the unique names and IDs of all machines "
                    + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space "
                    + f'belonging to the "{name}" environment?'
                )

                def get_tools(tool_query):
                    return FunctionDefinitions(
                        [
                            FunctionDefinition(
                                answer_machines_wrapper(tool_query, targets_callback)
                            )
                        ]
                    )

                result = llm_tool_query(query, get_tools).call_function()

                print(result)
                print(f"Should have found {len(machines)} machines")

                # Make sure the machine is present
                missing_machines = []
                found_machines = 0
                for machine in machines:
                    if not machine[1] in result:
                        missing_machines.append(machine[0] + " (" + machine[1] + ")")
                    else:
                        found_machines += 1

                self.assertEqual(
                    len(missing_machines),
                    0,
                    f"Found {found_machines} and missed {len(machines) - found_machines} machines. "
                    + f"Missing machines: {','.join(missing_machines)}",
                )
