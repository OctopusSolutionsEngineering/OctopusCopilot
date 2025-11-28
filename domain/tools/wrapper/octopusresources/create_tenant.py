def create_tenant_wrapper(query, callback, logging):
    def create_tenant(
        space_name=None,
        tenant_name=None,
        **kwargs,
    ):
        """Creates a tenant in Octopus Deploy.

        You must only select this function when the prompt is specifically requesting to create a single tenant.
        You will be penalized for selecting this function when the prompt contains any instructions to create a project, for example, "Create a project called...".
        If the prompt contains instructions to create a project, you must consider this function as not applicable.

        Example prompts include:
        * Create a tenant called "Europe" in the space "My Space"

        Args:
        space_name: The name of the space
        tenant_name: The name of the tenant
        """

        if logging:
            logging("Enter:", create_tenant.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(create_tenant.__name__, query, space_name, tenant_name)

    return create_tenant
