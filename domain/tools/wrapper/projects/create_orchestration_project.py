def create_orchestration_project_wrapper(query, callback, logging):

    def create_orchestration_project(
        space_name=None,
        project_name=None,
        no_prompt=False,
        **kwargs,
    ):
        """Creates an orchestration or orchestrator project in Octopus Deploy. Example prompts include:
            * Create an orchestration project in the space "My Space" called "My Project"
            * Create an orchestrator project in the space "My Space" called "My Project"
            * Create orchestration project called "My Project" in the space "My Space"
            * Create orchestrator project called "My Project" in the space "My Space"
            * Create orchestration project called "My Project"
            * Create orchestrator project called "My Project"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        no_prompt: Weather to disable the prompt. Defaults to False.
        """

        if logging:
            logging("Enter:", create_orchestration_project.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_orchestration_project.__name__,
            query,
            space_name,
            project_name,
            no_prompt,
        )

    return create_orchestration_project
