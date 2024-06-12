def get_project_dashboard_wrapper(original_query, api_key, url, callback):
    def get_project_dashboard_tool(space_name: None, project_name: None):
        """Display the project dashboard

            Args:
                space_name: The optional space name
                project_name: The optional project name
        """

        return callback(original_query, api_key, url, space_name, project_name)

    return get_project_dashboard_tool
