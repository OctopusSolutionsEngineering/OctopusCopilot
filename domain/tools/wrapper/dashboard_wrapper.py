def get_dashboard_wrapper(original_query, api_key, url, callback):
    def get_dashboard_tool(space_name: None):
        """Display the dashboard

            Args:
                space_name: The name of the space containing the projects.
                If this value is not defined, the default value will be used.
        """

        return callback(original_query, api_key, url, space_name)

    return get_dashboard_tool
