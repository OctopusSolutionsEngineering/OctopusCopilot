def get_dashboard_wrapper(original_query, api_key, url, callback, logging):
    def get_dashboard_tool(space_name=None, **kwargs):
        """Display the dashboard

            Args:
                space_name: The name of the space containing the projects.
                If this value is not defined, the default value will be used.
        """

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, api_key, url, space_name)

    return get_dashboard_tool
