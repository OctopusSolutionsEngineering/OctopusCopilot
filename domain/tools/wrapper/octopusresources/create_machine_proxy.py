def create_machine_proxy_wrapper(query, callback, logging):
    def create_machine_proxy(
        space_name=None,
        machine_proxy_name=None,
        **kwargs,
    ):
        """Creates a machine proxy in Octopus Deploy.
        You will be penalized for selecting this function for prompts that include references to a project, or creating a project.

        Example prompts include:
        * Create a machine proxy called "Reverse Proxy" in the space "My Space"

        Args:
        space_name: The name of the space
        machine_proxy_name: The name of the machine proxy
        """

        if logging:
            logging("Enter:", create_machine_proxy.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_machine_proxy.__name__, query, space_name, machine_proxy_name
        )

    return create_machine_proxy
