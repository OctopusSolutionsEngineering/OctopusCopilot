def cancel_runbook_run_wrapper(query, callback, logging):
    def cancel_runbook_run(space_name=None, project_name=None, runbook_name=None, environment_name=None,
                           tenant_name=None, **kwargs):
        """Answers queries about cancelling a runbook run in Octopus. Use this function when the query is
           asking to cancel a runbook run task.
    Questions can look like those in the following list:
    * Cancel the runbook run of "Backup database" for project "MyProject" to the "Test" environment.
    * Cancel the runbook "Destroy Infra" in the "Dev" environment.
    * Cancel the runbook "Create infra" for the tenant "MyTenant" in "Production".

        Args:
        space_name: The name of the space
        task_id: The server task
        project_name: The name of the project
        runbook_name: The runbook name
        environment_name: The name of the environment
        tenant_name: The name of the tenant
        """

        if logging:
            logging("Enter:", "cancel_runbook_run")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(query,
                        space_name,
                        project_name,
                        runbook_name,
                        environment_name,
                        tenant_name)

    return cancel_runbook_run
