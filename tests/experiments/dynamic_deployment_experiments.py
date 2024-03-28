import json
import os
import unittest

from domain.context.octopus_context import collect_llm_context
from domain.logging.query_loggin import log_query
from domain.messages.deployments_and_releases import build_deployments_and_releases_prompt
from domain.sanitizers.sanitized_list import get_item_or_none, sanitize_list, sanitize_environments
from domain.tools.function_definition import FunctionDefinition, FunctionDefinitions
from domain.tools.releases_and_deployments import answer_releases_and_deployments_callback
from domain.transformers.deployments_from_progression import get_deployment_progression, \
    get_deployment_array_from_progression
from infrastructure.octopus import get_projects, get_environments, get_project_channel, get_lifecycle, \
    get_project_progression_from_ids, get_project_progression, get_dashboard
from infrastructure.openai import llm_tool_query


def get_test_cases():
    """
    Generates a set of test cases based on the status of a real Octopus instance.
    :return: a list of tuples matching a project, environment, and channel to a deployment
    """
    projects = get_projects(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                            os.environ.get("TEST_OCTOPUS_SPACE_ID"))
    environments = get_environments(os.environ.get("TEST_OCTOPUS_API_KEY"), os.environ.get("TEST_OCTOPUS_URL"),
                                    os.environ.get("TEST_OCTOPUS_SPACE_ID"))

    test_cases = []

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
                    test_cases.append((
                        project["Name"],
                        channel["Name"],
                        environment["Name"],
                        list(map(lambda x: x["ReleaseVersion"], environment["Deployments"]))[0],
                    ))

    return test_cases


def releases_query_handler(original_query, enriched_query, space, projects, environments, channels, releases):
    api_key = os.environ.get("TEST_OCTOPUS_API_KEY")
    url = os.environ.get("TEST_OCTOPUS_URL")

    project = get_item_or_none(sanitize_list(projects), 0)
    environments = get_item_or_none(sanitize_list(environments), 0)

    messages = build_deployments_and_releases_prompt()
    context = {"input": enriched_query}

    # We need some additional JSON data to answer this question
    if project:
        # We only need the deployments, so strip out the rest of the JSON
        deployments = get_deployment_array_from_progression(
            json.loads(get_project_progression(space, project, api_key, url)),
            sanitize_environments(environments),
            3)
        context["json"] = json.dumps(deployments, indent=2)
    else:
        context["json"] = get_dashboard(space, api_key, url)

    chat_response = collect_llm_context(original_query,
                                        messages,
                                        context,
                                        space,
                                        project,
                                        None,
                                        None,
                                        None,
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
                                        None,
                                        None,
                                        None,
                                        None,
                                        api_key,
                                        url,
                                        log_query)

    return chat_response


class DynamicDeploymentExperiments(unittest.TestCase):
    """
    DynamicDeploymentExperiments works by building a set of test cases against a real Octopus instance, then running
    those tests cases via the LLM. This compares results we have determined by handcrafted API calls and data matching
    to what the LLM has extracted from a general context. It allows us to effectively run LLM queries across an entire
    space in an automated fashion to find edge cases that the LLM didn't handle correctly.

    Disable warnings using the instructions at https://stackoverflow.com/a/60853866/157605
    """

    def test_get_cases(self):
        # Get the test cases generated from the space
        test_cases = get_test_cases()
        # Loop through each case
        for project, channel, environment, deployment in test_cases:
            with self.subTest(f"{project} - {environment} - {channel}"):
                # Create a query that should generate the same result as the test case
                query = (f"Get the release version of the latest deployment of the \"{project}\" project "
                         + f"to the \"{environment}\" environment "
                         + f"in the \"{channel}\" channel "
                         + f"in the \"{os.environ.get('TEST_OCTOPUS_SPACE_NAME')}\" space.")

                def get_tools():
                    return FunctionDefinitions([
                        FunctionDefinition(
                            answer_releases_and_deployments_callback(query, releases_query_handler, log_query))])

                result = llm_tool_query(query, get_tools, log_query).call_function()

                self.assertTrue(deployment in result,
                                f"Expected {deployment} for Project {project} Environment {environment} and Channel {channel} in result:\n{result}")
