def octolint_direct_tenant_references_wrapper(callback, logging):
    def octolint_direct_tenant_references(space=None, **kwargs):
        """
        Checks for tenants that should be grouped by tags in the space. Example prompts include:
        * Find tenants that should be grouped by tags in the space "MySpace"
        * Suggest tenant tags in the space "MySpace" to make tenants more manageable

        Args:
        space: The name of the space to run the check in.
        """

        if logging:
            logging("Enter:", "octolint_direct_tenant_references")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(space)

    return octolint_direct_tenant_references
