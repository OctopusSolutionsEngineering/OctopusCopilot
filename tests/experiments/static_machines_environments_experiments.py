import unittest

from tenacity import retry

from infrastructure.openai import llm_message_query

# How many times to rerun the experiment. LLMs are non-deterministic, so you do need to rerun them multiple times.
test_count = 1
# The percent of successful experiments to consider the test a success. 100% is unreasonable with non-deterministic
# systems like LLMs. 80% is a good starting point.
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
        success_percent = (
            retry_state.retry_object.statistics["success_count"] / test_count * 100
        )
        print("")
        if test_count == 0:
            print("Success percent: 0.0%")
        else:
            print(f"Success percent: {success_percent}%")

        # Success is the outcome of all the attempts, not just the last attempt
        retry_state.outcome = True if success_percent >= threshold else False

    return retry_state.attempt_number <= test_count


class StaticDeploymentExperiments(unittest.TestCase):
    """
    This test case is used to run experiments against the LLM.

    Unlike other tests, the "test cases" in this class are not expected to be run to validate the correctness of the
    application. Instead, they are used to validate hypotheses and run experiments. Importantly, failed experiments
    are kept here as a reference.

    For this reason, the tests are disabled by not having a suffix of "_test", which prevents them being run by the
    CI/CD process. They can be run manually in the IDE.

    Executive Summary
    -----------------

    GPT 3.5 displayed some unusual behaviour where it detected patterns in the names of groups of targets and
    excluded "odd" targets that didn't match the pattern. Changing the order in which targets were processed by moving
    the "odd" targets to the start of the context changed the outcome by allowing the "odd" targets to be included in
    the answer. Renaming the "odd" targets to match the pattern also allowed them to be included in the answer.

    Although it is not captured in these test cases (I found and fixed the bug), having a context where some, but not
    all, targets lacked the id attribute also impacted the answer. The LLM would not include a target without an ID,
    presumably because the question asked for the ID in the answer.

    Observations:
    * A chain-of-thought and few-shot prompt helped the LLM to generate the correct answer.
    * Reducing the context size by removing unrelated targets also helped.
    * Ensuring the context was consistent (with every target having an ID) helped.
    """

    @retry(retry=retry_func)
    def test_get_development_machines(self):
        """
        Tests how the LLM extracts the targets in an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally fails.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open("context/matthew_casperson_development_machines.tf", "r") as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_2(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes.

        The only change between this test and "test_get_development_machines" is that the
        resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis" was moved from the top
        of the file to the second resource.

        This shows that small changes in the context can impact the results.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_azure_second.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_3(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally fails.

        This test removes a bunch of targets that were not scoped to the "Development" environment. It leaves in quite
        a few that are not scoped, but the overall size of the context is significantly reduced. The azure target
        has been moved to lower in the file. Interesting this still fails.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_trimmed.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_4(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally fails.

        This test removes a bunch of targets that were not scoped to the "Development" environment. It leaves only
         one target not scoped to the Development environment. The azure target has been moved to lover in the file.
         This still fails.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_trimmed_2.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_5(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes, but not because it returned the correct information.

        This test removes a all targets that were not scoped to the "Development" environment. The azure target has
        been moved to lover in the file.

        This tests passes, but only because the message below mentions the iis target:
        Please note that the "azure-iis" machine is not included as it is not a cloud region deployment target.

        For some reason the LLM is excluding the azure target from the results.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_trimmed_3.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_6(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes, but not because it returned the correct information.

        This test removes a all targets that were not scoped to the "Development" environment. The azure target has
        been moved to lover in the file.

        This tests passes, but only because the message below mentions the iis target:
        Please note that the "azure-iis" machine is not included as it is not a cloud region deployment target.

        For some reason the LLM is excluding the azure target from the results.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_trimmed_3.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_7(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes.

        This test removes all targets that were not scoped to the "Development" environment. The azure target has
        been moved to the top of the file.

        This test passes.

        This shows the LLM can be influenced by the order of the targets in the context.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_trimmed_4.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_8(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                Yes
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally fails.

        This test removes all targets that were not scoped to the "Development" environment. The azure target has
        been moved to lover in the file.

        This test fails, but often provides the insight that the LLM considered the cloud region targets to be
        the only machines in an environment. For example, you can find output like this:

        Looking at the HCL context, we can see that the machines are defined using the
        "octopusdeploy_cloud_region_deployment_target" resource type. We need to filter these resources based on the
        "environments" attribute to find the machines belonging to the "Development" environment.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            # The LLM didn't know how to identify all the targets
            (
                "system",
                'You must treat the terms "machines", "targets", and "agents" as interchangeable. ',
            ),
            (
                "system",
                "The following list of HCL resources define targets:\n"
                + "- octopusdeploy_listening_tentacle_deployment_target\n"
                + "- octopusdeploy_polling_tentacle_deployment_target\n"
                + "- octopusdeploy_cloud_region_deployment_target\n"
                + "- octopusdeploy_kubernetes_cluster_deployment_target\n"
                + "- octopusdeploy_ssh_connection_deployment_target\n"
                + "- octopusdeploy_offline_package_drop_deployment_target\n"
                + "- octopusdeploy_azure_cloud_service_deployment_target\n"
                + "- octopusdeploy_azure_service_fabric_cluster_deployment_target\n"
                + "- octopusdeploy_azure_web_app_deployment_target",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            (
                "user",
                "Imagine three different experts are answering this question. All experts will write down 1 step of their thinking, then share it with the group. Then all experts will go on to the next step, etc. If any expert realises they're wrong at any point then they leave. The question is...",
            ),
            # Get the LLM to implement a chain-of-thought
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_trimmed_3.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_9(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes, but not because it returned the correct information.

        This test presents a list of octopusdeploy_target machines that are not scoped to the "Development" environment.
        The only difference between them is the resource name and the machine name. Six of the machines have the prefix
        "pos-dev-", while the seventh machine is called "azure_iis".

        The LLM excludes the "azure_iis" machine from the results. My assumption here is that it has identified the
        naming convention used by the other machines and excluded the "azure_iis" machine because it doesn't fit the
        pattern.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_normalized.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'First, find every machine with any role that belongs to the "Development" environment. Second, find the machine\'s ID and name. Finally, list the machines name and ID.'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_10(self):
        """
        Tests how the LLM extracts the targets for an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        No
        Few-Shot Example:   No
        Tipping:            Yes

        This test generally passes.

        The difference between this test and "test_get_development_machines_9" is that all the machines have the
        prefix "pos-dev-". The LLM is able to identify all the machines in this case.

        There is definitely some pattern matching going on that I have not been able to override with system instructions.
        """

        messages = [
            (
                "system",
                "You are methodical agent who understands Terraform modules defining Octopus Deploy resources.",
            ),
            (
                "system",
                "The supplied HCL context provides details on Octopus resources like "
                + "projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, "
                + "library variable sets etc.",
            ),
            (
                "system",
                "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space.",
            ),
            (
                "system",
                "You must assume the supplied HCL is a complete and accurate representation of the Octopus space.",
            ),
            (
                "system",
                "You must assume all resources in the supplied HCL belong to the space mentioned in the question.",
            ),
            # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
            # resulted in the LLM providing instructions on how to find the information rather than presenting
            # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
            # The phrase "what" seems to be important in the question.
            (
                "system",
                "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
                + "are asking you to return 'what' the value of the requested information is.",
            ),
            # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
            # guide the LLM to provide as much information as possible in the answer, and not treat missing
            # information as an error.
            (
                "system",
                "Your answer must include any information you found in the HCL context relevant to the question.",
            ),
            (
                "system",
                "Your answer must clearly state if the supplied context does not provide the requested information.",
            ),
            (
                "system",
                "You must assume a missing HCL attribute means the value is empty.",
            ),
            (
                "system",
                "You must provide a response even if the context does not provide some of the requested information.",
            ),
            (
                "system",
                "It is ok if you can not find most of the requested information in the context - "
                + "just provide what you can find.",
            ),
            # The LLM will often provide a code sample that describes how to find the answer if the context does not
            # provide the requested information.
            (
                "system",
                "You will be penalized for providing a code sample as the answer.",
            ),
            (
                "system",
                'You must assume that if a target\'s "environments" attribute is empty, '
                + "it is not related to the environment in the question. ",
            ),
            # Sparkle that may improve the quality of the responses.
            ("system", "I’m going to tip $500 for a better solution!"),
            ("user", "{input}"),
            ("user", "Answer the question using the HCL below."),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_normalized_2.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'First, find every machine with any role that belongs to the "Development" environment. Second, find the machine\'s ID and name. Finally, list the machines name and ID.'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        print("")
        print(result)

        machines = [
            "pos-dev-azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )

    @retry(retry=retry_func)
    def test_get_development_machines_11(self):
        """
        Tests how the LLM extracts the targets in an environment associated with a space.

        Features
        -----------------------
        ToT:                No
        CoT Prompt:         No
        CoT Example:        Yes
        Few-Shot Example:   Yes
        Tipping:            Yes

        This test generally passes with a trimmed, but still not absolutely sanitized, context. The test
        "test_get_development_machines_4" fails with the same context. This shows we can get a better answer
        with a CoT and few-shot example.
        """

        messages = [
            (
                "system",
                "The supplied HCL context provides details on projects, environments, tenants, targets, machines, and agents.",
            ),
            (
                "system",
                "You must link the targets to the projects, environments, and tenants.",
            ),
            ("system", "You must include the azure-iss target."),
            ("system", "I’m going to tip $500 for a better solution!"),
            (
                "user",
                'Question1: List the name and ID of targets that belong to the "Test" environment.',
            ),
            (
                "user",
                """HCL1: ###
resource "octopusdeploy_environment" "environment_test" {{
  id                           = "Environments-10923"
  name                         = "Test"
}}
resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis" {{
  id                                = "Machines-18962"
  environments                      = [octopusdeploy_environment.environment_test.id]
  name                              = "Web App"
  roles                             = ["payments-team"]
}}
resource "octopusdeploy_cloud_region_deployment_target" "target_sydney_client_5" {{
  id                                = "Machines-18477"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "sydney-client-5"
  roles                             = ["payments-team"]
}}
resource "octopusdeploy_polling_tentacle_deployment_target" "target_azure_iis_2" {{
  id                                = "Machines-19002"
  environments                      = [octopusdeploy_environment.environment_test.id]
  name                              = "Web App 2"
  roles                             = ["payments-team"]
}}
resource octopusdeploy_kubernetes_cluster_deployment_target test_eks {{
id                                = "Machines-18963"
  cluster_url                       = "https://cluster"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "Worker Cluster"
  roles                             = ["payments-team"]
}}
resource "octopusdeploy_ssh_connection_deployment_target" "target_3_25_215_87" {{
  id                    = "Machines-18964"
  environments          = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                  = "Linux Jump Box"
  roles                 = ["vm"]
}}
resource "octopusdeploy_listening_tentacle_deployment_target" "target_vm_listening_ngrok" {{
  id                                = "Machines-18965"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "Database"
  roles                             = ["vm"]
}}
resource "octopusdeploy_offline_package_drop_deployment_target" "target_offline" {{
  id                                = "Machines-18966"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "Remote Site"
  roles                             = ["offline"]
}}
resource "octopusdeploy_azure_cloud_service_deployment_target" "target_azure" {{
  id                                = "Machines-18967"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "Old Azure Service"
  roles                             = ["cloud"]
}}
resource "octopusdeploy_azure_service_fabric_cluster_deployment_target" "target_service_fabric" {{
  id                                = "Machines-18968"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "Finance Cluster"
  roles                             = ["cloud"]
}}
resource "octopusdeploy_azure_web_app_deployment_target" "target_web_app" {{
  id                                = "Machines-14526"
  environments                      = ["${{octopusdeploy_environment.environment_test.id}}"]
  name                              = "New Web App"
  roles                             = ["cloud"]
}}
resource "octopusdeploy_azure_web_app_deployment_target" "target_web_app_prod" {{
  id                                = "Machines-14530"
  environments                      = ["${{octopusdeploy_environment.environment_production.id}}"]
  name                              = "New Web App Prod"
  roles                             = ["azure"]
}}
###
Answer 1:
First, find the environment with the name "Development".  The "octopusdeploy_environment" resource has the name "Development". This is the environment that the targets must be assigned to.
Second, find the following resources that represent targets or machines:
- "octopusdeploy_cloud_region_deployment_target"
- "octopusdeploy_polling_tentacle_deployment_target"
- "octopusdeploy_kubernetes_cluster_deployment_target"
- "octopusdeploy_ssh_connection_deployment_target"
- "octopusdeploy_listening_tentacle_deployment_target"
- "octopusdeploy_offline_package_drop_deployment_target"
- "octopusdeploy_azure_cloud_service_deployment_target"
- "octopusdeploy_azure_service_fabric_cluster_deployment_target"
- "octopusdeploy_azure_web_app_deployment_target"
Third, filter the resources based on the "environments" attribute to find the targets belonging to the "Development" environment.

The targets that belong to the "Test" environment are:
- Name: "sydney-client-5" ID: "Machines-18477"
- Name: "Web App" ID: "Machines-18962"
- Name: "Web App 2" ID: "Machines-19002"
- Name: "Worker Cluster" ID: "Machines-18963"
- Name: "Linux Jump Box" ID: "Machines-18964"
- Name: "Database" ID: "Machines-18965"
- Name: "Remote Site" ID: "Machines-18966"
- Name: "Old Azure Service" ID: "Machines-18967"
- Name: "Finance Cluster" ID: "Machines-18968"
- Name: "New Web App" ID: "Machines-14526"
""",
            ),
            ("user", "Question2: {input}"),
            # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
            # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
            ("user", "HCL2: ###\n{hcl}\n###"),
        ]

        with open(
            "context/matthew_casperson_development_machines_trimmed_2.tf", "r"
        ) as file:
            hcl = file.read()

        query = f'List the unique names and IDs of all machines belonging to the "Development" environment'

        result = llm_message_query(
            messages, {"json": "", "hcl": hcl, "context": None, "input": query}
        )

        machines = [
            "azure-iis",
            "pos-dev-client-1",
            "pos-dev-client-2",
            "pos-dev-client-3",
            "pos-dev-client-4",
            "pos-dev-client-5",
            "pos-dev-server",
        ]

        for machine in machines:
            self.assertTrue(
                machine in result, f'Expected "{machine}" in result:\n{result}'
            )
