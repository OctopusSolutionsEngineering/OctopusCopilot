def create_worker_pool_wrapper(query, callback, logging):
    def create_worker_pool(
        space_name=None,
        worker_pool_name=None,
        **kwargs,
    ):
        """Creates a worker pool in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create worker pools and only worker pools
        - DO NOT select this function for general questions about worker pools
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request worker pool creation, such as:
        * "Create a worker pool called 'Linux' in the space 'My Space'"
        * "Add a worker pool named 'Windows Pool'"
        * "Create the Production worker pool"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about worker pools
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating worker pools

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
