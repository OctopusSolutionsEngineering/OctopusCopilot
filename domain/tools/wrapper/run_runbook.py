def run_runbook_wrapper(query, callback, logging):
    def run_runbook(space_name=None, project_name=None, runbook_name=None, environment_name=None, tenant_name=None,
                    variables=None, **kwargs):
        """Responds to queries like: Run the runbook "Apply Windows updates" for the project "MyProject"
           in the "Development" environment

        Args:
        space_name: The name of the space
        project_name: The name of the project
        runbook_name: The name of the runbook
        environment_name: The name of the environment
        tenant_name: The optional name of the tenant
        variables: The optional dictionary of variable key/value pairs.
        """

        if logging:
            logging("Enter:", "run_runbook")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query,
                        space_name,
                        project_name,
                        runbook_name,
                        environment_name,
                        tenant_name,
                        variables)

    return run_runbook
