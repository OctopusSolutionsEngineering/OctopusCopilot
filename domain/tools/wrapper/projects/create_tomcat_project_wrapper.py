def create_tomcat_project_wrapper(query, callback, logging):
    def create_tomcat_project(
        space_name=None,
        project_name=None,
        no_prompt=False,
        **kwargs,
    ):
        """
        Creates an Apache Tomcat project deploying a Java WAR file.

        Example prompts include:
        * Create a Tomcat project in the space "My Space" called "My Project"
        * Create an Apache Tomcat deploying a war file called "My Project" in the space "My Space"
        * Create a tomcat project called "My Project"

        Args:
        space_name: The name of the space
        project_name: The name of the project
        no_prompt: Whether to disable the prompt. Defaults to False.
        """

        if logging:
            logging("Enter:", create_tomcat_project_wrapper.__name__)

        for key, value in kwargs.items():
            if logging:
                logging(f"Unexpected Key: {key}", "Value: {value}")

        # This is just a passthrough to the original callback
        return callback(
            create_tomcat_project_wrapper.__name__,
            query,
            space_name,
            project_name,
            no_prompt,
        )

    return create_tomcat_project
