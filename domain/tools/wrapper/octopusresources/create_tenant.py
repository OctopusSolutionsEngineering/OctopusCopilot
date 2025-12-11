def create_tenant_wrapper(query, callback, logging):
    def create_tenant(
        space_name=None,
        tenant_name=None,
        **kwargs,
    ):
        """Creates a tenant in Octopus Deploy.

        IMPORTANT - Tool Selection Criteria:
        - ONLY select this function when the prompt explicitly asks to create tenants and only tenants
        - DO NOT select this function for general questions about tenants
        - DO NOT select this function if the prompt mentions creating projects, steps, or other resources
        - DO NOT select this function if the prompt starts with phrases like "Create a Kubernetes project", "Create an Azure Web App project", etc.

        This function is ONLY for prompts that specifically request tenant creation, such as:
        * "Create a tenant called 'Europe' in the space 'My Space'"
        * "Add a tenant named 'Customer A'"
        * "Create the Production tenant"

        You will be penalized for selecting this function when:
        - The prompt asks general questions about tenants
        - The prompt contains instructions to create projects or other resources
        - The prompt is about anything other than creating tenants

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
