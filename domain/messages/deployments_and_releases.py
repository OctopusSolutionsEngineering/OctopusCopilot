def build_deployments_and_releases_prompt(step_by_step=False):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context and the JSON blob with releases..
    :param step_by_step: True if the LLM should display its reasoning step by step before the answer. False for concise answers.
    :return: The messages to pass to the llm.
    """

    # Some of the prompts come from https://arxiv.org/pdf/2312.16171.pdf
    messages = [
        ("system", "The supplied HCL context provides details on projects, environments, channels, and tenants."),
        ("system", "The supplied JSON context provides details on deployments and releases."),
        ("system",
         "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL."),
        ("system", "You must assume the resources in the HCL and JSON belong to the same space as each other."),
        # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
        # resulted in the LLM providing instructions on how to find the information rather than presenting
        # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
        # The phrase "what" seems to be important in the question.
        ("system",
         "You must assume questions requesting you to 'find', 'list', 'extract', 'display', or 'print' information "
         + "are asking you to return 'what' the value of the requested information is."),
        # The LLM would often fail completely if it encountered an empty or missing attribute. These instructions
        # guide the LLM to provide as much information as possible in the answer, and not treat missing
        # information as an error.
        ("system", "Your answer must include any information you found in the context relevant to the question."),
        ("system",
         "Your answer must clearly state if the supplied context does not provide the requested information."),
        ("system",
         "You must provide a response even if the context does not provide some of the requested information."),
        ("system",
         "It is ok if you can not find most of the requested information in the context - "
         + "just provide what you can find."),
        # The LLM will often provide a code sample that describes how to find the answer if the context does not
        # provide the requested information.
        ("system", "You will be penalized for providing a code sample as the answer."),
        ("system", "I’m going to tip $500 for a better solution!"),
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
