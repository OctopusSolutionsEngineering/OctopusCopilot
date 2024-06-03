import json
import os
import unittest

from domain.config.openai import max_context
from domain.context.octopus_context import collect_llm_context
from domain.sanitizers.sanitized_list import get_item_or_none, sanitize_list, sanitize_environments, sanitize_tenants
from domain.tools.query.function_definition import FunctionDefinition, FunctionDefinitions
from domain.tools.query.releases_and_deployments import answer_releases_and_deployments_wrapper
from domain.transformers.deployments_from_progression import get_deployment_progression
from domain.transformers.deployments_from_release import get_deployments_for_project
from infrastructure.octopus import get_projects, get_environments, get_project_channel, get_lifecycle, \
    get_project_progression_from_ids, get_dashboard, get_space_id_and_name_from_name
from infrastructure.openai import llm_tool_query


def get_test_cases(release_index=0, limit=0):
    """
    Generates a set of test cases based on the status of a real Octopus instance.
    :return: a list of tuples matching a project, environment, and channel to a deployment
    """
    projects = get_projects(os.environ.get("TEST_OCTOPUS_SPACE_ID"), os.environ.get("TEST_OCTOPUS_API_KEY"),
                            os.environ.get("TEST_OCTOPUS_URL"))
    environments = get_environments(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                                    os.environ.get("TEST_OCTOPUS_SPACE_ID"))

    test_cases = []

    count = 0
    for project in projects:
        if not project["TenantedDeploymentMode"] == "Untenanted":
            continue

        progression = get_project_progression_from_ids(os.environ.get("TEST_OCTOPUS_SPACE_ID"),
                                                       project["Id"],
                                                       os.environ.get("TEST_OCTOPUS_API_KEY"),
                                                       os.environ.get("TEST_OCTOPUS_URL"))

        project["Channels"] = get_project_channel(os.environ.get("TEST_OCTOPUS_API_KEY"),
                                                  os.environ.get("TEST_OCTOPUS_URL"),
                                                  os.environ.get("TEST_OCTOPUS_SPACE_ID"), project["Id"])

        for channel in project["Channels"]:
            lifecycle_id = channel["LifecycleId"] if channel["LifecycleId"] else project["LifecycleId"]
            channel["Lifecycle"] = get_lifecycle(os.environ.get("TEST_OCTOPUS_API_KEY"),
                                                 os.environ.get("TEST_OCTOPUS_URL"),
                                                 os.environ.get("TEST_OCTOPUS_SPACE_ID"), lifecycle_id)
            channel["Lifecycle"]["Environments"] = []
            for phase in channel["Lifecycle"]["Phases"]:
                for environment in phase["AutomaticDeploymentTargets"]:
                    channel["Lifecycle"]["Environments"].append(
                        [env for env in environments if env["Id"] == environment][0])
                for environment in phase["OptionalDeploymentTargets"]:
                    channel["Lifecycle"]["Environments"].append(
                        [env for env in environments if env["Id"] == environment][0])

            for environment in channel["Lifecycle"]["Environments"]:
                environment["Deployments"] = get_deployment_progression(progression, environment["Id"], channel["Id"])

        for channel in project["Channels"]:
            for environment in channel["Lifecycle"]["Environments"]:
                if environment["Deployments"]:

                    release = list(map(lambda x: x["ReleaseVersion"], environment["Deployments"]))

                    if len(release) > release_index:
                        test_cases.append((
                            project["Name"],
                            channel["Name"],
                            environment["Name"],
                            release[release_index],
                        ))

                        # early exit when a limit it set
                        count += 1
                        if 0 < limit <= count:
                            return test_cases

    return test_cases


def releases_query_handler(original_query, messages, space, projects, environments, channels, releases, tenants, dates,
                           **kwargs):
    api_key = os.environ.get("TEST_OCTOPUS_API_KEY")
    url = os.environ.get("TEST_OCTOPUS_URL")

    project = get_item_or_none(sanitize_list(projects), 0)
    environments = get_item_or_none(sanitize_list(environments), 0)

    context = {"input": original_query}

    space_id, actual_space_name = get_space_id_and_name_from_name(space, api_key, url)

    # We need some additional JSON data to answer this question
    if project:
        # We only need the deployments, so strip out the rest of the JSON
        deployments = get_deployments_for_project(space_id,
                                                  get_item_or_none(sanitize_list(projects), 0),
                                                  sanitize_environments(original_query, environments),
                                                  sanitize_tenants(tenants),
                                                  api_key,
                                                  url,
                                                  max_context)
        context["json"] = json.dumps(deployments, indent=2)
    else:
        context["json"] = get_dashboard(space_id, api_key, url)

    chat_response = collect_llm_context(original_query,
                                        messages,
                                        context,
                                        space_id,
                                        project,
                                        None,
                                        None,
                                        tenants,
                                        None,
                                        environments,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        None,
                                        channels,
                                        releases,
                                        None,
                                        None,
                                        None,
                                        api_key,
                                        url,
                                        None)

    return chat_response


class DynamicDeploymentExperiments(unittest.TestCase):
    """
    DynamicDeploymentExperiments works by building a set of test cases against a real Octopus instance, then running
    those tests cases via the LLM. This compares results we have determined by handcrafted API calls and data matching
    to what the LLM has extracted from a general context. It allows us to effectively run LLM queries across an entire
    space in an automated fashion to find edge cases that the LLM didn't handle correctly.

    This test verifies the LLMs ability to match data across 4 dimensions:
    * project
    * environment
    * channel
    * deployments

    Executive Summary
    -----------------

    This experiment always used a CoT and few-shot prompt.

    GPT 3.5 was reasonably good at this task, passing over 90% of the tests (in 20 minutes) when the last deployments
    provided by the progression endpoint wee used (usually just a few deployments).

    GPT 4 also had a success rate of 90%, but it took 40 minutes to complete.

    The tests that failed were different between GPT3.5 and GPT4, but GPT 4 didn't increase the success rate,
    took twice as long, and costs 100 times as much.

    The success rate for GPT 3.5 hovered around 80% with tests that returned the last 10, 20, and 30 deployments.
    This wasn't an indepth test, as the deployments were already sorted and we were asking for the latest one.

    Changing the JSON structure from a top level array of deployment items to an object with a property called
    "Deployments" that held the array improved the success rate from 50% to 80%:
    * Test Results - Unittests_for_dynamic_deployment_experiments_4d_DynamicDeploymentExperiments_test_second_latest_release.html (top level array)
    * Test Results - Unittests_for_dynamic_deployment_experiments_4d_DynamicDeploymentExperiments_test_second_latest_release_2.html (object with "Deployments" property)

    """

    def test_latest_release(self):
        # Get the test cases generated from the space
        test_cases = get_test_cases()
        # Loop through each case
        for project, channel, environment, deployment in test_cases:
            with self.subTest(f"{project} - {environment} - {channel}"):
                # Create a query that should generate the same result as the test case
                query = (f"What is the release version of the latest deployment of the \"{project}\" project "
                         + f"to the \"{environment}\" environment "
                         + f"in the \"{channel}\" channel "
                         + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space?")

                def get_tools(tool_query):
                    return FunctionDefinitions([
                        FunctionDefinition(
                            answer_releases_and_deployments_wrapper(tool_query, releases_query_handler))])

                result = llm_tool_query(query, get_tools).call_function()

                self.assertTrue(deployment in result,
                                f"Expected {deployment} for Project {project} Environment {environment} and Channel {channel} in result:\n{result}")

    def test_second_latest_release(self):
        # Get the test cases generated from the space
        test_cases = get_test_cases(1)
        # Loop through each case
        for project, channel, environment, deployment in test_cases:
            with self.subTest(f"{project} - {environment} - {channel}"):
                # Create a query that should generate the same result as the test case
                query = (f"What is the release version of the second last deployment of the \"{project}\" project "
                         + f"to the \"{environment}\" environment "
                         + f"in the \"{channel}\" channel "
                         + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space?")

                def get_tools(tool_query):
                    return FunctionDefinitions([
                        FunctionDefinition(
                            answer_releases_and_deployments_wrapper(tool_query, releases_query_handler))])

                result = llm_tool_query(query, get_tools).call_function()

                self.assertTrue(deployment in result,
                                f"Expected {deployment} for Project {project} Environment {environment} and Channel {channel} in result:\n{result}")

                print(result)
