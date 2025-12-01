def create_feed_wrapper(query, callback, logging):
    def create_feed(
        space_name=None,
        feed_name=None,
        feed_type=None,
        **kwargs,
    ):
        """Creates a feed in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create feeds
        - DO NOT select this function for general questions about feeds
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request feed creation, such as:
        * "Create a NuGet feed called 'My Feed' in the space 'My Space'"
        * "Create a Docker feed called 'DockerHub' in the space 'My Space'"
        * "Create a Maven feed called 'Java Apps' in the space 'My Space'"
        * "Create a Helm feed called 'Helm' in the space 'My Space'"
        * "Add a feed named 'Production Feed'"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about feeds
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating feeds

        Args:
            space_name: The name of the space
            feed_name: The name of the feed
            feed_type: The type of the feed
        """

        if logging:
            logging("Enter:", create_feed.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(create_feed.__name__, query, space_name, feed_name, feed_type)

    return create_feed
