def create_lifecycle_wrapper(query, callback, logging):
    def create_lifecycle(
        space_name=None,
        lifecycle_name=None,
        **kwargs,
    ):
        """Creates a lifecycle in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create lifecycles and only lifecycles
        - DO NOT select this function for general questions about lifecycles
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request lifecycle creation, such as:
        * "Create a lifecycle called 'Application' in the space 'My Space'"
        * "Add a lifecycle named 'Production'"
        * "Create the Development lifecycle"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about lifecycles
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating lifecycles

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
