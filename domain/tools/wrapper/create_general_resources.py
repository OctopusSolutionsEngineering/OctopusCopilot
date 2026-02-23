def create_general_resources_wrapper(query, callback, logging):
    def general_resources(
        space_name=None,
        **kwargs,
    ):
        """Creates general resources in Octopus Deploy.

        You must only select this function when the prompt asks to create non-project resources such as:
        * Accounts
        * Certificates
        * Environments
        * Feeds
        * Git Credentials
        * GitHub Connections
        * Lifecycles
        * Machine Proxies
        * Machine Policies
        * Script Modules
        * Step Templates
        * Targets
        * Machines
        * Tenants
        * Workers
        * Worker Pools
        * Variable Sets
        * Runbooks

        You will be penalized for selecting this function if the prompt mentions creating projects.
        You will be penalized for selecting this function for a prompt like "Create a script project called My Project and then add a lifecycle called Application".

        Example prompts are:
        * Create an environment called "My Environment" in the space "My Space"
        * Create an environment called "My Environment"
        * Create an account called "My Account" in the space "My Space"
        * Create a lifecycle called "My Lifecycle" in the space "My Space"
        * Create a variable set called "My Variable Set" in the space "My Space"
        * Create a worker pool called "My Worker Pool" in the space "My Space"
        * Create a step template called "My Step Template" in the space "My Space"
        * Create a machine policy called "My Machine Policy" in the space "My Space"
        * Create a tenant called "My Tenant" in the space "My Space"
        * Create a target called "My Target" in the space "My Space"
        * Create a machine called "My Machine" in the space "My Space"
        * Create a worker called "My Worker" in the space "My Space"
        * Create a feed called "My Feed" in the space "My Space"
        * Create a certificate called "My Certificate" in the space "My Space"
        * Create a certificate called "My Certificate"
        * Create a git credential called "My Git Credential" in the space "My Space"
        * Create a GitHub connection called "My GitHub Connection" in the space "My Space"
        * Create a script module called "My Script Module" in the space "My Space"
        * Create a machine proxy called "My Machine Proxy" in the space "My Space"

        The names in the prompts above are examples only and can be replaced with any name for the resource.

        Args:
            space_name: The optional name of the space
        """

        if logging:
            logging("Enter:", general_resources.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(general_resources.__name__, query, space_name)

    return general_resources
