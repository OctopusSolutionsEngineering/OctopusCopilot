def create_machine_policy_wrapper(query, callback, logging):
    def create_machine_policy(
        space_name=None,
        machine_policy_name=None,
        **kwargs,
    ):
        """Creates a machine policy in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create machine policies
        - DO NOT select this function for general questions about machine policies
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request machine policy creation, such as:
        * "Create a machine policy called 'Virtual Machines' in the space 'My Space'"
        * "Add a machine policy named 'Production Servers'"
        * "Create the Development machine policy"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about machine policies
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating machine policies

        Args:
            space_name: The name of the space
            machine_policy_name: The name of the machine policy
        """

        if logging:
            logging("Enter:", create_machine_policy.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_machine_policy.__name__, query, space_name, machine_policy_name
        )

    return create_machine_policy
