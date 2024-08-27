from domain.messages.deployment_logs import build_plain_text_prompt


def answer_runbook_run_logs_wrapper(query, callback, logging):
    def answer_runbook_run_logs(space=None, project=None, runbook=None, environment=None, tenant=None,
                                steps=None, lines=None, **kwargs):
        """Answers a query about the contents of the logs of a runbook run.
        You will be penalized for selecting this function when asking about runbook settings, configuration, or properties.
        You must select this function when the prompt asks anything about runbook logs.
        Some example prompts are:
        * Print the last 30 lines of text from the runbook logs of the latest runbook run to the "Production" environment.
        * Summarize the execution logs of the latest runbook run.
        * Find any urls in the run logs in the "Development" environment for the "Fabrikham" tenant for the "Backup Database" runbook in the "DevOps" project.

        Args:
        space: Space name
        project: project names
        runbook: runbook names
        environment: variable names
        tenant: tenant name
        steps: the step names or indexes to get logs from
        lines: the number of log lines to return
        """

        if logging:
            logging("Enter:", "answer_runbook_run_logs")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_plain_text_prompt()

        # This is just a passthrough to the original callback
        return callback(query, messages, space, project, runbook, environment, tenant, steps, lines)

    return answer_runbook_run_logs
