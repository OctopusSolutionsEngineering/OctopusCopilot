def create_orchestration_project_wrapper(query, callback, logging):
    def create_orchestration_project(
        space_name=None,
        project_name=None,
        **kwargs,
    ):
        """Creates an orchestration project in Octopus Deploy. Example prompts include:
            * Create an orchestration project in the space "My Space" called "My Project"
            * Create orchestration project called "My Project" in the space "My Space"
            * Create orchestration project called "My Project"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        """

        if logging:
            logging("Enter:", create_orchestration_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_orchestration_project.__name__, query, space_name, project_name
        )

    return create_orchestration_project
