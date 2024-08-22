def cancel_deployment_wrapper(query, callback, logging):
    def cancel_deployment(space_name=None, project_name=None, release_version=None, environment_name=None,
                          tenant_name=None, **kwargs):
        """Responds to queries like: "Cancel the latest deployment for the project "CRM" to the environment "Test"." or
           "Cancel the deployment for release "1.4.2" in the "Dev" environment." or "Cancel the latest release in the
           "Test" environment for the "MyTenant" tenant."

        Args:
        space_name: The name of the space
        task_id: The server task
        project_name: The name of the project
        release_version: The release version
        environment_name: The name of the environment
        tenant_name: The name of the tenant
        """

        if logging:
            logging("Enter:", "cancel_deployment")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query,
                        space_name,
                        project_name,
                        release_version,
                        environment_name,
                        tenant_name)

    return cancel_deployment
