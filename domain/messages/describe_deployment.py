def build_deployment_overview_prompt(few_shot=None, context=None):
    return [
        (
            "system",
            """You are a helpful agent that understands git diffs, git commits, github issues, and Octopus deployment logs.
                You are asked to provide information about a deployment.
                All the supplied information relates to changes that contributed to a deployment.
                You must also answer any questions asked by the user.""",
        ),
        *(few_shot if few_shot else []),
        *(context if context else []),
        (
            "user",
            "Question: {input}",
        ),
        (
            "user",
            "Answer:",
        ),
    ]
