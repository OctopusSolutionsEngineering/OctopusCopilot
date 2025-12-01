def octolint_unused_variables_wrapper(callback, logging):
    def octolint_unused_variables(space=None, project=None, **kwargs):
        """
        This function must only be selected by an LLM when the prompt specifically requests detection or identification of unused variables.

        Example prompts:
        * "Check for unused variables in the space 'MySpace'."
        * "Find unused project variables in the space 'MySpace'."
        * "Identify variables that are not being used in the project 'MyProject' in the space 'MySpace'."

        Do not select this function for general questions about variables, projects, or other resource types.

        Args:
        space: The name of the space to run the check in.
        project: The name of the project to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unused_variables")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space, project)

    return octolint_unused_variables
