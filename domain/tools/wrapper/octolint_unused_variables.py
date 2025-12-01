def octolint_unused_variables_wrapper(callback, logging):
    def octolint_unused_variables(space=None, project=None, **kwargs):
        """
        Checks for unused variables in projects the space. Example prompts include:
        * Check for unused variables in the space "MySpace".
        * Find unused project variables in the space "MySpace".

        You will be penalized for selecting this function when the prompt is a general question about variables or projects.

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
