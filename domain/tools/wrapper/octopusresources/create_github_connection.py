def create_github_connection_wrapper(query, callback, logging):
    def create_github_connection(
        space_name=None,
        github_connection_name=None,
        **kwargs,
    ):
        """Creates a github connection in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create github connections and only github connections
        - DO NOT select this function for general questions about github connections
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request github connection creation, such as:
        * "Create a github connection called 'Engineering' in the space 'My Space'"
        * "Add a github connection named 'MyOrg'"
        * "Create the Production github connection"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about github connections
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating github connections

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
