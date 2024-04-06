def build_deployments_and_releases_prompt(few_shot=None, additional_messages=None):
    """
    Build a message prompt for the LLM that instructs it to parse the Octopus HCL context and the JSON blob with releases.
    :param few_shot: Additional user messages providing a few shot example.
    :return: The messages to pass to the llm.
    """

    if few_shot is None:
        few_shot = []

    if additional_messages is None:
        additional_messages = []

    # Some of the prompts come from https://arxiv.org/pdf/2312.16171.pdf
    messages = [
        ("system", "You are a concise and helpful agent."),
        ("system",
         "Projects, environments, channels, and tenants, and spaces are provided in the HCL context."),
        ("system", "Deployments and releases are provided in the \"Deployments\" property in the JSON context."),
        ("system",
         "You must link the deployments in the JSON context to the projects, environments, channels, tenants, and space in the HCL context."),
        # The LLM was confused when it saw release versions that were not traditional semver type versions.
        # For example, the tests used to create guids for release versions to ensure the results matched the
        # newly created releases, and the response was often something like "The JSON does not contain
        # information about releases." Switching to calver style release versions fixed the tests.
        ("system", "The \"ReleaseVersion\" field in the JSON context contains the version of the release."),
        ("system", "Release versions can be any string."),
        ("system", "You will be penalized for assuming release versions must be numbers."),
        # Tests were failing because the LLM reported the HCL didn't contain information about releases and deployments.
        # We need to encourage the LLM not to report that there are no deployments in the context.
        ("system",
         "You will be penalized for responding that the HCL context does not contain information about deployments or releases."),
        ("system",
         "You will be penalized for responding that the JSON context does not contain information about deployments or releases."),
        # The LLM would often complain that it didn't know the relative order of deployments
        ("system",
         "The \"Created\" field in the items in the JSON array defines when a deployment was initiated to the associated environment and channel."),
        # The LLM will often answer "Based on the provided HCL and JSON context, the answer is ...".
        # This is not useful information for the end user.
        ('system', "You will be penalized for mentioning that the answer was based on the HCL or JSON context"),
        # Prompts like "List the description of a tenant" or "Find the tags associated with a tenant"
        # resulted in the LLM providing instructions on how to find the information rather than presenting
        # the answer. Here we instruct the LLM to provide the answer directly.
        ("system",
         "You must provide an answer to the question based on the data in the supplied JSON and HCL context."),
        ("system", "You will be penalized for providing instructions on how to find the answer."),
        ("system", "You will be penalized for providing a code sample as the answer."),
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
        ("system", "I’m going to tip $500 for a better solution!"),
        *few_shot,
        ("user", "Question: {input}"),
        *additional_messages,
        # https://help.openai.com/en/articles/6654000-best-practices-for-prompt-engineering-with-the-openai-api
        # Put instructions at the beginning of the prompt and use ### or """ to separate the instruction and context
        ("user", "JSON: ###\n{json}\n###"),
        ("user", "HCL: ###\n{hcl}\n###")]

    return messages
