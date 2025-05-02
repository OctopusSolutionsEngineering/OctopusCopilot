def create_machine_policy_wrapper(query, callback, logging):
    def create_machine_policy(
        space_name=None,
        machine_policy_name=None,
        **kwargs,
    ):
        """Creates a machine policy in Octopus Deploy. Example prompts include:
            * Create a machine policy called "Virtual Machines" in the space "My Space"

        Args:
        space_name: The name of the space
        machine_policy_name: The name of the machine policy
        """

        if logging:
            logging("Enter:", create_machine_policy.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_machine_policy.__name__, query, space_name, machine_policy_name
        )

    return create_machine_policy
