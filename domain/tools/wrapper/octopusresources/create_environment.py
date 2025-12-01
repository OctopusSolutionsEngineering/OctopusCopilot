def create_environment_wrapper(query, callback, logging):
    def create_environment(
        space_name=None,
        environment_name=None,
        **kwargs,
    ):
        """Creates an environment in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create environments
        - DO NOT select this function for general questions about environments
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request environment creation, such as:
        * "Create an environment called 'PreProd' in the space 'My Space'"
        * "Add an environment named 'Production'"
        * "Create the Development environment"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about environments
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating environments

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
