from domain.messages.deployment_logs import build_plain_text_prompt


def answer_runbook_run_logs_wrapper(query, callback, logging):
    """
    A wrapper's job is to return a function with the signature used by the LLM to extract entities from the query. The
    parameters of the wrapper are captured by the returned function without altering the signature of the function.

    The purpose of the wrapped function is to take the entities passed in by the LLM, generate the messages passed
    to the LLM, and call a callback with the extracted entities and the custom messages that explain how to the context
    generated by the entities.

    The callback is then responsible for building the context, passing the messages to the LLM, and returning the result.

    The callback is specific to the type of system calling this agent. For example, the chat interface requires the agent
    to build the context by calling an Octopus instance. The Chrome extension will pass the context in the body of the
    request. Tests will build the context from an ephemeral instance of Octopus. Abstracting the details of how the
    context is built allows the process of extracting entities and building messages to be shared, while building
    context is implementation specific.
    """

    def answer_runbook_run_logs(space=None, project=None, runbook=None, environment=None, channel=None, tenant=None,
                                steps=None, lines=None, **kwargs):
        """Answers a query about the contents of the logs of a runbook run.
        Use this function when the prompt asks anything about runbook logs.

        Args:
        space: Space name
        project: project names
        runbook: runbook names
        environment: variable names
        channel: channel name
        tenant: tenant name
        steps: the step names or indexes to get logs from
        lines: the number of lines to return
        """

        if logging:
            logging("Enter:", "answer_runbook_run_logs")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        messages = build_plain_text_prompt()

        # This is just a passthrough to the original callback
        return callback(query, messages, space, project, runbook, environment, channel, tenant, steps, lines)

    return answer_runbook_run_logs
