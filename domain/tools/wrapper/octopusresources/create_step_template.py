def create_step_template_wrapper(query, callback, logging):
    def create_step_template(
        space_name=None,
        step_template_name=None,
        **kwargs,
    ):
        """Creates a step_template in Octopus Deploy.
        You will be penalized for selecting this function for prompts that include references to a project, or creating a project.

        Example prompts include:
        * Create a step_template called "Deploy Web App" in the space "My Space"

        Args:
        space_name: The name of the space
        step_template_name: The name of the step_template
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
