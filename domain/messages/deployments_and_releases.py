def build_deployments_and_releases_prompt(step_by_step=False):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context and the JSON blob with releases..
    :param step_by_step: True if the LLM should display its reasoning step by step before the answer. False for concise answers.
    :return: The messages to pass to the llm.
    """

    # Some of the prompts come from https://arxiv.org/pdf/2312.16171.pdf
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

    # This message instructs the LLM to display its reasoning step by step before the answer. It can be a useful
    # debugging tool. It doesn't always work though, but you can rerun the query and try again.
    if step_by_step:
        messages.insert(0, ("system", "You are a verbose and helpful agent."))
        messages.append(("user", "Let's think step by step."))
    else:
        messages.insert(0, (
            "system", "You are a concise and helpful agent."))

    return messages
