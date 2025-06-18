def create_worker_wrapper(query, callback, logging):
    def create_worker(
        space_name=None,
        worker_name=None,
        **kwargs,
    ):
        """Creates a worker in Octopus Deploy. Example prompts include:
            * Create a worker called "Linux" in the space "My Space"

            You will be penalised for selecting this function if the prompt mentions a project, or creating a project.

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
