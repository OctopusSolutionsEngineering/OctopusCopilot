def show_project_dashboard_wrapper(original_query, api_key, url, callback, log_query):
    def show_project_dashboard(space_name=None, project_name=None, channel_name=None, **kwargs):
        """Displays or shows the project dashboard. Example prompts include:
        * Show the dashboard for the project "My Project"
        * Display the dashboard for the project "My Project"
        * Show the dashboard for the project "My Project" in the space called "My Space"
        * Project dashboard for "My Project" in "My Space
        * Project dashboard for "My Project"

            Args:
                space_name: The optional space name
                project_name: The optional project name
                channel_name: The optional channel name
        """

        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, api_key, url, space_name, project_name, channel_name)

    return show_project_dashboard
