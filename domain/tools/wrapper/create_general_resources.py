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
