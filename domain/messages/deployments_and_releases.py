def build_deployments_and_releases_prompt(few_shot=None):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context and the JSON blob with releases.
    :param few_shot: Additional user messages providing a few shot example.
    :return: The messages to pass to the llm.
    """

    if few_shot is None:
        few_shot = []

    # Some of the prompts come from https://arxiv.org/pdf/2312.16171.pdf
    messages = [
        ("system", "You are a concise and helpful agent."),
        ("system", "Projects, environments, channels, and tenants are defined in the supplied HCL context."),
        ("system", "Releases and deployments are defined in the supplied JSON context."),
        ("system",
         "You must link the deployments and releases in the JSON to the projects, environments, channels, and tenants in the HCL."),
        ("system", "You must assume the resources in the HCL and JSON belong to the same space as each other."),
        # Tests were failing because the LLM reported the HCL didn't contain information about releases and deployments
        ("system",
         "You will be penalized for responding that the HCL does not contain information about deployments and releases."),
        # The LLM would often complain that it didn't know the relative order of deployments
        ("system",
         "The \"Created\" field in the items in the JSON array defines when a deployment was initiated to the associated environment and channel."),
        # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
        # resulted in the LLM providing instructions on how to find the information rather than presenting
        # the answer. Questions "What are the tags associated with the tenant?" tended to get the answer.
        # The phrase "what" seems to be important in the question.
        ("system",
         "You must assume questions requesting you to 'find', 'get', 'list', 'extract', 'display', or 'print' information "
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
        *few_shot,
        ("user", "Question: {input}"),
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "JSON: ###\n{json}\n###"),
        ("user", "HCL: ###\n{hcl}\n###")]

    return messages
