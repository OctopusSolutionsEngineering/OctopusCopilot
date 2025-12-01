def create_step_template_wrapper(query, callback, logging):
    def create_step_template(
        space_name=None,
        step_template_name=None,
        **kwargs,
    ):
        """Creates a step template in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create step templates
        - DO NOT select this function for general questions about step templates
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request step template creation, such as:
        * "Create a step template called 'Deploy Web App' in the space 'My Space'"
        * "Add a step template named 'Backup Database'"
        * "Create the Deployment step template"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about step templates
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating step templates

        Args:
            space_name: The name of the space
            step_template_name: The name of the step template
        """

        if logging:
            logging("Enter:", create_step_template.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_step_template.__name__, query, space_name, step_template_name
        )

    return create_step_template
