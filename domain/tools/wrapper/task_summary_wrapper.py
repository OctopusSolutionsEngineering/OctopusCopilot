def show_task_summary_wrapper(original_query, callback, log_query):
    def show_task_summary(space_name=None, project_name=None, environment_name=None, tenant_name=None,
                          release_version=None, **kwargs):
        """Displays or shows the deployment task summary. Example prompts include:
        * Show the summary for the deployment of project "My Project" to environment "Production"
        * Display the task summary for the deployment of project "My Project" to environment "Production" with tenant "Contoso"
        * Print task summary for the deployment of project "My Project" to environment "Production" for release "1.4.6

        Args:
            space_name: The optional space name
            project_name: The optional project name
            environment_name: The optional environment name
            tenant_name: The optional tenant name
            release_version: The optional release version
        """

        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, space_name, project_name, environment_name, tenant_name,
                        release_version)

    return show_task_summary
