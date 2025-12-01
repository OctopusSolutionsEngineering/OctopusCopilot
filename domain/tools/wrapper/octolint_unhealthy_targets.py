def octolint_unhealthy_targets_wrapper(callback, logging):
    def octolint_unhealthy_targets(space=None, **kwargs):
        """
        This function must only be selected by an LLM when the prompt specifically requests detection or identification of unhealthy targets or machines.

        Example prompts:
        * "Check for unhealthy targets in the space 'MySpace'."
        * "Locate machines that have not passed a health check in the space 'MySpace'."
        * "Find unhealthy machines in the space 'MySpace'."

        Do not select this function for general questions about targets, projects, or other resource types.

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unhealthy_targets")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_unhealthy_targets
