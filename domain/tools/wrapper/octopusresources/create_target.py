def create_target_wrapper(query, callback, logging):
    def create_target(
        space_name=None,
        target_name=None,
        target_type=None,
        **kwargs,
    ):
        """Creates a target or machine in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create targets or machines and only targets or machines
        - DO NOT select this function for general questions about targets
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request target creation, such as:
        * "Create an Azure Web App target called 'My Web App' in the space 'My Space'"
        * "Create an ECS target called 'Cluster' in the space 'My Space'"
        * "Create a Kubernetes target called 'Argo' in the space 'My Space'"
        * "Create a Polling tentacle machine called 'Windows Server' in the space 'My Space'"
        * "Create a Listening tentacle machine called 'Linux' in the space 'My Space'"
        * "Create an SSH machine called 'Jump Box' in the space 'My Space'"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about targets
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating targets

        Args:
            space_name: The name of the space
            target_name: The name of the target
            target_type: The type of the target
        """

        if logging:
            logging("Enter:", create_target.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_target.__name__, query, space_name, target_name, target_type
        )

    return create_target
