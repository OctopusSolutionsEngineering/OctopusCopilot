from domain.messages.github_logs import build_github_logs_prompt


def answer_github_logs_wrapper(query, callback, logging):
    def answer_github_logs(
        owner=None, repo=None, workflow=None, steps=None, lines=None, **kwargs
    ):
        """Answers a query about the logs of a GitHub workflow run.
        Some example prompts are:
        * Print the last 30 lines of text from the logs of the "build.yaml" workflow in the "MyOrganisation/MyRepo" repository.
        * Print the last 30 lines of text from the logs of the "build.yaml" workflow in the "MyOrganisation" organisation and "MyRepo" repository.
        * Summarize the deployment logs of the latest logs of the "build.yaml" workflow in the "MyOrganisation/MyRepo" repository.
        * Show the errors from the deployment logs of the latest logs of the "build.yaml" workflow in the "MyOrganisation/MyRepo" repository.

        You will be penalized for selecting this function when the prompt is related to "git credentials".
        You will be penalized for selecting this function when the prompt is related to Octopus configration.
        You will be penalized for selecting this function when the prompt does not mention logs or a GitHub workflow.

        Args:
        owner: GitHub owner
        repo: GitHub repo
        workflow: GitHub workflow filename or ID
        steps: the step names or indexes to get logs from
        lines: the number of lines from the log file to return
        """

        if logging:
            logging("Enter:", "answer_github_logs")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_github_logs_prompt()

        # This is just a passthrough to the original callback
        return callback(query, messages, owner, repo, workflow, steps, lines)

    return answer_github_logs
