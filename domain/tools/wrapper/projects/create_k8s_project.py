def create_k8s_project_wrapper(query, callback, logging):
    def create_k8s_project(
        space_name=None,
        project_name=None,
        no_prompt=False,
        **kwargs,
    ):
        """
        Creates a Kubernetes project in Octopus Deploy, in addition to any supporting resources.

        Example prompts include:
        * Create a Kubernetes project in the space "My Space" called "My Project"
        * Create a Kubernetes project called "My Project" in the space "My Space"
        * Create a Kubernetes project called "My Project"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        no_prompt: Weather to disable the prompt. Defaults to False.
        """

        if logging:
            logging("Enter:", create_k8s_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_k8s_project.__name__, query, space_name, project_name, no_prompt
        )

    return create_k8s_project
