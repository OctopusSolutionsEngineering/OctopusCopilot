def create_terraform_project_wrapper(query, callback, logging):
    def create_script_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """
        Creates a Script project in Octopus Deploy

        Example prompts include:
        * Create a Script project in the space "My Space" called "My Project"
        * Create Script project called "My Project" in the space "My Space"
        * Create Script project called "My Project"
        * Create Script project called "My Project". Create an AWS account called "AWS" with access key "AKIAIOSFODNN7EXAMPLE"

        Args:
        space_name: The optional name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_script_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_script_project.__name__, query, space_name, project_name
        )

    return create_script_project
