def octolint_unused_targets_wrapper(callback, logging):
    def octolint_unused_targets(space=None, **kwargs):
        """
        This function must only be selected by an LLM when the prompt specifically requests detection or identification of unused targets or machines.

        Example prompts:
        * "Check for unused targets in the space 'MySpace'."
        * "Find unused machines in the space 'MySpace'."
        * "Identify targets that are not being used in the space 'MySpace'."

        Do not select this function for general questions about variables, projects, or other resource types.

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unused_targets")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_unused_targets
