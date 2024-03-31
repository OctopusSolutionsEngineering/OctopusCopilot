def build_hcl_prompt(step_by_step=False):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context.
    :param step_by_step: True if the LLM should display its reasoning step by step before the answer. False for concise answers.
    :return: The messages to pass to the llm.
    """

    # Some of the prompts come from https://arxiv.org/pdf/2312.16171.pdf
    messages = [
        ("system",
         "You understand Terraform modules defining Octopus Deploy resources."
         + "The supplied HCL context provides details on Octopus resources like projects, environments, channels, tenants, project groups, lifecycles, feeds, variables, library variable sets etc. "
         + "If the supplied HCL is empty, you must assume there are no resources defined in the Octopus space. "
         + "You must assume the supplied HCL is a complete and accurate representation of the Octopus space. "
         # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
         # resulted in the LLM providing instructions on how to find the information rather than presenting
         # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
         # The phrase "what" seems to be important in the question.
         + "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information are asking you to return 'what' the value of the requested information is. "
         # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
         # guide the LLM to provide as much information as possible in the answer, and not treat missing
         # information as an error.
         + "Your answer must include any information you found in the HCL context relevant to the question. "
         + "Your answer must clearly state if the supplied context does not provide the requested information. "
         + "You must assume a missing HCL attribute means the value is empty. "
         + "You must provide a response even if the context does not provide some of the requested information. "
         # The LLM will often provide a code sample that describes how to find the answer if the context does not
         # provide the requested information.
         + "You will be penalized for providing a code sample as the answer. "
         # The LLM sometimes didn't know how to find a tenant in the supplied context
         + "Tenants are defined in \"octopusdeploy_tenant\" resources. "
         + "Tenant names are defined in the \"octopusdeploy_tenant\" \"name\" attribute. "
         + "Tenant tags are defined in the \"octopusdeploy_tenant\" \"tenant_tags\" attribute. "
         # The LLM didn't know targets were the same as machines
         + "Cloud region targets (or machines) are defined in \"octopusdeploy_cloud_region_deployment_target\" resources. "
         + "You must treat the terms \"machines\", \"targets\", and \"agents\" as interchangeable. "
         # Sometimes the LLM got confused about Terraform variables and Octopus variables
         # The LLM also needed some guidance on how to identify variable usage in the steps
         + "You must assume questions about variables refer to Octopus variables. "
         + "Variables are referenced using the syntax #{{Variable Name}}, $OctopusParameters[\"Variable Name\"], "
         + "Octopus.Parameters[\"Variable Name\"], get_octopusvariable \"Variable Name\", "
         + "or get_octopusvariable(\"Variable Name\"). "
         # The LLM often complained that secret variables did not have a value
         + "The values of secret variables are not defined in the Terraform configuration. "
         + "You will be penalized if you mention the fact that the values of secret variables are not defined. "
         # Sparkle that may improve the quality of the responses.
         + "I’m going to tip $500 for a better solution!"),
        ("user", "{input}"),
        ("user", "Answer the question using the HCL below."),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "HCL: ###\n{hcl}\n###")]

    # This message instructs the LLM to display its reasoning step by step before the answer. It can be a useful
    # debugging tool. It doesn't always work though, but you can rerun the query and try again.
    if step_by_step:
        messages.insert(0, ("system", "You are a verbose and helpful agent."))
        messages.append(("user", "Let's think step by step."))
    else:
        messages.insert(0, (
            "system", "You are a concise and helpful agent."))

    return messages
