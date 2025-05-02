def answer_literal_logs_wrapper(query, callback, logging):
    def answer_literal_logs_usage(
        space=None,
        project=None,
        environment=None,
        channel=None,
        tenant=None,
        release=None,
        **kwargs,
    ):
        """Prints, writes, or outputs the deployment logs without any processing.

        Args:
        space: Space name
        projects: project names
        environments: variable names
        channel: channel name
        tenant: tenant name
        release: release version
        """

        if logging:
            logging("Enter:", "answer_literal_logs_usage")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(space, project, environment, channel, tenant, release)

    return answer_literal_logs_usage
