def build_deployment_overview_prompt(few_shot=None, context=None):
    return [
        (
            "system",
            """You are a helpful agent that understands git commits, issues, and deployments. 
                You are asked to provide information about a deployment. 
                You must provide a summary of the code that changed in the git commits. 
                You must summarize the issues and deployment logs.
                You must list the committers of the commits. 
                If the deployment was a failure, you must suggest a course of action.
                You must also answer any questions asked by the user.""",
        ),
        *few_shot,
        *context,
        (
            "user",
            "Question: {input}",
        ),
        (
            "user",
            "Answer:",
        ),
    ]
