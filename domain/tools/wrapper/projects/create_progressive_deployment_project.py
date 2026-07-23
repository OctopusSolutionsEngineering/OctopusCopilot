def create_progressive_deployment_project_wrapper(query, callback, logging):

    def create_progressive_deployment_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """
        Creates a Progressive deployment (also known as canary deployments or progressive delivery) project in Octopus Deploy, in addition to any supporting resources.

        Select this tool when the prompt mentions progressive deployments, canary deployments, or progressive rollouts.

        Example prompts include:
        * Create a Progressive deployment project in the space "My Space" called "My Project"
        * Create a project with the progressive rollouts step in the space "My Space" called "My Project"
        * Create Progressive delivery project called "My Project" in the space "My Space"
        * Create Progressive deployment project called "My Project"
        * Create Canary deployment project called "My Project". Create a Token account called "K8s" with value "blah"

        Args:
        space_name: The optional name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_progressive_deployment_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_progressive_deployment_project.__name__,
            query,
            space_name,
            project_name,
            False,
        )

    return create_progressive_deployment_project
