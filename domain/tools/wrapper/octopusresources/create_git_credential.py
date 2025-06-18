def create_git_credential_wrapper(query, callback, logging):
    def create_git_credential(
        space_name=None,
        git_credential_name=None,
        **kwargs,
    ):
        """Creates a git_credential in Octopus Deploy. Example prompts include:
            * Create a git_credential called "GitHub" in the space "My Space"

            You will be penalized for selecting this function if the prompt mentions a project, or creating a project.

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
