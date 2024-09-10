def show_project_dashboard_wrapper(
    original_query, octopus_details, callback, log_query
):
    def show_project_dashboard(space_name=None, project_name=None, **kwargs):
        """Displays or shows the project dashboard. Example prompts include:
        * Show the dashboard for the project "My Project"
        * Display the dashboard for the project "My Project"
        * Show the dashboard for the project "My Project" in the space called "My Space"
        * Project dashboard for "My Project" in "My Space
        * Project dashboard for "My Project"

            Args:
                space_name: The optional space name
                project_name: The optional project name
        """

        for key, value in kwargs.items():
            if log_query:
                log_query(f"Unexpected Key: {key}", "Value: {value}")

        api_key, url = octopus_details()

        return callback(original_query, api_key, url, space_name, project_name)

    return show_project_dashboard
