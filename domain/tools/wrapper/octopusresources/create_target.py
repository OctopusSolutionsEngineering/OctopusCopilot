def create_target_wrapper(query, callback, logging):
    def create_target(
        space_name=None,
        target_name=None,
        target_type=None,
        **kwargs,
    ):
        """Creates a target or machine in Octopus Deploy.

        You must only select this function when the prompt is specifically requesting to create a single target.
        You will be penalized for selecting this function when the prompt contains any instructions to create a project, for example, "Create a project called...".

        Example prompts include:
        * Create an Azure Web App target called "My Web App" in the space "My Space"
        * Create an ECS target called "Cluster" in the space "My Space"
        * Create a Kubernetes target called "Argo" in the space "My Space"
        * Create a Polling tentacle machine called "Windows Server" in the space "My Space"
        * Create a Listening tentacle machine called "Linux" in the space "My Space"
        * Create an SSH machine called "Jump Box" in the space "My Space"

        Args:
        space_name: The name of the space
        target_name: The name of the feed
        target_type: The type of the feed
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
