import unittest

from tenacity import retry

from domain.tools.wrapper.function_definition import FunctionDefinitions, FunctionDefinition
from infrastructure.openai import llm_tool_query

# How many times to rerun the experiment. LLMs are non-deterministic, so you do need to rerun them multiple times.
test_count = 5
# The percent of successful experiments to consider the test a success. 100% is unreasonable with non-deterministic
# systems like LLMs. 80% is a good starting point.
threshold = 80


# Define functions with comments that represent the functions that would be called by the copilot extension.
# These functions do not need to do any work, but should have the same function names and descriptions.

def approve_release_to_environment(space_name=None, project_name=None, release_version=None, environment_name=None,
                                   tenant_name=None, **kwargs):
    """Responds to queries like: "Approve release 0.98.1 to the environment Test" or
       "Approve "0.0.1" in the Dev environment." or "Approve the latest release in the Test environment."
    """

    return approve_manual_intervention(space_name, project_name, release_version, environment_name, tenant_name,
                                       **kwargs)


def approve_manual_intervention_for_environment(space_name=None, project_name=None, release_version=None,
                                                environment_name=None,
                                                tenant_name=None, **kwargs):
    """Responds to queries like: "Approve the manual intervention for 0.98.1 to the Development environment" or
       "Approve the manual intervention for the latest release to the Production environment."
    """

    return approve_manual_intervention(space_name, project_name, release_version, environment_name, tenant_name,
                                       **kwargs)


def approve_manual_intervention(space_name=None, project_name=None, release_version=None, environment_name=None,
                                tenant_name=None, **kwargs):
    """Answers queries about approving a manual intervention for a release. Use this function when the query is
       asking to approve a manual intervention. You will be penalized for selecting this function for a question
       about the status of a deployment.
Questions can look like those in the following list:
* Approve 4.0.1 to Test.
* Approve 0.2.1 to the Development environment for the project Contoso.
* Approve release 0.98.1 to the environment Production.
* Approve the latest release in the Test environment.
* Approve the manual intervention for 3.17.8 to the Staging environment.

    Args:
    space_name: The name of the space
    project_name: The name of the project
    release_version: The release version
    environment_name: The name of the environment
    tenant_name: The (optional) name of the tenant
    """

    # No actual work needs to be done for this experiment
    return "Success!"


def general_query_handler(query, body, messages):
    return body


def retry_func(retry_state):
    """
    This retry function reruns the test a fixed number of times and calculates success based on the results
    of all the attempts. This is different from the usual concept of retrying a test which will retry until
    the first successful attempt. We are essentially hacking the retry feature to allow us to run a fixed number
    of experiments rather than dealing with flaky tests.
    """

    # Add success and failed counts to the retry object
    if not retry_state.retry_object.statistics.get("failed_count"):
        retry_state.retry_object.statistics["failed_count"] = 0
    if not retry_state.retry_object.statistics.get("success_count"):
        retry_state.retry_object.statistics["success_count"] = 0

    # tally the successes and failures
    if retry_state.outcome.failed:
        retry_state.retry_object.statistics["failed_count"] += 1
    else:
        retry_state.retry_object.statistics["success_count"] += 1

    # Calculate the results on the last test
    if retry_state.retry_object.statistics["attempt_number"] == test_count:
        success_percent = retry_state.retry_object.statistics['success_count'] / test_count * 100
        print("")
        if test_count == 0:
            print("Success percent: 0.0%")
        else:
            print(f"Success percent: {success_percent}%")

        # Success is the outcome of all the attempts, not just the last attempt
        retry_state.outcome = True if success_percent >= threshold else False

    return retry_state.attempt_number <= test_count


class FunctionCallingLiteralExampleExperiment(unittest.TestCase):
    """
    This test case is used to run experiments against the LLM.

    Unlike other tests, the "test cases" in this class are not expected to be run to validate the correctness of the
    application. Instead, they are used to validate hypotheses and run experiments. Importantly, failed experiments
    are kept here as a reference.

    For this reason, the tests are disabled by not having a suffix of "_test", which prevents them being run by the
    CI/CD process. They can be run manually in the IDE.
    """

    @retry(retry=retry_func)
    def test_manual_approval_prompt_selection(self):
        """
        Tests how the LLM chooses the right function tool implementation based on the prompt and other tools that are available.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            No

        This test generally fails.

        This shows that the LLM is not able to determine the correct tool to use when parsing the provided query prompt.
        """

        query = "Approve \"0.0.1\" to the \"Staging\" environment"

        function = llm_tool_query(query, FunctionDefinitions([FunctionDefinition(tool) for tool
                                                              in [approve_release_to_environment,
                                                                  approve_manual_intervention_for_environment,
                                                                  approve_manual_intervention]]))

        # If a function is not matched, the fallback function called "none" is returned
        print(f"Function chosen: {function.name}")
        self.assertNotEqual(function.name, "none")
