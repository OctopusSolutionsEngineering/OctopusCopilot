def create_feed_wrapper(query, callback, logging):
    def create_feed(
        space_name=None,
        feed_name=None,
        feed_type=None,
        **kwargs,
    ):
        """Creates a feed in Octopus Deploy.

        You must only select this function when the prompt is specifically requesting to create a single feed.
        You will be penalized for selecting this function when the prompt contains any instructions to create a project, for example, "Create a project called...".

        Example prompts include:
        * Create a NuGet feed called "My Feed" in the space "My Space"
        * Create a Docker feed called "DockerHub" in the space "My Space"
        * Create a Maven feed called "Java Apps" in the space "My Space"
        * Create a Helm feed called "Helm" in the space "My Space"

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
