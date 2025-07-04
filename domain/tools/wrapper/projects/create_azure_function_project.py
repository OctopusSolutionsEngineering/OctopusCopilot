def create_azure_function_project_wrapper(query, callback, logging):

    def create_azure_function_project(
        space_name=None,
        project_name=None,
        no_prompt=False,
        **kwargs,
    ):
        """
        Creates an Azure Function project in Octopus Deploy, in addition to any supporting resources.

        Example prompts include:
        * Create an Azure Function project in the space "My Space" called "My Project"
        * Create an Azure Function project called "My Project" in the space "My Space"
        * Create an Azure Function project called "My Project"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        no_prompt: Weather to disable the prompt. Defaults to False.
        """

        if logging:
            logging("Enter:", create_azure_function_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_azure_function_project.__name__,
            query,
            space_name,
            project_name,
            no_prompt,
        )

    return create_azure_function_project
