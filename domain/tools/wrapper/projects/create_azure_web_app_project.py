def create_azure_web_app_project_wrapper(query, callback, logging):
    def create_azure_web_app_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """
        Creates an Azure Web App project in Octopus Deploy., and optionally create any other resources required to run the project such as:
        * Accounts
        * Feeds
        * Environments
        * Lifecycles
        * Steps
        * Triggers
        * Machines
        * Targets
        * Deployment processes
        * Runbooks
        * Tenants

        Example prompts include:
        * Create an Azure Web App project in the space "My Space" called "My Project"
        * Create an Azure Web App project called "My Project" in the space "My Space"
        * Create an Azure Web App project called "My Project"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_azure_web_app_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_azure_web_app_project.__name__, query, space_name, project_name
        )

    return create_azure_web_app_project
