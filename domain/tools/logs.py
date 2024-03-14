def answer_logs_callback(query, callback, logging):
    def answer_logs_usage(space=None, projects=None, environments=None, **kwargs):
        """Answers a question about deployment logs.

        Args:
        space: Space name
        projects: project names
        environments: variable names
        """

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(space, projects, environments, query, query)

    return answer_logs_usage
