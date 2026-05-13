def create_runbook_wrapper(query, callback, logging):
    def create_runbook(
        space_name=None,
        project_name=None,
        runbook_name=None,
        **kwargs,
    ):
        """
        Creates a runbook in Octopus Deploy, in addition to any supporting resources.

        Example prompts include:
        * Create a runbook called "Restart Server" in the project "Web App" in the space "My Space

        Args:
        space_name: The name of the space
        project_name: The name of the project
        runbook_name: The name of the runbook
        """

        if logging:
            logging("Enter:", create_runbook.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_runbook.__name__,
            query,
            space_name,
            project_name,
            False,
        )

    return create_runbook
