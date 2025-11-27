def create_environment_wrapper(query, callback, logging):
    def create_environment(
        space_name=None,
        environment_name=None,
        **kwargs,
    ):
        """Creates an environment in Octopus Deploy.

        You must only select this function when the prompt is specifically requesting to create an environment.
        You will be penalized for selecting this function when the prompt contains any instructions to create a project, for example, "Create a project called...".

        Example prompts include:
        * Create an environment called "PreProd" in the space "My Space"

        Args:
        space_name: The name of the space
        environment_name: The name of the environment
        """

        if logging:
            logging("Enter:", create_environment.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_environment.__name__, query, space_name, environment_name
        )

    return create_environment
