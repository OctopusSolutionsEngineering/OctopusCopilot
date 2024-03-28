import unittest

from tenacity import retry

from infrastructure.openai import llm_message_query

test_count = 5
threshold = 80


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


class DeploymentExperiments(unittest.TestCase):
    """
    This test case is used to run experiments against the LLM.

    Unlike other tests, the "test cases" in this class are not expected to be run to validate the correctness of the
    application. Instead, they are used to validate hypotheses and run experiments. Importantly, failed experiments
    are kept here as a reference.

    For this reason, the tests are disabled by not having a suffix of "_test", which prevents them being run by the
    CI/CD process. They can be run manually in the IDE.
    """

    @retry(retry=retry_func)
    def test_get_latest_release(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a simple prompt.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally fails.

        This shows that the LLM is not able to traverse the relationships between the resources in the HCL and the
        deployments in the JSON to find the correct release version without additional instructions. "Tipping" the LLM
        doesn't help either.
        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution!"),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_production_deployments.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_production_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the release version of the latest deployment to the \"Production\" environment for the project \"OctoFX\"?"

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": query})

        print("")
        print(result)

        self.assertTrue("2.10.517" in result)

    @retry(retry=retry_func)
    def test_get_latest_release_cot_prompt(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a simple prompt and
        a chain-of-thought instruction.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         Yes
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes.

        This shows that a COT prompt like "Let's think about this step by step" has a measurable impact on the ability
        of the LLM to extract the correct information from the context.
        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution! "
             + "Let's think about this step by step."),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_production_deployments.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_production_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the release version of the latest deployment to the \"Production\" environment for the project \"OctoFX\"?"

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": query})

        print("")
        print(result)

        self.assertTrue("2.10.517" in result)

    @retry(retry=retry_func)
    def test_get_latest_release_cot_prompt_2(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a simple prompt and
        a chain-of-thought instruction. This test does not reference a "release version", just a version.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         Yes
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes.

        This shows that a COT prompt like "Let's think about this step by step" has a measurable impact on the ability
        of the LLM to extract the correct information from the context.
        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution! "
             + "Let's think about this step by step."),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_production_deployments.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_production_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the version of the latest deployment to the \"Production\" environment for the project \"OctoFX\"?"

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": query})

        print("")
        print(result)

        self.assertTrue("2.10.517" in result)

    @retry(retry=retry_func)
    def test_get_latest_release_cot_prompt_development(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a simple prompt and
        a chain-of-thought instruction. This test does not reference a "release version", just a version. The
        JSON context includes 3 previous deployments.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         Yes
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes.

        This shows that a COT prompt like "Let's think about this step by step" has a measurable impact on the ability
        of the LLM to extract the correct information from the context.
        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution! "
             + "Let's think about this step by step."),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_development_deployments.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_development_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the version of the latest deployment to the \"Development\" environment for the project \"OctoFX\"?"

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": query})

        print("")
        print(result)

        self.assertTrue("2.10.921" in result)

    @retry(retry=retry_func)
    def test_get_latest_release_cot_prompt_development_2(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a simple prompt and
        a chain-of-thought instruction. This test does not reference a "release version" or "version", just the
        deployment. The JSON context includes 3 previous deployments.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         Yes
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes. Note that "test_get_latest_release_cot_prompt_development_corrupted_2" generally
        fails despite having the same prompt.
        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution! "
             + "Let's think about this step by step."),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_development_deployments.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_development_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the latest deployment to the \"Development\" environment for the project \"OctoFX\"?"

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": query})

        print("")
        print(result)

        self.assertTrue("2.10.921" in result)

    @retry(retry=retry_func)
    def test_get_latest_release_cot_prompt_development_corrupted(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a simple prompt and
        a chain-of-thought instruction. The JSON context includes 3 previous deployments. The HCL context is
        syntactically invalid with a string that is spanning multiple lines.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         Yes
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes.

        This shows that a COT prompt like "Let's think about this step by step" has a measurable impact on the ability
        of the LLM to extract the correct information from the context. It also shows that the LLM does not need strictly
        valid HCL to extract the correct information.
        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution! "
             + "Let's think about this step by step."),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_development_deployments_corrupted.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_development_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the version of the latest deployment to the \"Development\" environment for the project \"OctoFX\"?"

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": query})

        print("")
        print(result)

        self.assertTrue("2.10.921" in result)

    @retry(retry=retry_func)
    def test_get_latest_release_cot_prompt_development_corrupted_2(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a simple prompt and
        a chain-of-thought instruction. This test does not reference a "release version", just a version. The
        JSON context includes 3 previous deployments. The HCL context is syntactically invalid with a string that
        is spanning multiple lines.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         Yes
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally fails.

        The difference between this test and "test_get_latest_release_cot_prompt_development_corrupted" is only the
        that the prompt does not reference a "release version", just the latest deployment. This test returns the
        deployment ID instead. This is perhaps expected, although "test_get_latest_release_cot_prompt_development_2"
        generally passes and has the same prompt.

        This shows that corrupted HCL can impact the reliability of the answer.
        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution! "
             + "Let's think about this step by step."),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_development_deployments_corrupted.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_development_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the latest deployment to the \"Development\" environment for the project \"OctoFX\"?"

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": query})

        print("")
        print(result)

        self.assertTrue("2.10.921" in result)

    @retry(retry=retry_func)
    def test_get_latest_release_few_shot_cot(self):
        """
        Tests how the LLM extracts the release version of a deployment to an environment with a chain of thought
        prompt.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        Yes
        Few-Shot Example:   Yes
        Tipping:            Yes

        This test generally passes.

        """

        messages = [
            ("system",
             "The supplied HCL context provides details on projects, environments, channels, and tenants. "
             + "The supplied JSON context provides details on deployments and releases. "
             + "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL. "
             + "You must assume the resources in the HCL and JSON belong to the same space as each other. "
             + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
             + "I’m going to tip $500 for a better solution!"),
            ("user", "{input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "JSON: ###\n{json}\n###"),
            ("user", "HCL: ###\n{hcl}\n###")]

        with open('octofx_production_deployments.tf', 'r') as file:
            hcl = file.read()

        with open('octofx_production_deployments.json', 'r') as file:
            json = file.read()

        query = "What is the release version of the latest deployment to the \"Production\" environment for the project \"OctoFX\"?"

        few_shot = f"""
Task: What is the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment for the "MyChannel" channel and the "My Tenant" tenant?

Example 1:
HCL: ###
resource "octopusdeploy_environment" "theenvironmentresource" {{
id                           = "Environments-96789"
name                         = "MyEnvironment"
}}
resource "octopusdeploy_project" "theprojectresource" {{
id = "Projects-91234"
name = "My Project"
}}
resource "octopusdeploy_tenant" "thetennatresource" {{
id = "Tenants-9234"
name = "My Tenant"
}}
resource "octopusdeploy_channel" "thechannelresource" {{
id = "Channels-97001"
name = "MyChannel"
}}
###
JSON: ###
[
{{
    "Id": "Deployments-16435",
    "ProjectId": "Projects-91234",
    "EnvironmentId": "Environments-76534",
    "ReleaseId": "Releases-13568",
    "DeploymentId": "Deployments-16435",
    "TaskId": "ServerTasks-701983",
    "TenantId": "Tenants-9234",
    "ChannelId": "Channels-97001",
    "ReleaseVersion": "2.0.1",
    "Created": "2024-03-13T04:07:59.537+00:00",
    "QueueTime": "2024-03-13T04:07:59.537+00:00",
    "StartTime": "2024-03-13T04:08:00.196+00:00",
    "CompletedTime": "2024-03-13T04:08:47.885+00:00",
    "State": "Success"
}},
{{
    "Id": "Deployments-26435",
    "ProjectId": "Projects-91234",
    "EnvironmentId": "Environments-96789",
    "ReleaseId": "Releases-13568",
    "DeploymentId": "Deployments-26435",
    "TaskId": "ServerTasks-701983",
    "TenantId": "Tenants-9234",
    "ChannelId": "Channels-97001",
    "ReleaseVersion": "1.2.3-mybranch",
    "Created": "2024-03-13T04:07:59.537+00:00",
    "QueueTime": "2024-03-13T04:07:59.537+00:00",
    "StartTime": "2024-03-13T04:08:00.196+00:00",
    "CompletedTime": "2024-03-13T04:08:47.885+00:00",
    "State": "Success"
  }}
]
###
Output:
The HCL resource with the labels "octopusdeploy_environment" and "theenvironmentresource" has an attribute called "name" with the value "MyEnvironment" an an "id" attribute of "Environments-96789". This name matches the environment name in the query. Therefore, we must find deployments with the "EnvironmentId" of "Environments-96789".
The HCL resource with the labels "octopusdeploy_project" and "theprojectresource" has an attribute called "name" with the value "My Project" and "id" attribute of "Projects-91234". This name matches the project name in the query. Therefore, we must find deployments with the "ProjectId" of "Projects-91234".
The HCL resource with the labels "octopusdeploy_tenant" and "thetennatresource" has an attribute called "name" with the value "My Tenant" and an "id" attribute of "Tenants-9234". This name matches the tenant name in the query. Therefore, we must find deployments with the "TenantId" of "Tenants-9234".
The HCL resource with the labels "octopusdeploy_channel" and "thechannelresource" has an attribute called "name" with the value "MyChannel" and an "id" attribute of "Channels-97001". This name matches the channel name in the query. Therefore, we must find deployments with the "ChannelId" of "Channels-97001"
We filter the JSON array of deployments for a items with a "ProjectId" attribute with the value of "Projects-91234", an "EnvironmentId" attribute with the value of "Environments-96789", a "TenantId" attribute with the value of "Tenants-9234", and a "ChannelId" attribute with the value of "Channels-97001".
The deployment with the highest "StartTime" attribute is the latest deployment.
The release version is found in the deployment "ReleaseVersion" attribute.
Therefore, the release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "1.2.3-mybranch".

The answer:
The release version of the latest deployment of the "My Project" project to the "MyEnvironment" environment is "1.2.3-mybranch"

Question: {query}
        """

        result = llm_message_query(messages, {"json": json, "hcl": hcl, "context": None, "input": few_shot})

        print("")
        print(result)

        self.assertTrue("2.10.517" in result)
