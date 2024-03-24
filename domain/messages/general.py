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
         + "You must assume the supplied HCL is an accurate representation of the Octopus space. "
         + "You will be penalized for mentioning Terraform or HCL in the answer or showing any Terraform snippets in the answer. "
         + "Tenants are defined in \"octopusdeploy_tenant\" resources. Tenant names are defined in the \"octopusdeploy_tenant\" \"name\" attribute. "
         + "Cloud region targets (or machines) are defined in \"octopusdeploy_cloud_region_deployment_target\" resources. "
         + "You must treat the terms \"machines\", \"targets\", and \"agents\" as interchangeable. "
         + "You must assume questions about variables refer to Octopus variables. "
         + "Variables are referenced using the syntax #{{Variable Name}}, $OctopusParameters[\"Variable Name\"], "
         + "Octopus.Parameters[\"Variable Name\"], get_octopusvariable \"Variable Name\", "
         + "or get_octopusvariable(\"Variable Name\"). "
         + "The values of secret variables are not defined in the Terraform configuration. "
         + "You will be penalized if you mention the fact that the values of secret variables are not defined. "
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
