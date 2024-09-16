def build_deployment_overview_prompt(few_shot=None, context=None):
    return [
        (
            "system",
            """You are a helpful agent that understands git commits, issues, and deployments.
                You are asked to provide information about a deployment.
                If git commit details are provided, you must provide a summary of the code that changed in the git commits.
                If a list of committers are provided, you must list the committers.
                If details of issues are provided, you must provide a summary of the issues.
                You must summarize deployment logs.
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
