def create_lifecycle_wrapper(query, callback, logging):
    def create_lifecycle(
        space_name=None,
        lifecycle_name=None,
        **kwargs,
    ):
        """Creates a lifecycle in Octopus Deploy.
        You will be penalized for selecting this function for prompts that include references to a project, or creating a project.

        Example prompts include:
        * Create a lifecycle called "Application" in the space "My Space"

        Args:
        space_name: The name of the space
        lifecycle_name: The name of the lifecycle
        """

        if logging:
            logging("Enter:", create_lifecycle.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(create_lifecycle.__name__, query, space_name, lifecycle_name)

    return create_lifecycle
