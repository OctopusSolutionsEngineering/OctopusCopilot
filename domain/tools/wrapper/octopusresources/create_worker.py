def create_worker_wrapper(query, callback, logging):
    def create_worker(
        space_name=None,
        worker_name=None,
        **kwargs,
    ):
        """Creates a worker in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create workers and only workers
        - DO NOT select this function for general questions about workers
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request worker creation, such as:
        * "Create a worker called 'Linux' in the space 'My Space'"
        * "Add a worker named 'Windows Worker'"
        * "Create the Production worker"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about workers
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating workers

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
