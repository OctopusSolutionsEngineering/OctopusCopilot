def octolint_unused_tenants_wrapper(callback, logging):
    def octolint_unused_tenants(space=None, **kwargs):
        """
        This function must only be selected by an LLM when the prompt specifically requests detection or identification of unused tenants.

        Example prompts:
        * "Check for unused tenants in the space 'MySpace'."
        * "Find tenants that have not been used in 30 days in the space 'MySpace'."
        * "Identify tenants that have not performed a deployment in the space 'MySpace'."

        Do not select this function for general questions about tenants, projects, or other resource types.

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_unused_tenants")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_unused_tenants
