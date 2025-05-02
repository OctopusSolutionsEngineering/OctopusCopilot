def create_github_connection_wrapper(query, callback, logging):
    def create_github_connection(
        space_name=None,
        github_connection_name=None,
        **kwargs,
    ):
        """Creates a github_connection in Octopus Deploy. Example prompts include:
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
