def octolint_unused_tenants_wrapper(callback, logging):
    def octolint_unused_tenants(space=None, **kwargs):
        """
        Checks for tenants that have not been used in 30 days in the space. Example prompts include:
        * Find unused tenants in the space "MySpace"
        * Find tenants that have not performed a deployment to help manage licensing costs

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
