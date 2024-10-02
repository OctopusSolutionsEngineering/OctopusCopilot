def build_deployment_overview_prompt(few_shot=None, context=None, default_output=None):
    """Builds the prompt for the describing a deployment task.
    :param few_shot: few shot examples that are used to help guide the LLM
    :param context: context that is used by the LLM to answer the question
    :param default_output: instructions on what information to display to the user

    """

    return [
        (
            "system",
            """You are an expert in git, programming, DevOps, security, Kubernetes, operating systems like Windows and Linux, and cloud platforms like Azure, AWS, and Google Cloud.
                You are asked to provide information about a deployment with Octopus Deploy.
                All the supplied information relates to changes that contributed to a deployment.
                You must answer any questions asked by the user.""",
        ),
        *(few_shot if few_shot else []),
        *(context if context else []),
        (
            "user",
            "Question: {input}",
        ),
        # The default output often depends on whether the user asked a specific question or not.
        # For example, you could have an instruction like "Provide a summary of the deployment if the user did not ask a question"
        # The LLM must already have seen the question (or lack thereof), which is why these instructions are included after the user's question.
        *(default_output if default_output else []),
        (
            "user",
            "Answer:",
        ),
    ]
