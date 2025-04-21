def create_k8s_project_wrapper(query, callback, logging):
    def create_k8s_project(
        space_name=None,
        **kwargs,
    ):
        """Creates a Kubernetes project in Octopus Deploy. Example prompts include:
            * Create a Kubernetes project in the space "My Space" called "My Project"
            * Create a Kubernetes project called "My Project" in the space "My Space"
            * Create a Kubernetes project called "My Project"

        Args:
        space_name: The name of the space
        """

        if logging:
            logging("Enter:", "create_k8s_project")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            query,
            space_name,
        )

    return create_k8s_project
