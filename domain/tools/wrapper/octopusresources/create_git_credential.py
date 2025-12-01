def create_git_credential_wrapper(query, callback, logging):
    def create_git_credential(
        space_name=None,
        git_credential_name=None,
        **kwargs,
    ):
        """Creates a git credential in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create git credentials
        - DO NOT select this function for general questions about git credentials
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request git credential creation, such as:
        * "Create a git credential called 'GitHub' in the space 'My Space'"
        * "Add a git credential named 'GitLab'"
        * "Create the Production git credential"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about git credentials
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating git credentials

        Args:
            space_name: The name of the space
            git_credential_name: The name of the git credential
        """

        if logging:
            logging("Enter:", create_git_credential.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_git_credential.__name__, query, space_name, git_credential_name
        )

    return create_git_credential
