def build_hcl_prompt(few_shot=None):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context.
    :param few_shot: Additional user messages providing a few shot example.
    :return: The messages to pass to the llm.
    """

    # Some of the prompts come from https://arxiv.org/pdf/2312.16171.pdf

    if few_shot is None:
        few_shot = []

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
        # The LLM will often answer "Based on the provided HCL context, the answer is ...".
        # This is not useful information for the end user.
        (
            "system",
            "You will be penalized for mentioning that the answer was based on the HCL context",
        ),
        (
            "system",
            'You will be penalized for including phrases like "Based on the HCL" in the answer',
        ),
        # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
        # resulted in the LLM providing instructions on how to find the information rather than presenting
        # the answer. Here we instruct the LLM to provide the answer directly.
        (
            "system",
            "You must provide an answer to the question based on the data in the supplied HCL context.",
        ),
        (
            "system",
            "You will be penalized for providing instructions on how to find the answer.",
        ),
        ("system", "You will be penalized for providing a code sample as the answer."),
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
        ("system", "You must assume a missing HCL attribute means the value is empty."),
        (
            "system",
            "You must provide a response even if the context does not provide some of the requested information.",
        ),
        (
            "system",
            "It is ok if you can not find most or any of the requested information in the context - "
            + "just provide what you can find.",
        ),
        # The LLM will often provide a code sample that describes how to find the answer if the context does not
        # provide the requested information.
        ("system", "You will be penalized for providing a code sample as the answer."),
        # The LLM sometimes didn't know how to find a tenant in the supplied context
        ("system", 'Tenants are defined in "octopusdeploy_tenant" resources.'),
        (
            "system",
            'Tenant names are defined in the "octopusdeploy_tenant" "name" attribute.',
        ),
        (
            "system",
            'Tenant tags are defined in the "octopusdeploy_tenant" "tenant_tags" attribute.',
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
        # Sometimes the LLM got confused about Terraform variables and Octopus variables
        # The LLM also needed some guidance on how to identify variable usage in the steps
        (
            "system",
            "You must assume questions about variables refer to Octopus variables.",
        ),
        (
            "system",
            'Variables are referenced using the syntax #{{Variable Name}}, $OctopusParameters["Variable Name"], '
            + 'Octopus.Parameters["Variable Name"], get_octopusvariable "Variable Name", '
            + 'or get_octopusvariable("Variable Name"). ',
        ),
        # The LLM often complained that secret variables did not have a value
        (
            "system",
            "The values of secret variables are not defined in the Terraform configuration.",
        ),
        (
            "system",
            "You will be penalized if you mention the fact that the values of secret variables are not defined.",
        ),
        # Sparkle that may improve the quality of the responses.
        ("system", "I’m going to tip $500 for a better solution!"),
        # Get the LLM to implement a chain-of-thought
        ("system", "Think carefully and logically, explaining your answer."),
        *few_shot,
        ("user", "Question: {input}"),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "HCL: ###\n{hcl}\n###"),
        # We serialize projects as if they were not cac enabled. This allows us to capture the steps. But we still
        # want to know some information about what projects are cac enabled.
        ("user", "Config-as-Code Settings: ###\n{cac_details}\n###"),
        ("user", "Answer:"),
    ]

    return messages
