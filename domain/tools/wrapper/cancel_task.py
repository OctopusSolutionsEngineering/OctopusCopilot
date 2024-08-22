def cancel_task_wrapper(query, callback, logging):
    def cancel_deployment_to_environment(space_name=None, project_name=None, release_version=None, environment_name=None,
                                         tenant_name=None, **kwargs):
        """Responds to queries like: "Cancel the latest deployment for the project "CRM" to the environment "Test"." or
           "Cancel the deployment for release "1.4.2" in the "Dev" environment." or "Cancel the latest release in the
           "Test" environment for the "MyTenant" tenant."
        """
        return cancel_task(confirm_callback_function_name=cancel_deployment_to_environment.__name__,
                           space_name=space_name,
                           project_name=project_name,
                           release_version=release_version,
                           environment_name=environment_name,
                           tenant_name=tenant_name,
                           runbook_run=None,
                           **kwargs)

    def cancel_runbook_run_for_environment(space_name=None, project_name=None, runbook_name=None, environment_name=None,
                                           tenant_name=None, **kwargs):
        """Responds to queries like: "Cancel the runbook run of "Backup database" for project "MyProject" to the "Test" environment"
           or "Cancel the runbook "Destroy Infra" in the "Dev" environment." or "Cancel the runbook "Create infra" for
           the tenant "MyTenant" in "Production"."
        """
        return cancel_task(confirm_callback_function_name=cancel_runbook_run_for_environment.__name__,
                           space_name=space_name,
                           project_name=project_name,
                           release_version=None,
                           environment_name=environment_name,
                           tenant_name=tenant_name,
                           runbook_name=runbook_name,
                           **kwargs)

    def cancel_task(confirm_callback_function_name=None, space_name=None, task_id=None, project_name=None,
                    release_version=None, environment_name=None, runbook_name=None, tenant_name=None, **kwargs):
        """Answers queries about canceling a deployment, runbook run or other task. Use this function when the query is
               asking to cancel a task.
    Questions can look like those in the following list:
    * Cancel the latest deployment to the "Test" environment for the project "Contoso"
    * Cancel the deployment for release "1.4.2" in the "Dev" environment
    * Cancel the runbook run of "Destroy infra" to "Dev"
    * Cancel the runbook "Create infra" to the "Staging" environment for the project "MyProject"
    * Cancel the task "ServerTasks-112747"

            Args:
            space_name: The name of the space
            task_id: The server task
            project_name: The name of the project
            release_version: The release version
            environment_name: The name of the environment
            runbook_name: The name of the runbook
            tenant_name: The name of the tenant
            """

        if logging:
            logging("Enter:", "cancel_task")

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # Fallback incase this is the function chosen by the LLM.
        if confirm_callback_function_name is None:
            confirm_callback_function_name = cancel_task.__name__

        # This is just a passthrough to the original callback
        return callback(confirm_callback_function_name,
                        query,
                        space_name,
                        task_id,
                        project_name,
                        release_version,
                        environment_name,
                        tenant_name,
                        runbook_name)

    return cancel_deployment_to_environment, cancel_runbook_run_for_environment, cancel_task
