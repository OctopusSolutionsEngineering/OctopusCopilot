def create_script_project_wrapper(query, callback, logging):

    def create_script_project(
        space_name=None,
        project_name=None,
        auto_apply=False,
        **kwargs,
    ):
        """
        Creates a Script project in Octopus Deploy, in addition to any supporting resources.

        Example prompts include:
        * Create a Script project in the space "My Space" called "My Project"
        * Create Script project called "My Project" in the space "My Space"
        * Create Script project called "My Project"
        * Create Script project called "My Project". Create an AWS account called "AWS" with access key "AKIAIOSFODNN7EXAMPLE"

        Args:
        space_name: The optional name of the space
        project_name: The name of the project
        auto_apply: Whether to automatically apply the project after creation. Defaults to False.
        """

        if logging:
            logging("Enter:", create_script_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_script_project.__name__, query, space_name, project_name, auto_apply
        )

    return create_script_project
