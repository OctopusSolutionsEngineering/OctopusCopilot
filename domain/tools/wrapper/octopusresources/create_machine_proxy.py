def create_machine_proxy_wrapper(query, callback, logging):
    def create_machine_proxy(
        space_name=None,
        machine_proxy_name=None,
        **kwargs,
    ):
        """Creates a machine proxy in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create machine proxies
        - DO NOT select this function for general questions about machine proxies
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request machine proxy creation, such as:
        * "Create a machine proxy called 'Reverse Proxy' in the space 'My Space'"
        * "Add a machine proxy named 'Production Proxy'"
        * "Create the Development machine proxy"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about machine proxies
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating machine proxies

        Args:
            space_name: The name of the space
            machine_proxy_name: The name of the machine proxy
        """

        if logging:
            logging("Enter:", create_machine_proxy.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_machine_proxy.__name__, query, space_name, machine_proxy_name
        )

    return create_machine_proxy
