def create_github_connection_wrapper(query, callback, logging):
    def create_github_connection(
        space_name=None,
        github_connection_name=None,
        **kwargs,
    ):
        """Creates a github_connection in Octopus Deploy.

        You must only select this function when the prompt is specifically requesting to create a single github connection.
        You will be penalized for selecting this function for a prompt that asks a general question about github connections.
        You will be penalized for selecting this function when the prompt contains any instructions to create a project, for example, "Create a project called...".
        If the prompt contains instructions to create a project, you must consider this function as not applicable.

        Example prompts include:
        * Create a github_connection called "Engineering" in the space "My Space"

        Args:
        space_name: The name of the space
        github_connection_name: The name of the github connection
        """

        if logging:
            logging("Enter:", create_github_connection.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_github_connection.__name__, query, space_name, github_connection_name
        )

    return create_github_connection
