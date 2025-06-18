def create_worker_wrapper(query, callback, logging):
    def create_worker(
        space_name=None,
        worker_name=None,
        **kwargs,
    ):
        """Creates a worker in Octopus Deploy.
        You will be penalized for selecting this function for prompts that include references to a project, or creating a project.

        Example prompts include:
        * Create a worker called "Linux" in the space "My Space"

        Args:
        space_name: The name of the space
        worker_name: The name of the worker
        """

        if logging:
            logging("Enter:", create_worker.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(create_worker.__name__, query, space_name, worker_name)

    return create_worker
