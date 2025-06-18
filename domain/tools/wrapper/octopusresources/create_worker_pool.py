def create_worker_pool_wrapper(query, callback, logging):
    def create_worker_pool(
        space_name=None,
        worker_pool_name=None,
        **kwargs,
    ):
        """Creates a worker_pool in Octopus Deploy. Example prompts include:
            * Create a worker_pool called "Linux" in the space "My Space"

            You will be penalized for selecting this function if the prompt mentions a project, or creating a project.

        Args:
        space_name: The name of the space
        worker_pool_name: The name of the worker pool
        """

        if logging:
            logging("Enter:", create_worker_pool.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_worker_pool.__name__, query, space_name, worker_pool_name
        )

    return create_worker_pool
