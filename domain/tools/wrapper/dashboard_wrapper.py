def show_space_dashboard_wrapper(original_query, api_key, url, callback, logging):
    def show_space_dashboard(space_name=None, **kwargs):
        """Displays or shows the space dashboard. Example prompts include:
        * Show the dashboard
        * Show the dashboard for the space called "My Space"
        * Display the dashboard for the space called "My Space"
        * Show the dashboard for space "My Space"
        * Dashboard for "My Space"

            Args:
                space_name: The space name
        """

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        return callback(original_query, api_key, url, space_name)

    return show_space_dashboard
