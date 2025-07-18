def create_script_module_wrapper(query, callback, logging):
    def create_script_module(
        space_name=None,
        script_module_name=None,
        **kwargs,
    ):
        """Creates a script_module in Octopus Deploy.
        You will be penalized for selecting this function for prompts that include references to a project, or creating a project.

        Example prompts include:
        * Create a script_module called "List Files" in the space "My Space"

        Args:
        space_name: The name of the space
        script_module_name: The name of the script_module
        """

        if logging:
            logging("Enter:", create_script_module.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_script_module.__name__, query, space_name, script_module_name
        )

    return create_script_module
