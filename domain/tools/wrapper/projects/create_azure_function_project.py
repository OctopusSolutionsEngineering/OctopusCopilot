def create_azure_function_project_wrapper(query, callback, logging):
    def create_azure_function_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """Creates an Azure Function project in Octopus Deploy. Example prompts include:
            * Create an Azure Function project in the space "My Space" called "My Project"
            * Create an Azure Function project called "My Project" in the space "My Space"
            * Create an Azure Function project called "My Project"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_azure_function_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_azure_function_project.__name__, query, space_name, project_name
        )

    return create_azure_function_project
