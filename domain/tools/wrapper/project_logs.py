from domain.messages.deployment_logs import build_plain_text_prompt


def answer_project_deployment_logs_wrapper(query, callback, logging):
    def answer_project_deployment_logs(space=None, project=None, environment=None, channel=None, tenant=None,
                                       release=None, steps=None, lines=None, **kwargs):
        """Answers a query about the contents of the deployment logs of a project to an environment.
        Use this function when the prompt asks anything about deployment or project logs. Some example prompts are:
        * Print the last 30 lines of text from the deployment logs of the latest project deployment to the "Production" environment.
        * Summarize the deployment logs of the latest deployment.
        * Find any urls in the deployment logs of release version "1.0.2" to the "Development" environment for the "Contoso" tenant for the "Web App" project in the "Hotfix" channel.

        Args:
        space: Space name
        project: project names
        environment: variable names
        channel: channel name
        tenant: tenant name
        release: release version
        steps: the step names or indexes to get logs from
        lines: the number of lines from the log file to return
        """

        if logging:
            logging("Enter:", "answer_project_deployment_logs")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_plain_text_prompt()

        # This is just a passthrough to the original callback
        return callback(query, messages, space, project, environment, channel, tenant, release, steps, lines)

    return answer_project_deployment_logs
