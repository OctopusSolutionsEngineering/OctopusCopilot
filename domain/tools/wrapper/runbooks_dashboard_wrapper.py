def get_runbook_dashboard_wrapper(original_query, api_key, url, callback, log_query):
    def get_runbook_dashboard_tool(space_name=None, project_name=None, runbook_name=None, **kwargs):
        """Display the runbook dashboard. Example prompts include:
        * Show the dashboard for the runbook "My Runbook" in project "My Project"
        * Show the dashboard for the runbook "My Runbook" in the project "My Project" in the space called "My Space"
        * Runbook dashboard for runbook "My Runbook" in "My Project" in "My Space
        * Runbook dashboard for "My Runbook"

            Args:
                space_name: The name of the space containing the projects.
                project_name: The name of the project containing the runbook.
                runbook_name: The name of the runbook.
        """

        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, api_key, url, space_name, project_name, runbook_name)

    return get_runbook_dashboard_tool
