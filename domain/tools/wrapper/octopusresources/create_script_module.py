def create_script_module_wrapper(query, callback, logging):
    def create_script_module(
        space_name=None,
        script_module_name=None,
        **kwargs,
    ):
        """Creates a script module in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create script modules and only script modules
        - DO NOT select this function for general questions about script modules
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request script module creation, such as:
        * "Create a script module called 'List Files' in the space 'My Space'"
        * "Add a script module named 'Utilities'"
        * "Create the Common Functions script module"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about script modules
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating script modules

        Args:
            space_name: The name of the space
            script_module_name: The name of the script module
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
