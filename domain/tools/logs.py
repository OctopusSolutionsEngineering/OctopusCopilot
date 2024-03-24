def answer_logs_callback(query, callback, logging):
    def answer_logs_usage(space=None, project=None, environment=None, channel=None, tenant=None, **kwargs):
        """Answers a query about the contents of a deployment log for an octopus project.

        Args:
        space: Space name
        projects: project names
        environments: variable names
        channel: channel name
        tenant: tenant name
        """

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query, query, space, project, environment, channel, tenant)

    return answer_logs_usage
